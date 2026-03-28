import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:markdown/markdown.dart' as md;
import 'package:readability/readability.dart' as readability;
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

import '../models/article.dart';
import '../providers/app_state.dart';
import '../services/database_service.dart';
import '../theme/theme.dart';

class ReaderScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;

  const ReaderScreen(
      {super.key, required this.articles, required this.initialIndex});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showWebView = false;
  bool _loadingReader = false;
  final Map<String, String> _readerCache = {};
  final Set<String> _prefetchInFlight = {};
  final DatabaseService _db = DatabaseService();
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  double _progress = 0.0;
  final bool _startingAudio = false;
  int _currentParagraphIndex = 0;
  int _offsetBase = 0;
  bool _pendingAutoPlay = false;
  String _markdownContent = '';
  String _plainText = '';
  List<String> _paragraphs = [];
  List<String> _displayParagraphs = [];
  List<int> _paragraphOffsets = [];
  final Map<int, ScrollController> _scrollControllers = {};
  final Map<int, bool> _headerCollapsedByArticle = {};
  final Map<int, double> _scrollProgressByArticle = {};
  final Map<int, double> _audioProgressByArticle = {};
  double? _lastAppliedTtsRate;
  String? _lastAppliedVoice;
  String _currentWord = '';
  Timer? _autoScrollResumeTimer;
  bool _autoScrollSuspendedForUser = false;

  static const Duration _autoScrollResumeDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _attachTtsHandlers();

    // Preload TTS engine to remove first-play lag
    _tts.setSpeechRate(AppState.speechRateBase);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lowDataMode = context.read<AppState>().lowDataMode;
      _prefetchReader(widget.articles[_currentIndex], showLoader: true);
      _updateTextForArticle(widget.articles[_currentIndex], _currentIndex);
      _prefetchUpcomingArticles(lowDataMode ? 4 : 2);
    });
  }

  @override
  void dispose() {
    _autoScrollResumeTimer?.cancel();
    _tts.stop();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _toggleStarred(Article article, {required bool starred}) async {
    final appState = context.read<AppState>();
    await appState.markArticleStarred(article.guid, starred: starred);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(starred ? 'Saved for later' : 'Removed from saved'),
      ),
    );
  }

  Future<void> _markRead(Article article) async {
    final appState = context.read<AppState>();
    final existing = appState.getArticleState(article.guid);
    if (existing?.readAt != null) return;
    await appState.markArticleRead(article.guid, read: true);
  }

  double _currentArticleCombinedProgress() {
    final scroll = _scrollProgressByArticle[_currentIndex] ?? 0.0;
    final audio = _audioProgressByArticle[_currentIndex] ?? 0.0;
    return scroll > audio ? scroll : audio;
  }

  void _syncProgressUiForCurrentArticle() {
    final combined = _currentArticleCombinedProgress().clamp(0.0, 1.0);
    if ((_progress - combined).abs() < 0.001) return;
    setState(() {
      _progress = combined;
    });
  }

  Future<void> _checkAndAutoMarkRead(int articleIndex) async {
    if (articleIndex != _currentIndex) return;
    final appState = context.read<AppState>();
    if (!appState.autoMarkReadEnabled) return;

    final progress = _currentArticleCombinedProgress();
    final threshold = appState.autoMarkReadThreshold / 100.0;
    if (progress < threshold) return;

    await _markRead(widget.articles[articleIndex]);
  }

  void _recordScrollProgress(int articleIndex, ScrollController controller) {
    if (!controller.hasClients) return;
    final max = controller.position.maxScrollExtent;
    if (max <= 0) return;
    final pct = (controller.offset / max).clamp(0.0, 1.0);
    final previous = _scrollProgressByArticle[articleIndex] ?? 0.0;
    if (pct > previous) {
      _scrollProgressByArticle[articleIndex] = pct;
      if (articleIndex == _currentIndex && !_isPlaying) {
        _syncProgressUiForCurrentArticle();
      }
      _checkAndAutoMarkRead(articleIndex);
    }
  }

  void _recordAudioProgress(double pct) {
    final clamped = pct.clamp(0.0, 1.0);
    final previous = _audioProgressByArticle[_currentIndex] ?? 0.0;
    if (clamped > previous) {
      _audioProgressByArticle[_currentIndex] = clamped;
    }
    _checkAndAutoMarkRead(_currentIndex);
  }

  void _attachTtsHandlers() {
    _tts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    });
    _tts.setProgressHandler((String text, int start, int end, String? word) {
      if (_plainText.isEmpty) return;
      final absolute = (_offsetBase + start).clamp(0, _plainText.length);
      final pct = absolute / _plainText.length;
      final paragraphIdx =
          _paragraphOffsets.lastIndexWhere((element) => element <= absolute);
      setState(() {
        if (paragraphIdx >= 0) {
          _currentParagraphIndex = paragraphIdx;
        }
        _progress = pct;
        _currentWord = _resolveCurrentWord(text, start, end, word);
      });
      _recordAudioProgress(pct);
      _scrollToProgress(pct);
    });
    _tts.setCompletionHandler(() async {
      final next = _currentParagraphIndex + 1;

      if (next < _paragraphs.length) {
        await _playParagraph(next);
        return;
      }

      setState(() {
        _isPlaying = false;
        _progress = 1.0;
        _currentWord = '';
      });
      _recordAudioProgress(1.0);

      final appState = context.read<AppState>();
      final hasNext = _currentIndex < widget.articles.length - 1;

      if (hasNext && appState.autoPlayNext) {
        _goToArticle(_currentIndex + 1, autoplay: true);
      }
    });
    _tts.setCancelHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentWord = '';
      });
    });
    _tts.setPauseHandler(() {
      setState(() {
        _isPaused = true;
      });
    });
    _tts.setContinueHandler(() {
      setState(() {
        _isPaused = false;
        _isPlaying = true;
      });
    });
  }

  Future<void> _applyVoiceSettings(AppState appState) async {
    final targetRate = appState.speechRateTts;
    if (_lastAppliedTtsRate != targetRate) {
      _lastAppliedTtsRate = targetRate;
      await _tts.setSpeechRate(targetRate);
    }
    if (_lastAppliedVoice != appState.voiceId) {
      _lastAppliedVoice = appState.voiceId;
      if (appState.voiceId != null) {
        final parts = appState.voiceId!.split('|');
        final name = parts.isNotEmpty ? parts[0] : null;
        final locale = parts.length > 1 ? parts[1] : null;
        await _tts.setVoice({
          if (name != null) 'name': name,
          if (locale != null) 'locale': locale,
        });
      } else {
        // Best-effort reset to platform default by sending an empty voice map.
        try {
          await _tts.setVoice({'name': '', 'locale': ''});
        } catch (_) {
          // ignore on platforms that don't support resetting voice
        }
      }
    }
  }

  void _updateTextForArticle(Article article, int articleIndex) {
    final html = _bodyHtml(article);
    final markdown = _htmlToMarkdown(html);
    final safeMarkdown = markdown.trim();
    final markdownParagraphs = _splitMarkdownIntoParagraphs(markdown);

    final ttsParagraphs = <String>[];

    for (final para in markdownParagraphs) {
      final sanitized = _sanitizeForTts(para);
      if (sanitized.isEmpty || _isMostlySymbols(sanitized)) continue;
      ttsParagraphs.add(sanitized);
    }

    // As a fallback for feeds with no clear paragraph breaks, use readability text content.
    if (ttsParagraphs.isEmpty) {
      final textParagraphs = _extractParagraphsFromHtml(html);
      for (final para in textParagraphs) {
        final sanitized = _sanitizeForTts(para);
        if (sanitized.isEmpty || _isMostlySymbols(sanitized)) continue;
        ttsParagraphs.add(sanitized);
      }
    }

    // Still nothing usable.
    if (ttsParagraphs.isEmpty) {
      setState(() {
        _markdownContent = safeMarkdown;
        _paragraphs = [];
        _displayParagraphs = [];
        _paragraphOffsets = [];
        _plainText = '';
        _headerCollapsedByArticle[articleIndex] = false;
        _progress = 0;
        _currentParagraphIndex = 0;
        _currentWord = '';
        _offsetBase = 0;
      });
      return;
    }

    var offset = 0;
    final offsets = <int>[];
    final displayParagraphs = <String>[];
    for (final para in markdownParagraphs) {
      final sanitized = _sanitizeForTts(para);
      if (sanitized.isEmpty || _isMostlySymbols(sanitized)) continue;
      displayParagraphs.add(para.trim());
    }
    for (final p in ttsParagraphs) {
      offsets.add(offset);
      offset += p.length + 2; // include the paragraph break
    }
    setState(() {
      _markdownContent = safeMarkdown;
      _paragraphs = ttsParagraphs;
      _displayParagraphs = displayParagraphs;
      _paragraphOffsets = offsets;
      _plainText = ttsParagraphs.join('\n\n');
      _headerCollapsedByArticle[articleIndex] = false;
      _progress = 0;
      _currentParagraphIndex = 0;
      _currentWord = '';
      _offsetBase = 0;
    });
  }

  List<String> _splitMarkdownIntoParagraphs(String markdown) {
    final lines = markdown.split('\n');
    final buffer = StringBuffer();
    final paragraphs = <String>[];

    void flush() {
      if (buffer.length == 0) return;
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        paragraphs.add(text);
      }
      buffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final isBlank = line.trim().isEmpty;

      if (isBlank) {
        flush();
        continue;
      }

      buffer.writeln(line);
    }

    flush();
    return paragraphs;
  }

  List<String> _extractParagraphsFromHtml(String html) {
    final doc = html_parser.parse(html);
    // Drop common noise containers before collecting text.
    const junkSelectors =
        'script,style,noscript,template,svg,nav,footer,header';
    for (final node in doc.querySelectorAll(junkSelectors)) {
      node.remove();
    }

    final paragraphs = <String>[];

    bool isBlockLike(dom.Element el) {
      const blockTags = {
        'p',
        'li',
        'blockquote',
        'pre',
        'code',
        'article',
        'section',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6'
      };
      return blockTags.contains(el.localName);
    }

    void collect(dom.Node node) {
      if (node is dom.Element && isBlockLike(node)) {
        final text = node.text.trim();
        if (text.isNotEmpty) {
          paragraphs.add(text);
        }
        return;
      }
      for (final child in node.nodes) {
        collect(child);
      }
    }

    if (doc.body != null) {
      collect(doc.body!);
    } else {
      collect(doc.documentElement ?? doc);
    }

    return paragraphs;
  }

  void _handleScroll(ScrollController controller, int articleIndex) {
    if (articleIndex != _currentIndex) return;
    const collapseAt = 140.0;
    const expandAt = 80.0;
    final collapsed = _headerCollapsedByArticle[articleIndex] ?? false;
    if (!controller.hasClients) return;
    final offset = controller.offset;

    if (!collapsed && offset > collapseAt) {
      setState(() => _headerCollapsedByArticle[articleIndex] = true);
    } else if (collapsed && offset < expandAt) {
      setState(() => _headerCollapsedByArticle[articleIndex] = false);
    }
    _recordScrollProgress(articleIndex, controller);
  }

  String _sanitizeForTts(String input) {
    var text = input;
    // Strip markdown links, keep link text.
    text = text.replaceAllMapped(
      RegExp(r'\[(.*?)\]\((https?:\/\/[^\)]+)\)'),
      (match) => match[1] ?? '',
    );
    // Remove bare URLs.
    text = text.replaceAll(RegExp(r'https?:\/\/\S+'), '');
    // Drop common markdown emphasis markers that can surface as spoken symbols.
    text = text.replaceAllMapped(
        RegExp(r'(^|\s)[*_]{1,3}(?=\w)'), (m) => m[1] ?? ''); // leading * or _
    text = text.replaceAllMapped(
        RegExp(r'(\w)[*_]{1,3}(?=\s|$)'), (m) => m[1] ?? ''); // trailing * or _
    // Remove decorative markdown lines (----, ****, ===).
    text = text.replaceAll(RegExp(r'^[*_`~\-=]{3,}\s*', multiLine: true), ' ');
    // Replace standalone bullet symbols.
    text = text.replaceAll(RegExp(r'(^|\s)[•·◦▷▶►∘▫▪❖➤➔]+(\s|$)'), ' ');
    // Collapse long runs of punctuation so the TTS doesn't read each mark individually.
    text = text.replaceAll(RegExp(r'([!?,.;:]){2,}'), r'$1');
    // Remove tiny standalone symbol tokens (e.g., lone emojis or ASCII art fragments).
    text = text.replaceAll(RegExp(r'(^|\s)[^\w\s]{1,3}(?=\s|$)'), ' ');
    // Collapse extra whitespace.
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  bool _isMostlySymbols(String paragraph) {
    // Count non-whitespace characters
    final nonWhitespace = paragraph.replaceAll(RegExp(r'\s'), '');
    if (nonWhitespace.isEmpty) return false;

    final alphaNumCount =
        RegExp(r'[a-zA-Z0-9]').allMatches(nonWhitespace).length;
    // Count symbol characters (non-alphanumeric, non-basic punctuation)
    final symbolCount = nonWhitespace
        .replaceAll(RegExp(r'[a-zA-Z0-9.,!?;:()"\-\[\]]'), '')
        .length;

    // Treat as noise if mostly symbols, or if almost no alphanumeric characters exist.
    if (alphaNumCount <= 2 && symbolCount > 0) return true;
    return symbolCount / nonWhitespace.length > 0.6;
  }

  Future<void> _startPlayback({int paragraphIndex = 0}) async {
    if (_paragraphs.isEmpty) return;

    final appState = context.read<AppState>();

    await _applyVoiceSettings(appState);

    // Set before TTS events fire so progress/highlight map to the tapped paragraph.
    _offsetBase = paragraphIndex < _paragraphOffsets.length
        ? _paragraphOffsets[paragraphIndex]
        : 0;

    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _currentParagraphIndex = paragraphIndex;
      _progress = _plainText.isNotEmpty
          ? (_offsetBase / _plainText.length).clamp(0.0, 1.0)
          : 0.0;
    });
    _recordAudioProgress(_progress);

    await _playParagraph(paragraphIndex);
  }

  Future<void> _playParagraph(int index) async {
    if (index >= _paragraphs.length) {
      setState(() {
        _isPlaying = false;
        _progress = 1;
      });
      return;
    }

    final text = _paragraphs[index];

    // Track absolute offset so progress callbacks stay aligned after jumps.
    _offsetBase =
        index < _paragraphOffsets.length ? _paragraphOffsets[index] : 0;

    await _tts.stop();
    await _tts.speak(text);

    setState(() {
      _currentParagraphIndex = index;
      _progress = _plainText.isNotEmpty
          ? (_offsetBase / _plainText.length).clamp(0.0, 1.0)
          : 0.0;
      _currentWord = '';
    });
    _recordAudioProgress(_progress);
  }

  Future<void> _pausePlayback() async {
    await _tts.pause();
  }

  Future<void> _resumePlayback() async {
    // Resume by restarting from the current paragraph (platforms lack resume()).
    await _startPlayback(paragraphIndex: _currentParagraphIndex);
  }

  Future<void> _stopPlayback() async {
    await _tts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _progress = _currentArticleCombinedProgress();
    });
  }

  void _seekToProgress(double value) {
    if (_plainText.isEmpty) return;
    final targetOffset = (value * _plainText.length).round();
    final paragraphIdx = _paragraphOffsets.lastIndexWhere(
        (offset) => offset <= targetOffset && offset + 1 < _plainText.length);
    final idx = paragraphIdx < 0 ? 0 : paragraphIdx;
    _startPlayback(paragraphIndex: idx);
  }

  void _prefetchUpcomingArticles(int count) {
    for (int i = 1; i <= count; i++) {
      final nextIndex = _currentIndex + i;
      if (nextIndex < widget.articles.length) {
        _prefetchReader(widget.articles[nextIndex]);
      }
    }
  }

  void _goToArticle(int index, {bool autoplay = false}) {
    if (index < 0 || index >= widget.articles.length) return;
    _autoScrollResumeTimer?.cancel();
    _autoScrollSuspendedForUser = false;
    _pendingAutoPlay = autoplay;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToProgress(double progress) {
    if (_autoScrollSuspendedForUser) return;
    final controller = _scrollControllers[_currentIndex];
    if (controller == null || !controller.hasClients) return;
    final max = controller.position.maxScrollExtent;
    if (max <= 0) return;
    final target = (max * progress).clamp(0.0, max);
    if ((controller.offset - target).abs() < 24) return;
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _pauseAutoScrollForUser() {
    _autoScrollResumeTimer?.cancel();
    if (!_autoScrollSuspendedForUser && mounted) {
      setState(() {
        _autoScrollSuspendedForUser = true;
      });
    } else {
      _autoScrollSuspendedForUser = true;
    }
  }

  void _scheduleAutoScrollResume() {
    _autoScrollResumeTimer?.cancel();
    _autoScrollResumeTimer = Timer(_autoScrollResumeDelay, () {
      if (!mounted) return;
      setState(() {
        _autoScrollSuspendedForUser = false;
      });
      if (_isPlaying) {
        _scrollToProgress(_progress);
      }
    });
  }

  bool _handleReaderScrollNotification(
    ScrollNotification notification,
    int articleIndex,
  ) {
    if (articleIndex != _currentIndex) return false;

    final userDriven =
        (notification is ScrollStartNotification &&
                notification.dragDetails != null) ||
            (notification is ScrollUpdateNotification &&
                notification.dragDetails != null) ||
            (notification is OverscrollNotification &&
                notification.dragDetails != null);

    if (userDriven) {
      _pauseAutoScrollForUser();
      _scheduleAutoScrollResume();
      return false;
    }

    if (notification is ScrollEndNotification && _autoScrollSuspendedForUser) {
      _scheduleAutoScrollResume();
    }

    return false;
  }

  String _normalizeSpokenWord(String raw) {
    return raw.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '').trim();
  }

  String _resolveCurrentWord(
      String ttsText, int start, int end, String? reportedWord) {
    final fromReported = _normalizeSpokenWord(reportedWord ?? '');
    if (fromReported.isNotEmpty) return fromReported;

    if (start >= 0 && end > start && end <= ttsText.length) {
      final fromRange = _normalizeSpokenWord(ttsText.substring(start, end));
      if (fromRange.isNotEmpty) return fromRange;
    }

    if (_plainText.isEmpty) return '';
    final idx = (_offsetBase + start).clamp(0, _plainText.length);
    int left = idx;
    while (left > 0 && RegExp(r'[\w]').hasMatch(_plainText[left - 1])) {
      left -= 1;
    }
    int right = idx;
    while (right < _plainText.length &&
        RegExp(r'[\w]').hasMatch(_plainText[right])) {
      right += 1;
    }
    if (right > left) {
      return _normalizeSpokenWord(_plainText.substring(left, right));
    }
    return '';
  }

  String _highlightCurrentWordInParagraph(String markdown) {
    if (!_isPlaying || _currentWord.isEmpty || markdown.isEmpty) {
      return markdown;
    }
    final pattern = RegExp(
      '(?<!\\w)${RegExp.escape(_currentWord)}(?!\\w)',
      caseSensitive: false,
    );
    final matches = pattern.allMatches(markdown).toList();
    if (matches.isEmpty) return markdown;
    final m = matches.first;
    final token = markdown.substring(m.start, m.end);
    return '${markdown.substring(0, m.start)}==$token==${markdown.substring(m.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const baseBottomBarHeight = 132.0;
    final readerBottomPadding = baseBottomBarHeight + bottomSafe + 12;
    final markdownStyleSheet =
        MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
    );
    markdownStyleSheet.styles['tts'] = markdownStyleSheet.p?.copyWith(
      backgroundColor: Colors.yellowAccent.withOpacity(0.65),
      fontWeight: FontWeight.w600,
    );
    final appState = context.watch<AppState>();
    final article = widget.articles[_currentIndex];
    final state = appState.getArticleState(article.guid);
    final isStarred = state?.starredAt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title ?? 'Article'),
        actions: [
          IconButton(
            icon: Icon(isStarred ? Icons.star : Icons.star_border),
            onPressed: () => _toggleStarred(article, starred: !isStarred),
          ),
          IconButton(
            icon: Icon(_showWebView ? Icons.article : Icons.open_in_new),
            onPressed: article.url != null
                ? () {
                    setState(() {
                      _showWebView = !_showWebView;
                    });
                    if (!_showWebView) {
                      _prefetchReader(article);
                    }
                  }
                : null,
            tooltip: _showWebView ? 'Show reader' : 'Show web view',
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.articles.length,
            physics:
                const NeverScrollableScrollPhysics(), // Disable horizontal scrolling
            onPageChanged: (index) {
              _tts.stop();
              setState(() {
                _currentIndex = index;
                _isPlaying = false;
                _isPaused = false;
                _progress = _currentArticleCombinedProgress();
              });
              _prefetchReader(widget.articles[index], showLoader: true);
              _updateTextForArticle(widget.articles[index], index);
              if (_pendingAutoPlay) {
                _pendingAutoPlay = false;
                _startPlayback(paragraphIndex: 0);
              } else {
                final lowDataMode = context.read<AppState>().lowDataMode;
                _prefetchUpcomingArticles(lowDataMode ? 3 : 1);
              }
            },
            itemBuilder: (context, index) {
              final item = widget.articles[index];
              final headerCollapsed = _headerCollapsedByArticle[index] ?? false;

              if (_loadingReader && !_showWebView) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_showWebView &&
                  item.url != null &&
                  (Platform.isAndroid || Platform.isIOS)) {
                final controller = webview.WebViewController()
                  ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
                  ..loadRequest(Uri.parse(item.url!));

                return SafeArea(
                  child: webview.WebViewWidget(
                    controller: controller,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer()),
                    },
                  ),
                );
              }

              if (_showWebView && item.url != null) {
                // Platform does not support embedded WebView in this build (e.g., Windows).
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s24),
                    child: Text(
                      'In-app WebView is only supported on Android/iOS.\nShowing text view instead.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Builder(builder: (context) {
                  final scrollController = _scrollControllers.putIfAbsent(
                    index,
                    () {
                      final c = ScrollController();
                      c.addListener(() => _handleScroll(c, index));
                      return c;
                    },
                  );
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) =>
                        _handleReaderScrollNotification(notification, index),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(bottom: readerBottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: headerCollapsed
                                ? const SizedBox.shrink()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (item.imageUrl != null &&
                                          item.imageUrl!.isNotEmpty) ...[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: SizedBox(
                                            height: 180,
                                            width: double.infinity,
                                            child: Image.network(
                                              item.imageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.s12),
                                      ],
                                      Text(
                                        item.title ?? 'Untitled',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                      const SizedBox(height: AppSpacing.s8),
                                      if (item.author != null) ...[
                                        Text('By ${item.author!}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                        const SizedBox(height: AppSpacing.s8),
                                      ],
                                      const SizedBox(height: AppSpacing.s16),
                                    ],
                                  ),
                          ),
                          ..._buildReaderParagraphs(
                            item,
                            markdownStyleSheet,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _UnreadBadge(articles: widget.articles),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _currentIndex > 0
                        ? () => _goToArticle(_currentIndex - 1)
                        : null,
                    tooltip: 'Previous article',
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: _currentIndex < widget.articles.length - 1
                        ? () => _goToArticle(_currentIndex + 1)
                        : null,
                    tooltip: 'Next article',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAudioControls(article),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReaderParagraphs(
    Article article,
    MarkdownStyleSheet markdownStyleSheet,
  ) {
    final fallbackMarkdown = _markdownContent.isNotEmpty
        ? _markdownContent
        : _htmlToMarkdown(_bodyHtml(article));

    if (_displayParagraphs.isEmpty) {
      return [
        MarkdownBody(
          data: fallbackMarkdown,
          onTapLink: (_, href, __) => _handleMarkdownLink(href),
          inlineSyntaxes: [_TtsInlineSyntax()],
          styleSheet: markdownStyleSheet,
        ),
      ];
    }

    return List<Widget>.generate(_displayParagraphs.length, (index) {
      final isActive = (_isPlaying || _isPaused) && index == _currentParagraphIndex;
      final paragraph = isActive
          ? _highlightCurrentWordInParagraph(_displayParagraphs[index])
          : _displayParagraphs[index];
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.yellowAccent.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: MarkdownBody(
          data: paragraph,
          onTapLink: (_, href, __) => _handleMarkdownLink(href),
          inlineSyntaxes: [_TtsInlineSyntax()],
          styleSheet: markdownStyleSheet,
        ),
      );
    });
  }

  String _htmlToMarkdown(String html) {
    final trimmed = html.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final doc = html_parser.parse(trimmed);
    // Remove scripts/styles/trackers that end up as junk paragraphs.
    const junkSelectors =
        'script,style,noscript,template,svg,nav,footer,header';
    for (final node in doc.querySelectorAll(junkSelectors)) {
      node.remove();
    }
    final cleaned = doc.body?.innerHtml ?? trimmed;
    return html2md.convert(cleaned);
  }

  String _bodyHtml(Article article) {
    final cached = _readerCache[article.guid];
    if (cached != null) return cached;
    // Prefer full content, then summary, then rawData; default empty.
    return article.content ?? article.summary ?? article.rawData ?? '';
  }

  Future<void> _prefetchReader(
    Article article, {
    bool showLoader = false,
  }) async {
    final url = article.url;
    if (url == null || url.isEmpty) return;
    if (_readerCache.containsKey(article.guid)) return;
    if (_prefetchInFlight.contains(article.guid)) return;
    _prefetchInFlight.add(article.guid);

    if (showLoader && mounted) {
      setState(() {
        _loadingReader = true;
      });
    }

    try {
      final cached = await _db.getPrefetchedArticleContent(article.guid);
      if (cached != null && cached.trim().isNotEmpty) {
        _readerCache[article.guid] = cached;
        if (mounted && article.guid == widget.articles[_currentIndex].guid) {
          _updateTextForArticle(article, widget.articles.indexOf(article));
        }
        return;
      }

      final parsed = await readability.parseAsync(url);
      final content = (parsed.content ?? parsed.textContent ?? '').trim();
      if (content.isNotEmpty) {
        _readerCache[article.guid] = content;
        await _db.upsertPrefetchedArticleContent(article.guid, content);
        if (mounted && article.guid == widget.articles[_currentIndex].guid) {
          _updateTextForArticle(article, widget.articles.indexOf(article));
        }
      }
    } finally {
      _prefetchInFlight.remove(article.guid);
      if (showLoader && mounted) {
        setState(() {
          _loadingReader = false;
        });
      }
    }
  }

  Future<void> _handleMarkdownLink(String? href) async {
    if (href == null || href.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(href);
    if (uri == null) {
      return;
    }
    if (!await canLaunchUrl(uri)) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildAudioControls(Article article) {
    final canPlay = _paragraphs.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  if (_startingAudio)
                    const SizedBox(
                      width: 38,
                      height: 38,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  Icon(
                    _isPlaying && !_isPaused
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 32,
                  ),
                ],
              ),
              onPressed: canPlay && !_startingAudio
                  ? () {
                      if (_isPlaying && !_isPaused) {
                        _pausePlayback();
                      } else if (_isPaused) {
                        _resumePlayback();
                      } else {
                        _startPlayback(paragraphIndex: _currentParagraphIndex);
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.stop_circle, size: 28),
              onPressed: (_isPlaying || _isPaused) && !_startingAudio
                  ? _stopPlayback
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: _progress.clamp(0.0, 1.0),
                onChanged:
                    canPlay ? (v) => setState(() => _progress = v) : null,
                onChangeEnd: canPlay ? _seekToProgress : null,
              ),
            ),
            const SizedBox(width: 8),
            Text('${((_progress) * 100).floor()}%'),
          ],
        ),
        if (canPlay)
          Text(
            'Playing section ${_currentParagraphIndex + 1}/${_paragraphs.length}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          )
        else
          const Text('Read-aloud not available for this article.'),
      ],
    );
  }
}

class _TtsInlineSyntax extends md.InlineSyntax {
  _TtsInlineSyntax() : super(r'==([^=\n]+)==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final value = match[1] ?? '';
    parser.addNode(md.Element.text('tts', value));
    return true;
  }
}

class _UnreadBadge extends StatelessWidget {
  final List<Article> articles;
  const _UnreadBadge({required this.articles});

  @override
  Widget build(BuildContext context) {
    final unread = articles
        .where((a) =>
            context.watch<AppState>().getArticleState(a.guid)?.readAt == null)
        .length;
    return Chip(
      label: Text('Unread: $unread'),
    );
  }
}
