import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
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
      } catch (err) {
        if (!mounted) return;
        messenger
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToAddFeed('$err'))));
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
        return ArticleListScreen(
          allFeeds: true,
          feedTitle: AppLocalizations.of(context)!.tabFeeds,
          onAddFeed: () => _showAddFeedDialog(context),
        );
      },
    );
  }
}
