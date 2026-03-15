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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Account',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Subscriptions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.subscriptions),
                title: const Text('Manage Subscriptions'),
                subtitle: const Text('Add or remove the feeds you follow'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SubscriptionsScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Import Subscriptions'),
                subtitle: const Text('Import via OPML file'),
                onTap: () {
                  // TODO: OPML import
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export Subscriptions'),
                subtitle: const Text('Export your feeds to OPML'),
                onTap: () {
                  // TODO: OPML export
                },
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Themes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Themes'),
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
            ],
          );
        },
      ),
    );
  }
}
