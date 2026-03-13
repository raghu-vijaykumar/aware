import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/article_list_screen.dart';

class FeedList extends StatefulWidget {
  const FeedList({super.key});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  final _urlController = TextEditingController();
  bool _isAdding = false;

  Future<void> _showAddFeedDialog(BuildContext context) async {
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Feed'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(hintText: 'Enter feed URL'),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
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
      } catch (err) {
        if (!mounted) return;
        messenger
            .showSnackBar(SnackBar(content: Text('Failed to add feed: $err')));
      } finally {
        if (mounted) {
          setState(() => _isAdding = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Feeds'),
          ),
          body: RefreshIndicator(
            onRefresh: appState.loadFeeds,
            child: ListView.builder(
              itemCount: appState.feeds.length,
              itemBuilder: (context, index) {
                final feed = appState.feeds[index];
                return ListTile(
                  leading: feed.iconUrl != null
                      ? Image.network(feed.iconUrl!, width: 40, height: 40)
                      : const Icon(Icons.rss_feed),
                  title: Text(feed.title ?? 'Untitled Feed'),
                  subtitle: Text(feed.description ?? ''),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ArticleListScreen(
                        feedId: feed.id ?? 0,
                        feedTitle: feed.title ?? 'Feed',
                      ),
                    ));
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _isAdding ? null : () => _showAddFeedDialog(context),
            child: _isAdding
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
