// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Будьте в курсе без усилий';

  @override
  String get onboardingLanguageTitle => 'Выберите язык';

  @override
  String get onboardingLanguageDesc =>
      'Выберите предпочитаемый язык интерфейса приложения.';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в aware';

  @override
  String get onboardingWelcomeDesc =>
      'Ваш персональный RSS-ридер. Будьте в курсе того, что важно, все в одном месте.';

  @override
  String get onboardingOfflineTitle => 'Чтение офлайн';

  @override
  String get onboardingOfflineDesc =>
      'Ленты загружаются, чтобы вы могли читать в любое время и в любом месте. Слушайте с помощью синтеза речи.';

  @override
  String get onboardingNotifyTitle => 'Не пропускайте публикации';

  @override
  String get onboardingNotifyDesc =>
      'Получайте уведомления о новых статьях. Добавьте свою первую ленту, чтобы начать.';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get skip => 'Пропустить';

  @override
  String get tabFeeds => 'Ленты';

  @override
  String get tabMarketplace => 'Маркет';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get addFeedTitle => 'Добавить RSS-ленту';

  @override
  String get addFeedUrlLabel => 'URL ленты';

  @override
  String get addFeedUrlHint => 'https://пример.com/feed.xml';

  @override
  String get cancel => 'Отмена';

  @override
  String get add => 'Добавить';

  @override
  String get feedAdded => 'Лента добавлена';

  @override
  String failedToAddFeed(Object error) {
    return 'Не удалось добавить ленту: $error';
  }

  @override
  String get feedUrlRequired => 'Требуется URL ленты';

  @override
  String get marketplaceTitle => 'Маркет';

  @override
  String get marketplaceSubtitle => 'Подборки RSS-ссылок по категориям';

  @override
  String get marketplaceHeroTitle => 'Открывайте качественные ленты быстро';

  @override
  String get marketplaceHeroDesc =>
      'Просматривайте проверенные источники по темам. Нажмите «Подписаться», чтобы мгновенно добавить их в свою ленту.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count категорий';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count лент';
  }

  @override
  String get marketplaceSearchHint => 'Поиск лент...';

  @override
  String get marketplaceUntitledFeed => 'Лента без названия';

  @override
  String get marketplaceSubscribed => 'Подписано';

  @override
  String get marketplaceFollow => 'Подписаться';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'Подписано на $title';
  }

  @override
  String get marketplaceInvalidUrl => 'Неверный URL ленты';

  @override
  String get marketplaceUnreachable =>
      'Не удалось подписаться: лента недоступна';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count проверенных источников';
  }

  @override
  String get signIn => 'Войти';

  @override
  String get emailLabel => 'Эл. почта';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get emailRequired => 'Введите адрес эл. почты';

  @override
  String get passwordRequired => 'Введите пароль';

  @override
  String get subscriptionsTitle => 'Подписки';

  @override
  String get subscriptionsEmpty =>
      'Подписок пока нет. Добавьте ленты из Маркета!';

  @override
  String get untitledFeed => 'Лента без названия';

  @override
  String get paused => 'Приостановлено';

  @override
  String get resume => 'Возобновить';

  @override
  String get pause => 'Пауза';

  @override
  String get unsubscribe => 'Отписаться';

  @override
  String get unsubscribeTitle => 'Отписаться';

  @override
  String unsubscribeConfirm(Object title) {
    return 'Отписаться от $title?';
  }

  @override
  String get foldersTitle => 'Папки';

  @override
  String get createFolderTitle => 'Новая папка';

  @override
  String get folderNameHint => 'Имя папки';

  @override
  String get create => 'Создать';

  @override
  String get rename => 'Переименовать';

  @override
  String get renameFolderTitle => 'Переименовать папку';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteFolderTitle => 'Удалить папку';

  @override
  String deleteFolderConfirm(Object name) {
    return 'Удалить «$name» и разгруппировать его ленты?';
  }

  @override
  String get createFolderTooltip => 'Создать папку';

  @override
  String get noFoldersYet => 'Папок пока нет';

  @override
  String get createFirstFolder => 'Создайте свою первую папку';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      many: '',
      few: 'ы',
      one: 'а',
    );
    return '$count лент$_temp0';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get liked => 'Понравившиеся';

  @override
  String get saved => 'Сохраненные';

  @override
  String get last24h => 'Посл. 24 ч';

  @override
  String get last7d => 'Посл. 7 д';

  @override
  String get last30d => 'Посл. 30 д';

  @override
  String get engagement => 'Вовлеченность';

  @override
  String get unreadOnly => 'Только непрочитанные';

  @override
  String get lengthPreview => 'Длина / предпросмотр';

  @override
  String get any => 'Любая';

  @override
  String get short => 'Короткие <100 сл';

  @override
  String get medium => 'Средние 100–300';

  @override
  String get long => 'Длинные >300';

  @override
  String get multiParagraph => '2+ абзаца';

  @override
  String get timeWindow => 'Временной промежуток';

  @override
  String get all => 'Все';

  @override
  String get sources => 'Источники';

  @override
  String get allSources => 'Все источники';

  @override
  String get keyword => 'Ключевое слово';

  @override
  String get keywordHint => 'Название, краткое содержание или текст';

  @override
  String get reset => 'Сбросить';

  @override
  String get done => 'Готово';

  @override
  String get searchArticlesHint => 'Поиск статей...';

  @override
  String get retry => 'Повторить';

  @override
  String get noArticlesYet => 'Статей пока нет. Потяните для обновления.';

  @override
  String get noArticlesMatch => 'Статьи по текущим фильтрам не найдены.';

  @override
  String get untitled => 'Без названия';

  @override
  String get removedLike => 'Оценка «Нравится» убрана';

  @override
  String get likedArticle => 'Статья понравилась';

  @override
  String get removedFromSaved => 'Удалено из сохраненных';

  @override
  String get savedForLater => 'Сохранено на потом';

  @override
  String get markedUnread => 'Помечено как непрочитанное';

  @override
  String get markedRead => 'Помечено как прочитанное';

  @override
  String get undo => 'Отменить';

  @override
  String get publishDateUnknown => 'Дата публикации неизвестна';

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(Object count) {
    return '$count мин. назад';
  }

  @override
  String hoursAgo(Object count) {
    return '$count ч назад';
  }

  @override
  String daysAgo(Object count) {
    return '$count д. назад';
  }

  @override
  String weeksAgo(Object count) {
    return '$count нед. назад';
  }

  @override
  String monthsAgo(Object count) {
    return '$count мес. назад';
  }

  @override
  String yearsAgo(Object count) {
    return '$count г. назад';
  }

  @override
  String get fetched => 'получено';

  @override
  String get continueReading => 'Продолжить чтение';

  @override
  String get readerSavedForLater => 'Сохранено на потом';

  @override
  String get readerRemovedFromSaved => 'Удалено из сохраненных';

  @override
  String get resumingLastRead => 'Возобновление последней прочитанной статьи';

  @override
  String get startingPlayback =>
      'Запуск воспроизведения для непрочитанной статьи';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'Показать ридер';

  @override
  String get showWebView => 'Показать веб-вид';

  @override
  String get webviewUnsupported =>
      'Встроенный WebView поддерживается только на Android/iOS.\nВместо него отображается текстовый вид.';

  @override
  String byAuthor(Object author) {
    return 'Автор: $author';
  }

  @override
  String get markedReadSkipped =>
      'Помечено как прочитанное и переход к следующей';

  @override
  String get markUnread => 'Пометить как непрочитанное';

  @override
  String get markReadPlay =>
      'Пометить как прочитанное и воспроизвести следующее';

  @override
  String get previousArticle => 'Предыдущая статья';

  @override
  String get nextArticle => 'Следующая статья';

  @override
  String playingSection(Object current, Object total) {
    return 'Воспроизведение раздела $current/$total';
  }

  @override
  String get readAloudNotAvailable => 'Озвучивание недоступно для этой статьи.';

  @override
  String unreadCount(Object count) {
    return 'Непрочитанных: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'Встроенное видео поддерживается только на Android/iOS.';

  @override
  String get loadVideo => 'Загрузить видео';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get goAdFree => 'Без рекламы';

  @override
  String get goAdFreeSubtitle =>
      'Всего \$1/мес. Поддержите независимого разработчика.';

  @override
  String get pricePerMonth => '\$1/мес';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Подпишитесь за \$1/мес и получите:';

  @override
  String get premiumRemoveAds => 'Убрать всю рекламу';

  @override
  String get premiumCloudStorage => 'Облачное хранилище для ваших данных';

  @override
  String get premiumCloudSubscriptions => 'Сохранять подписки в облаке';

  @override
  String get premiumSync => 'Войти и синхронизировать между устройствами';

  @override
  String get premiumFolders => 'Неограниченная организация папок';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get subscribeNow => 'Подписаться \$1/мес';

  @override
  String get subscriptionComingSoon =>
      'Подписка скоро появится! С вас будет списываться \$1/мес.';

  @override
  String get sectionAdvanced => 'Расширенные';

  @override
  String get readTracking => 'Отслеживание чтения';

  @override
  String get readTrackingSubtitle =>
      'Автоматически помечать статьи как прочитанные на основе прогресса чтения';

  @override
  String get autoMarkRead => 'Автоматическая отметка по прогрессу';

  @override
  String get autoMarkReadSubtitle =>
      'Помечает как прочитанное, когда прокрутка или аудио достигает порога';

  @override
  String get autoMarkThreshold => 'Порог автоматической отметки';

  @override
  String progressNeeded(Object percent) {
    return 'Требуется $percent% прогресса';
  }

  @override
  String get sectionVoice => 'Голос и озвучивание';

  @override
  String get narrationSpeed => 'Скорость озвучивания по умолчанию';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = спокойный стандарт)';
  }

  @override
  String get defaultVoice => 'Голос по умолчанию';

  @override
  String get systemDefault => 'Системный';

  @override
  String get autoPlayNext => 'Автовоспроизведение следующей статьи';

  @override
  String get autoPlayNextSubtitle =>
      'Когда озвучивание заканчивается, перейти к следующему элементу';

  @override
  String get sectionData => 'Данные';

  @override
  String get lowDataMode => 'Предзагрузка в экономичном режиме';

  @override
  String get lowDataModeSubtitle =>
      'Предзагружать текст статей в фоне и использовать кэшированный контент, когда доступен';

  @override
  String get sectionAccessibility => 'Доступность';

  @override
  String get textSize => 'Размер текста';

  @override
  String get textSizeSubtitle =>
      'Применяется во всем приложении, включая статьи и навигацию.';

  @override
  String get sampleText =>
      'Съешь ещё этих мягких французских булок, да выпей чаю.';

  @override
  String get sectionSubscriptions => 'Подписки';

  @override
  String get manageSubscriptions => 'Управление подписками';

  @override
  String get manageSubscriptionsSubtitle =>
      'Добавлять или удалять ленты, на которые вы подписаны';

  @override
  String get manageFolders => 'Управление папками';

  @override
  String get manageFoldersSubtitle => 'Организовывать ленты в папки';

  @override
  String get importSubscriptions => 'Импорт подписок';

  @override
  String get importSubscriptionsSubtitle => 'Импорт через OPML-файл';

  @override
  String get exportSubscriptions => 'Экспорт подписок';

  @override
  String get exportSubscriptionsSubtitle => 'Экспортировать ленты в OPML';

  @override
  String get sectionThemes => 'Темы';

  @override
  String get themes => 'Темы';

  @override
  String get themesSubtitle => 'Светлая / Тёмная / Системная';

  @override
  String get selectTheme => 'Выбрать тему';

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get sectionLanguage => 'Язык';

  @override
  String get language => 'Язык';

  @override
  String get languageSubtitle => 'Русский';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageChinese => 'Китайский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageHindi => 'Хинди';

  @override
  String get languageArabic => 'Арабский';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languagePortuguese => 'Португальский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageKorean => 'Корейский';

  @override
  String get languageItalian => 'Итальянский';

  @override
  String get sectionLegal => 'Правовая информация';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get openSourceLicenses => 'Лицензии с открытым кодом';

  @override
  String get noFeedsFoundOpml => 'Ленты в OPML не найдены';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      many: '',
      few: 'ы',
      one: 'а',
    );
    return 'Импортировано $count лент$_temp0';
  }

  @override
  String get allFeedsAlreadyAdded => 'Все ленты уже были добавлены';

  @override
  String importFailed(Object error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get noSubscriptionsToExport => 'Нет подписок для экспорта';

  @override
  String exportedCount(Object count) {
    return 'Экспортировано $count лент(ы)';
  }

  @override
  String exportFailed(Object error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get exportShareText => 'Экспорт подписок Aware';

  @override
  String get exportShareSubject => 'Экспорт подписок Aware';

  @override
  String get savedArticlesTitle => 'Сохраненные статьи';

  @override
  String get noSavedArticlesYet => 'Сохраненных статей пока нет.';

  @override
  String error(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get privacyPolicyLastUpdated =>
      'Последнее обновление: 20 июня 2026 г.';

  @override
  String get privacyInfoWeCollect => 'Информация, которую мы собираем';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware не собирает, не хранит и не передает личные данные. Все данные приложения (ленты, статьи, прогресс чтения, настройки и предпочтения) хранятся локально на вашем устройстве и никогда не отправляются на сервер.';

  @override
  String get privacyThirdParty => 'Сторонние сервисы';

  @override
  String get privacyThirdPartyBody =>
      'Aware использует Google AdMob для показа рекламы. AdMob может собирать обезличенные данные об использовании и идентификаторы устройства для показа релевантной рекламы. Реклама показывается только с неперсонализированными запросами. Никакие данные пользователя не передаются рекламодателям.\n\nПолитика конфиденциальности Google применяется к данным, собираемым AdMob:\n';

  @override
  String get privacyDataStorage => 'Хранение данных';

  @override
  String get privacyDataStorageBody =>
      'Все подписки на ленты, статьи, прогресс чтения и настройки приложения хранятся локально в базе данных SQLite на вашем устройстве. Вы можете экспортировать свои данные в любое время через функцию экспорта OPML в Настройках.\n\nЧтобы удалить все данные, удалите приложение или очистите данные приложения в настройках устройства.';

  @override
  String get privacyContact => 'Контакты';

  @override
  String get privacyContactBody =>
      'Если у вас есть вопросы по этой политике конфиденциальности, свяжитесь с нами через каналы поддержки приложения.';
}
