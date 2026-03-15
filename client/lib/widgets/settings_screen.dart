import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/login_screen.dart';
import '../screens/subscriptions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Map<String, String>> _voices = [];
  bool _loadingVoices = false;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadVoices() async {
    setState(() => _loadingVoices = true);
    try {
      final data = await _flutterTts.getVoices;
      // Some platforms return List<dynamic> with maps.
      final mapped = (data as List)
          .whereType<Map>()
          .map((v) => {
                'name': '${v['name'] ?? v['voice'] ?? ''}',
                'locale': '${v['locale'] ?? ''}',
              })
          .where((v) => v['name']!.isNotEmpty)
          .toSet()
          .toList();
      mapped.sort((a, b) => a['name']!.compareTo(b['name']!));
      if (mounted) {
        setState(() {
          _voices = mapped;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loadingVoices = false);
      }
    }
  }

  String _voiceKey(Map<String, String> voice) =>
      '${voice['name']}|${voice['locale']}';

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
                  'Voice & Read aloud',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Default narration speed'),
                subtitle: Consumer<AppState>(
                  builder: (context, appState, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: appState.speechRate,
                        min: 0.5,
                        max: 1.5,
                        divisions: 10,
                        label: '${appState.speechRate.toStringAsFixed(2)}x',
                        onChanged: (value) =>
                            context.read<AppState>().setSpeechRate(value),
                      ),
                      Text('${appState.speechRate.toStringAsFixed(2)}x'),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('Default voice'),
                subtitle: _loadingVoices
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      )
                    : Consumer<AppState>(
                        builder: (context, appState, _) {
                          final current = appState.voiceId;
                          return DropdownButton<String?>(
                            isExpanded: true,
                            value: current != null &&
                                    _voices.any((v) =>
                                        _voiceKey(v) ==
                                        current)
                                ? current
                                : null,
                            hint: const Text('System default'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('System default'),
                              ),
                              ..._voices.map(
                                (voice) => DropdownMenuItem<String?>(
                                  value: _voiceKey(voice),
                                  child: Text(
                                      '${voice['name']} (${voice['locale']})'),
                                ),
                              ),
                            ],
                            onChanged: (value) async {
                              await context.read<AppState>().setVoiceId(value);
                            },
                          );
                        },
                      ),
              ),
              SwitchListTile(
                title: const Text('Auto-play next article'),
                subtitle:
                    const Text('When narration finishes, move to the next item'),
                value:
                    context.select<AppState, bool>((s) => s.autoPlayNext),
                onChanged: (value) =>
                    context.read<AppState>().setAutoPlayNext(value),
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
