import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'aware'**
  String get appName;

  /// Application title shown in settings/about
  ///
  /// In en, this message translates to:
  /// **'Aware'**
  String get appTitle;

  /// Application version number
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// Tagline shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Stay informed, effortlessly'**
  String get splashTagline;

  /// Title for onboarding language selection page
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingLanguageTitle;

  /// Description for onboarding language selection page
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app interface.'**
  String get onboardingLanguageDesc;

  /// Title for first onboarding page
  ///
  /// In en, this message translates to:
  /// **'Welcome to aware'**
  String get onboardingWelcomeTitle;

  /// Description for first onboarding page
  ///
  /// In en, this message translates to:
  /// **'Your personal feed reader. Stay informed about what matters, all in one place.'**
  String get onboardingWelcomeDesc;

  /// Title for second onboarding page
  ///
  /// In en, this message translates to:
  /// **'Read Offline'**
  String get onboardingOfflineTitle;

  /// Description for second onboarding page
  ///
  /// In en, this message translates to:
  /// **'Feeds are downloaded so you can read anytime, anywhere. Listen with text-to-speech.'**
  String get onboardingOfflineDesc;

  /// Title for third onboarding page
  ///
  /// In en, this message translates to:
  /// **'Never Miss a Post'**
  String get onboardingNotifyTitle;

  /// Description for third onboarding page
  ///
  /// In en, this message translates to:
  /// **'Get notified when new articles arrive. Add your first feed to get started.'**
  String get onboardingNotifyDesc;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Get Started button on last onboarding page
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Skip button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Bottom navigation tab for feeds
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get tabFeeds;

  /// Bottom navigation tab for marketplace
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get tabMarketplace;

  /// Bottom navigation tab for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// Title of the add feed dialog
  ///
  /// In en, this message translates to:
  /// **'Add RSS Feed'**
  String get addFeedTitle;

  /// Label for feed URL input
  ///
  /// In en, this message translates to:
  /// **'Feed URL'**
  String get addFeedUrlLabel;

  /// Hint text for feed URL input
  ///
  /// In en, this message translates to:
  /// **'https://example.com/feed.xml'**
  String get addFeedUrlHint;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Snackbar message when feed is added
  ///
  /// In en, this message translates to:
  /// **'Feed added'**
  String get feedAdded;

  /// Snackbar message when adding a feed fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add feed: {error}'**
  String failedToAddFeed(Object error);

  /// Validation message when feed URL is empty
  ///
  /// In en, this message translates to:
  /// **'Feed URL is required'**
  String get feedUrlRequired;

  /// Title of marketplace screen
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplaceTitle;

  /// Subtitle of marketplace screen
  ///
  /// In en, this message translates to:
  /// **'Curated RSS links by category'**
  String get marketplaceSubtitle;

  /// Hero section title on marketplace
  ///
  /// In en, this message translates to:
  /// **'Discover quality feeds fast'**
  String get marketplaceHeroTitle;

  /// Hero section description on marketplace
  ///
  /// In en, this message translates to:
  /// **'Browse trusted sources by topic. Tap follow to add them to your home feed instantly.'**
  String get marketplaceHeroDesc;

  /// Category count stat
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String marketplaceCategoriesCount(Object count);

  /// Feed count stat
  ///
  /// In en, this message translates to:
  /// **'{count} feeds'**
  String marketplaceFeedsCount(Object count);

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search feeds...'**
  String get marketplaceSearchHint;

  /// Fallback title for unnamed feed
  ///
  /// In en, this message translates to:
  /// **'Untitled feed'**
  String get marketplaceUntitledFeed;

  /// Tooltip when feed is subscribed
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get marketplaceSubscribed;

  /// Follow button tooltip
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get marketplaceFollow;

  /// Snackbar when subscribing to a feed
  ///
  /// In en, this message translates to:
  /// **'Subscribed to {title}'**
  String marketplaceSubscribedTo(Object title);

  /// Error when feed URL is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid feed URL'**
  String get marketplaceInvalidUrl;

  /// Error when feed subscription fails
  ///
  /// In en, this message translates to:
  /// **'Failed to subscribe: feed may be unreachable'**
  String get marketplaceUnreachable;

  /// Subtitle showing curated source count
  ///
  /// In en, this message translates to:
  /// **'{count} curated sources'**
  String marketplaceCuratedSources(Object count);

  /// Sign in button / title
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Validation for empty email
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailRequired;

  /// Validation for empty password
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordRequired;

  /// Title of subscriptions screen
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet. Add feeds from the Marketplace!'**
  String get subscriptionsEmpty;

  /// Fallback title for unnamed feed
  ///
  /// In en, this message translates to:
  /// **'Untitled Feed'**
  String get untitledFeed;

  /// Paused feed label
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Resume feed action
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Pause feed action
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Unsubscribe action
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// Unsubscribe dialog title
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribeTitle;

  /// Unsubscribe confirmation message
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe from {title}?'**
  String unsubscribeConfirm(Object title);

  /// Title of folders screen
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get foldersTitle;

  /// Create folder dialog title
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get createFolderTitle;

  /// Folder name input hint
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderNameHint;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Rename button
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Rename folder dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename Folder'**
  String get renameFolderTitle;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete folder dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get deleteFolderTitle;

  /// Delete folder confirmation
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" and ungroup its feeds?'**
  String deleteFolderConfirm(Object name);

  /// Tooltip for create folder button
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolderTooltip;

  /// Empty state for folders
  ///
  /// In en, this message translates to:
  /// **'No folders yet'**
  String get noFoldersYet;

  /// Button to create first folder
  ///
  /// In en, this message translates to:
  /// **'Create your first folder'**
  String get createFirstFolder;

  /// Feed count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count} feed{count, plural, one {} other {s}}'**
  String feedCount(num count);

  /// Filters button
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Unread filter chip
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Liked filter chip
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// Saved filter chip
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Time filter: last 24 hours
  ///
  /// In en, this message translates to:
  /// **'Last 24h'**
  String get last24h;

  /// Time filter: last 7 days
  ///
  /// In en, this message translates to:
  /// **'Last 7d'**
  String get last7d;

  /// Time filter: last 30 days
  ///
  /// In en, this message translates to:
  /// **'Last 30d'**
  String get last30d;

  /// Filter section: engagement
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get engagement;

  /// Unread only filter option
  ///
  /// In en, this message translates to:
  /// **'Unread only'**
  String get unreadOnly;

  /// Filter section: length/preview
  ///
  /// In en, this message translates to:
  /// **'Length / preview'**
  String get lengthPreview;

  /// Any length filter
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// Short article filter
  ///
  /// In en, this message translates to:
  /// **'Short <100w'**
  String get short;

  /// Medium article filter
  ///
  /// In en, this message translates to:
  /// **'Medium 100-300'**
  String get medium;

  /// Long article filter
  ///
  /// In en, this message translates to:
  /// **'Long >300'**
  String get long;

  /// Multi-paragraph filter
  ///
  /// In en, this message translates to:
  /// **'2+ paragraphs'**
  String get multiParagraph;

  /// Filter section: time window
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get timeWindow;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Filter section: sources
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// All sources filter option
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get allSources;

  /// Filter section: keyword
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get keyword;

  /// Keyword search hint
  ///
  /// In en, this message translates to:
  /// **'Title, summary, or content'**
  String get keywordHint;

  /// Reset filters button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Search field placeholder in article list
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get searchArticlesHint;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Empty state for article list
  ///
  /// In en, this message translates to:
  /// **'No articles yet. Pull to refresh.'**
  String get noArticlesYet;

  /// Empty state when filters match nothing
  ///
  /// In en, this message translates to:
  /// **'No articles match the current filters.'**
  String get noArticlesMatch;

  /// Fallback article title
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// Snackbar when removing a like
  ///
  /// In en, this message translates to:
  /// **'Removed like'**
  String get removedLike;

  /// Snackbar when liking an article
  ///
  /// In en, this message translates to:
  /// **'Liked article'**
  String get likedArticle;

  /// Snackbar when removing from saved
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedFromSaved;

  /// Snackbar when saving for later
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get savedForLater;

  /// Snackbar when marking unread
  ///
  /// In en, this message translates to:
  /// **'Marked unread'**
  String get markedUnread;

  /// Snackbar when marking read
  ///
  /// In en, this message translates to:
  /// **'Marked read'**
  String get markedRead;

  /// Undo action label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Fallback when publish date is unknown
  ///
  /// In en, this message translates to:
  /// **'Publish date unknown'**
  String get publishDateUnknown;

  /// Time label: just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Time label: minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(Object count);

  /// Time label: hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(Object count);

  /// Time label: days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(Object count);

  /// Time label: weeks ago
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String weeksAgo(Object count);

  /// Time label: months ago
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String monthsAgo(Object count);

  /// Time label: years ago
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String yearsAgo(Object count);

  /// Indicator that timestamp is fallback fetched time
  ///
  /// In en, this message translates to:
  /// **'fetched'**
  String get fetched;

  /// FAB label for continue reading
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// Snackbar when saving in reader
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get readerSavedForLater;

  /// Snackbar when removing save in reader
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get readerRemovedFromSaved;

  /// Snackbar when resuming playback
  ///
  /// In en, this message translates to:
  /// **'Resuming last read article'**
  String get resumingLastRead;

  /// Snackbar when auto-playing
  ///
  /// In en, this message translates to:
  /// **'Starting playback for unread article'**
  String get startingPlayback;

  /// Tooltip to show reader view
  ///
  /// In en, this message translates to:
  /// **'Show reader'**
  String get showReader;

  /// Tooltip to show web view
  ///
  /// In en, this message translates to:
  /// **'Show web view'**
  String get showWebView;

  /// Message when WebView is unsupported on platform
  ///
  /// In en, this message translates to:
  /// **'In-app WebView is only supported on Android/iOS.\nShowing text view instead.'**
  String get webviewUnsupported;

  /// Article author attribution
  ///
  /// In en, this message translates to:
  /// **'By {author}'**
  String byAuthor(Object author);

  /// Snackbar when marking read and skipping
  ///
  /// In en, this message translates to:
  /// **'Marked read & skipped to next'**
  String get markedReadSkipped;

  /// Tooltip to mark as unread
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get markUnread;

  /// Tooltip to mark read and play next
  ///
  /// In en, this message translates to:
  /// **'Mark read & play next'**
  String get markReadPlay;

  /// Tooltip for previous article button
  ///
  /// In en, this message translates to:
  /// **'Previous article'**
  String get previousArticle;

  /// Tooltip for next article button
  ///
  /// In en, this message translates to:
  /// **'Next article'**
  String get nextArticle;

  /// Audio playback progress text
  ///
  /// In en, this message translates to:
  /// **'Playing section {current}/{total}'**
  String playingSection(Object current, Object total);

  /// Message when TTS is not available
  ///
  /// In en, this message translates to:
  /// **'Read-aloud not available for this article.'**
  String get readAloudNotAvailable;

  /// Unread article count badge
  ///
  /// In en, this message translates to:
  /// **'Unread: {count}'**
  String unreadCount(Object count);

  /// Message when embedded video is unsupported
  ///
  /// In en, this message translates to:
  /// **'Embedded video is only supported on Android/iOS.'**
  String get embeddedVideoUnsupported;

  /// Button to load embedded video
  ///
  /// In en, this message translates to:
  /// **'Load Video'**
  String get loadVideo;

  /// Title of settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Premium card title
  ///
  /// In en, this message translates to:
  /// **'Go Ad-Free'**
  String get goAdFree;

  /// Premium card subtitle
  ///
  /// In en, this message translates to:
  /// **'Just \$1/month. Support indie dev.'**
  String get goAdFreeSubtitle;

  /// Price label
  ///
  /// In en, this message translates to:
  /// **'\$1/mo'**
  String get pricePerMonth;

  /// Premium dialog title
  ///
  /// In en, this message translates to:
  /// **'Aware Premium'**
  String get premiumTitle;

  /// Premium dialog description
  ///
  /// In en, this message translates to:
  /// **'Subscribe for \$1/month and get:'**
  String get premiumSubscribeDesc;

  /// Premium feature: remove ads
  ///
  /// In en, this message translates to:
  /// **'Remove all ads'**
  String get premiumRemoveAds;

  /// Premium feature: cloud storage
  ///
  /// In en, this message translates to:
  /// **'Cloud storage for your data'**
  String get premiumCloudStorage;

  /// Premium feature: cloud subscriptions
  ///
  /// In en, this message translates to:
  /// **'Save subscriptions in the cloud'**
  String get premiumCloudSubscriptions;

  /// Premium feature: sync
  ///
  /// In en, this message translates to:
  /// **'Sign in & sync across devices'**
  String get premiumSync;

  /// Premium feature: folders
  ///
  /// In en, this message translates to:
  /// **'Unlimited folder organization'**
  String get premiumFolders;

  /// Not now button
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Coming soon badge label
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Subscribe button
  ///
  /// In en, this message translates to:
  /// **'Subscribe \$1/mo'**
  String get subscribeNow;

  /// Snackbar when subscription is coming soon
  ///
  /// In en, this message translates to:
  /// **'Subscription coming soon! You\'ll be charged \$1/month.'**
  String get subscriptionComingSoon;

  /// Settings section: advanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get sectionAdvanced;

  /// Read tracking setting title
  ///
  /// In en, this message translates to:
  /// **'Read tracking'**
  String get readTracking;

  /// Read tracking setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Auto-mark articles as read based on reading progress'**
  String get readTrackingSubtitle;

  /// Auto-mark read setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-mark read by progress'**
  String get autoMarkRead;

  /// Auto-mark read setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Marks as read when scroll or audio reaches your threshold'**
  String get autoMarkReadSubtitle;

  /// Auto-mark threshold setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-mark threshold'**
  String get autoMarkThreshold;

  /// Progress threshold label
  ///
  /// In en, this message translates to:
  /// **'{percent}% progress needed'**
  String progressNeeded(Object percent);

  /// Settings section: voice & read aloud
  ///
  /// In en, this message translates to:
  /// **'Voice & Read aloud'**
  String get sectionVoice;

  /// Narration speed setting title
  ///
  /// In en, this message translates to:
  /// **'Default narration speed'**
  String get narrationSpeed;

  /// Speed slider label
  ///
  /// In en, this message translates to:
  /// **'{speed}x (1x = calm default)'**
  String speedLabel(Object speed);

  /// Default voice setting title
  ///
  /// In en, this message translates to:
  /// **'Default voice'**
  String get defaultVoice;

  /// System default voice option
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// Auto-play next setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-play next article'**
  String get autoPlayNext;

  /// Auto-play next setting subtitle
  ///
  /// In en, this message translates to:
  /// **'When narration finishes, move to the next item'**
  String get autoPlayNextSubtitle;

  /// Settings section: data
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// Low data mode setting title
  ///
  /// In en, this message translates to:
  /// **'Low-data mode prefetch'**
  String get lowDataMode;

  /// Low data mode setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Prefetch article text in background and prefer cached content when available'**
  String get lowDataModeSubtitle;

  /// Settings section: accessibility
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get sectionAccessibility;

  /// Text size setting title
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// Text size setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Applies across the app, including articles and navigation.'**
  String get textSizeSubtitle;

  /// Sample text for text size preview
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog.'**
  String get sampleText;

  /// Settings section: subscriptions
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get sectionSubscriptions;

  /// Manage subscriptions setting title
  ///
  /// In en, this message translates to:
  /// **'Manage Subscriptions'**
  String get manageSubscriptions;

  /// Manage subscriptions setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Add or remove the feeds you follow'**
  String get manageSubscriptionsSubtitle;

  /// Manage folders setting title
  ///
  /// In en, this message translates to:
  /// **'Manage Folders'**
  String get manageFolders;

  /// Manage folders setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Organise feeds into folders'**
  String get manageFoldersSubtitle;

  /// Import subscriptions setting title
  ///
  /// In en, this message translates to:
  /// **'Import Subscriptions'**
  String get importSubscriptions;

  /// Import subscriptions setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Import via OPML file'**
  String get importSubscriptionsSubtitle;

  /// Export subscriptions setting title
  ///
  /// In en, this message translates to:
  /// **'Export Subscriptions'**
  String get exportSubscriptions;

  /// Export subscriptions setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Export your feeds to OPML'**
  String get exportSubscriptionsSubtitle;

  /// Settings section: themes
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get sectionThemes;

  /// Themes setting title
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// Themes setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Light / Dark / System'**
  String get themesSubtitle;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Settings section: language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language setting subtitle - currently selected language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSubtitle;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Settings section: legal
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get sectionLegal;

  /// Privacy policy setting title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Open source licenses setting title
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// Snackbar when no feeds found in OPML
  ///
  /// In en, this message translates to:
  /// **'No feeds found in OPML'**
  String get noFeedsFoundOpml;

  /// Snackbar when import succeeds
  ///
  /// In en, this message translates to:
  /// **'Imported {count} feed{count, plural, one {} other {s}}'**
  String importedCount(num count);

  /// Snackbar when all feeds already exist
  ///
  /// In en, this message translates to:
  /// **'All feeds were already added'**
  String get allFeedsAlreadyAdded;

  /// Snackbar when import fails
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(Object error);

  /// Snackbar when no subscriptions to export
  ///
  /// In en, this message translates to:
  /// **'No subscriptions to export'**
  String get noSubscriptionsToExport;

  /// Snackbar when export succeeds
  ///
  /// In en, this message translates to:
  /// **'Exported {count} feed(s)'**
  String exportedCount(Object count);

  /// Snackbar when export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// Share text for OPML export
  ///
  /// In en, this message translates to:
  /// **'Aware subscriptions export'**
  String get exportShareText;

  /// Share subject for OPML export
  ///
  /// In en, this message translates to:
  /// **'Aware subscriptions export'**
  String get exportShareSubject;

  /// Title of saved articles screen
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticlesTitle;

  /// Empty state for saved articles
  ///
  /// In en, this message translates to:
  /// **'No saved articles yet.'**
  String get noSavedArticlesYet;

  /// Error message format
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// Privacy policy screen title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Privacy policy last updated date
  ///
  /// In en, this message translates to:
  /// **'Last updated: June 20, 2026'**
  String get privacyPolicyLastUpdated;

  /// Privacy section: information we collect
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get privacyInfoWeCollect;

  /// Privacy section body: information we collect
  ///
  /// In en, this message translates to:
  /// **'Aware does not collect, store, or transmit any personal data. All app data (feeds, articles, reading progress, preferences, and settings) is stored locally on your device and is never sent to any server.'**
  String get privacyInfoWeCollectBody;

  /// Privacy section: third-party services
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get privacyThirdParty;

  /// Privacy section body: third-party services
  ///
  /// In en, this message translates to:
  /// **'Aware uses Google AdMob to display advertisements. AdMob may collect non-personal usage data and device identifiers to serve relevant ads. Ads are served with non-personalized ad requests only. No user-level data is shared with advertisers.\n\nGoogle\'s Privacy Policy applies to data collected by AdMob:\n'**
  String get privacyThirdPartyBody;

  /// Privacy section: data storage
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get privacyDataStorage;

  /// Privacy section body: data storage
  ///
  /// In en, this message translates to:
  /// **'All feed subscriptions, articles, reading progress, and app preferences are stored locally in a SQLite database on your device. You can export your data at any time via the OPML export feature in Settings.\n\nTo delete all data, uninstall the app or clear app data from your device settings.'**
  String get privacyDataStorageBody;

  /// Privacy section: contact
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContact;

  /// Privacy section body: contact
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this privacy policy, please contact us through the app\'s support channels.'**
  String get privacyContactBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
