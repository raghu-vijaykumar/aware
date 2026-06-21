import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyStyle = textTheme.bodyMedium?.copyWith(height: 1.6);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.privacyPolicyTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.privacyPolicyTitle,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.privacyPolicyLastUpdated,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.privacyInfoWeCollect,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.privacyInfoWeCollectBody,
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyThirdParty,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.privacyThirdPartyBody,
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
              AppLocalizations.of(context)!.privacyDataStorage,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.privacyDataStorageBody,
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.privacyContact,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.privacyContactBody,
              style: bodyStyle,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
