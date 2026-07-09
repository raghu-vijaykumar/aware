// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'आसानी से सूचित रहें';

  @override
  String get onboardingLanguageTitle => 'अपनी भाषा चुनें';

  @override
  String get onboardingLanguageDesc =>
      'ऐप इंटरफ़ेस के लिए अपनी पसंदीदा भाषा चुनें।';

  @override
  String get onboardingWelcomeTitle => 'aware में आपका स्वागत है';

  @override
  String get onboardingWelcomeDesc =>
      'आपका व्यक्तिगत फ़ीड रीडर। एक ही जगह पर, जो मायने रखता है उसके बारे में सूचित रहें।';

  @override
  String get onboardingOfflineTitle => 'ऑफ़लाइन पढ़ें';

  @override
  String get onboardingOfflineDesc =>
      'फ़ीड डाउनलोड हो जाते हैं ताकि आप कभी भी, कहीं भी पढ़ सकें। टेक्स्ट-टू-स्पीच से सुनें।';

  @override
  String get onboardingNotifyTitle => 'कोई पोस्ट मिस न करें';

  @override
  String get onboardingNotifyDesc =>
      'नए लेख आने पर सूचनाएं प्राप्त करें। शुरू करने के लिए अपना पहला फ़ीड जोड़ें।';

  @override
  String get next => 'अगला';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get tabFeeds => 'फ़ीड';

  @override
  String get tabMarketplace => 'बाज़ार';

  @override
  String get tabSettings => 'सेटिंग्स';

  @override
  String get addFeedTitle => 'RSS फ़ीड जोड़ें';

  @override
  String get addFeedUrlLabel => 'फ़ीड URL';

  @override
  String get addFeedUrlHint => 'https://उदाहरण.com/feed.xml';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get feedAdded => 'फ़ीड जोड़ा गया';

  @override
  String failedToAddFeed(Object error) {
    return 'फ़ीड जोड़ने में विफल: $error';
  }

  @override
  String get feedUrlRequired => 'फ़ीड URL आवश्यक है';

  @override
  String get marketplaceTitle => 'बाज़ार';

  @override
  String get marketplaceSubtitle => 'श्रेणी के अनुसार क्यूरेटेड RSS लिंक';

  @override
  String get marketplaceHeroTitle => 'तेज़ी से गुणवत्तापूर्ण फ़ीड खोजें';

  @override
  String get marketplaceHeroDesc =>
      'विषय के अनुसार विश्वसनीय स्रोत ब्राउज़ करें। अपने होम फ़ीड में तुरंत जोड़ने के लिए फ़ॉलो करें पर टैप करें।';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count श्रेणियाँ';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count फ़ीड';
  }

  @override
  String get marketplaceSearchHint => 'फ़ीड खोजें...';

  @override
  String get marketplaceUntitledFeed => 'शीर्षकहीन फ़ीड';

  @override
  String get marketplaceSubscribed => 'सब्सक्राइब किया';

  @override
  String get marketplaceFollow => 'फ़ॉलो करें';

  @override
  String marketplaceSubscribedTo(Object title) {
    return '$title में सब्सक्राइब किया';
  }

  @override
  String get marketplaceInvalidUrl => 'अमान्य फ़ीड URL';

  @override
  String get marketplaceUnreachable =>
      'सब्सक्राइब करने में विफल: फ़ीड शायद पहुंच से बाहर है';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count क्यूरेटेड स्रोत';
  }

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get emailRequired => 'अपना ईमेल दर्ज करें';

  @override
  String get passwordRequired => 'अपना पासवर्ड दर्ज करें';

  @override
  String get subscriptionsTitle => 'सब्सक्रिप्शन';

  @override
  String get subscriptionsEmpty =>
      'अभी तक कोई सब्सक्रिप्शन नहीं। बाज़ार से फ़ीड जोड़ें!';

  @override
  String get untitledFeed => 'शीर्षकहीन फ़ीड';

  @override
  String get paused => 'रोका गया';

  @override
  String get resume => 'जारी रखें';

  @override
  String get pause => 'रोकें';

  @override
  String get unsubscribe => 'सब्सक्राइब हटाएं';

  @override
  String get unsubscribeTitle => 'सब्सक्राइब हटाएं';

  @override
  String unsubscribeConfirm(Object title) {
    return '$title से सब्सक्राइब हटाएं?';
  }

  @override
  String get foldersTitle => 'फ़ोल्डर';

  @override
  String get createFolderTitle => 'नया फ़ोल्डर';

  @override
  String get folderNameHint => 'फ़ोल्डर का नाम';

  @override
  String get create => 'बनाएं';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get renameFolderTitle => 'फ़ोल्डर का नाम बदलें';

  @override
  String get delete => 'हटाएं';

  @override
  String get deleteFolderTitle => 'फ़ोल्डर हटाएं';

  @override
  String deleteFolderConfirm(Object name) {
    return '\"$name\" हटाएं और इसके फ़ीड को अनग्रुप करें?';
  }

  @override
  String get createFolderTooltip => 'फ़ोल्डर बनाएं';

  @override
  String get noFoldersYet => 'अभी तक कोई फ़ोल्डर नहीं';

  @override
  String get createFirstFolder => 'अपना पहला फ़ोल्डर बनाएं';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count फ़ीड$_temp0';
  }

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get unread => 'न पढ़ा गया';

  @override
  String get liked => 'पसंद किया';

  @override
  String get saved => 'सहेजा गया';

  @override
  String get last24h => 'पिछले 24 घंटे';

  @override
  String get last7d => 'पिछले 7 दिन';

  @override
  String get last30d => 'पिछले 30 दिन';

  @override
  String get engagement => 'सहभागिता';

  @override
  String get unreadOnly => 'केवल न पढ़ा गया';

  @override
  String get lengthPreview => 'लंबाई / पूर्वावलोकन';

  @override
  String get any => 'कोई भी';

  @override
  String get short => 'छोटा <100 शब्द';

  @override
  String get medium => 'मध्यम 100-300';

  @override
  String get long => 'लंबा >300';

  @override
  String get multiParagraph => '2+ पैराग्राफ';

  @override
  String get timeWindow => 'समय सीमा';

  @override
  String get all => 'सभी';

  @override
  String get sources => 'स्रोत';

  @override
  String get allSources => 'सभी स्रोत';

  @override
  String get keyword => 'कीवर्ड';

  @override
  String get keywordHint => 'शीर्षक, सारांश, या सामग्री';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get done => 'हो गया';

  @override
  String get searchArticlesHint => 'लेख खोजें...';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get noArticlesYet =>
      'अभी तक कोई लेख नहीं। रिफ्रेश करने के लिए खींचें।';

  @override
  String get noArticlesMatch => 'कोई लेख वर्तमान फ़िल्टर से मेल नहीं खाता।';

  @override
  String get untitled => 'शीर्षकहीन';

  @override
  String get removedLike => 'पसंद हटा दी गई';

  @override
  String get likedArticle => 'लेख पसंद किया';

  @override
  String get removedFromSaved => 'सहेजे गए से हटा दिया गया';

  @override
  String get savedForLater => 'बाद के लिए सहेजा गया';

  @override
  String get markedUnread => 'न पढ़ा गया चिह्नित';

  @override
  String get markedRead => 'पढ़ा गया चिह्नित';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get publishDateUnknown => 'प्रकाशन तिथि अज्ञात';

  @override
  String get justNow => 'अभी';

  @override
  String minutesAgo(Object count) {
    return '$count मिनट पहले';
  }

  @override
  String hoursAgo(Object count) {
    return '$count घंटे पहले';
  }

  @override
  String daysAgo(Object count) {
    return '$count दिन पहले';
  }

  @override
  String weeksAgo(Object count) {
    return '$count सप्ताह पहले';
  }

  @override
  String monthsAgo(Object count) {
    return '$count महीने पहले';
  }

  @override
  String yearsAgo(Object count) {
    return '$count साल पहले';
  }

  @override
  String get fetched => 'लाया गया';

  @override
  String get continueReading => 'पढ़ना जारी रखें';

  @override
  String get readerSavedForLater => 'बाद के लिए सहेजा गया';

  @override
  String get readerRemovedFromSaved => 'सहेजे गए से हटा दिया गया';

  @override
  String get resumingLastRead => 'अंतिम पढ़ा गया लेख फिर से शुरू कर रहा है';

  @override
  String get startingPlayback => 'न पढ़े गए लेख के लिए प्लेबैक शुरू हो रहा है';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'रीडर दिखाएं';

  @override
  String get showWebView => 'वेब व्यू दिखाएं';

  @override
  String get webviewUnsupported =>
      'इन-ऐप WebView केवल Android/iOS पर समर्थित है।\nइसके बजाय टेक्स्ट व्यू दिखाया जा रहा है।';

  @override
  String byAuthor(Object author) {
    return '$author द्वारा';
  }

  @override
  String get markedReadSkipped => 'पढ़ा गया चिह्नित किया और अगले पर जाएं';

  @override
  String get markUnread => 'न पढ़ा गया चिह्नित करें';

  @override
  String get markReadPlay => 'पढ़ा गया चिह्नित करें और अगला चलाएं';

  @override
  String get previousArticle => 'पिछला लेख';

  @override
  String get nextArticle => 'अगला लेख';

  @override
  String playingSection(Object current, Object total) {
    return 'अनुभाग चल रहा है $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'इस लेख के लिए जोर से पढ़ना उपलब्ध नहीं है।';

  @override
  String unreadCount(Object count) {
    return 'न पढ़ा गया: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'एम्बेडेड वीडियो केवल Android/iOS पर समर्थित है।';

  @override
  String get loadVideo => 'वीडियो लोड करें';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get goAdFree => 'विज्ञापन-मुक्त बनें';

  @override
  String get goAdFreeSubtitle => 'केवल \$1/माह। इंडी डेवलपर का समर्थन करें।';

  @override
  String get pricePerMonth => '\$1/माह';

  @override
  String get premiumTitle => 'Aware प्रीमियम';

  @override
  String get premiumSubscribeDesc => '\$1/माह में सब्सक्राइब करें और पाएं:';

  @override
  String get premiumRemoveAds => 'सभी विज्ञापन हटाएं';

  @override
  String get premiumCloudStorage => 'आपके डेटा के लिए क्लाउड स्टोरेज';

  @override
  String get premiumCloudSubscriptions => 'क्लाउड में सब्सक्रिप्शन सहेजें';

  @override
  String get premiumSync => 'साइन इन करें और डिवाइसों पर सिंक करें';

  @override
  String get premiumFolders => 'असीमित फ़ोल्डर संगठन';

  @override
  String get notNow => 'अब नहीं';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get subscribeNow => 'सब्सक्राइब करें \$1/माह';

  @override
  String get subscriptionComingSoon =>
      'सब्सक्रिप्शन जल्द आ रहा है! आपसे \$1/माह लिया जाएगा।';

  @override
  String get sectionAdvanced => 'उन्नत';

  @override
  String get readTracking => 'पढ़ने का ट्रैकिंग';

  @override
  String get readTrackingSubtitle =>
      'पढ़ने की प्रगति के आधार पर लेखों को स्वचालित रूप से पढ़ा गया चिह्नित करें';

  @override
  String get autoMarkRead => 'प्रगति द्वारा स्वतः पढ़ा गया चिह्नित करें';

  @override
  String get autoMarkReadSubtitle =>
      'जब स्क्रॉल या ऑडियो आपकी सीमा तक पहुंचे तो पढ़ा गया चिह्नित करता है';

  @override
  String get autoMarkThreshold => 'स्वतः चिह्नित सीमा';

  @override
  String progressNeeded(Object percent) {
    return '$percent% प्रगति आवश्यक';
  }

  @override
  String get sectionVoice => 'आवाज़ और जोर से पढ़ना';

  @override
  String get narrationSpeed => 'डिफ़ॉल्ट कथन गति';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = शांत डिफ़ॉल्ट)';
  }

  @override
  String get defaultVoice => 'डिफ़ॉल्ट आवाज़';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get autoPlayNext => 'अगला लेख स्वचालित रूप से चलाएं';

  @override
  String get autoPlayNextSubtitle => 'जब कथन समाप्त हो, अगले आइटम पर जाएं';

  @override
  String get sectionData => 'डेटा';

  @override
  String get lowDataMode => 'कम-डेटा मोड प्रीफ़ेच';

  @override
  String get lowDataModeSubtitle =>
      'पृष्ठभूमि में लेख टेक्स्ट प्रीफ़ेच करें और उपलब्ध होने पर कैश की गई सामग्री पसंद करें';

  @override
  String get sectionAccessibility => 'अभिगम्यता';

  @override
  String get textSize => 'टेक्स्ट आकार';

  @override
  String get textSizeSubtitle =>
      'लेख और नेविगेशन सहित पूरे ऐप पर लागू होता है।';

  @override
  String get sampleText => 'नमूना टेक्स्ट आकार पूर्वावलोकन के लिए पाठ।';

  @override
  String get sectionSubscriptions => 'सब्सक्रिप्शन';

  @override
  String get manageSubscriptions => 'सब्सक्रिप्शन प्रबंधित करें';

  @override
  String get manageSubscriptionsSubtitle =>
      'आपके द्वारा फ़ॉलो किए जाने वाले फ़ीड जोड़ें या हटाएं';

  @override
  String get manageFolders => 'फ़ोल्डर प्रबंधित करें';

  @override
  String get manageFoldersSubtitle => 'फ़ीड को फ़ोल्डरों में व्यवस्थित करें';

  @override
  String get importSubscriptions => 'सब्सक्रिप्शन आयात करें';

  @override
  String get importSubscriptionsSubtitle => 'OPML फ़ाइल के माध्यम से आयात करें';

  @override
  String get exportSubscriptions => 'सब्सक्रिप्शन निर्यात करें';

  @override
  String get exportSubscriptionsSubtitle =>
      'अपने फ़ीड को OPML में निर्यात करें';

  @override
  String get sectionThemes => 'थीम';

  @override
  String get themes => 'थीम';

  @override
  String get themesSubtitle => 'हल्का / गहरा / सिस्टम';

  @override
  String get selectTheme => 'थीम चुनें';

  @override
  String get system => 'सिस्टम';

  @override
  String get light => 'हल्का';

  @override
  String get dark => 'गहरा';

  @override
  String get sectionLanguage => 'भाषा';

  @override
  String get language => 'भाषा';

  @override
  String get languageSubtitle => 'हिन्दी';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageChinese => 'चीनी';

  @override
  String get languageSpanish => 'स्पैनिश';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageArabic => 'अरबी';

  @override
  String get languageFrench => 'फ़्रेंच';

  @override
  String get languagePortuguese => 'पुर्तगाली';

  @override
  String get languageRussian => 'रूसी';

  @override
  String get languageJapanese => 'जापानी';

  @override
  String get languageGerman => 'जर्मन';

  @override
  String get languageKorean => 'कोरियाई';

  @override
  String get languageItalian => 'इतालवी';

  @override
  String get sectionLegal => 'कानूनी';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get openSourceLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get noFeedsFoundOpml => 'OPML में कोई फ़ीड नहीं मिला';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count फ़ीड$_temp0 आयात किए गए';
  }

  @override
  String get allFeedsAlreadyAdded => 'सभी फ़ीड पहले ही जोड़े जा चुके हैं';

  @override
  String importFailed(Object error) {
    return 'आयात विफल: $error';
  }

  @override
  String get noSubscriptionsToExport =>
      'निर्यात करने के लिए कोई सब्सक्रिप्शन नहीं';

  @override
  String exportedCount(Object count) {
    return '$count फ़ीड निर्यात किए गए';
  }

  @override
  String exportFailed(Object error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String get exportShareText => 'Aware सब्सक्रिप्शन निर्यात';

  @override
  String get exportShareSubject => 'Aware सब्सक्रिप्शन निर्यात';

  @override
  String get savedArticlesTitle => 'सहेजे गए लेख';

  @override
  String get noSavedArticlesYet => 'अभी तक कोई सहेजा गया लेख नहीं।';

  @override
  String error(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get privacyPolicyLastUpdated => 'अंतिम अपडेट: 20 जून, 2026';

  @override
  String get privacyInfoWeCollect => 'हम कौन सी जानकारी एकत्र करते हैं';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware कोई व्यक्तिगत डेटा एकत्र, संग्रहीत या प्रसारित नहीं करता है। सभी ऐप डेटा (फ़ीड, लेख, पढ़ने की प्रगति, प्राथमिकताएं और सेटिंग्स) आपके डिवाइस पर स्थानीय रूप से संग्रहीत होते हैं और कभी भी किसी सर्वर को नहीं भेजे जाते हैं।';

  @override
  String get privacyThirdParty => 'तृतीय-पक्ष सेवाएं';

  @override
  String get privacyThirdPartyBody =>
      'Aware विज्ञापन प्रदर्शित करने के लिए Google AdMob का उपयोग करता है। AdMob प्रासंगिक विज्ञापन देने के लिए गैर-व्यक्तिगत उपयोग डेटा और डिवाइस पहचानकर्ता एकत्र कर सकता है। विज्ञापन केवल गैर-व्यक्तिगत विज्ञापन अनुरोधों के साथ दिए जाते हैं। विज्ञापनदाताओं के साथ कोई उपयोगकर्ता डेटा साझा नहीं किया जाता है।\n\nGoogle की गोपनीयता नीति AdMob द्वारा एकत्र किए गए डेटा पर लागू होती है:\n';

  @override
  String get privacyDataStorage => 'डेटा संग्रहण';

  @override
  String get privacyDataStorageBody =>
      'सभी फ़ीड सब्सक्रिप्शन, लेख, पढ़ने की प्रगति और ऐप प्राथमिकताएं आपके डिवाइस पर SQLite डेटाबेस में स्थानीय रूप से संग्रहीत होती हैं। आप सेटिंग्स में OPML निर्यात सुविधा के माध्यम से किसी भी समय अपना डेटा निर्यात कर सकते हैं।\n\nसभी डेटा हटाने के लिए, ऐप को अनइंस्टॉल करें या अपने डिवाइस सेटिंग्स से ऐप डेटा साफ़ करें।';

  @override
  String get privacyContact => 'संपर्क';

  @override
  String get privacyContactBody =>
      'यदि आपके पास इस गोपनीयता नीति के बारे में प्रश्न हैं, तो कृपया ऐप के सहायता चैनलों के माध्यम से हमसे संपर्क करें।';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
