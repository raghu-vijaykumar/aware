import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/feed.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  Map<String, List<Feed>> _feedsByCategory = {};
  final Map<String, _CategoryMeta> _categories = {};
  bool _isLoading = true;
  String? _selectedCategory;
  final _urlController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadCuratedFeeds();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddFeedDialog(BuildContext context) async {
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addFeedTitle),
          content: TextField(
            controller: _urlController,
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.addFeedUrlHint),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => _isAdding = true);
      try {
        await appState.addFeedFromUrl(_urlController.text.trim());
        if (!mounted) return;
        _urlController.clear();
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.feedAdded)));
      } catch (err) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToAddFeed('$err'))));
      } finally {
        if (mounted) {
          setState(() => _isAdding = false);
        }
      }
    }
  }

  Color _parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _loadCuratedFeeds() async {
    try {
      final jsonString = await rootBundle.loadString('assets/curated_feeds.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final categoriesJson = data['categories'] as List<dynamic>?;
      if (categoriesJson != null) {
        for (final c in categoriesJson) {
          final m = c as Map<String, dynamic>;
          final id = m['id'] as String;
          _categories[id] = _CategoryMeta(
            id: id,
            label: m['label'] as String? ?? id,
            color: _parseHexColor(m['color'] as String? ?? '#42A5F5'),
          );
        }
      }

      final feedsJson = data['feeds'] as List<dynamic>;
      final feeds = feedsJson.where((f) {
        final m = f as Map<String, dynamic>;
        final url = m['url'] as String;
        final uri = Uri.tryParse(url);
        return uri != null && uri.hasScheme && uri.hasAuthority && (uri.scheme == 'http' || uri.scheme == 'https');
      }).map((f) {
        final m = f as Map<String, dynamic>;
        return Feed(
          url: m['url'] as String,
          title: m['title'] as String?,
          description: m['description'] as String?,
          category: m['category'] as String?,
        );
      }).toList();

      setState(() {
        _feedsByCategory =
            _groupBy(feeds, (feed) => feed.category ?? 'Uncategorized');
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load curated feeds: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<Feed>> _groupBy(
      List<Feed> feeds, String Function(Feed) keyFn) {
    final map = <String, List<Feed>>{};
    for (final feed in feeds) {
      final key = keyFn(feed);
      map.putIfAbsent(key, () => []).add(feed);
    }
    return map;
  }

  int get _filteredFeedCount =>
      _filteredFeedsByCategory.values.fold<int>(0, (sum, list) => sum + list.length);

  Map<String, List<Feed>> get _filteredFeedsByCategory {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return _feedsByCategory;
    final filtered = <String, List<Feed>>{};
    _feedsByCategory.forEach((category, feeds) {
      final matching = feeds.where((feed) {
        final label = _labelFor(feed.category).toLowerCase();
        return (feed.title?.toLowerCase().contains(query) ?? false) ||
            (feed.description?.toLowerCase().contains(query) ?? false) ||
            feed.url.toLowerCase().contains(query) ||
            label.contains(query);
      }).toList();
      if (matching.isNotEmpty) {
        filtered[category] = matching;
      }
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.s16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.marketplaceTitle),
            Text(
              AppLocalizations.of(context)!.marketplaceSubtitle,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: AppLocalizations.of(context)!.addFeedTitle,
            onPressed: () => _showAddFeedDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCuratedFeeds,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),
                    const SizedBox(height: AppSpacing.s12),
                    _buildSearchBar(context),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                        child: Text(
                          '${_filteredFeedCount} feeds found',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s12),
                    _buildCategoryFilters(context),
                    const SizedBox(height: AppSpacing.s12),
                    ..._buildCategorySections(),
                    const SizedBox(height: AppSpacing.s32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalFeeds =
        _feedsByCategory.values.fold<int>(0, (sum, list) => sum + list.length);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.16),
            colorScheme.secondary.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.marketplaceHeroTitle,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  AppLocalizations.of(context)!.marketplaceHeroDesc,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s12,
                  children: [
                    _statPill(
                        context, Icons.category, AppLocalizations.of(context)!.marketplaceCategoriesCount('${_feedsByCategory.length}')),
                    _statPill(context, Icons.rss_feed, AppLocalizations.of(context)!.marketplaceFeedsCount('$totalFeeds')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.s8),
          Text(label,
              style: TextStyle(
                  color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.marketplaceSearchHint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = _categories.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedCategory == null,
            onSelected: (_) => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: AppSpacing.s8),
          ...categories.map((meta) {
            final selected = _selectedCategory == meta.id;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s8),
              child: ChoiceChip(
                label: Text(meta.label),
                selected: selected,
                backgroundColor: meta.color.withOpacity(0.08),
                selectedColor: meta.color.withOpacity(0.18),
                side: BorderSide(
                    color: selected
                        ? meta.color
                        : colorScheme.outline.withOpacity(0.4)),
                labelStyle: TextStyle(
                  color: selected ? meta.color.darken() : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) =>
                    setState(() => _selectedCategory = selected ? null : meta.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections() {
    final source = _filteredFeedsByCategory;
    final visibleCategories = source.entries.where((entry) {
      if (_selectedCategory == null) return true;
      return entry.key == _selectedCategory;
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return visibleCategories.map((entry) {
      final meta = _categories.putIfAbsent(entry.key, () =>
          _CategoryMeta(id: entry.key, label: entry.key, color: Colors.blue));
      final feeds = entry.value;
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
        child: Material(
          color: colorScheme.surface,
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ExpansionTile(
              initiallyExpanded: _selectedCategory == entry.key,
              tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.s8),
              collapsedBackgroundColor: colorScheme.surface,
              backgroundColor: colorScheme.surface,
              leading: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: meta.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(meta.id), color: meta.color),
              ),
              title: Text(
                meta.label,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.marketplaceCuratedSources('${feeds.length}'),
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              children: feeds.map((feed) => _buildFeedTile(feed, meta.color)).toList(),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFeedTile(Feed feed, Color accent) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isSubscribed = appState.feeds.any((f) => f.url == feed.url);
        final messenger = ScaffoldMessenger.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          child: Material(
            color: colorScheme.surface,
            elevation: 6,
            shadowColor: colorScheme.shadow.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withOpacity(0.16)),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    accent.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feed.title ?? AppLocalizations.of(context)!.marketplaceUntitledFeed,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    children: [
                      Text(
                        _labelFor(feed.category),
                        style: textTheme.titleSmall?.copyWith(
                          color: accent.darken(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isSubscribed
                              ? Icons.rss_feed
                              : Icons.rss_feed_outlined,
                          color: isSubscribed
                              ? accent
                              : colorScheme.onSurfaceVariant,
                        ),
                        tooltip: isSubscribed ? AppLocalizations.of(context)!.marketplaceSubscribed : AppLocalizations.of(context)!.marketplaceFollow,
                        onPressed: isSubscribed
                            ? null
                            : () async {
                                try {
                                  await appState.addFeedFromUrl(feed.url);
                                  messenger.showSnackBar(
                                    SnackBar(
                                    content: Text(
                                        AppLocalizations.of(context)!.marketplaceSubscribedTo(feed.title ?? 'feed')),
                                    ),
                                  );
                                } catch (e) {
                                  final msg = e is ArgumentError
                                      ? AppLocalizations.of(context)!.marketplaceInvalidUrl
                                      : AppLocalizations.of(context)!.marketplaceUnreachable;
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                  if (feed.description != null &&
                      feed.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      feed.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Text(
                          Uri.tryParse(feed.url)?.host ?? feed.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
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
  }

  IconData _iconFor(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('tech') || lower.contains('dev') || lower.contains('program') || lower.contains('engineering')) return Icons.memory_rounded;
    if (lower.contains('ai') || lower.contains('data') || lower.contains('intelligence')) return Icons.smart_toy_outlined;
    if (lower.contains('design') || lower.contains('ui') || lower.contains('ux')) return Icons.palette_outlined;
    if (lower.contains('business') || lower.contains('startup') || lower.contains('economy') || lower.contains('finance') || lower.contains('money')) return Icons.trending_up;
    if (lower.contains('news') || lower.contains('world') || lower.contains('country-') || lower.contains('local') || lower.contains('public')) return Icons.public;
    if (lower.contains('science') || lower.contains('space') || lower.contains('nasa')) return Icons.science_outlined;
    if (lower.contains('security') || lower.contains('shield') || lower.contains('hacker') || lower.contains('cyber')) return Icons.shield_outlined;
    if (lower.contains('sport') || lower.contains('tennis') || lower.contains('cricket') || lower.contains('football') || lower.contains('soccer')) return Icons.sports_soccer;
    if (lower.contains('health') || lower.contains('beauty') || lower.contains('fitness')) return Icons.spa_outlined;
    if (lower.contains('food') || lower.contains('cook') || lower.contains('recipe') || lower.contains('restaurant')) return Icons.restaurant_outlined;
    if (lower.contains('gaming') || lower.contains('game')) return Icons.sports_esports_outlined;
    if (lower.contains('movie') || lower.contains('film') || lower.contains('television') || lower.contains('tv')) return Icons.movie_outlined;
    if (lower.contains('music') || lower.contains('audio') || lower.contains('podcast')) return Icons.music_note_outlined;
    if (lower.contains('photo') || lower.contains('camera') || lower.contains('image')) return Icons.camera_alt_outlined;
    if (lower.contains('book') || lower.contains('read') || lower.contains('literature')) return Icons.menu_book_outlined;
    if (lower.contains('travel') || lower.contains('tourism') || lower.contains('flight')) return Icons.flight_outlined;
    if (lower.contains('architecture') || lower.contains('building') || lower.contains('apartment')) return Icons.apartment_outlined;
    if (lower.contains('fashion') || lower.contains('style') || lower.contains('cloth')) return Icons.checkroom_outlined;
    if (lower.contains('car') || lower.contains('auto') || lower.contains('vehicle')) return Icons.directions_car_outlined;
    if (lower.contains('history') || lower.contains('heritage')) return Icons.history_outlined;
    if (lower.contains('diy') || lower.contains('interior') || lower.contains('home')) return Icons.handyman_outlined;
    if (lower.contains('funny') || lower.contains('humor') || lower.contains('comedy')) return Icons.emoji_emotions_outlined;
    if (lower.contains('android')) return Icons.android_outlined;
    if (lower.contains('apple') || lower.contains('ios')) return Icons.apple_outlined;
    if (lower.contains('personal') || lower.contains('self')) return Icons.person_outlined;
    return Icons.rss_feed;
  }

  String _labelFor(String? id) {
    return _categories[id]?.label ?? (id ?? 'feed');
  }
}

class _CategoryMeta {
  final String id;
  final String label;
  final Color color;

  const _CategoryMeta({
    required this.id,
    required this.label,
    required this.color,
  });
}

extension _ColorUtils on Color {
  Color darken([double amount = 0.12]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
