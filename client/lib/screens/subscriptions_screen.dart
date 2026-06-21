import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/theme.dart';
import '../l10n/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context)!.subscriptionsTitle),
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
            return Center(
              child: Text(AppLocalizations.of(context)!.subscriptionsEmpty),
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
                  title: Text(feed.title ?? AppLocalizations.of(context)!.untitledFeed),
                  subtitle: feed.paused
                      ? Text(AppLocalizations.of(context)!.paused,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor))
                      : null,
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
                              title: Text(AppLocalizations.of(context)!.unsubscribeTitle),
                              content: Text(
                                  AppLocalizations.of(context)!.unsubscribeConfirm(feed.title ?? 'this feed')),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(AppLocalizations.of(context)!.unsubscribe),
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
                        child: Text(feed.paused ? AppLocalizations.of(context)!.resume : AppLocalizations.of(context)!.pause),
                      ),
                      PopupMenuItem(
                        value: 'unsubscribe',
                        child: Text(AppLocalizations.of(context)!.unsubscribe),
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
