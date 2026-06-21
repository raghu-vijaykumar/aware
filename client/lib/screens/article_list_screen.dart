import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/article.dart';
import '../models/feed.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../widgets/native_ad_tile.dart';
import 'reader_screen.dart';

class ArticleListScreen extends StatefulWidget {
  final int? feedId;
  final String feedTitle;
  final bool allFeeds;
  final VoidCallback? onAddFeed;

  const ArticleListScreen(
      {super.key, required this.feedTitle, this.feedId, this.allFeeds = false, this.onAddFeed});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  static const int _pageSize = 50;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _totalCount = 0;
  final List<Article> _allLoadedArticles = [];
  String? _loadError;

  _LengthFilter _lengthFilter = _LengthFilter.all;
  _TimeWindow _timeWindow = _TimeWindow.all;
  String? _selectedSource;
  String? _keyword;
  bool _unreadOnly = false;
  bool _likedOnly = false;
  bool _savedOnly = false;
  bool _showSearch = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialBatch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _loadInitialBatch() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final appState = context.read<AppState>();
      _totalCount = await appState.getArticlesCount(feedId: widget.feedId);
      final articles = await appState.getArticlesPaginated(
        feedId: widget.feedId,
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _allLoadedArticles
          ..clear()
          ..addAll(articles);
        _hasMore = _allLoadedArticles.length < _totalCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final appState = context.read<AppState>();
      final articles = await appState.getArticlesPaginated(
        feedId: widget.feedId,
        limit: _pageSize,
        offset: _allLoadedArticles.length,
      );
      if (!mounted) return;
      setState(() {
        _allLoadedArticles.addAll(articles);
        _hasMore = _allLoadedArticles.length < _totalCount;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    await _loadInitialBatch();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.error(_loadError!)),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_allLoadedArticles.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noArticlesYet),
      );
    }

    return Consumer<AppState>(builder: (context, appState, child) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;
      final isLight = theme.brightness == Brightness.light;
      final cardShadowColor =
          colorScheme.shadow.withOpacity(isLight ? 0.25 : 0.55);

      final filteredArticles = _applyFilters(_allLoadedArticles, appState.feeds);
      final articleCount = filteredArticles.length;
      final adCount = articleCount ~/ 10;

      return Column(
        children: [
          _buildQuickFilters(
            context,
            textTheme: textTheme,
            colorScheme: colorScheme,
            articles: _allLoadedArticles,
            feeds: appState.feeds,
          ),
          if (_keyword != null && _keyword!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Text(
                '$articleCount articles found',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          Expanded(
            child: filteredArticles.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.noArticlesMatch),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    itemCount: articleCount + adCount + (_hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s12),
                    itemBuilder: (context, index) {
                      if (index == articleCount + adCount) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          key: ValueKey('loading_$index'),
                        );
                      }

                      if ((index + 1) % 5 == 0) {
                        return NativeAdTile(key: ValueKey('ad_$index'));
                      }

                      final articleIndex = index - ((index + 1) ~/ 5);
                      final article = filteredArticles[articleIndex];
                      final state =
                          appState.getArticleState(article.guid);
                      final isRead = state?.readAt != null;
                      final isLiked = state?.likedAt != null;
                      final isStarred = state?.starredAt != null;
                      final readProgress = state?.readProgress ?? 0.0;
                      final isPartiallyRead = !isRead && readProgress > 0.0;

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
                          padding:
                              const EdgeInsets.only(left: AppSpacing.s16),
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
                          padding: const EdgeInsets.only(
                              right: AppSpacing.s16),
                          child: Icon(
                            isStarred ? Icons.star_border : Icons.star,
                            color: colorScheme.primary,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _toggleReadStatus(
                              appState: appState,
                              article: article,
                              isRead: isRead,
                            );
                          } else {
                            await appState.markArticleStarred(
                                article.guid,
                                starred: !isStarred);
                            _showActionSnackBar(
                              message: isStarred
                                  ? AppLocalizations.of(context)!.removedFromSaved
                                  : AppLocalizations.of(context)!.savedForLater,
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
                                    padding: const EdgeInsets.all(
                                        AppSpacing.s16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.title ?? AppLocalizations.of(context)!.untitled,
                                          style: textTheme.titleLarge
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w700),
                                        ),
                                        const SizedBox(
                                            height: AppSpacing.s8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 14,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.s4),
                                            Flexible(
                                              child: Text(
                                                '${_relativeTimeLabel(article)}  ${_articleSource(article, appState.feeds)}',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () async {
                                                await appState
                                                    .markArticleLiked(
                                                  article.guid,
                                                  liked: !isLiked,
                                                );
                                                if (!mounted) return;
                                                _showActionSnackBar(
                                                  message: isLiked
                                                      ? AppLocalizations.of(context)!.removedLike
                                                      : AppLocalizations.of(context)!.likedArticle,
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                                child: Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons
                                                          .favorite_border,
                                                  size: 18,
                                                  color: likeIconColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () async {
                                                await appState
                                                    .markArticleStarred(
                                                  article.guid,
                                                  starred: !isStarred,
                                                );
                                                if (!mounted) return;
                                                _showActionSnackBar(
                                                  message: isStarred
                                                      ? AppLocalizations.of(context)!.removedFromSaved
                                                      : AppLocalizations.of(context)!.savedForLater,
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                                child: Icon(
                                                  isStarred
                                                      ? Icons.bookmark
                                                      : Icons
                                                          .bookmark_border,
                                                  size: 18,
                                                  color: saveIconColor,
                                                ),
                                              ),
                                            ),
                                            if (article.url != null)
                                              InkWell(
                                                borderRadius: BorderRadius.circular(20),
                                                onTap: () =>
                                                    _shareArticle(
                                                        context, article),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  child: Icon(
                                                      Icons.share,
                                                      size: 18,
                                                      color: colorScheme
                                                          .onSurfaceVariant
                                                          .withOpacity(0.6)),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (isPartiallyRead)
                                          Padding(
                                            padding: const EdgeInsets.only(top: AppSpacing.s8),
                                            child: LinearProgressIndicator(
                                              value: readProgress,
                                              backgroundColor: colorScheme.surfaceVariant,
                                              color: colorScheme.primary,
                                              minHeight: 3,
                                            ),
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
  }

  Widget _buildContinueReadingFAB() {
    if (_allLoadedArticles.isEmpty) {
      return const SizedBox.shrink();
    }
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final filtered = _applyFilters(_allLoadedArticles, appState.feeds);
        final unread = filtered.where((a) =>
            appState.getArticleState(a.guid)?.readAt == null).toList();
        
        if (unread.isEmpty) return const SizedBox.shrink();

        bool hasProgress = false;
        for (final a in unread) {
          final state = appState.getArticleState(a.guid);
          if (state != null && (state.readProgress ?? 0.0) > 0.0) {
            hasProgress = true;
            break;
          }
        }

        if (!hasProgress) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: () => _launchCatchUpQueue(context, unread, appState),
          icon: const Icon(Icons.play_arrow),
          label: Text(AppLocalizations.of(context)!.continueReading),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showSearch
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showSearch = false;
                    _searchController.clear();
                    _keyword = null;
                  });
                },
              ),
              title: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchArticlesHint,
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _keyword = value.trim().isEmpty ? null : value.trim();
                  });
                },
              ),
              actions: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _keyword = null);
                    },
                  ),
              ],
            )
          : AppBar(
              title: Text(widget.feedTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: AppLocalizations.of(context)!.searchArticlesHint,
                  onPressed: () {
                    setState(() {
                      _showSearch = true;
                      _keyword = null;
                    });
                    _searchFocusNode.requestFocus();
                  },
                ),
                if (widget.onAddFeed != null)
                  IconButton(
                    icon: const Icon(Icons.add_link),
                    tooltip: AppLocalizations.of(context)!.addFeedTitle,
                    onPressed: widget.onAddFeed,
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
              ],
            ),
      body: _buildBody(),
      floatingActionButton: _buildContinueReadingFAB(),
    );
  }

  Future<void> _shareArticle(BuildContext context, Article article) async {
    if (article.url == null) return;
    await Share.share(article.url!,
        subject: article.title ?? 'aware article',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 0, 0));
  }

  void _showActionSnackBar({
    required String message,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
  }

  Future<void> _toggleReadStatus({
    required AppState appState,
    required Article article,
    required bool isRead,
  }) async {
    await appState.markArticleRead(article.guid, read: !isRead);
    if (!mounted) return;

    if (isRead) {
      _showActionSnackBar(message: AppLocalizations.of(context)!.markedUnread);
      return;
    }

    _showActionSnackBar(
      message: AppLocalizations.of(context)!.markedRead,
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.undo,
        onPressed: () async {
          await appState.markArticleRead(article.guid, read: false);
        },
      ),
    );
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
    final filtered = articles.where((article) {
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

    filtered.sort((a, b) {
      final aState = context.read<AppState>().getArticleState(a.guid);
      final bState = context.read<AppState>().getArticleState(b.guid);
      final aUnread = aState?.readAt == null;
      final bUnread = bState?.readAt == null;
      if (aUnread != bUnread) {
        return aUnread ? -1 : 1; // unread first
      }
      final aTime = a.publishedAt ?? a.fetchedAt ?? 0;
      final bTime = b.publishedAt ?? b.fetchedAt ?? 0;
      return bTime.compareTo(aTime); // newest first within groups
    });

    return filtered;
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
            label: Text(AppLocalizations.of(context)!.filters),
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
                    label: Text(AppLocalizations.of(context)!.unread),
                    selected: _unreadOnly,
                    onSelected: (_) =>
                        setState(() => _unreadOnly = !_unreadOnly),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.liked),
                    selected: _likedOnly,
                    onSelected: (_) => setState(() => _likedOnly = !_likedOnly),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.saved),
                    selected: _savedOnly,
                    onSelected: (_) => setState(() => _savedOnly = !_savedOnly),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.last24h),
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
                          Text(AppLocalizations.of(context)!.filters, style: textTheme.titleMedium),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(AppLocalizations.of(context)!.engagement, style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.unreadOnly),
                            selected: _unreadOnly,
                            onSelected: (_) =>
                                update(() => _unreadOnly = !_unreadOnly),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.liked),
                            selected: _likedOnly,
                            onSelected: (_) =>
                                update(() => _likedOnly = !_likedOnly),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.saved),
                            selected: _savedOnly,
                            onSelected: (_) =>
                                update(() => _savedOnly = !_savedOnly),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(AppLocalizations.of(context)!.lengthPreview, style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.any),
                            selected: _lengthFilter == _LengthFilter.all,
                            onSelected: (_) =>
                                update(() => _lengthFilter = _LengthFilter.all),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.short),
                            selected: _lengthFilter == _LengthFilter.short,
                            onSelected: (_) => update(
                                () => _lengthFilter = _LengthFilter.short),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.medium),
                            selected: _lengthFilter == _LengthFilter.medium,
                            onSelected: (_) => update(
                                () => _lengthFilter = _LengthFilter.medium),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.long),
                            selected: _lengthFilter == _LengthFilter.long,
                            onSelected: (_) => update(
                                () => _lengthFilter = _LengthFilter.long),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.multiParagraph),
                            selected:
                                _lengthFilter == _LengthFilter.multiParagraph,
                            onSelected: (_) => update(() =>
                                _lengthFilter = _LengthFilter.multiParagraph),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(AppLocalizations.of(context)!.timeWindow, style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.all),
                            selected: _timeWindow == _TimeWindow.all,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.all),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.last24h),
                            selected: _timeWindow == _TimeWindow.last24h,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.last24h),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.last7d),
                            selected: _timeWindow == _TimeWindow.last7d,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.last7d),
                          ),
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.last30d),
                            selected: _timeWindow == _TimeWindow.last30d,
                            onSelected: (_) =>
                                update(() => _timeWindow = _TimeWindow.last30d),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(AppLocalizations.of(context)!.sources, style: textTheme.labelLarge),
                      Wrap(
                        spacing: AppSpacing.s8,
                        children: [
                          ChoiceChip(
                            label: Text(AppLocalizations.of(context)!.allSources),
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
                      Text(AppLocalizations.of(context)!.keyword, style: textTheme.labelLarge),
                      TextField(
                        controller: keywordController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.keywordHint,
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
                            child: Text(AppLocalizations.of(context)!.reset),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.done),
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

  String _feedTitleFor(Article article, List<Feed> feeds) {
    if (article.feedId <= 0) return 'Unknown';
    try {
      final feed = feeds.firstWhere((f) => f.id == article.feedId);
      if (feed.title != null && feed.title!.isNotEmpty) {
        return feed.title!;
      }
      return feed.url;
    } catch (_) {
      return 'Unknown';
    }
  }

  void _launchCatchUpQueue(BuildContext context, List<Article> unreadArticles, AppState appState) {
    final queue = List<Article>.from(unreadArticles);
    queue.sort((a, b) {
      final aTime = a.publishedAt ?? a.fetchedAt ?? 0;
      final bTime = b.publishedAt ?? b.fetchedAt ?? 0;
      return aTime.compareTo(bTime);
    });

    int startIndex = 0;
    int mostRecentAccess = -1;

    for (int i = 0; i < queue.length; i++) {
        final state = appState.getArticleState(queue[i].guid);
        if (state != null && state.lastAccessedAt != null) {
            if (state.lastAccessedAt! > mostRecentAccess) {
                mostRecentAccess = state.lastAccessedAt!;
                startIndex = i;
            }
        }
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReaderScreen(
        articles: queue,
        initialIndex: startIndex,
        autoPlayMode: true,
      ),
    ));
  }

  String _relativeTimeLabel(Article article) {
    final timestamp = article.publishedAt ?? article.fetchedAt;
    if (timestamp == null) return AppLocalizations.of(context)!.publishDateUnknown;

    final publishedDate =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
    final diff = DateTime.now().difference(publishedDate);

    String label;
    if (diff.inMinutes < 1) {
      label = AppLocalizations.of(context)!.justNow;
    } else if (diff.inMinutes < 60) {
      label = AppLocalizations.of(context)!.minutesAgo('${diff.inMinutes}');
    } else if (diff.inHours < 24) {
      label = AppLocalizations.of(context)!.hoursAgo('${diff.inHours}');
    } else if (diff.inDays < 7) {
      label = AppLocalizations.of(context)!.daysAgo('${diff.inDays}');
    } else {
      final weeks = (diff.inDays / 7).floor();
      if (weeks < 5) {
        label = AppLocalizations.of(context)!.weeksAgo('$weeks');
      } else {
        final months = (diff.inDays / 30).floor();
        if (months < 12) {
          label = AppLocalizations.of(context)!.monthsAgo('$months');
        } else {
          final years = (diff.inDays / 365).floor();
          label = AppLocalizations.of(context)!.yearsAgo('$years');
        }
      }
    }

    // If we had to fall back to fetchedAt, mark it.
    return article.publishedAt != null ? label : '$label (${AppLocalizations.of(context)!.fetched})';
  }
}

enum _LengthFilter { all, short, medium, long, multiParagraph }

enum _TimeWindow { all, last24h, last7d, last30d }
