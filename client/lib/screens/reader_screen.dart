import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:readability/readability.dart' as readability;
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

import '../models/article.dart';
import '../providers/app_state.dart';
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
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  double _progress = 0.0;
  bool _startingAudio = false;
  int _currentParagraphIndex = 0;
  int _offsetBase = 0;
  bool _pendingAutoPlay = false;
  String _plainText = '';
  List<String> _paragraphs = [];
  List<int> _paragraphOffsets = [];
  final Map<int, List<GlobalKey>> _paragraphKeysByArticle = {};
  final Map<int, ScrollController> _scrollControllers = {};
  double? _lastAppliedRate;
  String? _lastAppliedVoice;
  DateTime? _lastScrollTime;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _attachTtsHandlers();

    // Preload TTS engine to remove first-play lag
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);

    // Mark the initial article as read after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead(widget.articles[_currentIndex]);
      _prefetchReader(widget.articles[_currentIndex]);
      _updateTextForArticle(widget.articles[_currentIndex], _currentIndex);
      _prefetchUpcomingArticles(2);
    });
  }

  @override
  void dispose() {
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

  void _markRead(Article article) async {
    final appState = context.read<AppState>();
    await appState.markArticleRead(article.guid, read: true);
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
      if (paragraphIdx >= 0 && paragraphIdx != _currentParagraphIndex) {
        setState(() {
          _currentParagraphIndex = paragraphIdx;
        });
        _scrollToParagraph(paragraphIdx);
      }
      setState(() {
        _progress = pct;
      });
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
      });

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
    if (_lastAppliedRate != appState.speechRate) {
      _lastAppliedRate = appState.speechRate;
      await _tts.setSpeechRate(appState.speechRate);
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
    final markdown = _htmlToMarkdown(_bodyHtml(article));
    final parts = markdown
        .split(RegExp(r'\n{2,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map(_sanitizeForTts)
        .where((p) => !_isMostlySymbols(p))
        .toList();
    var offset = 0;
    final offsets = <int>[];
    for (final p in parts) {
      offsets.add(offset);
      offset += p.length + 2; // include the paragraph break
    }
    setState(() {
      _paragraphs = parts;
      _paragraphOffsets = offsets;
      _plainText = parts.join('\n\n');
      _paragraphKeysByArticle[articleIndex] =
          List.generate(parts.length, (_) => GlobalKey());
      _progress = 0;
      _currentParagraphIndex = 0;
      _offsetBase = 0;
    });
  }

  String _sanitizeForTts(String input) {
    var text = input;
    // Strip markdown links, keep link text.
    text = text.replaceAll(RegExp(r'\[(.*?)\]\((https?:\/\/[^\)]+)\)'), r'$1');
    // Remove bare URLs.
    text = text.replaceAll(RegExp(r'https?:\/\/\S+'), '');
    // Collapse extra whitespace.
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  bool _isMostlySymbols(String paragraph) {
    // Count non-whitespace characters
    final nonWhitespace = paragraph.replaceAll(RegExp(r'\s'), '');
    if (nonWhitespace.isEmpty) return false;

    // Count symbol characters (non-alphanumeric, non-punctuation)
    final symbolCount = nonWhitespace
        .replaceAll(RegExp(r'[a-zA-Z0-9\s.,!?;:()"\-\[\]]'), '')
        .length;

    // If more than 60% of non-whitespace characters are symbols, consider it mostly symbols
    return symbolCount / nonWhitespace.length > 0.6;
  }

  Future<void> _startPlayback({int paragraphIndex = 0}) async {
    if (_paragraphs.isEmpty) return;

    final appState = context.read<AppState>();

    await _applyVoiceSettings(appState);

    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _currentParagraphIndex = paragraphIndex;
    });

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

    await _tts.stop();
    await _tts.speak(text);

    setState(() {
      _currentParagraphIndex = index;
      _progress = index / _paragraphs.length;
    });

    _scrollToParagraph(index);
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
      _progress = 0;
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
    _pendingAutoPlay = autoplay;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToParagraph(int paragraphIdx) {
    final keys = _paragraphKeysByArticle[_currentIndex];
    final controller = _scrollControllers[_currentIndex];

    if (keys == null || controller == null) return;
    if (paragraphIdx < 0 || paragraphIdx >= keys.length) return;

    final ctx = keys[paragraphIdx].currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      alignment: 0.2,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.articles.length,
        physics: const NeverScrollableScrollPhysics(), // Disable horizontal scrolling
        onPageChanged: (index) async {
          await _tts.stop();
          setState(() {
            _currentIndex = index;
            _isPlaying = false;
            _isPaused = false;
            _progress = 0;
          });
          _markRead(widget.articles[index]);
          _prefetchReader(widget.articles[index]);
          _updateTextForArticle(widget.articles[index], index);
          if (_pendingAutoPlay) {
            _pendingAutoPlay = false;
            _startPlayback(paragraphIndex: 0);
          } else {
            _prefetchUpcomingArticles(1);
          }
        },
        itemBuilder: (context, index) {
          final item = widget.articles[index];
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.s8),
                if (item.author != null) ...[
                  Text('By ${item.author!}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.s8),
                ],
                const SizedBox(height: AppSpacing.s16),
                _buildAudioControls(item),
                const SizedBox(height: AppSpacing.s12),
                Builder(builder: (context) {
                  final scrollController = _scrollControllers.putIfAbsent(
                      index, () => ScrollController());
                  final paraKeys =
                      _paragraphKeysByArticle[index] ?? const <GlobalKey>[];
                  return Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final entry in _paragraphs.asMap().entries) ...[
                            GestureDetector(
                              onTap: () =>
                                  _startPlayback(paragraphIndex: entry.key),
                              child: Container(
                                key: paraKeys.isNotEmpty &&
                                        entry.key < paraKeys.length
                                    ? paraKeys[entry.key]
                                    : null,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: _currentParagraphIndex == entry.key &&
                                          _isPlaying
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.45)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant
                                          .withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SelectableText(
                                  entry.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(height: 1.4),
                                ),
                              ),
                            ),
                          ],
                          if (_paragraphs.isEmpty)
                            MarkdownBody(
                              data: _htmlToMarkdown(_bodyHtml(item)),
                              onTapLink: (_, href, __) =>
                                  _handleMarkdownLink(href),
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                      Theme.of(context))
                                  .copyWith(
                                p: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(height: 1.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        ),
      ),
    );
  }

  String _htmlToMarkdown(String html) {
    final trimmed = html.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return html2md.convert(trimmed);
  }

  String _bodyHtml(Article article) {
    final cached = _readerCache[article.guid];
    if (cached != null) return cached;
    // Prefer full content, then summary, then rawData; default empty.
    return article.content ?? article.summary ?? article.rawData ?? '';
  }

  Future<void> _prefetchReader(Article article) async {
    if (article.url == null) return;
    if (_readerCache.containsKey(article.guid)) return;

    setState(() {
      _loadingReader = true;
    });

    try {
      final parsed = await readability.parseAsync(article.url!);
      final content = parsed.content ?? parsed.textContent ?? '';
      if (content.trim().isNotEmpty) {
        _readerCache[article.guid] = content;
        if (mounted && article.guid == widget.articles[_currentIndex].guid) {
          _updateTextForArticle(article, widget.articles.indexOf(article));
        }
      }
    } finally {
      if (mounted) {
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
            'Tap a paragraph to jump. Playing paragraph ${_currentParagraphIndex + 1}/${_paragraphs.length}',
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
