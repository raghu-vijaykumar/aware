import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool _isLoading = true;
  String? _selectedCategory;

  static final List<_CategoryMeta> _categories = [
    _CategoryMeta(id: 'tech', label: 'Tech & Engineering', color: Colors.indigo),
    _CategoryMeta(id: 'ai', label: 'AI & Data', color: Colors.deepPurple),
    _CategoryMeta(id: 'design', label: 'Design & UX', color: Colors.pink),
    _CategoryMeta(id: 'business', label: 'Business & Startups', color: Colors.teal),
    _CategoryMeta(id: 'news', label: 'News & World', color: Colors.orange),
    _CategoryMeta(id: 'science', label: 'Science & Space', color: Colors.blueGrey),
    _CategoryMeta(id: 'security', label: 'Security', color: Colors.redAccent),
    _CategoryMeta(id: 'sports', label: 'Sports', color: Colors.green),
  ];

  static final List<Feed> _defaultMarketplaceFeeds = [
    // Tech & Engineering
    Feed(
      url: 'https://techcrunch.com/feed/',
      title: 'TechCrunch',
      description: 'Startups, products, and Silicon Valley news.',
      category: 'tech',
    ),
    Feed(
      url: 'https://www.theverge.com/rss/index.xml',
      title: 'The Verge',
      description: 'Technology, gadgets, culture, and science reporting.',
      category: 'tech',
    ),
    Feed(
      url: 'https://github.blog/category/engineering/feed/',
      title: 'GitHub Engineering',
      description: 'Deep dives into the systems behind GitHub.',
      category: 'tech',
    ),
    Feed(
      url: 'https://devblogs.microsoft.com/feed/',
      title: 'Microsoft DevBlogs',
      description: 'Updates from Microsoft product and platform teams.',
      category: 'tech',
    ),
    Feed(
      url: 'https://aws.amazon.com/blogs/aws/feed/',
      title: 'AWS News Blog',
      description: 'New AWS launches, services, and architecture tips.',
      category: 'tech',
    ),
    // AI & Data
    Feed(
      url: 'https://openai.com/blog/rss',
      title: 'OpenAI Blog',
      description: 'Research, product updates, and policy notes on AI.',
      category: 'ai',
    ),
    Feed(
      url: 'https://blog.research.google/feed?format=xml',
      title: 'Google AI Blog',
      description: 'Research and applied AI from Google teams.',
      category: 'ai',
    ),
    Feed(
      url: 'https://ai.facebook.com/blog/rss/',
      title: 'Meta AI',
      description: 'Research breakthroughs and open-source releases.',
      category: 'ai',
    ),
    Feed(
      url: 'https://huggingface.co/blog/feed.xml',
      title: 'Hugging Face Blog',
      description: 'Open models, tooling, and community highlights.',
      category: 'ai',
    ),
    Feed(
      url: 'https://thegradient.pub/rss/',
      title: 'The Gradient',
      description: 'Long-form essays and interviews on machine learning.',
      category: 'ai',
    ),
    // Design & UX
    Feed(
      url: 'https://www.smashingmagazine.com/feed/',
      title: 'Smashing Magazine',
      description: 'UX, UI, frontend, and accessibility best practices.',
      category: 'design',
    ),
    Feed(
      url: 'https://uxdesign.cc/feed',
      title: 'UX Collective',
      description: 'Practical design stories and case studies.',
      category: 'design',
    ),
    Feed(
      url: 'https://www.nngroup.com/articles/rss/',
      title: 'Nielsen Norman Group',
      description: 'Evidence-based UX research and guidance.',
      category: 'design',
    ),
    Feed(
      url: 'https://sidebar.io/feed.xml',
      title: 'Sidebar Design',
      description: 'Daily design inspiration and curated links.',
      category: 'design',
    ),
    Feed(
      url: 'https://alistapart.com/main/feed/',
      title: 'A List Apart',
      description: 'Design and development for the web.',
      category: 'design',
    ),
    // Business & Startups
    Feed(
      url: 'https://www.ycombinator.com/blog/rss',
      title: 'Y Combinator Blog',
      description: 'Founder stories, advice, and YC updates.',
      category: 'business',
    ),
    Feed(
      url: 'https://a16z.com/feed/',
      title: 'a16z',
      description: 'Technology investing, market analysis, and essays.',
      category: 'business',
    ),
    Feed(
      url: 'https://review.firstround.com/feed',
      title: 'First Round Review',
      description: 'Tactical guides for building companies.',
      category: 'business',
    ),
    Feed(
      url: 'https://www.saastr.com/feed/',
      title: 'SaaStr',
      description: 'Scaling SaaS companies, revenue, and GTM playbooks.',
      category: 'business',
    ),
    Feed(
      url: 'https://stratechery.com/feed/',
      title: 'Stratechery',
      description: 'Strategic analysis of tech and media (mix of free posts).',
      category: 'business',
    ),
    // News & World
    Feed(
      url: 'http://feeds.bbci.co.uk/news/rss.xml',
      title: 'BBC News',
      description: 'Global headlines and breaking news.',
      category: 'news',
    ),
    Feed(
      url: 'https://www.theguardian.com/world/rss',
      title: 'The Guardian World',
      description: 'International reporting and analysis.',
      category: 'news',
    ),
    Feed(
      url: 'https://rss.cnn.com/rss/cnn_topstories.rss',
      title: 'CNN Top Stories',
      description: 'Top U.S. and world news stories.',
      category: 'news',
    ),
    Feed(
      url: 'https://feeds.npr.org/1001/rss.xml',
      title: 'NPR News',
      description: 'In-depth U.S. news and features.',
      category: 'news',
    ),
    Feed(
      url: 'https://feeds.apnews.com/apf-topnews',
      title: 'Associated Press',
      description: 'AP wire for fast breaking coverage.',
      category: 'news',
    ),
    // Science & Space
    Feed(
      url: 'https://www.nasa.gov/rss/dyn/breaking_news.rss',
      title: 'NASA Breaking News',
      description: 'Agency updates, missions, and space science.',
      category: 'science',
    ),
    Feed(
      url: 'https://www.sciencedaily.com/rss/top/science.xml',
      title: 'ScienceDaily',
      description: 'Daily science research highlights.',
      category: 'science',
    ),
    Feed(
      url: 'https://www.quantamagazine.org/feed/',
      title: 'Quanta Magazine',
      description: 'Deep stories on math, physics, and computing.',
      category: 'science',
    ),
    Feed(
      url: 'https://feeds.arstechnica.com/arstechnica/science',
      title: 'Ars Technica Science',
      description: 'Science and space reporting from Ars.',
      category: 'science',
    ),
    Feed(
      url: 'https://www.newscientist.com/feed/home/',
      title: 'New Scientist',
      description: 'Discoveries, research, and human biology.',
      category: 'science',
    ),
    // Security
    Feed(
      url: 'https://krebsonsecurity.com/feed/',
      title: 'Krebs on Security',
      description: 'Cybercrime investigations and threat intel.',
      category: 'security',
    ),
    Feed(
      url: 'https://feeds.feedburner.com/TheHackersNews',
      title: 'The Hacker News',
      description: 'Latest security incidents and advisories.',
      category: 'security',
    ),
    Feed(
      url: 'https://www.schneier.com/feed/atom/',
      title: 'Schneier on Security',
      description: 'Security policy, cryptography, and commentary.',
      category: 'security',
    ),
    Feed(
      url: 'https://www.cisa.gov/uscert/ncas/alerts.xml',
      title: 'CISA Alerts',
      description: 'U.S. cyber defense alerts and advisories.',
      category: 'security',
    ),
    Feed(
      url: 'https://www.microsoft.com/en-us/security/blog/feed/',
      title: 'Microsoft Security Blog',
      description: 'Enterprise security guidance and incident reports.',
      category: 'security',
    ),
    // Sports
    Feed(
      url: 'http://www.espn.com/espn/rss/news',
      title: 'ESPN Headlines',
      description: 'Top sports headlines across leagues.',
      category: 'sports',
    ),
    Feed(
      url: 'https://feeds.bbci.co.uk/sport/rss.xml?edition=us',
      title: 'BBC Sport',
      description: 'U.K. and world sports coverage.',
      category: 'sports',
    ),
    Feed(
      url: 'https://www.cbssports.com/rss/headlines/',
      title: 'CBS Sports',
      description: 'Scores, highlights, and breaking news.',
      category: 'sports',
    ),
    Feed(
      url: 'https://www.si.com/.rss/full/',
      title: 'Sports Illustrated',
      description: 'Features and analysis across major sports.',
      category: 'sports',
    ),
    Feed(
      url: 'https://rss.nytimes.com/services/xml/rss/nyt/Sports.xml',
      title: 'NYTimes Sports',
      description: 'Reporting and commentary on sports and athletes.',
      category: 'sports',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCuratedFeeds();
  }

  Future<void> _loadCuratedFeeds() async {
    final feeds = _defaultMarketplaceFeeds;

    setState(() {
      _feedsByCategory =
          _groupBy(feeds, (feed) => feed.category ?? 'Uncategorized');
      _isLoading = false;
    });
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
            const Text('Marketplace'),
            Text(
              'Curated RSS links by category',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
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
                  'Discover quality feeds fast',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Browse trusted sources by topic. Tap follow to add them to your home feed instantly.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s12,
                  children: [
                    _statPill(
                        context, Icons.category, '${_feedsByCategory.length} categories'),
                    _statPill(context, Icons.rss_feed, '$totalFeeds feeds'),
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

  Widget _buildCategoryFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          ..._categories.map((meta) {
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
    final visibleCategories = _feedsByCategory.entries.where((entry) {
      if (_selectedCategory == null) return true;
      return entry.key == _selectedCategory;
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return visibleCategories.map((entry) {
      final meta = _categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () =>
            _CategoryMeta(id: entry.key, label: entry.key, color: Colors.blue),
      );
      final feeds = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: meta.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconFor(meta.id),
                      color: meta.color,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${feeds.length} curated sources',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            ...feeds.map((feed) => _buildFeedTile(feed, meta.color)).toList(),
            const SizedBox(height: AppSpacing.s16),
          ],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.rss_feed, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                feed.title ?? 'Untitled feed',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _labelFor(feed.category),
                                style: TextStyle(
                                  color: accent.darken(),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        if (feed.description != null &&
                            feed.description!.isNotEmpty)
                          Text(
                            feed.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
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
                  const SizedBox(width: AppSpacing.s12),
                  ElevatedButton(
                    onPressed: isSubscribed
                        ? null
                        : () async {
                            try {
                              await appState.addFeedFromUrl(feed.url);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Subscribed to ${feed.title ?? 'feed'}'),
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to subscribe: $e')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSubscribed ? colorScheme.surface : accent,
                      foregroundColor:
                          isSubscribed ? colorScheme.onSurface : Colors.white,
                      side: BorderSide(color: accent.withOpacity(0.4)),
                    ),
                    child: Text(isSubscribed ? 'Subscribed' : 'Follow'),
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
    switch (id) {
      case 'tech':
        return Icons.memory_rounded;
      case 'ai':
        return Icons.smart_toy_outlined;
      case 'design':
        return Icons.palette_outlined;
      case 'business':
        return Icons.trending_up;
      case 'news':
        return Icons.public;
      case 'science':
        return Icons.science_outlined;
      case 'security':
        return Icons.shield_outlined;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.rss_feed;
    }
  }

  String _labelFor(String? id) {
    return _categories.firstWhere(
          (c) => c.id == id,
          orElse: () => _CategoryMeta(
            id: id ?? 'feed',
            label: id ?? 'feed',
            color: Colors.blue,
          ),
        ).label;
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
