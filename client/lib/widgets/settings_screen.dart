import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/app_state.dart';
import '../screens/login_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../services/opml_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final OpmlService _opml = OpmlService();
  List<Map<String, String>> _voices = [];
  bool _loadingVoices = false;
  static const List<String> _coolVoiceNames = [
    'Aurora',
    'Echo',
    'Zephyr',
    'Nimbus',
    'Drift',
    'Lumen',
    'Harbor',
    'Orbit',
    'Pulse',
    'Sierra',
    'Nova',
    'Atlas',
    'Canyon',
    'Glacier',
    'Solaris',
    'Prism',
    'Quartz',
    'Voyage',
    'Summit',
    'Mesa',
  ];

  String _coolVoiceLabel(Map<String, String> voice, int index) {
    final cool = _coolVoiceNames[index % _coolVoiceNames.length];
    final locale = voice['locale'];
    final origin = voice['name'] ?? 'Voice';
    final localeText =
        (locale != null && locale.isNotEmpty) ? locale : 'global';
    return '$cool - $origin ($localeText)';
  }

  List<Map<String, String>> _pickTopVoices(List<Map<String, String>> voices) {
    // Prefer a small set of common English locales; fall back to any first five.
    const preferredLocales = ['en-US', 'en-GB', 'en-IN', 'en-AU', 'en-CA'];
    final selected = <Map<String, String>>[];

    for (final loc in preferredLocales) {
      final match = voices.firstWhere(
        (v) => (v['locale'] ?? '').startsWith(loc),
        orElse: () => {},
      );
      if (match.isNotEmpty && !selected.contains(match)) {
        selected.add(match);
      }
      if (selected.length >= 5) break;
    }

    for (final v in voices) {
      if (selected.length >= 5) break;
      if (!selected.contains(v)) selected.add(v);
    }

    return selected.take(5).toList();
  }

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
          _voices = _pickTopVoices(mapped);
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

  Future<void> _importSubscriptions() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['opml', 'xml'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    try {
      final content = file.bytes != null
          ? utf8.decode(file.bytes!)
          : await File(file.path!).readAsString();

      final urls = _opml.extractFeedUrls(content);
      if (urls.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No feeds found in OPML')),
        );
        return;
      }

      final appState = context.read<AppState>();
      var added = 0;
      for (final url in urls) {
        final already = appState.feeds.any((f) => f.url == url);
        if (already) continue;
        try {
          await appState.addFeedFromUrl(url);
          added++;
        } catch (err) {
          debugPrint('Failed to import $url: $err');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added > 0
                ? 'Imported $added feed${added == 1 ? '' : 's'}'
                : 'All feeds were already added',
          ),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $err')),
      );
    }
  }

  Future<void> _exportSubscriptions() async {
    final appState = context.read<AppState>();
    final feeds = appState.feeds;
    if (feeds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subscriptions to export')),
      );
      return;
    }

    try {
      final opmlContent = _opml.buildOpml(feeds);
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/aware-subscriptions-${DateTime.now().millisecondsSinceEpoch}.opml';
      final file = File(filePath);
      await file.writeAsString(opmlContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Aware subscriptions export',
        subject: 'Aware subscriptions export',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${feeds.length} feed(s)')),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $err')),
      );
    }
  }

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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Advanced',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_motion),
                title: const Text('Read tracking'),
                subtitle: const Text(
                    'Auto-mark articles as read based on reading progress'),
              ),
              SwitchListTile(
                title: const Text('Auto-mark read by progress'),
                subtitle: const Text(
                    'Marks as read when scroll or audio reaches your threshold'),
                value: context
                    .select<AppState, bool>((s) => s.autoMarkReadEnabled),
                onChanged: (value) =>
                    context.read<AppState>().setAutoMarkReadEnabled(value),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Auto-mark threshold'),
                subtitle: Consumer<AppState>(
                  builder: (context, appState, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        min: 10,
                        max: 100,
                        divisions: 18,
                        value: appState.autoMarkReadThreshold.toDouble(),
                        label: '${appState.autoMarkReadThreshold}%',
                        onChanged: appState.autoMarkReadEnabled
                            ? (value) => context
                                .read<AppState>()
                                .setAutoMarkReadThreshold(value.round())
                            : null,
                      ),
                      Text(
                        '${appState.autoMarkReadThreshold}% progress needed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
                        min: AppState.speechRateMinRatio,
                        max: AppState.speechRateMaxRatio,
                        divisions: ((AppState.speechRateMaxRatio -
                                    AppState.speechRateMinRatio) /
                                0.1)
                            .round(),
                        label: '${appState.speechRate.toStringAsFixed(1)}x',
                        onChanged: (value) =>
                            context.read<AppState>().setSpeechRate(value),
                      ),
                      Text(
                        '${appState.speechRate.toStringAsFixed(1)}x (1x = calm default)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('Default voice', style: TextStyle(fontSize: 14)),
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                            value: current != null &&
                                    _voices.any((v) => _voiceKey(v) == current)
                                ? current
                                : null,
                            hint: const Text('System default'),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('System default'),
                              ),
                              ..._voices.asMap().entries.map(
                                    (entry) => DropdownMenuItem<String?>(
                                      value: _voiceKey(entry.value),
                                      child: Text(
                                        _coolVoiceLabel(entry.value, entry.key),
                                      ),
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
                subtitle: const Text(
                    'When narration finishes, move to the next item'),
                value: context.select<AppState, bool>((s) => s.autoPlayNext),
                onChanged: (value) =>
                    context.read<AppState>().setAutoPlayNext(value),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Data',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: const Text('Low-data mode prefetch'),
                subtitle: const Text(
                    'Prefetch article text in background and prefer cached content when available'),
                value: context.select<AppState, bool>((s) => s.lowDataMode),
                onChanged: (value) =>
                    context.read<AppState>().setLowDataMode(value),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Accessibility',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text size'),
                subtitle: Consumer<AppState>(
                  builder: (context, appState, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        min: AppState.textScaleMin,
                        max: AppState.textScaleMax,
                        divisions:
                            ((AppState.textScaleMax - AppState.textScaleMin) /
                                    0.05)
                                .round(),
                        value: appState.textScaleFactor,
                        label: '${(appState.textScaleFactor * 100).round()}%',
                        onChanged: (value) =>
                            context.read<AppState>().setTextScaleFactor(value),
                      ),
                      Text(
                        'Applies across the app, including articles and navigation.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The quick brown fox jumps over the lazy dog.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
                onTap: _importSubscriptions,
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export Subscriptions'),
                subtitle: const Text('Export your feeds to OPML'),
                onTap: _exportSubscriptions,
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
