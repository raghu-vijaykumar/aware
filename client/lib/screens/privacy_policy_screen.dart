import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyStyle = textTheme.bodyMedium?.copyWith(height: 1.6);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: June 20, 2026',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Information We Collect',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aware does not collect, store, or transmit any personal data. '
              'All app data (feeds, articles, reading progress, preferences, '
              'and settings) is stored locally on your device and is never '
              'sent to any server.',
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text(
              'Third-Party Services',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aware uses Google AdMob to display advertisements. AdMob may '
              'collect non-personal usage data and device identifiers to serve '
              'relevant ads. Ads are served with non-personalized ad requests '
              'only. No user-level data is shared with advertisers.\n\n'
              'Google\'s Privacy Policy applies to data collected by AdMob:\n',
              style: bodyStyle,
            ),
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('https://policies.google.com/privacy'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                'https://policies.google.com/privacy',
                style: bodyStyle?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data Storage',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'All feed subscriptions, articles, reading progress, and app '
              'preferences are stored locally in a SQLite database on your '
              'device. You can export your data at any time via the OPML '
              'export feature in Settings.\n\n'
              'To delete all data, uninstall the app or clear app data '
              'from your device settings.',
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text(
              'Contact',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have questions about this privacy policy, please contact:\n'
              'aware@raghuv.com',
              style: bodyStyle,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
