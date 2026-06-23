import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:markdown/markdown.dart' as md;
import 'package:readability/readability.dart' as readability;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

import '../models/article.dart';
import '../providers/app_state.dart';
import '../services/reader_audio_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../theme/theme.dart';
import '../widgets/ad_banner.dart';
import '../l10n/app_localizations.dart';

class ReaderScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;
  final bool autoPlayMode;

  const ReaderScreen(
      {super.key, required this.articles, required this.initialIndex, this.autoPlayMode = false});

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
  StreamSubscription<ReaderPlaybackSnapshot>? _readerStateSubscription;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isBuffering = false;
  double _progress = 0.0;
  int _currentParagraphIndex = 0;
  String _markdownContent = '';
  String _plainText = '';
  List<String> _paragraphs = [];
  List<String> _displayParagraphs = [];
  List<int> _paragraphOffsets = [];
  final Map<int, ScrollController> _scrollControllers = {};
  final Map<int, webview.WebViewController> _webControllers = {};
  final Map<int, bool> _headerCollapsedByArticle = {};
  final Map<int, double> _scrollProgressByArticle = {};
  final Map<int, double> _audioProgressByArticle = {};
  String _currentWord = '';
  Timer? _autoScrollResumeTimer;
  bool _autoScrollSuspendedForUser = false;
  static const Duration _autoScrollResumeDelay = Duration(seconds: 2);
  Timer? _progressDebounce;
  int _tapCount = 0;
  int _lastTappedParagraph = -1;
  Timer? _tapTimer;
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  bool _hasAutoPlayed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ReaderScreen] initState: articles=${widget.articles.length}, initialIndex=${widget.initialIndex}, autoPlayMode=${widget.autoPlayMode}');
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    readerAudioHandler.configureQueue(
      widget.articles,
      currentIndex: widget.initialIndex,
    );
    _readerStateSubscription = readerAudioHandler.readerState.listen(
      _handleReaderPlaybackSnapshot,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = await StorageService.getInstance();
      final seen = await storage.read('reader_onboarding_seen');
      if (seen != 'true' && mounted) {
        setState(() => _showOnboarding = true);
        await storage.write('reader_onboarding_seen', 'true');
      }
      final lowDataMode = context.read<AppState>().lowDataMode;
      _prefetchReader(widget.articles[_currentIndex], showLoader: true);
      _updateTextForArticle(widget.articles[_currentIndex], _currentIndex);
      _prefetchUpcomingArticles(lowDataMode ? 4 : 2);
    });
  }

  @override
  void dispose() {
    debugPrint('[ReaderScreen] dispose');
    _autoScrollResumeTimer?.cancel();
    _readerStateSubscription?.cancel();
    _progressDebounce?.cancel();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    _webControllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleStarred(Article article, {required bool starred}) async {
    final appState = context.read<AppState>();
    await appState.markArticleStarred(article.guid, starred: starred);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(starred ? AppLocalizations.of(context)!.readerSavedForLater : AppLocalizations.of(context)!.readerRemovedFromSaved),
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

  void _scheduleProgressSave() {
    if (_progress <= 0 || _progress >= 1.0) return;
    final articleIndex = _currentIndex;
    final progress = _progress;
    final paragraphIndex = _currentParagraphIndex;
    
    _progressDebounce?.cancel();
    _progressDebounce = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final appState = context.read<AppState>();
      final article = widget.articles[articleIndex];
      appState.recordArticleProgress(article.guid, progress, paragraphIndex);
    });
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
      if (articleIndex == _currentIndex) {
        _scheduleProgressSave();
      }
    }
  }

  void _recordAudioProgress(double pct) {
    final clamped = pct.clamp(0.0, 1.0);
    final previous = _audioProgressByArticle[_currentIndex] ?? 0.0;
    if (clamped > previous) {
      _audioProgressByArticle[_currentIndex] = clamped;
    }
    _checkAndAutoMarkRead(_currentIndex);
    _scheduleProgressSave();
  }

  void _handleReaderPlaybackSnapshot(ReaderPlaybackSnapshot snapshot) {
    if (!mounted) return;

    debugPrint('[ReaderScreen] snapshot: playing=${snapshot.isPlaying}, paused=${snapshot.isPaused}, buffering=${snapshot.isBuffering}, article=${snapshot.currentArticleIndex}, para=${snapshot.currentParagraphIndex}, progress=${snapshot.progress.toStringAsFixed(3)}, word="${snapshot.currentWord}"');

    final articleChanged = snapshot.currentArticleIndex != _currentIndex;
    if (articleChanged) {
      debugPrint('[ReaderScreen] snapshot: article changed from $_currentIndex to ${snapshot.currentArticleIndex}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _goToArticle(snapshot.currentArticleIndex);
      });
    }

    setState(() {
      _isPlaying = snapshot.isPlaying;
      _isPaused = snapshot.isPaused;
      _isBuffering = snapshot.isBuffering;
      _currentParagraphIndex = snapshot.currentParagraphIndex;
      _progress = snapshot.progress;
      _currentWord = snapshot.currentWord;
    });
    _recordAudioProgress(snapshot.progress);
    if (snapshot.isPlaying && !_showWebView) {
      _scrollToProgress(snapshot.progress);
    }
  }

  void _updateTextForArticle(Article article, int articleIndex) {
    debugPrint('[ReaderScreen] _updateTextForArticle: articleIndex=$articleIndex, guid=${article.guid}');
    final html = _bodyHtml(article);
    final markdown = _htmlToMarkdown(html);
    final safeMarkdown = markdown.trim();
    final markdownParagraphs = _splitMarkdownIntoParagraphs(markdown);

    final displayParagraphs = <String>[];
    final ttsParagraphs = <String>[];

    for (final para in markdownParagraphs) {
      final sanitized = _sanitizeForTts(para);
      final isVideo = para.contains('VIDEO_EMBED_START:');
      if (!isVideo && (sanitized.isEmpty || _isMostlySymbols(sanitized) || _isAdText(sanitized))) continue;
      displayParagraphs.add(para.trim());
      ttsParagraphs.add(sanitized.isEmpty ? ' ' : sanitized);
    }

    // As a fallback for feeds with no clear paragraph breaks, use readability text content.
    if (ttsParagraphs.isEmpty) {
      final textParagraphs = _extractParagraphsFromHtml(html);
      for (final para in textParagraphs) {
        final sanitized = _sanitizeForTts(para);
        final isVideo = para.contains('VIDEO_EMBED_START:');
        if (!isVideo && (sanitized.isEmpty || _isMostlySymbols(sanitized) || _isAdText(sanitized))) continue;
        displayParagraphs.add(para.trim());
        ttsParagraphs.add(sanitized.isEmpty ? ' ' : sanitized);
      }
    }

    // Still nothing usable.
    if (ttsParagraphs.isEmpty) {
      readerAudioHandler.registerArticleContent(
        articleIndex: articleIndex,
        paragraphs: const [],
        paragraphOffsets: const [],
        plainText: '',
      );
      setState(() {
        _markdownContent = safeMarkdown;
        _paragraphs = [];
        _displayParagraphs = [];
        _paragraphOffsets = [];
        _plainText = '';
        _headerCollapsedByArticle[articleIndex] = false;
      });
      return;
    }

    debugPrint('[ReaderScreen] _updateTextForArticle: ttsParagraphs=${ttsParagraphs.length}, displayParagraphs=${displayParagraphs.length}');
    var offset = 0;
    final offsets = <int>[];
    for (final p in ttsParagraphs) {
      offsets.add(offset);
      offset += p.length + 2; // include the paragraph break
    }
    readerAudioHandler.registerArticleContent(
      articleIndex: articleIndex,
      paragraphs: ttsParagraphs,
      paragraphOffsets: offsets,
      plainText: ttsParagraphs.join('\n\n'),
    );
    setState(() {
      _markdownContent = safeMarkdown;
      _paragraphs = ttsParagraphs;
      _displayParagraphs = displayParagraphs;
      _paragraphOffsets = offsets;
      _plainText = ttsParagraphs.join('\n\n');
      _headerCollapsedByArticle[articleIndex] = false;
    });

    if (articleIndex == _currentIndex) {
      final appState = context.read<AppState>();
      final state = appState.getArticleState(article.guid);
      debugPrint('[ReaderScreen] _updateTextForArticle: current article, autoPlayMode=${widget.autoPlayMode}, hasAutoPlayed=$_hasAutoPlayed, state=$state');
      if (state != null) {
        debugPrint('[ReaderScreen] _updateTextForArticle: state readProgress=${state.readProgress}, lastParagraphIndex=${state.lastParagraphIndex}');
        if (!_hasAutoPlayed && widget.autoPlayMode && state.lastParagraphIndex != null) {
          _hasAutoPlayed = true;
          _currentParagraphIndex = state.lastParagraphIndex!;
          debugPrint('[ReaderScreen] _updateTextForArticle: resuming from paragraph $_currentParagraphIndex');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(duration: const Duration(seconds: 2), content: Text(AppLocalizations.of(context)!.resumingLastRead)),
          );
          _startPlayback(paragraphIndex: _currentParagraphIndex);
        } else if (state.readProgress != null && state.readProgress! > 0) {
          debugPrint('[ReaderScreen] _updateTextForArticle: restoring scroll to ${state.readProgress}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _scrollToProgress(state.readProgress!);
            }
          });
        }
      } else if (!_hasAutoPlayed && widget.autoPlayMode) {
        _hasAutoPlayed = true;
        debugPrint('[ReaderScreen] _updateTextForArticle: starting auto playback from beginning');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(duration: const Duration(seconds: 2), content: Text(AppLocalizations.of(context)!.startingPlayback)),
        );
        _startPlayback();
      }
    }
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
    // Remove video embeds from TTS
    text = text.replaceAll(RegExp(r'VIDEO_EMBED_START:.*?VIDEO_EMBED_END'), '');
    // Strip common video unsupported text
    text = text.replaceAll(RegExp(r'this video playback is not supported\.?', caseSensitive: false), ' ');
    text = text.replaceAll(RegExp(r'this video cannot be played\.?', caseSensitive: false), ' ');
    // Strip markdown links and images, keep link/alt text. The optional ! is for images.
    text = text.replaceAllMapped(
      RegExp(r'!?\[(.*?)\]\((https?:\/\/[^\)]+)\)'),
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
    // Remove markdown header symbols.
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    // Remove all remaining markdown/special symbols that are often read aloud annoyingly by TTS.
    text = text.replaceAll(RegExp(r'[*_~`<>{}\[\]\|\\]'), ' ');
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

  bool _isAdText(String paragraph) {
    final lower = paragraph.toLowerCase();
    final adPatterns = [
      'advertisement',
      'advertising',
      'sponsored',
      'paid promotion',
      'promoted by',
      'this content was produced by',
      'brought to you by',
      'presented by',
    ];
    return adPatterns.any((p) => lower.contains(p));
  }

  Future<void> _startPlayback({int paragraphIndex = 0}) async {
    debugPrint('[ReaderScreen] _startPlayback: paragraphIndex=$paragraphIndex, _paragraphs.length=${_paragraphs.length}');
    if (_paragraphs.isEmpty) {
      debugPrint('[ReaderScreen] _startPlayback: no paragraphs available');
      return;
    }

    final appState = context.read<AppState>();
    debugPrint('[ReaderScreen] _startPlayback: speechRate=${appState.speechRateTts}, voiceId=${appState.voiceId}, autoPlayNext=${appState.autoPlayNext}');
    await readerAudioHandler.updateSpeechConfig(
      speechRate: appState.speechRateTts,
      voiceId: appState.voiceId,
      autoPlayNext: appState.autoPlayNext,
    );
    await readerAudioHandler.playFromParagraph(paragraphIndex);
  }

  Future<void> _pausePlayback() async {
    debugPrint('[ReaderScreen] _pausePlayback');
    await readerAudioHandler.pause();
  }

  Future<void> _resumePlayback() async {
    debugPrint('[ReaderScreen] _resumePlayback');
    await readerAudioHandler.play();
  }

  Future<void> _stopPlayback() async {
    await readerAudioHandler.stop();
  }

  void _seekToProgress(double value) {
    debugPrint('[ReaderScreen] _seekToProgress: value=$value, _plainText.length=${_plainText.length}');
    if (_plainText.isEmpty) {
      debugPrint('[ReaderScreen] _seekToProgress: plainText empty');
      return;
    }
    final targetOffset = (value * _plainText.length).round();
    final paragraphIdx = _paragraphOffsets.lastIndexWhere(
        (offset) => offset <= targetOffset && offset + 1 < _plainText.length);
    final idx = paragraphIdx < 0 ? 0 : paragraphIdx;
    debugPrint('[ReaderScreen] _seekToProgress: targetOffset=$targetOffset, paragraphIdx=$paragraphIdx, finalIdx=$idx');
    readerAudioHandler.playFromParagraph(idx);
  }

  void _prefetchUpcomingArticles(int count) {
    for (int i = 1; i <= count; i++) {
      final nextIndex = _currentIndex + i;
      if (nextIndex < widget.articles.length) {
        _prefetchReader(widget.articles[nextIndex]);
      }
    }
  }

  void _goToArticle(int index) {
    debugPrint('[ReaderScreen] _goToArticle: index=$index');
    if (index < 0 || index >= widget.articles.length) {
      debugPrint('[ReaderScreen] _goToArticle: index out of bounds');
      return;
    }
    _autoScrollResumeTimer?.cancel();
    _autoScrollSuspendedForUser = false;
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
        notification is ScrollStartNotification && notification.dragDetails != null;

    if (userDriven) {
      debugPrint('[ReaderScreen] scroll: user scroll started, pausing auto-scroll');
      _pauseAutoScrollForUser();
      _scheduleAutoScrollResume();
      return false;
    }

    if (notification is ScrollEndNotification && _autoScrollSuspendedForUser) {
      _scheduleAutoScrollResume();
    }

    return false;
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'save':
                  await _toggleStarred(article, starred: !isStarred);
                  break;
                case 'webview':
                  setState(() {
                    _showWebView = true;
                  });
                  if (_showWebView) {
                    final c = _webControllers[_currentIndex];
                    if (c == null) {
                      final controller = webview.WebViewController()
                        ..setJavaScriptMode(webview.JavaScriptMode.unrestricted);
                      controller.loadRequest(Uri.parse(article.url!));
                      _webControllers[_currentIndex] = controller;
                    }
                  }
                  break;
                case 'reader':
                  setState(() {
                    _showWebView = false;
                  });
                  _prefetchReader(article);
                  break;
                case 'copylink':
                  if (article.url != null) {
                    await Clipboard.setData(ClipboardData(text: article.url!));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(duration: const Duration(seconds: 2), content: Text(AppLocalizations.of(context)!.linkCopied)),
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(isStarred ? Icons.bookmark : Icons.bookmark_border),
                  title: Text(isStarred ? AppLocalizations.of(context)!.unsave : AppLocalizations.of(context)!.save),
                ),
              ),
              if (article.url != null && !_showWebView)
                PopupMenuItem(
                  value: 'webview',
                  child: ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: Text(AppLocalizations.of(context)!.showWebView),
                  ),
                ),
              if (article.url != null && _showWebView)
                PopupMenuItem(
                  value: 'reader',
                  child: ListTile(
                    leading: const Icon(Icons.article),
                    title: Text(AppLocalizations.of(context)!.showReader),
                  ),
                ),
              if (article.url != null)
                PopupMenuItem(
                  value: 'copylink',
                  child: ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(AppLocalizations.of(context)!.copyLink),
                  ),
                ),
            ],
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
            onPageChanged: (index) async {
              debugPrint('[ReaderScreen] onPageChanged: index=$index');
              final lowDataMode = context.read<AppState>().lowDataMode;
              setState(() {
                _currentIndex = index;
                _progress = _currentArticleCombinedProgress();
              });
              final currentAudioArticle = readerAudioHandler.readerState.value.currentArticleIndex;
              debugPrint('[ReaderScreen] onPageChanged: readerState article=$currentAudioArticle');
              if (currentAudioArticle != index) {
                debugPrint('[ReaderScreen] onPageChanged: activating article $index in audio handler');
                await readerAudioHandler.activateArticle(index);
              }
              if (_showWebView) {
                final url = widget.articles[index].url;
                if (url != null) {
                  final c = _webControllers[index];
                  if (c == null) {
                    final controller = webview.WebViewController()
                      ..setJavaScriptMode(webview.JavaScriptMode.unrestricted);
                    controller.loadRequest(Uri.parse(url));
                    _webControllers[index] = controller;
                  } else {
                    c.loadRequest(Uri.parse(url));
                  }
                }
              } else {
                _prefetchReader(widget.articles[index], showLoader: true);
                _updateTextForArticle(widget.articles[index], index);
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
                final controller = _webControllers.putIfAbsent(index, () {
                  final c = webview.WebViewController()
                    ..setJavaScriptMode(webview.JavaScriptMode.unrestricted);
                  c.loadRequest(Uri.parse(item.url!));
                  return c;
                });

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
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s24),
                    child: Text(
                      AppLocalizations.of(context)!.webviewUnsupported,
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
                                        item.title ?? AppLocalizations.of(context)!.untitled,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                      const SizedBox(height: AppSpacing.s8),
                                      if (item.author != null) ...[
                                        Text(AppLocalizations.of(context)!.byAuthor(item.author!),
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
          if (_showOnboarding) _buildOnboardingOverlay(),
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
              AdBanner(isTtsActive: _isPlaying || _isPaused),
              Row(
                children: [
                  _UnreadBadge(articles: widget.articles),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      state?.readAt != null
                          ? Icons.mark_email_read
                          : Icons.mark_email_unread,
                      color: state?.readAt != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () async {
                      if (state?.readAt == null) {
                        await _markRead(article);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(duration: const Duration(seconds: 2), content: Text(AppLocalizations.of(context)!.markedReadSkipped)),
                        );
                        if (_currentIndex < widget.articles.length - 1) {
                          readerAudioHandler.skipToNext();
                        } else {
                          Navigator.of(context).pop();
                        }
                      } else {
                        await context.read<AppState>().markArticleRead(article.guid, read: false);
                      }
                    },
                    tooltip: state?.readAt != null ? AppLocalizations.of(context)!.markUnread : AppLocalizations.of(context)!.markReadPlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _currentIndex > 0
                        ? readerAudioHandler.skipToPrevious
                        : null,
                    tooltip: AppLocalizations.of(context)!.previousArticle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: _currentIndex < widget.articles.length - 1
                        ? readerAudioHandler.skipToNext
                        : null,
                    tooltip: AppLocalizations.of(context)!.nextArticle,
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

  void _handleParagraphTap(int index) {
    debugPrint('[ReaderScreen] _handleParagraphTap: index=$index, tapCount=$_tapCount, lastTapped=$_lastTappedParagraph');
    if (_lastTappedParagraph != index) {
      _tapCount = 0;
      _lastTappedParagraph = index;
    }
    _tapCount++;
    _tapTimer?.cancel();
    if (_tapCount >= 3) {
      debugPrint('[ReaderScreen] _handleParagraphTap: triple tap, seeking to paragraph $index');
      _tapCount = 0;
      if (_displayParagraphs.isNotEmpty && index < _displayParagraphs.length) {
        readerAudioHandler.playFromParagraph(index);
      }
    } else {
      _tapTimer = Timer(const Duration(milliseconds: 400), () {
        _tapCount = 0;
      });
    }
  }

  Widget _buildOnboardingOverlay() {
    final steps = [
      _OnboardingStepData(
        icon: Icons.touch_app,
        title: 'Tap to Read Aloud',
        desc: 'Tap any paragraph to start audio playback from that point.',
      ),
      _OnboardingStepData(
        icon: Icons.exposure_plus_2,
        title: 'Triple-Tap to Seek',
        desc: 'Triple-tap any paragraph to seek audio to that exact section.',
      ),
      _OnboardingStepData(
        icon: Icons.open_in_new,
        title: 'Switch to Web View',
        desc: 'Tap the icon in the toolbar to view the original article page.',
      ),
      _OnboardingStepData(
        icon: Icons.swipe,
        title: 'Navigate Articles',
        desc: 'Use the skip buttons at the bottom to move between articles.',
      ),
    ];

    final step = _onboardingStep.clamp(0, steps.length - 1);
    final data = steps[step];

    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(color: Colors.black54),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(data.icon, size: 48,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.desc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: List.generate(steps.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == step ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == step
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _showOnboarding = false),
                    child: Text(AppLocalizations.of(context)!.skip),
                  ),
                  Row(
                    children: [
                      if (step > 0)
                        OutlinedButton(
                          onPressed: () => setState(() => _onboardingStep--),
                          child: const Text('Back'),
                        ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (step < steps.length - 1) {
                            setState(() => _onboardingStep++);
                          } else {
                            setState(() => _showOnboarding = false);
                          }
                        },
                        child: Text(
                          step < steps.length - 1
                              ? AppLocalizations.of(context)!.next
                              : AppLocalizations.of(context)!.getStarted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
          inlineSyntaxes: [_VideoInlineSyntax(), _TtsInlineSyntax()],
          builders: {
            'video': _VideoBuilder(),
          },
          styleSheet: markdownStyleSheet,
        ),
      ];
    }

    final activeIndex = _displayParagraphs.isEmpty
        ? 0
        : _currentParagraphIndex.clamp(0, _displayParagraphs.length - 1);

    return List<Widget>.generate(_displayParagraphs.length, (index) {
      final isActive = (_isPlaying || _isPaused) && index == activeIndex;
      final paragraph = isActive
          ? _highlightCurrentWordInParagraph(_displayParagraphs[index])
          : _displayParagraphs[index];
      return GestureDetector(
        onTap: () => _handleParagraphTap(index),
        child: AnimatedContainer(
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
            inlineSyntaxes: [_VideoInlineSyntax(), _TtsInlineSyntax()],
            builders: {
              'video': _VideoBuilder(),
            },
            styleSheet: markdownStyleSheet,
          ),
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
    
    // Replace iframe and video tags with our custom markdown
    for (final node in doc.querySelectorAll('iframe, video')) {
      var src = node.attributes['src'];
      if (src != null && src.isNotEmpty) {
        if (src.startsWith('//')) {
          src = 'https:$src';
        }
        final p = dom.Element.tag('p');
        p.text = 'VIDEO_EMBED_START:${src}VIDEO_EMBED_END';
        node.replaceWith(p);
      }
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
    debugPrint('[ReaderScreen] _prefetchReader: guid=${article.guid}, url=$url, showLoader=$showLoader');
    if (url == null || url.isEmpty) {
      debugPrint('[ReaderScreen] _prefetchReader: no URL');
      return;
    }
    if (_readerCache.containsKey(article.guid)) {
      debugPrint('[ReaderScreen] _prefetchReader: already cached');
      return;
    }
    if (_prefetchInFlight.contains(article.guid)) {
      debugPrint('[ReaderScreen] _prefetchReader: already in flight');
      return;
    }
    _prefetchInFlight.add(article.guid);

    if (showLoader && mounted) {
      setState(() {
        _loadingReader = true;
      });
    }

    try {
      final cached = await _db.getPrefetchedArticleContent(article.guid);
      if (cached != null && cached.trim().isNotEmpty) {
        debugPrint('[ReaderScreen] _prefetchReader: using cached content, length=${cached.length}');
        _readerCache[article.guid] = cached;
        if (mounted && article.guid == widget.articles[_currentIndex].guid) {
          _updateTextForArticle(article, widget.articles.indexOf(article));
        }
        return;
      }

      debugPrint('[ReaderScreen] _prefetchReader: parsing from URL');
      String content = '';
      try {
        final parsed = await readability.parseAsync(url);
        content = (parsed.content ?? parsed.textContent ?? '').trim();
        debugPrint('[ReaderScreen] _prefetchReader: readability content length=${content.length}');
      } catch (e) {
        debugPrint('[ReaderScreen] _prefetchReader: readability parse error: $e');
      }

      // Fetch raw HTML to extract images and videos readability might have missed
      String? rawHtml;
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 15) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        );
        if (response.statusCode == 200) {
          rawHtml = response.body;
        }
      } catch (e) {
        debugPrint('[ReaderScreen] _prefetchReader: raw HTML fetch error: $e');
      }

      if (rawHtml != null) {
        final doc = html_parser.parse(rawHtml);
        final mediaHtml = StringBuffer();

        // Extract <img> tags not already in content
        for (final img in doc.querySelectorAll('img')) {
          var src = img.attributes['src'];
          if (src == null || src.isEmpty) continue;
          src = _resolveUrl(src, url);
          if (content.contains(src)) continue;
          final alt = img.attributes['alt'] ?? '';
          mediaHtml.writeln('<p><img src="$src" alt="$alt" /></p>');
        }

        // Extract <picture> <source> srcset images
        for (final picture in doc.querySelectorAll('picture')) {
          final img = picture.querySelector('img');
          if (img == null) continue;
          var src = img.attributes['src'];
          if (src == null || src.isEmpty) {
            // Try srcset
            final source = picture.querySelector('source');
            src = source?.attributes['srcset'];
            if (src != null) {
              src = src.split(' ').first;
            }
          }
          if (src == null || src.isEmpty) continue;
          src = _resolveUrl(src, url);
          if (content.contains(src)) continue;
          final alt = img.attributes['alt'] ?? '';
          mediaHtml.writeln('<p><img src="$src" alt="$alt" /></p>');
        }

        // Extract <iframe> embeds (YouTube, etc.) not already in content
        for (final iframe in doc.querySelectorAll('iframe')) {
          var src = iframe.attributes['src'];
          if (src == null || src.isEmpty) continue;
          src = _resolveUrl(src, url);
          if (content.contains(src)) continue;
          mediaHtml.writeln('<iframe src="$src"></iframe>');
        }

        if (mediaHtml.isNotEmpty) {
          content = '$content\n${mediaHtml.toString()}';
          debugPrint('[ReaderScreen] _prefetchReader: appended media HTML, content length=${content.length}');
        }
      }

      if (content.isNotEmpty) {
        _readerCache[article.guid] = content;
        await _db.upsertPrefetchedArticleContent(article.guid, content);
        if (mounted && article.guid == widget.articles[_currentIndex].guid) {
          _updateTextForArticle(article, widget.articles.indexOf(article));
        }
      } else {
        debugPrint('[ReaderScreen] _prefetchReader: no content extracted');
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

  String _resolveUrl(String src, String baseUrl) {
    if (src.startsWith('http://') || src.startsWith('https://')) return src;
    final base = Uri.tryParse(baseUrl);
    if (base == null) return src;
    if (src.startsWith('//')) return '${base.scheme}:$src';
    return base.resolve(src).toString();
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
                  if (_isBuffering)
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
              onPressed: canPlay
                  ? () {
                      if (_isPlaying && !_isPaused) {
                        _pausePlayback();
                      } else if (_isPaused) {
                        _resumePlayback();
                      } else if (_isBuffering) {
                        debugPrint('[ReaderScreen] play button: was buffering, starting playback');
                        _startPlayback(paragraphIndex: _currentParagraphIndex);
                      } else {
                        _startPlayback(paragraphIndex: _currentParagraphIndex);
                      }
                    }
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
            AppLocalizations.of(context)!.playingSection('${_currentParagraphIndex + 1}', '${_paragraphs.length}'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          )
        else
          Text(AppLocalizations.of(context)!.readAloudNotAvailable),
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

class _VideoInlineSyntax extends md.InlineSyntax {
  _VideoInlineSyntax() : super(r'VIDEO_EMBED_START:(.*?)VIDEO_EMBED_END');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final src = match[1] ?? '';
    final el = md.Element.withTag('video');
    el.attributes['src'] = src;
    parser.addNode(el);
    return true;
  }
}

class _VideoBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final src = element.attributes['src'] ?? '';
    return _EmbeddedVideoPlayer(url: src);
  }
}

class _EmbeddedVideoPlayer extends StatefulWidget {
  final String url;
  const _EmbeddedVideoPlayer({required this.url});

  @override
  State<_EmbeddedVideoPlayer> createState() => _EmbeddedVideoPlayerState();
}

class _EmbeddedVideoPlayerState extends State<_EmbeddedVideoPlayer> {
  bool _showVideo = false;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(AppLocalizations.of(context)!.embeddedVideoUnsupported),
        ),
      );
    }

    if (!_showVideo) {
      return Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.video_library, size: 48, color: Colors.white54),
            Positioned(
              bottom: 12,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(AppLocalizations.of(context)!.loadVideo),
                onPressed: () => setState(() => _showVideo = true),
              ),
            ),
          ],
        ),
      );
    }

    final controller = webview.WebViewController()
      ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    return Container(
      height: 240,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: webview.WebViewWidget(
          controller: controller,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer()),
            Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer()),
          },
        ),
      ),
    );
  }
}

class _OnboardingStepData {
  final IconData icon;
  final String title;
  final String desc;
  const _OnboardingStepData({
    required this.icon,
    required this.title,
    required this.desc,
  });
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
      label: Text(AppLocalizations.of(context)!.unreadCount('$unread')),
    );
  }
}
