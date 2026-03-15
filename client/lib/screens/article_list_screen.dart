import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/article.dart';
import '../models/feed.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import 'reader_screen.dart';

class ArticleListScreen extends StatefulWidget {
  final int? feedId;
  final String feedTitle;
  final bool allFeeds;

  const ArticleListScreen(
      {super.key, required this.feedTitle, this.feedId, this.allFeeds = false});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late Future<List<Article>> _articlesFuture;

  _LengthFilter _lengthFilter = _LengthFilter.all;
  _TimeWindow _timeWindow = _TimeWindow.all;
  String? _selectedSource;
  String? _keyword;
  bool _unreadOnly = false;
  bool _likedOnly = false;
  bool _savedOnly = false;

  @override
  void initState() {
    super.initState();
    _articlesFuture = widget.allFeeds
        ? context.read<AppState>().getAllArticles()
        : context.read<AppState>().getArticlesForFeed(widget.feedId!);
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
                _articlesFuture = widget.allFeeds
                    ? context.read<AppState>().getAllArticles()
                    : context
                        .read<AppState>()
                        .getArticlesForFeed(widget.feedId!);
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

            final filteredArticles = _applyFilters(articles, appState.feeds);

            return Column(
              children: [
                _buildQuickFilters(
                  context,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  articles: articles,
                  feeds: appState.feeds,
                ),
                Expanded(
                  child: filteredArticles.isEmpty
                      ? const Center(
                          child: Text('No articles match the current filters.'),
                        )
                      : ListView.separated(
                          itemCount: filteredArticles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.s12),
                          itemBuilder: (context, index) {
                            final article = filteredArticles[index];
                      final state = appState.getArticleState(article.guid);
                      final isRead = state?.readAt != null;
                      final isLiked = state?.likedAt != null;
                      final isStarred = state?.starredAt != null;
                      final readIconColor = isRead
                          ? colorScheme.primary.withOpacity(0.55)
                          : colorScheme.primary;
                      final likeIconColor = isLiked
                          ? colorScheme.error
                          : colorScheme.onSurface.withOpacity(0.6);
                      final saveIconColor = isStarred
                          ? colorScheme.secondary
                          : colorScheme.onSurface.withOpacity(0.6);

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
                            isRead
                                ? Icons.mark_email_unread
                                : Icons.mark_email_read,
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
                                content: Text(
                                    isRead ? 'Marked unread' : 'Marked read'),
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
                              horizontal: AppSpacing.s16,
                              vertical: AppSpacing.s8),
                          child: Material(
                            color: Colors.transparent,
                            elevation: isLight ? 10 : 14,
                            shadowColor: cardShadowColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: isRead
                                    ? theme.cardColor.withOpacity(0.9)
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (_) => ReaderScreen(
                                          articles: filteredArticles,
                                          initialIndex: index),
                                    ));
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.s16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.title ?? 'Untitled',
                                          style: textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: AppSpacing.s4),
                                        Text(
                                          _articleSource(article, appState.feeds),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.s8),
                                        // Removed inline summary preview to keep cards compact.
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: AppSpacing.s4),
                                            Text(
                                              _relativeTimeLabel(article),
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.s8),
                                        Row(
                                          children: [
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: likeIconColor,
                                              ),
                                                tooltip:
                                                  isLiked ? 'Unlike' : 'Like',
                                              onPressed: () async {
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                        context);
                                                await appState
                                                    .markArticleLiked(
                                                  article.guid,
                                                  liked: !isLiked,
                                                );
                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(isLiked
                                                        ? 'Removed like'
                                                        : 'Liked article'),
                                                  ),
                                                );
                                              },
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: Icon(
                                                isRead
                                                    ? Icons.mark_email_read
                                                    : Icons.mark_email_unread,
                                                color: readIconColor,
                                              ),
                                              tooltip: isRead
                                                  ? 'Mark unread'
                                                  : 'Mark read',
                                              onPressed: () async {
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                        context);
                                                await appState.markArticleRead(
                                                  article.guid,
                                                  read: !isRead,
                                                );
                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(isRead
                                                        ? 'Marked unread'
                                                        : 'Marked read'),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: Icon(
                                                isStarred
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                color: saveIconColor,
                                              ),
                                              tooltip: isStarred
                                                  ? 'Unsave'
                                                  : 'Save for later',
                                              onPressed: () async {
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                        context);
                                                await appState
                                                    .markArticleStarred(
                                                  article.guid,
                                                  starred: !isStarred,
                                                );
                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(isStarred
                                                        ? 'Removed from saved'
                                                        : 'Saved for later'),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (article.url != null)
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                icon: const Icon(Icons.share),
                                                tooltip: 'Share',
                                                onPressed: () => _shareArticle(
                                                    context, article),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  String _articleSource(Article article, List<Feed> feeds) {
    final source = _sourceLabel(article, feeds);
    final author = article.author?.trim();
    if (author != null && author.isNotEmpty) {
      return '$source - $author';
    }
    return source;
  }

  List<Article> _applyFilters(List<Article> articles, List<Feed> feeds) {
    return articles.where((article) {
      // Read filter
      final state = context.read<AppState>().getArticleState(article.guid);
      if (_unreadOnly && state?.readAt != null) return false;
      if (_likedOnly && state?.likedAt == null) return false;
      if (_savedOnly && state?.starredAt == null) return false;

      // Time window filter
      final published = article.publishedAt ?? article.fetchedAt;
      if (_timeWindow != _TimeWindow.all) {
        if (published == null) return false;
        final publishedDate = DateTime.fromMillisecondsSinceEpoch(published);
        final hoursAgo = DateTime.now().difference(publishedDate).inHours;
        switch (_timeWindow) {
          case _TimeWindow.last24h:
            if (hoursAgo > 24) return false;
            break;
          case _TimeWindow.last7d:
            if (hoursAgo > 24 * 7) return false;
            break;
          case _TimeWindow.last30d:
            if (hoursAgo > 24 * 30) return false;
            break;
          case _TimeWindow.all:
            break;
        }
      }

      // Length filter based on summary/content word count
      final textForLength = (article.summary?.trim().isNotEmpty ?? false)
          ? article.summary
          : article.content;
      final wordCount = _wordCount(textForLength);
      switch (_lengthFilter) {
        case _LengthFilter.short:
          if (wordCount >= 100) return false;
          break;
        case _LengthFilter.medium:
          if (wordCount < 100 || wordCount > 300) return false;
          break;
        case _LengthFilter.long:
          if (wordCount <= 300) return false;
          break;
        case _LengthFilter.multiParagraph:
          if (!_hasMultipleParagraphs(textForLength)) return false;
          break;
        case _LengthFilter.all:
          break;
      }

      // Source filter
      final articleSource = _sourceLabel(article, feeds);
      if (_selectedSource != null &&
          _selectedSource!.isNotEmpty &&
          articleSource != _selectedSource) {
        return false;
      }

      // Keyword filter (title, summary, content)
      if (_keyword != null && _keyword!.trim().isNotEmpty) {
        final kw = _keyword!.toLowerCase();
        final haystacks = [
          article.title,
          article.summary,
          article.content,
        ].whereType<String>();
        final matches = haystacks.any((h) => h.toLowerCase().contains(kw));
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  int _wordCount(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\\s+')).length;
  }

  bool _hasMultipleParagraphs(String? text) {
    if (text == null) return false;
    final blocks = text.split(RegExp(r'(\\n\\s*\\n)+'));
    return blocks.where((b) => b.trim().isNotEmpty).length > 1;
  }

  Widget _buildQuickFilters(
    BuildContext context, {
    required List<Article> articles,
    required List<Feed> feeds,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _openFilterDrawer(
                context, articles, feeds, textTheme, colorScheme),
            icon: const Icon(Icons.filter_list),
            label: const Text('Filters'),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ChoiceChip(
                    label: const Text('Unread'),
                    selected: _unreadOnly,
                    onSelected: (_) =>
                        setState(() => _unreadOnly = !_unreadOnly),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ChoiceChip(
                    label: const Text('Liked'),
                    selected: _likedOnly,
                    onSelected: (_) =>
                        setState(() => _likedOnly = !_likedOnly),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ChoiceChip(
                    label: const Text('Saved'),
                    selected: _savedOnly,
                    onSelected: (_) =>
                        setState(() => _savedOnly = !_savedOnly),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ChoiceChip(
                    label: const Text('Last 24h'),
                    selected: _timeWindow == _TimeWindow.last24h,
                    onSelected: (_) => setState(() => _timeWindow =
                        _timeWindow == _TimeWindow.last24h
                            ? _TimeWindow.all
                            : _TimeWindow.last24h),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterDrawer(BuildContext context, List<Article> articles,
      List<Feed> feeds, TextTheme textTheme, ColorScheme colorScheme) {
    final topSources = _topSources(articles, feeds);
    final keywordController = TextEditingController(text: _keyword ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void update(void Function() cb) {
              setSheetState(cb);
              setState(cb);
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.s16,
                  right: AppSpacing.s16,
                  top: AppSpacing.s16,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.s16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text('Filters', style: textTheme.titleMedium),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text('Engagement', style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: const Text('Unread only'),
                            selected: _unreadOnly,
                            onSelected: (_) =>
                                update(() => _unreadOnly = !_unreadOnly),
                          ),
                          ChoiceChip(
                            label: const Text('Liked'),
                            selected: _likedOnly,
                            onSelected: (_) =>
                                update(() => _likedOnly = !_likedOnly),
                          ),
                          ChoiceChip(
                            label: const Text('Saved'),
                            selected: _savedOnly,
                            onSelected: (_) =>
                                update(() => _savedOnly = !_savedOnly),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text('Length / preview', style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: const Text('Any'),
                            selected: _lengthFilter == _LengthFilter.all,
                            onSelected: (_) =>
                                update(() => _lengthFilter = _LengthFilter.all),
                          ),
                          ChoiceChip(
                            label: const Text('Short <100w'),
                            selected: _lengthFilter == _LengthFilter.short,
                            onSelected: (_) =>
                                update(() => _lengthFilter = _LengthFilter.short),
                          ),
                          ChoiceChip(
                            label: const Text('Medium 100-300'),
                            selected: _lengthFilter == _LengthFilter.medium,
                            onSelected: (_) => update(
                                () => _lengthFilter = _LengthFilter.medium),
                          ),
                          ChoiceChip(
                            label: const Text('Long >300'),
                            selected: _lengthFilter == _LengthFilter.long,
                            onSelected: (_) =>
                                update(() => _lengthFilter = _LengthFilter.long),
                          ),
                          ChoiceChip(
                            label: const Text('2+ paragraphs'),
                            selected: _lengthFilter == _LengthFilter.multiParagraph,
                            onSelected: (_) => update(() =>
                                _lengthFilter = _LengthFilter.multiParagraph),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text('Time window', style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _timeWindow == _TimeWindow.all,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.all),
                          ),
                          ChoiceChip(
                            label: const Text('Last 24h'),
                            selected: _timeWindow == _TimeWindow.last24h,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.last24h),
                          ),
                          ChoiceChip(
                            label: const Text('Last 7d'),
                            selected: _timeWindow == _TimeWindow.last7d,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.last7d),
                          ),
                          ChoiceChip(
                            label: const Text('Last 30d'),
                            selected: _timeWindow == _TimeWindow.last30d,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.last30d),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text('Sources', style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: const Text('All sources'),
                            selected: _selectedSource == null,
                            onSelected: (_) =>
                                update(() => _selectedSource = null),
                          ),
                          for (final source in topSources)
                            ChoiceChip(
                              label: Text(source),
                              selected: _selectedSource == source,
                              onSelected: (_) =>
                                  update(() => _selectedSource = source),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text('Keyword', style: textTheme.labelLarge),
                      TextField(
                        controller: keywordController,
                        decoration: const InputDecoration(
                          hintText: 'Title, summary, or content',
                        ),
                        onChanged: (value) => update(() => _keyword =
                            value.trim().isEmpty ? null : value.trim()),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              update(() {
                                _lengthFilter = _LengthFilter.all;
                                _timeWindow = _TimeWindow.all;
                                _selectedSource = null;
                                _keyword = null;
                                _unreadOnly = false;
                                _likedOnly = false;
                                _savedOnly = false;
                              });
                            },
                            child: const Text('Reset'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _topSources(List<Article> articles, List<Feed> feeds,
      {int maxSources = 5}) {
    final counts = <String, int>{};
    for (final article in articles) {
      final source = _sourceLabel(article, feeds);
      if (source.isEmpty) continue;
      counts[source] = (counts[source] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(maxSources).map((e) => e.key).toList();
  }

  String _sourceLabel(Article article, List<Feed> feeds) {
    final feedTitle = _feedTitleFor(article, feeds);
    if (feedTitle != null && feedTitle.isNotEmpty) return feedTitle;

    final host = article.url != null ? Uri.tryParse(article.url!)?.host : null;
    if (host != null && host.isNotEmpty) return host;

    return widget.feedTitle;
  }

  String? _feedTitleFor(Article article, List<Feed> feeds) {
    for (final feed in feeds) {
      if (feed.id == article.feedId) {
        final title = feed.title?.trim();
        if (title != null && title.isNotEmpty) return title;
        break;
      }
    }
    return null;
  }

  String _relativeTimeLabel(Article article) {
    final timestamp = article.publishedAt ?? article.fetchedAt;
    if (timestamp == null) return 'Publish date unknown';

    final publishedDate =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
    final diff = DateTime.now().difference(publishedDate);

    String label;
    if (diff.inMinutes < 1) {
      label = 'Just now';
    } else if (diff.inMinutes < 60) {
      label = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      label = '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      label = '${diff.inDays}d ago';
    } else {
      final weeks = (diff.inDays / 7).floor();
      if (weeks < 5) {
        label = '${weeks}w ago';
      } else {
        final months = (diff.inDays / 30).floor();
        if (months < 12) {
          label = '${months}mo ago';
        } else {
          final years = (diff.inDays / 365).floor();
          label = '${years}y ago';
        }
      }
    }

    // If we had to fall back to fetchedAt, mark it.
    return article.publishedAt != null ? label : '$label (fetched)';
  }
}

enum _LengthFilter { all, short, medium, long, multiParagraph }

enum _TimeWindow { all, last24h, last7d, last30d }
