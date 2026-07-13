import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../providers/app_state.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../services/opml_service.dart';
import '../theme/theme.dart';
import '../l10n/app_localizations.dart';

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
    final result = await FilePicker.pickFiles(
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
          SnackBar(content: Text(AppLocalizations.of(context)!.noFeedsFoundOpml)),
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
                ? AppLocalizations.of(context)!.importedCount(added)
                : AppLocalizations.of(context)!.allFeedsAlreadyAdded,
          ),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.importFailed('$err'))),
      );
    }
  }

  Future<void> _exportSubscriptions() async {
    final appState = context.read<AppState>();
    final feeds = appState.feeds;
    if (feeds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noSubscriptionsToExport)),
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

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: AppLocalizations.of(context)!.exportShareText,
        subject: AppLocalizations.of(context)!.exportShareSubject,
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.exportedCount('${feeds.length}'))),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed('$err'))),
      );
    }
  }

  Widget _buildPremiumCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPremiumDialog(context, appState),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.goAdFree,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.goAdFreeSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.pricePerMonth,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPremiumDialog(
      BuildContext context, AppState appState) async {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.premiumTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.premiumSubscribeDesc,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _featureRow(Icons.videocam_off, AppLocalizations.of(context)!.premiumRemoveAds),
              const SizedBox(height: 12),
              _featureRow(Icons.cloud, AppLocalizations.of(context)!.premiumCloudStorage),
              const SizedBox(height: 12),
              _featureRow(Icons.bookmark, AppLocalizations.of(context)!.premiumCloudSubscriptions),
              const SizedBox(height: 12),
              _featureRow(Icons.sync, AppLocalizations.of(context)!.premiumSync),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.comingSoon,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.notNow),
            ),
          ],
        );
      },
    );
  }

  Widget _featureRow(IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            children: [
              _buildPremiumCard(context, appState),
              const SizedBox(height: AppSpacing.s8),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.sectionAdvanced,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_motion),
                title: Text(AppLocalizations.of(context)!.readTracking),
                subtitle: Text(
                    AppLocalizations.of(context)!.readTrackingSubtitle),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.autoMarkRead),
                subtitle: Text(
                    AppLocalizations.of(context)!.autoMarkReadSubtitle),
                value: context
                    .select<AppState, bool>((s) => s.autoMarkReadEnabled),
                onChanged: (value) =>
                    context.read<AppState>().setAutoMarkReadEnabled(value),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: Text(AppLocalizations.of(context)!.autoMarkThreshold),
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
                        AppLocalizations.of(context)!.progressNeeded('${appState.autoMarkReadThreshold}'),
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
                  AppLocalizations.of(context)!.sectionVoice,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: Text(AppLocalizations.of(context)!.narrationSpeed),
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
                        AppLocalizations.of(context)!.speedLabel(appState.speechRate.toStringAsFixed(1)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: Text(AppLocalizations.of(context)!.defaultVoice, style: TextStyle(fontSize: 14)),
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
                            hint: Text(AppLocalizations.of(context)!.systemDefault),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(AppLocalizations.of(context)!.systemDefault),
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
                title: Text(AppLocalizations.of(context)!.autoPlayNext),
                subtitle: Text(
                    AppLocalizations.of(context)!.autoPlayNextSubtitle),
                value: context.select<AppState, bool>((s) => s.autoPlayNext),
                onChanged: (value) =>
                    context.read<AppState>().setAutoPlayNext(value),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.sectionAccessibility,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: Text(AppLocalizations.of(context)!.textSize),
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
                        AppLocalizations.of(context)!.textSizeSubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.sampleText,
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
                  AppLocalizations.of(context)!.sectionSubscriptions,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.subscriptions),
                title: Text(AppLocalizations.of(context)!.manageSubscriptions),
                subtitle: Text(AppLocalizations.of(context)!.manageSubscriptionsSubtitle),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SubscriptionsScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: Text(AppLocalizations.of(context)!.importSubscriptions),
                subtitle: Text(AppLocalizations.of(context)!.importSubscriptionsSubtitle),
                onTap: _importSubscriptions,
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: Text(AppLocalizations.of(context)!.exportSubscriptions),
                subtitle: Text(AppLocalizations.of(context)!.exportSubscriptionsSubtitle),
                onTap: _exportSubscriptions,
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.sectionThemes,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.themes),
                subtitle: Text(AppLocalizations.of(context)!.themesSubtitle),
                onTap: () async {
                  final selected = await showDialog<ThemeMode>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.selectTheme),
                        content: Consumer<AppState>(
                          builder: (context, appState, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<ThemeMode>(
                                  value: ThemeMode.system,
                                  groupValue: appState.themeMode,
                                  title: Text(AppLocalizations.of(context)!.system),
                                  onChanged: (mode) {
                                    if (mode != null) {
                                      Navigator.of(context).pop(mode);
                                    }
                                  },
                                ),
                                RadioListTile<ThemeMode>(
                                  value: ThemeMode.light,
                                  groupValue: appState.themeMode,
                                  title: Text(AppLocalizations.of(context)!.light),
                                  onChanged: (mode) {
                                    if (mode != null) {
                                      Navigator.of(context).pop(mode);
                                    }
                                  },
                                ),
                                RadioListTile<ThemeMode>(
                                  value: ThemeMode.dark,
                                  groupValue: appState.themeMode,
                                  title: Text(AppLocalizations.of(context)!.dark),
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
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.sectionLanguage,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.language),
                subtitle: Text(AppLocalizations.of(context)!.languageSubtitle),
                onTap: () async {
                  final selected = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.selectLanguage),
                        content: Consumer<AppState>(
                          builder: (context, appState, child) {
                            final currentCode =
                                appState.locale?.languageCode ?? 'en';
                            const localeLabels = <String, String>{
                              'en': 'English',
                              'zh': '中文',
                              'es': 'Español',
                              'hi': 'हिन्दी',
                              'ar': 'العربية',
                              'fr': 'Français',
                              'pt': 'Português',
                              'ru': 'Русский',
                              'ja': '日本語',
                              'de': 'Deutsch',
                              'ko': '한국어',
                              'it': 'Italiano',
                            };
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: localeLabels.entries.map((entry) {
                                return RadioListTile<String>(
                                  value: entry.key,
                                  groupValue: currentCode,
                                  title: Text(entry.value),
                                  onChanged: (code) {
                                    if (code != null) {
                                      Navigator.of(context).pop(code);
                                    }
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      );
                    },
                  );

                  if (selected != null) {
                    await context.read<AppState>().setLocale(selected);
                  }
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.sectionLegal,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: Text(AppLocalizations.of(context)!.privacyPolicy),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(AppLocalizations.of(context)!.openSourceLicenses),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Aware',
                  applicationVersion: '1.0.0',
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Developer',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.red),
                title: const Text('Test Crash'),
                subtitle: const Text('Force a crash to verify Crashlytics'),
                onTap: () => FirebaseCrashlytics.instance.crash(),
              ),
            ],
          );
        },
      ),
    );
  }
}
