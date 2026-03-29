import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/feed_list.dart';
import '../widgets/settings_screen.dart';
import 'marketplace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _urlController = TextEditingController();
  bool _isAdding = false;

  static const List<Widget> _widgetOptions = <Widget>[
    FeedList(),
    MarketplaceScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadFeeds();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _promptAddFeed(BuildContext context) async {
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add RSS Feed'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/feed.xml',
              labelText: 'Feed URL',
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
            enabled: !_isAdding,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed:
                  _isAdding ? null : () => Navigator.of(context).pop(true),
              child: _isAdding
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        );
      },
    );

    if (shouldAdd == true) {
      setState(() => _isAdding = true);
      try {
        final url = _urlController.text.trim();
        if (url.isEmpty) throw 'Feed URL is required';
        await appState.addFeedFromUrl(url);
        if (!mounted) return;
        _urlController.clear();
        messenger.showSnackBar(
          const SnackBar(content: Text('Feed added')),
        );
      } catch (err) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Failed to add feed: $err')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isAdding = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Feeds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
