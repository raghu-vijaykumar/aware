// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => '轻松掌握信息';

  @override
  String get onboardingLanguageTitle => '选择你的语言';

  @override
  String get onboardingLanguageDesc => '选择你偏好的应用界面语言。';

  @override
  String get onboardingWelcomeTitle => '欢迎使用 aware';

  @override
  String get onboardingWelcomeDesc => '你的个人订阅源阅读器。在一个地方了解重要信息。';

  @override
  String get onboardingOfflineTitle => '离线阅读';

  @override
  String get onboardingOfflineDesc => '订阅源已下载，你可以随时随地阅读。使用文字转语音收听。';

  @override
  String get onboardingNotifyTitle => '不错过任何文章';

  @override
  String get onboardingNotifyDesc => '新文章到达时接收通知。添加你的第一个订阅源开始使用。';

  @override
  String get next => '下一步';

  @override
  String get getStarted => '开始';

  @override
  String get skip => '跳过';

  @override
  String get tabFeeds => '订阅源';

  @override
  String get tabMarketplace => '市场';

  @override
  String get tabSettings => '设置';

  @override
  String get addFeedTitle => '添加 RSS 订阅源';

  @override
  String get addFeedUrlLabel => '订阅源 URL';

  @override
  String get addFeedUrlHint => 'https://example.com/feed.xml';

  @override
  String get cancel => '取消';

  @override
  String get add => '添加';

  @override
  String get feedAdded => '订阅源已添加';

  @override
  String failedToAddFeed(Object error) {
    return '添加订阅源失败：$error';
  }

  @override
  String get feedUrlRequired => '需要订阅源 URL';

  @override
  String get marketplaceTitle => '市场';

  @override
  String get marketplaceSubtitle => '按类别精选的 RSS 链接';

  @override
  String get marketplaceHeroTitle => '快速发现优质订阅源';

  @override
  String get marketplaceHeroDesc => '按主题浏览可信来源。点击关注即可立即添加到你的首页订阅源。';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count 个分类';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count 个订阅源';
  }

  @override
  String get marketplaceSearchHint => '搜索订阅源...';

  @override
  String get marketplaceUntitledFeed => '未命名的订阅源';

  @override
  String get marketplaceSubscribed => '已订阅';

  @override
  String get marketplaceFollow => '关注';

  @override
  String marketplaceSubscribedTo(Object title) {
    return '已订阅 $title';
  }

  @override
  String get marketplaceInvalidUrl => '无效的订阅源 URL';

  @override
  String get marketplaceUnreachable => '订阅失败：订阅源可能无法访问';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count 个精选来源';
  }

  @override
  String get signIn => '登录';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get passwordLabel => '密码';

  @override
  String get emailRequired => '输入你的电子邮件';

  @override
  String get passwordRequired => '输入你的密码';

  @override
  String get subscriptionsTitle => '订阅';

  @override
  String get subscriptionsEmpty => '还没有订阅。从市场添加订阅源！';

  @override
  String get untitledFeed => '未命名的订阅源';

  @override
  String get paused => '已暂停';

  @override
  String get resume => '恢复';

  @override
  String get pause => '暂停';

  @override
  String get unsubscribe => '取消订阅';

  @override
  String get unsubscribeTitle => '取消订阅';

  @override
  String unsubscribeConfirm(Object title) {
    return '取消订阅 $title？';
  }

  @override
  String get foldersTitle => '文件夹';

  @override
  String get createFolderTitle => '新建文件夹';

  @override
  String get folderNameHint => '文件夹名称';

  @override
  String get create => '创建';

  @override
  String get rename => '重命名';

  @override
  String get renameFolderTitle => '重命名文件夹';

  @override
  String get delete => '删除';

  @override
  String get deleteFolderTitle => '删除文件夹';

  @override
  String deleteFolderConfirm(Object name) {
    return '移除\"$name\"并取消其订阅源的分组？';
  }

  @override
  String get createFolderTooltip => '创建文件夹';

  @override
  String get noFoldersYet => '还没有文件夹';

  @override
  String get createFirstFolder => '创建你的第一个文件夹';

  @override
  String feedCount(num count) {
    return '$count 个订阅源';
  }

  @override
  String get filters => '筛选';

  @override
  String get unread => '未读';

  @override
  String get liked => '已赞';

  @override
  String get saved => '已保存';

  @override
  String get last24h => '最近 24 小时';

  @override
  String get last7d => '最近 7 天';

  @override
  String get last30d => '最近 30 天';

  @override
  String get engagement => '互动';

  @override
  String get unreadOnly => '仅未读';

  @override
  String get lengthPreview => '长度/预览';

  @override
  String get any => '任意';

  @override
  String get short => '短 <100 词';

  @override
  String get medium => '中 100-300';

  @override
  String get long => '长 >300';

  @override
  String get multiParagraph => '2+ 段落';

  @override
  String get timeWindow => '时间范围';

  @override
  String get all => '全部';

  @override
  String get sources => '来源';

  @override
  String get allSources => '所有来源';

  @override
  String get keyword => '关键词';

  @override
  String get keywordHint => '标题、摘要或内容';

  @override
  String get reset => '重置';

  @override
  String get done => '完成';

  @override
  String get searchArticlesHint => '搜索文章...';

  @override
  String get retry => '重试';

  @override
  String get noArticlesYet => '还没有文章。下拉刷新。';

  @override
  String get noArticlesMatch => '没有符合当前筛选条件的文章。';

  @override
  String get untitled => '未命名';

  @override
  String get removedLike => '已取消点赞';

  @override
  String get likedArticle => '已点赞文章';

  @override
  String get removedFromSaved => '已从保存中移除';

  @override
  String get savedForLater => '已保存供以后使用';

  @override
  String get markedUnread => '已标记为未读';

  @override
  String get markedRead => '已标记为已读';

  @override
  String get undo => '撤销';

  @override
  String get publishDateUnknown => '发布日期未知';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(Object count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(Object count) {
    return '$count 小时前';
  }

  @override
  String daysAgo(Object count) {
    return '$count 天前';
  }

  @override
  String weeksAgo(Object count) {
    return '$count 周前';
  }

  @override
  String monthsAgo(Object count) {
    return '$count 个月前';
  }

  @override
  String yearsAgo(Object count) {
    return '$count 年前';
  }

  @override
  String get fetched => '已获取';

  @override
  String get continueReading => '继续阅读';

  @override
  String get readerSavedForLater => '已保存供以后使用';

  @override
  String get readerRemovedFromSaved => '已从保存中移除';

  @override
  String get resumingLastRead => '继续上一次阅读的文章';

  @override
  String get startingPlayback => '开始播放未读文章';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => '显示阅读器';

  @override
  String get showWebView => '显示网页视图';

  @override
  String get webviewUnsupported => '应用内 WebView 仅在 Android/iOS 上支持。\n改为显示文本视图。';

  @override
  String byAuthor(Object author) {
    return '作者：$author';
  }

  @override
  String get markedReadSkipped => '已标记为已读并跳转到下一篇';

  @override
  String get markUnread => '标记为未读';

  @override
  String get markReadPlay => '标记为已读并播放下一篇';

  @override
  String get previousArticle => '上一篇文章';

  @override
  String get nextArticle => '下一篇文章';

  @override
  String playingSection(Object current, Object total) {
    return '正在播放部分 $current/$total';
  }

  @override
  String get readAloudNotAvailable => '此文章不支持朗读。';

  @override
  String unreadCount(Object count) {
    return '未读：$count';
  }

  @override
  String get embeddedVideoUnsupported => '嵌入式视频仅在 Android/iOS 上支持。';

  @override
  String get loadVideo => '加载视频';

  @override
  String get settingsTitle => '设置';

  @override
  String get goAdFree => '去除广告';

  @override
  String get goAdFreeSubtitle => '仅 \$1/月。支持独立开发者。';

  @override
  String get pricePerMonth => '\$1/月';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => '订阅仅 \$1/月，即可获得：';

  @override
  String get premiumRemoveAds => '去除所有广告';

  @override
  String get premiumCloudStorage => '数据云存储';

  @override
  String get premiumCloudSubscriptions => '在云端保存订阅';

  @override
  String get premiumSync => '登录并在设备间同步';

  @override
  String get premiumFolders => '无限文件夹组织';

  @override
  String get notNow => '稍后';

  @override
  String get comingSoon => '即将推出';

  @override
  String get subscribeNow => '订阅 \$1/月';

  @override
  String get subscriptionComingSoon => '订阅即将推出！每月将收取 \$1。';

  @override
  String get sectionAdvanced => '高级';

  @override
  String get readTracking => '阅读跟踪';

  @override
  String get readTrackingSubtitle => '根据阅读进度自动标记文章为已读';

  @override
  String get autoMarkRead => '按进度自动标记已读';

  @override
  String get autoMarkReadSubtitle => '当滚动或音频达到你的阈值时标记为已读';

  @override
  String get autoMarkThreshold => '自动标记阈值';

  @override
  String progressNeeded(Object percent) {
    return '需要 $percent% 的进度';
  }

  @override
  String get sectionVoice => '语音与朗读';

  @override
  String get narrationSpeed => '默认朗读速度';

  @override
  String speedLabel(Object speed) {
    return '${speed}x（1x = 平静默认）';
  }

  @override
  String get defaultVoice => '默认声音';

  @override
  String get systemDefault => '系统默认';

  @override
  String get autoPlayNext => '自动播放下一篇文章';

  @override
  String get autoPlayNextSubtitle => '朗读结束时，转到下一项';

  @override
  String get sectionData => '数据';

  @override
  String get lowDataMode => '低数据模式预取';

  @override
  String get lowDataModeSubtitle => '在后台预取文章文本，并在可用时优先使用缓存内容';

  @override
  String get sectionAccessibility => '无障碍';

  @override
  String get textSize => '文字大小';

  @override
  String get textSizeSubtitle => '适用于整个应用，包括文章和导航。';

  @override
  String get sampleText => '敏捷的棕色狐狸跳过了懒狗。';

  @override
  String get sectionSubscriptions => '订阅';

  @override
  String get manageSubscriptions => '管理订阅';

  @override
  String get manageSubscriptionsSubtitle => '添加或删除你关注的订阅源';

  @override
  String get manageFolders => '管理文件夹';

  @override
  String get manageFoldersSubtitle => '将订阅源组织到文件夹中';

  @override
  String get importSubscriptions => '导入订阅';

  @override
  String get importSubscriptionsSubtitle => '通过 OPML 文件导入';

  @override
  String get exportSubscriptions => '导出订阅';

  @override
  String get exportSubscriptionsSubtitle => '将你的订阅源导出为 OPML';

  @override
  String get sectionThemes => '主题';

  @override
  String get themes => '主题';

  @override
  String get themesSubtitle => '浅色 / 深色 / 系统';

  @override
  String get selectTheme => '选择主题';

  @override
  String get system => '系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get sectionLanguage => '语言';

  @override
  String get language => '语言';

  @override
  String get languageSubtitle => '中文';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageHindi => '印地语';

  @override
  String get languageArabic => '阿拉伯语';

  @override
  String get languageFrench => '法语';

  @override
  String get languagePortuguese => '葡萄牙语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageItalian => '意大利语';

  @override
  String get sectionLegal => '法律信息';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get noFeedsFoundOpml => '在 OPML 中未找到订阅源';

  @override
  String importedCount(num count) {
    return '已导入 $count 个订阅源';
  }

  @override
  String get allFeedsAlreadyAdded => '所有订阅源已添加';

  @override
  String importFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String get noSubscriptionsToExport => '没有可导出的订阅';

  @override
  String exportedCount(Object count) {
    return '已导出 $count 个订阅源';
  }

  @override
  String exportFailed(Object error) {
    return '导出失败：$error';
  }

  @override
  String get exportShareText => 'Aware 订阅导出';

  @override
  String get exportShareSubject => 'Aware 订阅导出';

  @override
  String get savedArticlesTitle => '已保存的文章';

  @override
  String get noSavedArticlesYet => '还没有已保存的文章。';

  @override
  String error(Object error) {
    return '错误：$error';
  }

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicyLastUpdated => '最后更新：2026 年 6 月 20 日';

  @override
  String get privacyInfoWeCollect => '我们收集的信息';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware 不会收集、存储或传输任何个人数据。所有应用数据（订阅源、文章、阅读进度、偏好和设置）均存储在设备本地，绝不会发送到任何服务器。';

  @override
  String get privacyThirdParty => '第三方服务';

  @override
  String get privacyThirdPartyBody =>
      'Aware 使用 Google AdMob 展示广告。AdMob 可能会收集非个人使用数据和设备标识符以提供相关广告。广告仅通过非个性化广告请求提供。不会与广告商共享任何用户数据。\n\nGoogle 的隐私政策适用于 AdMob 收集的数据：\n';

  @override
  String get privacyDataStorage => '数据存储';

  @override
  String get privacyDataStorageBody =>
      '所有订阅源、文章、阅读进度和应用偏好都存储在设备本地的 SQLite 数据库中。你可以随时通过设置中的 OPML 导出功能导出数据。\n\n要删除所有数据，请卸载应用或从设备设置中清除应用数据。';

  @override
  String get privacyContact => '联系方式';

  @override
  String get privacyContactBody => '如果你对此隐私政策有疑问，请通过应用的支持渠道联系我们。';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
