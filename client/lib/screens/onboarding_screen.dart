import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';

import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.language,
      color: Colors.blue,
    ),
    _OnboardingPage(
      icon: Icons.rss_feed,
      color: Colors.indigo,
    ),
    _OnboardingPage(
      icon: Icons.library_books,
      color: Colors.teal,
    ),
    _OnboardingPage(
      icon: Icons.notifications,
      color: Colors.deepPurple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _pageTitle(int index) {
    switch (index) {
      case 0: return AppLocalizations.of(context)!.onboardingLanguageTitle;
      case 1: return AppLocalizations.of(context)!.onboardingWelcomeTitle;
      case 2: return AppLocalizations.of(context)!.onboardingOfflineTitle;
      case 3: return AppLocalizations.of(context)!.onboardingNotifyTitle;
      default: return '';
    }
  }

  String _pageDesc(int index) {
    switch (index) {
      case 0: return AppLocalizations.of(context)!.onboardingLanguageDesc;
      case 1: return AppLocalizations.of(context)!.onboardingWelcomeDesc;
      case 2: return AppLocalizations.of(context)!.onboardingOfflineDesc;
      case 3: return AppLocalizations.of(context)!.onboardingNotifyDesc;
      default: return '';
    }
  }

  Future<void> _completeOnboarding() async {
    final storage = await StorageService.getInstance();
    await storage.write('onboarding_complete', 'true');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(page.icon, size: 72, color: page.color),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _pageTitle(index),
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pageDesc(index),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        if (index == 0) ...[
                          const SizedBox(height: 32),
                          Consumer<AppState>(
                            builder: (context, appState, child) {
                              final currentCode =
                                  appState.locale?.languageCode ?? 'en';
                              final localeLabels = <String, String Function(AppLocalizations)>{
                                'en': (l) => l.languageEnglish,
                                'zh': (l) => l.languageChinese,
                                'es': (l) => l.languageSpanish,
                                'hi': (l) => l.languageHindi,
                                'ar': (l) => l.languageArabic,
                                'fr': (l) => l.languageFrench,
                                'pt': (l) => l.languagePortuguese,
                                'ru': (l) => l.languageRussian,
                                'ja': (l) => l.languageJapanese,
                                'de': (l) => l.languageGerman,
                                'ko': (l) => l.languageKorean,
                                'it': (l) => l.languageItalian,
                              };
                              final l10n = AppLocalizations.of(context)!;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButton<String>(
                                  value: currentCode,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: localeLabels.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value(l10n)),
                                    );
                                  }).toList(),
                                  onChanged: (code) {
                                    if (code != null) {
                                      appState.setLocale(code);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.3),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.getStarted,
                  ),
                ),
              ),
            ),
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  AppLocalizations.of(context)!.skip,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              const SizedBox(height: 48),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.color,
  });
}
