// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'ابق على اطلاع بسهولة';

  @override
  String get onboardingLanguageTitle => 'اختر لغتك';

  @override
  String get onboardingLanguageDesc => 'اختر لغتك المفضلة لواجهة التطبيق.';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في aware';

  @override
  String get onboardingWelcomeDesc =>
      'قارئ التغذية الخاص بك. ابق على اطلاع بما يهم، كل ذلك في مكان واحد.';

  @override
  String get onboardingOfflineTitle => 'القراءة بدون اتصال';

  @override
  String get onboardingOfflineDesc =>
      'يتم تنزيل التغذية لتتمكن من القراءة في أي وقت وأي مكان. استمع باستخدام تحويل النص إلى كلام.';

  @override
  String get onboardingNotifyTitle => 'لا تفوت أي منشور';

  @override
  String get onboardingNotifyDesc =>
      'احصل على إشعارات عند وصول مقالات جديدة. أضف أول تغذية للبدء.';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get skip => 'تخطي';

  @override
  String get tabFeeds => 'التغذية';

  @override
  String get tabMarketplace => 'المتجر';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get addFeedTitle => 'إضافة تغذية RSS';

  @override
  String get addFeedUrlLabel => 'رابط التغذية';

  @override
  String get addFeedUrlHint => 'https://مثال.com/feed.xml';

  @override
  String get cancel => 'إلغاء';

  @override
  String get add => 'إضافة';

  @override
  String get feedAdded => 'تمت إضافة التغذية';

  @override
  String failedToAddFeed(Object error) {
    return 'فشل في إضافة التغذية: $error';
  }

  @override
  String get feedUrlRequired => 'رابط التغذية مطلوب';

  @override
  String get marketplaceTitle => 'المتجر';

  @override
  String get marketplaceSubtitle => 'روابط RSS مختارة حسب الفئة';

  @override
  String get marketplaceHeroTitle => 'اكتشف تغذية عالية الجودة بسرعة';

  @override
  String get marketplaceHeroDesc =>
      'تصفح المصادر الموثوقة حسب الموضوع. اضغط على متابعة لإضافتها إلى تغذيتك الرئيسية فورًا.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count فئة';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count تغذية';
  }

  @override
  String get marketplaceSearchHint => 'بحث في التغذية...';

  @override
  String get marketplaceUntitledFeed => 'تغذية بدون عنوان';

  @override
  String get marketplaceSubscribed => 'مشترك';

  @override
  String get marketplaceFollow => 'متابعة';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'مشترك في $title';
  }

  @override
  String get marketplaceInvalidUrl => 'رابط التغذية غير صالح';

  @override
  String get marketplaceUnreachable =>
      'فشل الاشتراك: قد تكون التغذية غير متاحة';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count مصدر مختار';
  }

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get emailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get passwordRequired => 'أدخل كلمة المرور';

  @override
  String get subscriptionsTitle => 'الاشتراكات';

  @override
  String get subscriptionsEmpty => 'لا توجد اشتراكات بعد. أضف تغذية من المتجر!';

  @override
  String get untitledFeed => 'تغذية بدون عنوان';

  @override
  String get paused => 'متوقف مؤقتًا';

  @override
  String get resume => 'استئناف';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get unsubscribe => 'إلغاء الاشتراك';

  @override
  String get unsubscribeTitle => 'إلغاء الاشتراك';

  @override
  String unsubscribeConfirm(Object title) {
    return 'إلغاء الاشتراك في $title؟';
  }

  @override
  String get foldersTitle => 'المجلدات';

  @override
  String get createFolderTitle => 'مجلد جديد';

  @override
  String get folderNameHint => 'اسم المجلد';

  @override
  String get create => 'إنشاء';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get renameFolderTitle => 'إعادة تسمية المجلد';

  @override
  String get delete => 'حذف';

  @override
  String get deleteFolderTitle => 'حذف المجلد';

  @override
  String deleteFolderConfirm(Object name) {
    return 'إزالة \"$name\" وفك تجميع تغذيته؟';
  }

  @override
  String get createFolderTooltip => 'إنشاء مجلد';

  @override
  String get noFoldersYet => 'لا توجد مجلدات بعد';

  @override
  String get createFirstFolder => 'أنشئ مجلدك الأول';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count تغذية$_temp0';
  }

  @override
  String get filters => 'عوامل تصفية';

  @override
  String get unread => 'غير مقروء';

  @override
  String get liked => 'معجب';

  @override
  String get saved => 'محفوظ';

  @override
  String get last24h => 'آخر 24 ساعة';

  @override
  String get last7d => 'آخر 7 أيام';

  @override
  String get last30d => 'آخر 30 يومًا';

  @override
  String get engagement => 'المشاركة';

  @override
  String get unreadOnly => 'غير مقروء فقط';

  @override
  String get lengthPreview => 'الطول / المعاينة';

  @override
  String get any => 'أي';

  @override
  String get short => 'قصير <100 كلمة';

  @override
  String get medium => 'متوسط 100-300';

  @override
  String get long => 'طويل >300';

  @override
  String get multiParagraph => 'فقرة+ 2';

  @override
  String get timeWindow => 'النطاق الزمني';

  @override
  String get all => 'الكل';

  @override
  String get sources => 'المصادر';

  @override
  String get allSources => 'جميع المصادر';

  @override
  String get keyword => 'كلمة مفتاحية';

  @override
  String get keywordHint => 'العنوان، الملخص، أو المحتوى';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get done => 'تم';

  @override
  String get searchArticlesHint => 'بحث في المقالات...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noArticlesYet => 'لا توجد مقالات بعد. اسحب للتحديث.';

  @override
  String get noArticlesMatch => 'لا توجد مقالات تطابق عوامل التصفية الحالية.';

  @override
  String get untitled => 'بدون عنوان';

  @override
  String get removedLike => 'تمت إزالة الإعجاب';

  @override
  String get likedArticle => 'أعجبك المقال';

  @override
  String get removedFromSaved => 'تمت الإزالة من المحفوظات';

  @override
  String get savedForLater => 'تم الحفظ لوقت لاحق';

  @override
  String get markedUnread => 'تم وضع علامة غير مقروء';

  @override
  String get markedRead => 'تم وضع علامة مقروء';

  @override
  String get undo => 'تراجع';

  @override
  String get publishDateUnknown => 'تاريخ النشر غير معروف';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(Object count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(Object count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(Object count) {
    return 'منذ $count يوم';
  }

  @override
  String weeksAgo(Object count) {
    return 'منذ $count أسبوع';
  }

  @override
  String monthsAgo(Object count) {
    return 'منذ $count شهر';
  }

  @override
  String yearsAgo(Object count) {
    return 'منذ $count سنة';
  }

  @override
  String get fetched => 'تم الجلب';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get readerSavedForLater => 'تم الحفظ لوقت لاحق';

  @override
  String get readerRemovedFromSaved => 'تمت الإزالة من المحفوظات';

  @override
  String get resumingLastRead => 'استئناف آخر مقالة مقروءة';

  @override
  String get startingPlayback => 'بدء التشغيل لمقالة غير مقروءة';

  @override
  String get showReader => 'إظهار القارئ';

  @override
  String get showWebView => 'إظهار عرض الويب';

  @override
  String get webviewUnsupported =>
      'عرض الويب المدمج مدعوم فقط على Android/iOS.\nسيتم عرض عرض النص بدلاً من ذلك.';

  @override
  String byAuthor(Object author) {
    return 'بواسطة $author';
  }

  @override
  String get markedReadSkipped => 'وُضعت علامة مقروء وانتقل إلى التالي';

  @override
  String get markUnread => 'وضع علامة غير مقروء';

  @override
  String get markReadPlay => 'وضع علامة مقروء وتشغيل التالي';

  @override
  String get previousArticle => 'المقالة السابقة';

  @override
  String get nextArticle => 'المقالة التالية';

  @override
  String playingSection(Object current, Object total) {
    return 'تشغيل القسم $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'القراءة بصوت عالٍ غير متاحة لهذه المقالة.';

  @override
  String unreadCount(Object count) {
    return 'غير مقروء: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'الفيديو المضمن مدعوم فقط على Android/iOS.';

  @override
  String get loadVideo => 'تحميل الفيديو';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get goAdFree => 'بدون إعلانات';

  @override
  String get goAdFreeSubtitle => 'فقط \$1/شهر. ادعم مطورًا مستقلاً.';

  @override
  String get pricePerMonth => '\$1/شهر';

  @override
  String get premiumTitle => 'Aware بريميوم';

  @override
  String get premiumSubscribeDesc => 'اشترك مقابل \$1/شهر واحصل على:';

  @override
  String get premiumRemoveAds => 'إزالة جميع الإعلانات';

  @override
  String get premiumCloudStorage => 'تخزين سحابي لبياناتك';

  @override
  String get premiumCloudSubscriptions => 'حفظ الاشتراكات في السحابة';

  @override
  String get premiumSync => 'تسجيل الدخول والمزامنة عبر الأجهزة';

  @override
  String get premiumFolders => 'تنظيم غير محدود للمجلدات';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get subscribeNow => 'اشترك \$1/شهر';

  @override
  String get subscriptionComingSoon => 'الاشتراك قريبًا! سيتم خصم \$1/شهر.';

  @override
  String get sectionAdvanced => 'متقدم';

  @override
  String get readTracking => 'تتبع القراءة';

  @override
  String get readTrackingSubtitle =>
      'وضع علامة تلقائيًا على المقالات كمقروءة بناءً على تقدم القراءة';

  @override
  String get autoMarkRead => 'وضع علامة تلقائي حسب التقدم';

  @override
  String get autoMarkReadSubtitle =>
      'يضع علامة مقروء عندما يصل التمرير أو الصوت إلى الحد الخاص بك';

  @override
  String get autoMarkThreshold => 'حد العلامة التلقائية';

  @override
  String progressNeeded(Object percent) {
    return 'مطلوب تقدم بنسبة $percent%';
  }

  @override
  String get sectionVoice => 'الصوت والقراءة بصوت عالٍ';

  @override
  String get narrationSpeed => 'سرعة السرد الافتراضية';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = هادئ افتراضي)';
  }

  @override
  String get defaultVoice => 'الصوت الافتراضي';

  @override
  String get systemDefault => 'إعدادات النظام';

  @override
  String get autoPlayNext => 'تشغيل المقالة التالية تلقائيًا';

  @override
  String get autoPlayNextSubtitle =>
      'عند انتهاء السرد، الانتقال إلى العنصر التالي';

  @override
  String get sectionData => 'البيانات';

  @override
  String get lowDataMode => 'التحميل المسبق في وضع البيانات المنخفضة';

  @override
  String get lowDataModeSubtitle =>
      'تحميل نص المقالات مسبقًا في الخلفية وتفضيل المحتوى المخبأ عند توفره';

  @override
  String get sectionAccessibility => 'إمكانية الوصول';

  @override
  String get textSize => 'حجم النص';

  @override
  String get textSizeSubtitle =>
      'يسري على التطبيق بالكامل، بما في ذلك المقالات والتنقل.';

  @override
  String get sampleText => 'نص تجريبي لحجم النص.';

  @override
  String get sectionSubscriptions => 'الاشتراكات';

  @override
  String get manageSubscriptions => 'إدارة الاشتراكات';

  @override
  String get manageSubscriptionsSubtitle =>
      'إضافة أو إزالة التغذية التي تتابعها';

  @override
  String get manageFolders => 'إدارة المجلدات';

  @override
  String get manageFoldersSubtitle => 'تنظيم التغذية في مجلدات';

  @override
  String get importSubscriptions => 'استيراد الاشتراكات';

  @override
  String get importSubscriptionsSubtitle => 'استيراد عبر ملف OPML';

  @override
  String get exportSubscriptions => 'تصدير الاشتراكات';

  @override
  String get exportSubscriptionsSubtitle => 'تصدير التغذية إلى OPML';

  @override
  String get sectionThemes => 'السمات';

  @override
  String get themes => 'السمات';

  @override
  String get themesSubtitle => 'فاتح / داكن / النظام';

  @override
  String get selectTheme => 'اختيار السمة';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get language => 'اللغة';

  @override
  String get languageSubtitle => 'العربية';

  @override
  String get selectLanguage => 'اختيار اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageChinese => 'الصينية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageHindi => 'الهندية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languagePortuguese => 'البرتغالية';

  @override
  String get languageRussian => 'الروسية';

  @override
  String get languageJapanese => 'اليابانية';

  @override
  String get languageGerman => 'الألمانية';

  @override
  String get languageKorean => 'الكورية';

  @override
  String get languageItalian => 'الإيطالية';

  @override
  String get sectionLegal => 'قانوني';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get openSourceLicenses => 'تراخيص المصدر المفتوح';

  @override
  String get noFeedsFoundOpml => 'لم يتم العثور على تغذية في OPML';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'تم استيراد $count تغذية$_temp0';
  }

  @override
  String get allFeedsAlreadyAdded => 'تمت إضافة جميع التغذية مسبقًا';

  @override
  String importFailed(Object error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get noSubscriptionsToExport => 'لا توجد اشتراكات للتصدير';

  @override
  String exportedCount(Object count) {
    return 'تم تصدير $count تغذية';
  }

  @override
  String exportFailed(Object error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get exportShareText => 'تصدير اشتراكات Aware';

  @override
  String get exportShareSubject => 'تصدير اشتراكات Aware';

  @override
  String get savedArticlesTitle => 'المقالات المحفوظة';

  @override
  String get noSavedArticlesYet => 'لا توجد مقالات محفوظة بعد.';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyPolicyLastUpdated => 'آخر تحديث: 20 يونيو 2026';

  @override
  String get privacyInfoWeCollect => 'المعلومات التي نجمعها';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware لا يجمع أو يخزن أو ينقل أي بيانات شخصية. جميع بيانات التطبيق (التغذية، المقالات، تقدم القراءة، التفضيلات، والإعدادات) تُخزن محليًا على جهازك ولا تُرسل أبدًا إلى أي خادم.';

  @override
  String get privacyThirdParty => 'خدمات الطرف الثالث';

  @override
  String get privacyThirdPartyBody =>
      'يستخدم Aware Google AdMob لعرض الإعلانات. قد يجمع AdMob بيانات استخدام غير شخصية ومعرفات الجهاز لعرض إعلانات ملائمة. يتم عرض الإعلانات فقط مع طلبات إعلانات غير مخصصة. لا تتم مشاركة أي بيانات مستخدم مع المعلنين.\n\nتنطبق سياسة خصوصية Google على البيانات التي يجمعها AdMob:\n';

  @override
  String get privacyDataStorage => 'تخزين البيانات';

  @override
  String get privacyDataStorageBody =>
      'جميع اشتراكات التغذية، المقالات، تقدم القراءة، وتفضيلات التطبيق تُخزن محليًا في قاعدة بيانات SQLite على جهازك. يمكنك تصدير بياناتك في أي وقت عبر ميزة تصدير OPML في الإعدادات.\n\nلحذف جميع البيانات، قم بإلغاء تثبيت التطبيق أو مسح بيانات التطبيق من إعدادات جهازك.';

  @override
  String get privacyContact => 'اتصل بنا';

  @override
  String get privacyContactBody =>
      'إذا كانت لديك أسئلة حول سياسة الخصوصية هذه، يرجى الاتصال بنا عبر قنوات الدعم في التطبيق.';
}
