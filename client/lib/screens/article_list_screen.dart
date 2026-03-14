import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/article.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
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
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final textTheme = theme.textTheme;
            final isLight = theme.brightness == Brightness.light;
            final cardShadowColor =
                colorScheme.shadow.withOpacity(isLight ? 0.25 : 0.55);

            return ListView.separated(
              itemCount: articles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final article = articles[index];
                final state = appState.getArticleState(article.guid);
                final isRead = state?.readAt != null;
                final isStarred = state?.starredAt != null;
                final readIconColor = isRead
                    ? colorScheme.onSurface.withOpacity(0.55)
                    : colorScheme.primary;
                final readTextColor =
                    isRead ? colorScheme.onSurface.withOpacity(0.5) : null;
                final starIconColor = isStarred
                    ? colorScheme.secondary
                    : colorScheme.onSurface.withOpacity(0.6);
                final starTextColor = isStarred ? colorScheme.secondary : null;

                return Dismissible(
                  key: ValueKey(article.guid),
                  background: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: AppSpacing.s16),
                    child: Icon(
                      isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                      color: colorScheme.secondary,
                    ),
                  ),
                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.s16),
                    child: Icon(
                      isStarred ? Icons.star_border : Icons.star,
                      color: colorScheme.primary,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isRead
                              ? theme.cardColor.withOpacity(0.9)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: cardShadowColor,
                              offset: const Offset(0, 8),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ReaderScreen(
                                  articles: articles, initialIndex: index),
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            isRead
                                                ? Icons.mark_email_read
                                                : Icons.mark_email_unread,
                                            size: 18,
                                            color: readIconColor,
                                          ),
                                          const SizedBox(width: AppSpacing.s8),
                                          Text(
                                            isRead ? 'Read' : 'Unread',
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: readTextColor,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.s16),
                                          Icon(
                                            isStarred
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 18,
                                            color: starIconColor,
                                          ),
                                          const SizedBox(width: AppSpacing.s8),
                                          Text(
                                            isStarred ? 'Saved' : 'Tap to save',
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: starTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (article.url != null)
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        tooltip: 'Share article',
                                        onPressed: () =>
                                            _shareArticle(context, article),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.s16),
                                Text(
                                  article.title ?? 'Untitled',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Text(
                                  article.summary ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }

  Future<void> _shareArticle(BuildContext context, Article article) async {
    if (article.url == null) return;
    await Share.share(article.url!,
        subject: article.title ?? 'aware article',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 0, 0));
  }
}
