import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Account'),
                subtitle: Text(appState.isLoggedIn
                    ? 'Signed in as ${appState.userEmail ?? 'unknown'}'
                    : 'Not signed in'),
                trailing: appState.isLoggedIn
                    ? TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          await appState.logout();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signed out')),
                          );
                        },
                      )
                    : TextButton(
                        child: const Text('Sign in'),
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ));
                        },
                      ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Light / Dark / System'),
                onTap: () {
                  // TODO: Theme selector
                },
              ),
              ListTile(
                title: const Text('Sync'),
                subtitle: const Text('Sync read/star state to server'),
                trailing: IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: appState.isLoggedIn
                      ? () async {
                          await appState.syncState();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sync completed')),
                          );
                        }
                      : null,
                ),
              ),
              ListTile(
                title: const Text('Import OPML'),
                onTap: () {
                  // TODO: OPML import
                },
              ),
              ListTile(
                title: const Text('Export OPML'),
                onTap: () {
                  // TODO: OPML export
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
