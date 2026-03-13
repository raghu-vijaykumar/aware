import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/app_state.dart';
import 'reader_screen.dart';

class ArticleListScreen extends StatefulWidget {
  final int feedId;
  final String feedTitle;

  const ArticleListScreen(
      {super.key, required this.feedId, required this.feedTitle});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture =
        context.read<AppState>().getArticlesForFeed(widget.feedId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feedTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _articlesFuture =
                    context.read<AppState>().getArticlesForFeed(widget.feedId);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(
                child: Text('No articles yet. Pull to refresh.'));
          }

          return Consumer<AppState>(builder: (context, appState, child) {
            return ListView.separated(
              itemCount: articles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final article = articles[index];
                final state = appState.getArticleState(article.guid);
                final isRead = state?.readAt != null;
                final isStarred = state?.starredAt != null;

                return Dismissible(
                  key: ValueKey(article.guid),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.amber.shade700,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      isStarred ? Icons.star_border : Icons.star,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (direction == DismissDirection.startToEnd) {
                      await appState.markArticleRead(article.guid,
                          read: !isRead);
                      messenger.showSnackBar(
                        SnackBar(
                          content:
                              Text(isRead ? 'Marked unread' : 'Marked read'),
                        ),
                      );
                    } else {
                      await appState.markArticleStarred(article.guid,
                          starred: !isStarred);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(isStarred
                              ? 'Removed from saved'
                              : 'Saved for later'),
                        ),
                      );
                    }
                    return false;
                  },
                  child: ListTile(
                    title: Text(
                      article.title ?? 'Untitled',
                      style: TextStyle(
                        color: isRead ? Theme.of(context).disabledColor : null,
                      ),
                    ),
                    subtitle: Text(article.summary ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isStarred)
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReaderScreen(
                            articles: articles, initialIndex: index),
                      ));
                    },
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
