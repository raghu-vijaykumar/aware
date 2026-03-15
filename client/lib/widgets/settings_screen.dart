import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/login_screen.dart';
import '../screens/subscriptions_screen.dart';

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
                leading: const Icon(Icons.subscriptions),
                title: const Text('Subscriptions'),
                subtitle: const Text('Manage the feeds you follow'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SubscriptionsScreen(),
                  ));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Light / Dark / System'),
                onTap: () async {
                  final selected = await showDialog<ThemeMode>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select Theme'),
                        content: Consumer<AppState>(
                          builder: (context, appState, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<ThemeMode>(
                                  value: ThemeMode.system,
                                  groupValue: appState.themeMode,
                                  title: const Text('System'),
                                  onChanged: (mode) {
                                    if (mode != null) {
                                      Navigator.of(context).pop(mode);
                                    }
                                  },
                                ),
                                RadioListTile<ThemeMode>(
                                  value: ThemeMode.light,
                                  groupValue: appState.themeMode,
                                  title: const Text('Light'),
                                  onChanged: (mode) {
                                    if (mode != null) {
                                      Navigator.of(context).pop(mode);
                                    }
                                  },
                                ),
                                RadioListTile<ThemeMode>(
                                  value: ThemeMode.dark,
                                  groupValue: appState.themeMode,
                                  title: const Text('Dark'),
                                  onChanged: (mode) {
                                    if (mode != null) {
                                      Navigator.of(context).pop(mode);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );

                  if (selected != null) {
                    await context.read<AppState>().setThemeMode(selected);
                  }
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
