import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/app_state.dart';

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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Mark the initial article as read after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead(widget.articles[_currentIndex]);
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
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              // TODO: Open in browser
            },
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
        },
        itemBuilder: (context, index) {
          final item = widget.articles[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.title ?? 'Untitled',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (item.author != null) ...[
                    Text('By ${item.author!}',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                  ],
                  if (item.summary != null) ...[
                    Text(item.summary!,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],
                  if (item.content != null) ...[
                    Text(item.content!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
}
