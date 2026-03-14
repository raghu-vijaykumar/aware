import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../services/database_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (!appState.isInitialized) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final feeds = appState.feeds;
          if (feeds.isEmpty) {
            return const Center(
              child:
                  Text('No subscriptions yet. Add feeds from the Marketplace!'),
            );
          }

          return ListView.builder(
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              final feed = feeds[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                child: ListTile(
                  leading: feed.iconUrl != null
                      ? Image.network(feed.iconUrl!, width: 40, height: 40)
                      : const Icon(Icons.rss_feed, size: 40),
                  title: Text(feed.title ?? 'Untitled Feed'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feed.description ?? ''),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        children: [
                          if (feed.category != null)
                            Chip(
                              label: Text(feed.category!),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (feed.curator != null)
                            Text('by ${feed.curator}',
                                style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'pause':
                          await _db.setFeedPaused(feed.id!, !feed.paused);
                          await appState.loadFeeds();
                          break;
                        case 'unsubscribe':
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Unsubscribe'),
                              content: Text(
                                  'Unsubscribe from ${feed.title ?? 'this feed'}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Unsubscribe'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _db.deleteFeed(feed.id!);
                            await appState.loadFeeds();
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pause',
                        child: Text(feed.paused ? 'Resume' : 'Pause'),
                      ),
                      const PopupMenuItem(
                        value: 'unsubscribe',
                        child: Text('Unsubscribe'),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Could navigate to feed details or articles
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
