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

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Feed>> _feedsByCategory = {};
  Map<String, List<Feed>> _feedsByCurator = {};
  bool _isLoading = true;

  static final List<Feed> _defaultMarketplaceFeeds = [
    Feed(
        url: 'https://developers.googleblog.com/feeds/posts/default',
        title: 'Google Blog',
        category: 'tech',
        curator: 'Google'),
    Feed(
        url: 'https://research.google/blog/rss/',
        title: 'Google Research',
        category: 'tech',
        curator: 'Google Research'),
    Feed(
        url: 'https://engineering.fb.com/feed/',
        title: 'Meta Engineering',
        category: 'tech',
        curator: 'Meta'),
    Feed(
        url: 'https://medium.com/feed/airbnb-engineering',
        title: 'Airbnb Engineering',
        category: 'tech',
        curator: 'Airbnb'),
    Feed(
        url: 'https://engineering.linkedin.com/blog.rss.html',
        title: 'LinkedIn Engineering',
        category: 'tech',
        curator: 'LinkedIn'),
    Feed(
        url: 'https://engineering.atspotify.com/feed/',
        title: 'Spotify Engineering',
        category: 'tech',
        curator: 'Spotify'),
    Feed(
        url: 'https://dropbox.tech/feed',
        title: 'Dropbox Tech',
        category: 'tech',
        curator: 'Dropbox'),
    Feed(
        url: 'https://slack.engineering/feed',
        title: 'Slack Engineering',
        category: 'tech',
        curator: 'Slack'),
    Feed(
        url: 'https://medium.com/feed/pinterest-engineering',
        title: 'Pinterest Engineering',
        category: 'tech',
        curator: 'Pinterest'),
    Feed(
        url: 'https://devblogs.microsoft.com/feed/',
        title: 'Microsoft DevBlogs',
        category: 'tech',
        curator: 'Microsoft'),
    Feed(
        url: 'https://aws.amazon.com/blogs/aws/feed/',
        title: 'AWS Blog',
        category: 'tech',
        curator: 'AWS'),
    Feed(
        url: 'https://github.blog/category/engineering/feed/',
        title: 'GitHub Engineering',
        category: 'tech',
        curator: 'GitHub'),
    Feed(
        url: 'https://blog.cloudflare.com/rss/',
        title: 'Cloudflare Blog',
        category: 'tech',
        curator: 'Cloudflare'),
    Feed(
        url: 'https://www.databricks.com/feed',
        title: 'Databricks Blog',
        category: 'tech',
        curator: 'Databricks'),
    Feed(
        url: 'https://www.atlassian.com/blog/artificial-intelligence/feed',
        title: 'Atlassian AI Blog',
        category: 'tech',
        curator: 'Atlassian'),
    Feed(
        url: 'https://discord.com/blog/rss.xml',
        title: 'Discord Blog',
        category: 'tech',
        curator: 'Discord'),
    Feed(
        url: 'https://www.canva.dev/blog/engineering/feed',
        title: 'Canva Engineering',
        category: 'tech',
        curator: 'Canva'),
    Feed(
        url: 'https://doordash.engineering/feed/',
        title: 'DoorDash Engineering',
        category: 'tech',
        curator: 'DoorDash'),
    Feed(
        url: 'https://engineering.grab.com/feed',
        title: 'Grab Engineering',
        category: 'tech',
        curator: 'Grab'),
    Feed(
        url: 'https://about.gitlab.com/atom.xml',
        title: 'GitLab Blog',
        category: 'tech',
        curator: 'GitLab'),
    Feed(
        url: 'https://www.heroku.com/blog/feed/',
        title: 'Heroku Blog',
        category: 'tech',
        curator: 'Heroku'),
    Feed(
        url: 'https://medium.com/feed/adobetech',
        title: 'Adobe Tech',
        category: 'tech',
        curator: 'Adobe'),
    Feed(
        url: 'https://engineering.salesforce.com/feed/',
        title: 'Salesforce Engineering',
        category: 'tech',
        curator: 'Salesforce'),
    Feed(
        url: 'https://dropbox.tech/security/feed',
        title: 'Dropbox Security',
        category: 'tech',
        curator: 'Dropbox'),
    Feed(
        url: 'https://developer.squareup.com/blog/rss.xml',
        title: 'Square Developer',
        category: 'tech',
        curator: 'Square'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCuratedFeeds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCuratedFeeds() async {
    final feeds = _defaultMarketplaceFeeds;

    setState(() {
      _feedsByCategory =
          _groupBy(feeds, (feed) => feed.category ?? 'Uncategorized');
      _feedsByCurator = _groupBy(feeds, (feed) => feed.curator ?? 'Unknown');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Category'),
            Tab(text: 'By People'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryView(),
                _buildCuratorView(),
              ],
            ),
    );
  }

  Widget _buildCategoryView() {
    return ListView(
      children: _feedsByCategory.entries.map((entry) {
        return ExpansionTile(
          title: Text('${entry.key} (${entry.value.length})'),
          children: entry.value.map((feed) => _buildFeedTile(feed)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildCuratorView() {
    return ListView(
      children: _feedsByCurator.entries.map((entry) {
        return ExpansionTile(
          title: Text('${entry.key} (${entry.value.length})'),
          children: entry.value.map((feed) => _buildFeedTile(feed)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildFeedTile(Feed feed) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isSubscribed = appState.feeds.any((f) => f.url == feed.url);
        final messenger = ScaffoldMessenger.of(context);

        return Card(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          child: ListTile(
            leading: feed.iconUrl != null
                ? Image.network(feed.iconUrl!, width: 40, height: 40)
                : const Icon(Icons.rss_feed, size: 40),
            title: Text(feed.title ?? 'Untitled Feed'),
            subtitle: Text(feed.description ?? ''),
            trailing: ElevatedButton(
              onPressed: isSubscribed
                  ? null
                  : () async {
                      try {
                        await appState.addFeedFromUrl(feed.url);
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Subscribed to ${feed.title ?? 'feed'}')),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to subscribe: $e')),
                        );
                      }
                    },
              child: Text(isSubscribed ? 'Subscribed' : 'Follow'),
            ),
          ),
        );
      },
    );
  }
}
