import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:readability/readability.dart' as readability;
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Mark the initial article as read after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead(widget.articles[_currentIndex]);
      _prefetchReader(widget.articles[_currentIndex]);
    });
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
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _markRead(widget.articles[index]);
          _prefetchReader(widget.articles[index]);
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                    Image.network(item.imageUrl!),
                    const SizedBox(height: AppSpacing.s16),
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
                  MarkdownBody(
                    data: _htmlToMarkdown(_bodyHtml(item)),
                    onTapLink: (_, href, __) => _handleMarkdownLink(href),
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
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
              Text('${_currentIndex + 1}/${widget.articles.length}'),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _pageController.jumpToPage(_currentIndex);
                },
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
}
