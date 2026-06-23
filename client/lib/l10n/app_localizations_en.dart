// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Stay informed, effortlessly';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageDesc =>
      'Select your preferred language for the app interface.';

  @override
  String get onboardingWelcomeTitle => 'Welcome to aware';

  @override
  String get onboardingWelcomeDesc =>
      'Your personal feed reader. Stay informed about what matters, all in one place.';

  @override
  String get onboardingOfflineTitle => 'Read Offline';

  @override
  String get onboardingOfflineDesc =>
      'Feeds are downloaded so you can read anytime, anywhere. Listen with text-to-speech.';

  @override
  String get onboardingNotifyTitle => 'Never Miss a Post';

  @override
  String get onboardingNotifyDesc =>
      'Get notified when new articles arrive. Add your first feed to get started.';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get tabFeeds => 'Feeds';

  @override
  String get tabMarketplace => 'Marketplace';

  @override
  String get tabSettings => 'Settings';

  @override
  String get addFeedTitle => 'Add RSS Feed';

  @override
  String get addFeedUrlLabel => 'Feed URL';

  @override
  String get addFeedUrlHint => 'https://example.com/feed.xml';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get feedAdded => 'Feed added';

  @override
  String failedToAddFeed(Object error) {
    return 'Failed to add feed: $error';
  }

  @override
  String get feedUrlRequired => 'Feed URL is required';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get marketplaceSubtitle => 'Curated RSS links by category';

  @override
  String get marketplaceHeroTitle => 'Discover quality feeds fast';

  @override
  String get marketplaceHeroDesc =>
      'Browse trusted sources by topic. Tap follow to add them to your home feed instantly.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count categories';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count feeds';
  }

  @override
  String get marketplaceSearchHint => 'Search feeds...';

  @override
  String get marketplaceUntitledFeed => 'Untitled feed';

  @override
  String get marketplaceSubscribed => 'Subscribed';

  @override
  String get marketplaceFollow => 'Follow';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'Subscribed to $title';
  }

  @override
  String get marketplaceInvalidUrl => 'Invalid feed URL';

  @override
  String get marketplaceUnreachable =>
      'Failed to subscribe: feed may be unreachable';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count curated sources';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequired => 'Enter your email';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String get subscriptionsTitle => 'Subscriptions';

  @override
  String get subscriptionsEmpty =>
      'No subscriptions yet. Add feeds from the Marketplace!';

  @override
  String get untitledFeed => 'Untitled Feed';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get unsubscribeTitle => 'Unsubscribe';

  @override
  String unsubscribeConfirm(Object title) {
    return 'Unsubscribe from $title?';
  }

  @override
  String get foldersTitle => 'Folders';

  @override
  String get createFolderTitle => 'New Folder';

  @override
  String get folderNameHint => 'Folder name';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get renameFolderTitle => 'Rename Folder';

  @override
  String get delete => 'Delete';

  @override
  String get deleteFolderTitle => 'Delete Folder';

  @override
  String deleteFolderConfirm(Object name) {
    return 'Remove \"$name\" and ungroup its feeds?';
  }

  @override
  String get createFolderTooltip => 'Create Folder';

  @override
  String get noFoldersYet => 'No folders yet';

  @override
  String get createFirstFolder => 'Create your first folder';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count feed$_temp0';
  }

  @override
  String get filters => 'Filters';

  @override
  String get unread => 'Unread';

  @override
  String get liked => 'Liked';

  @override
  String get saved => 'Saved';

  @override
  String get last24h => 'Last 24h';

  @override
  String get last7d => 'Last 7d';

  @override
  String get last30d => 'Last 30d';

  @override
  String get engagement => 'Engagement';

  @override
  String get unreadOnly => 'Unread only';

  @override
  String get lengthPreview => 'Length / preview';

  @override
  String get any => 'Any';

  @override
  String get short => 'Short <100w';

  @override
  String get medium => 'Medium 100-300';

  @override
  String get long => 'Long >300';

  @override
  String get multiParagraph => '2+ paragraphs';

  @override
  String get timeWindow => 'Time window';

  @override
  String get all => 'All';

  @override
  String get sources => 'Sources';

  @override
  String get allSources => 'All sources';

  @override
  String get keyword => 'Keyword';

  @override
  String get keywordHint => 'Title, summary, or content';

  @override
  String get reset => 'Reset';

  @override
  String get done => 'Done';

  @override
  String get searchArticlesHint => 'Search articles...';

  @override
  String get retry => 'Retry';

  @override
  String get noArticlesYet => 'No articles yet. Pull to refresh.';

  @override
  String get noArticlesMatch => 'No articles match the current filters.';

  @override
  String get untitled => 'Untitled';

  @override
  String get removedLike => 'Removed like';

  @override
  String get likedArticle => 'Liked article';

  @override
  String get removedFromSaved => 'Removed from saved';

  @override
  String get savedForLater => 'Saved for later';

  @override
  String get markedUnread => 'Marked unread';

  @override
  String get markedRead => 'Marked read';

  @override
  String get undo => 'Undo';

  @override
  String get publishDateUnknown => 'Publish date unknown';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String weeksAgo(Object count) {
    return '${count}w ago';
  }

  @override
  String monthsAgo(Object count) {
    return '${count}mo ago';
  }

  @override
  String yearsAgo(Object count) {
    return '${count}y ago';
  }

  @override
  String get fetched => 'fetched';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get readerSavedForLater => 'Saved for later';

  @override
  String get readerRemovedFromSaved => 'Removed from saved';

  @override
  String get resumingLastRead => 'Resuming last read article';

  @override
  String get startingPlayback => 'Starting playback for unread article';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'Show reader';

  @override
  String get showWebView => 'Show web view';

  @override
  String get webviewUnsupported =>
      'In-app WebView is only supported on Android/iOS.\nShowing text view instead.';

  @override
  String byAuthor(Object author) {
    return 'By $author';
  }

  @override
  String get markedReadSkipped => 'Marked read & skipped to next';

  @override
  String get markUnread => 'Mark unread';

  @override
  String get markReadPlay => 'Mark read & play next';

  @override
  String get previousArticle => 'Previous article';

  @override
  String get nextArticle => 'Next article';

  @override
  String playingSection(Object current, Object total) {
    return 'Playing section $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'Read-aloud not available for this article.';

  @override
  String unreadCount(Object count) {
    return 'Unread: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'Embedded video is only supported on Android/iOS.';

  @override
  String get loadVideo => 'Load Video';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get goAdFree => 'Go Ad-Free';

  @override
  String get goAdFreeSubtitle => 'Just \$1/month. Support indie dev.';

  @override
  String get pricePerMonth => '\$1/mo';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Subscribe for \$1/month and get:';

  @override
  String get premiumRemoveAds => 'Remove all ads';

  @override
  String get premiumCloudStorage => 'Cloud storage for your data';

  @override
  String get premiumCloudSubscriptions => 'Save subscriptions in the cloud';

  @override
  String get premiumSync => 'Sign in & sync across devices';

  @override
  String get premiumFolders => 'Unlimited folder organization';

  @override
  String get notNow => 'Not now';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get subscribeNow => 'Subscribe \$1/mo';

  @override
  String get subscriptionComingSoon =>
      'Subscription coming soon! You\'ll be charged \$1/month.';

  @override
  String get sectionAdvanced => 'Advanced';

  @override
  String get readTracking => 'Read tracking';

  @override
  String get readTrackingSubtitle =>
      'Auto-mark articles as read based on reading progress';

  @override
  String get autoMarkRead => 'Auto-mark read by progress';

  @override
  String get autoMarkReadSubtitle =>
      'Marks as read when scroll or audio reaches your threshold';

  @override
  String get autoMarkThreshold => 'Auto-mark threshold';

  @override
  String progressNeeded(Object percent) {
    return '$percent% progress needed';
  }

  @override
  String get sectionVoice => 'Voice & Read aloud';

  @override
  String get narrationSpeed => 'Default narration speed';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = calm default)';
  }

  @override
  String get defaultVoice => 'Default voice';

  @override
  String get systemDefault => 'System default';

  @override
  String get autoPlayNext => 'Auto-play next article';

  @override
  String get autoPlayNextSubtitle =>
      'When narration finishes, move to the next item';

  @override
  String get sectionData => 'Data';

  @override
  String get lowDataMode => 'Low-data mode prefetch';

  @override
  String get lowDataModeSubtitle =>
      'Prefetch article text in background and prefer cached content when available';

  @override
  String get sectionAccessibility => 'Accessibility';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeSubtitle =>
      'Applies across the app, including articles and navigation.';

  @override
  String get sampleText => 'The quick brown fox jumps over the lazy dog.';

  @override
  String get sectionSubscriptions => 'Subscriptions';

  @override
  String get manageSubscriptions => 'Manage Subscriptions';

  @override
  String get manageSubscriptionsSubtitle =>
      'Add or remove the feeds you follow';

  @override
  String get manageFolders => 'Manage Folders';

  @override
  String get manageFoldersSubtitle => 'Organise feeds into folders';

  @override
  String get importSubscriptions => 'Import Subscriptions';

  @override
  String get importSubscriptionsSubtitle => 'Import via OPML file';

  @override
  String get exportSubscriptions => 'Export Subscriptions';

  @override
  String get exportSubscriptionsSubtitle => 'Export your feeds to OPML';

  @override
  String get sectionThemes => 'Themes';

  @override
  String get themes => 'Themes';

  @override
  String get themesSubtitle => 'Light / Dark / System';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'English';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageFrench => 'French';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageGerman => 'German';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageItalian => 'Italian';

  @override
  String get sectionLegal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get noFeedsFoundOpml => 'No feeds found in OPML';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Imported $count feed$_temp0';
  }

  @override
  String get allFeedsAlreadyAdded => 'All feeds were already added';

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get noSubscriptionsToExport => 'No subscriptions to export';

  @override
  String exportedCount(Object count) {
    return 'Exported $count feed(s)';
  }

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get exportShareText => 'Aware subscriptions export';

  @override
  String get exportShareSubject => 'Aware subscriptions export';

  @override
  String get savedArticlesTitle => 'Saved Articles';

  @override
  String get noSavedArticlesYet => 'No saved articles yet.';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyLastUpdated => 'Last updated: June 20, 2026';

  @override
  String get privacyInfoWeCollect => 'Information We Collect';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware does not collect, store, or transmit any personal data. All app data (feeds, articles, reading progress, preferences, and settings) is stored locally on your device and is never sent to any server.';

  @override
  String get privacyThirdParty => 'Third-Party Services';

  @override
  String get privacyThirdPartyBody =>
      'Aware uses Google AdMob to display advertisements. AdMob may collect non-personal usage data and device identifiers to serve relevant ads. Ads are served with non-personalized ad requests only. No user-level data is shared with advertisers.\n\nGoogle\'s Privacy Policy applies to data collected by AdMob:\n';

  @override
  String get privacyDataStorage => 'Data Storage';

  @override
  String get privacyDataStorageBody =>
      'All feed subscriptions, articles, reading progress, and app preferences are stored locally in a SQLite database on your device. You can export your data at any time via the OPML export feature in Settings.\n\nTo delete all data, uninstall the app or clear app data from your device settings.';

  @override
  String get privacyContact => 'Contact';

  @override
  String get privacyContactBody =>
      'If you have questions about this privacy policy, please contact us through the app\'s support channels.';
}
