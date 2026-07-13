// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => '簡単に情報をキャッチ';

  @override
  String get onboardingLanguageTitle => '言語を選択';

  @override
  String get onboardingLanguageDesc => 'アプリのインターフェースに使用する言語を選択してください。';

  @override
  String get onboardingWelcomeTitle => 'aware へようこそ';

  @override
  String get onboardingWelcomeDesc => 'パーソナルフィードリーダー。大事な情報をひとつの場所で。';

  @override
  String get onboardingOfflineTitle => 'オフラインで読む';

  @override
  String get onboardingOfflineDesc =>
      'フィードがダウンロードされるので、いつでもどこでも読めます。テキスト読み上げで聴くこともできます。';

  @override
  String get onboardingNotifyTitle => '投稿を見逃さない';

  @override
  String get onboardingNotifyDesc => '新しい記事が届いたら通知を受け取ります。最初のフィードを追加して始めましょう。';

  @override
  String get next => '次へ';

  @override
  String get getStarted => '始める';

  @override
  String get skip => 'スキップ';

  @override
  String get tabFeeds => 'フィード';

  @override
  String get tabMarketplace => 'マーケットプレイス';

  @override
  String get tabSettings => '設定';

  @override
  String get addFeedTitle => 'RSSフィードを追加';

  @override
  String get addFeedUrlLabel => 'フィードURL';

  @override
  String get addFeedUrlHint => 'https://example.com/feed.xml';

  @override
  String get cancel => 'キャンセル';

  @override
  String get add => '追加';

  @override
  String get feedAdded => 'フィードを追加しました';

  @override
  String failedToAddFeed(Object error) {
    return 'フィードの追加に失敗しました: $error';
  }

  @override
  String get feedUrlRequired => 'フィードURLが必要です';

  @override
  String get marketplaceTitle => 'マーケットプレイス';

  @override
  String get marketplaceSubtitle => 'カテゴリ別に厳選されたRSSリンク';

  @override
  String get marketplaceHeroTitle => '高品質なフィードを素早く見つける';

  @override
  String get marketplaceHeroDesc =>
      'トピック別に信頼できるソースを閲覧。フォローをタップしてホームフィードに即座に追加。';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count カテゴリ';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count フィード';
  }

  @override
  String get marketplaceSearchHint => 'フィードを検索...';

  @override
  String get marketplaceUntitledFeed => '無題のフィード';

  @override
  String get marketplaceSubscribed => '購読中';

  @override
  String get marketplaceFollow => 'フォロー';

  @override
  String marketplaceSubscribedTo(Object title) {
    return '$title を購読しました';
  }

  @override
  String get marketplaceInvalidUrl => '無効なフィードURL';

  @override
  String get marketplaceUnreachable => '購読に失敗しました: フィードにアクセスできない可能性があります';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count の厳選ソース';
  }

  @override
  String get signIn => 'サインイン';

  @override
  String get emailLabel => 'メール';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get emailRequired => 'メールアドレスを入力';

  @override
  String get passwordRequired => 'パスワードを入力';

  @override
  String get subscriptionsTitle => '購読';

  @override
  String get subscriptionsEmpty => 'まだ購読がありません。マーケットプレイスからフィードを追加！';

  @override
  String get untitledFeed => '無題のフィード';

  @override
  String get paused => '一時停止中';

  @override
  String get resume => '再開';

  @override
  String get pause => '一時停止';

  @override
  String get unsubscribe => '購読解除';

  @override
  String get unsubscribeTitle => '購読解除';

  @override
  String unsubscribeConfirm(Object title) {
    return '$title の購読を解除しますか？';
  }

  @override
  String get create => '作成';

  @override
  String get rename => '名前を変更';

  @override
  String get delete => '削除';

  @override
  String feedCount(num count) {
    return '$count フィード';
  }

  @override
  String get filters => 'フィルター';

  @override
  String get unread => '未読';

  @override
  String get liked => 'いいね';

  @override
  String get saved => '保存済み';

  @override
  String get last24h => '24時間';

  @override
  String get last7d => '7日間';

  @override
  String get last30d => '30日間';

  @override
  String get engagement => 'エンゲージメント';

  @override
  String get unreadOnly => '未読のみ';

  @override
  String get lengthPreview => '長さ / プレビュー';

  @override
  String get any => 'すべて';

  @override
  String get short => '短い <100語';

  @override
  String get medium => '中程度 100-300';

  @override
  String get long => '長い >300';

  @override
  String get multiParagraph => '2段落以上';

  @override
  String get timeWindow => '期間';

  @override
  String get all => 'すべて';

  @override
  String get sources => 'ソース';

  @override
  String get allSources => 'すべてのソース';

  @override
  String get keyword => 'キーワード';

  @override
  String get keywordHint => 'タイトル、要約、または本文';

  @override
  String get reset => 'リセット';

  @override
  String get done => '完了';

  @override
  String get searchArticlesHint => '記事を検索...';

  @override
  String get retry => '再試行';

  @override
  String get noArticlesYet => '記事がまだありません。プルして更新。';

  @override
  String get noArticlesMatch => '現在のフィルターに一致する記事はありません。';

  @override
  String get untitled => '無題';

  @override
  String get removedLike => 'いいねを解除';

  @override
  String get likedArticle => '記事にいいね';

  @override
  String get removedFromSaved => '保存済みから削除';

  @override
  String get savedForLater => '後で読むために保存';

  @override
  String get markedUnread => '未読にマーク';

  @override
  String get markedRead => '既読にマーク';

  @override
  String get undo => '元に戻す';

  @override
  String get publishDateUnknown => '公開日不明';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(Object count) {
    return '$count 分前';
  }

  @override
  String hoursAgo(Object count) {
    return '$count 時間前';
  }

  @override
  String daysAgo(Object count) {
    return '$count 日前';
  }

  @override
  String weeksAgo(Object count) {
    return '$count 週間前';
  }

  @override
  String monthsAgo(Object count) {
    return '$count ヶ月前';
  }

  @override
  String yearsAgo(Object count) {
    return '$count 年前';
  }

  @override
  String get fetched => '取得済み';

  @override
  String get continueReading => '続きを読む';

  @override
  String get readerSavedForLater => '後で読むために保存';

  @override
  String get readerRemovedFromSaved => '保存済みから削除';

  @override
  String get resumingLastRead => '最後に読んだ記事を再開';

  @override
  String get startingPlayback => '未読記事の再生を開始';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'リーダー表示';

  @override
  String get showWebView => 'Web表示';

  @override
  String get webviewUnsupported =>
      'アプリ内WebViewはAndroid/iOSでのみサポートされています。\n代わりにテキスト表示を表示します。';

  @override
  String byAuthor(Object author) {
    return '$author 著';
  }

  @override
  String get markedReadSkipped => '既読にして次へスキップ';

  @override
  String get markUnread => '未読にする';

  @override
  String get markReadPlay => '既読にして次を再生';

  @override
  String get previousArticle => '前の記事';

  @override
  String get nextArticle => '次の記事';

  @override
  String playingSection(Object current, Object total) {
    return 'セクション $current/$total を再生中';
  }

  @override
  String get readAloudNotAvailable => 'この記事では読み上げ機能は利用できません。';

  @override
  String unreadCount(Object count) {
    return '未読: $count';
  }

  @override
  String get embeddedVideoUnsupported => '埋め込みビデオはAndroid/iOSでのみサポートされています。';

  @override
  String get loadVideo => 'ビデオを読み込む';

  @override
  String get settingsTitle => '設定';

  @override
  String get goAdFree => '広告を非表示に';

  @override
  String get goAdFreeSubtitle => 'わずか \$1/月。個人開発者を支援。';

  @override
  String get pricePerMonth => '\$1/月';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => '\$1/月で購読して以下を入手：';

  @override
  String get premiumRemoveAds => 'すべての広告を削除';

  @override
  String get premiumCloudStorage => 'データのクラウドストレージ';

  @override
  String get premiumCloudSubscriptions => '購読をクラウドに保存';

  @override
  String get premiumSync => 'サインインしてデバイス間で同期';

  @override
  String get notNow => '今はしない';

  @override
  String get comingSoon => '近日公開';

  @override
  String get subscribeNow => '購読 \$1/月';

  @override
  String get subscriptionComingSoon => '購読機能はまもなく公開！月額 \$1 が請求されます。';

  @override
  String get sectionAdvanced => '詳細設定';

  @override
  String get readTracking => '読書追跡';

  @override
  String get readTrackingSubtitle => '読書の進行度に基づいて記事を自動的に既読にする';

  @override
  String get autoMarkRead => '進行度で自動既読';

  @override
  String get autoMarkReadSubtitle => 'スクロールまたは音声がしきい値に達したときに既読としてマーク';

  @override
  String get autoMarkThreshold => '自動マークしきい値';

  @override
  String progressNeeded(Object percent) {
    return '$percent% の進行が必要';
  }

  @override
  String get sectionVoice => '音声と読み上げ';

  @override
  String get narrationSpeed => 'デフォルトの読み上げ速度';

  @override
  String speedLabel(Object speed) {
    return '$speed倍（1x = 標準）';
  }

  @override
  String get defaultVoice => 'デフォルト音声';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get autoPlayNext => '次の記事を自動再生';

  @override
  String get autoPlayNextSubtitle => '読み上げが終了したら、次のアイテムに移動';

  @override
  String get sectionAccessibility => 'アクセシビリティ';

  @override
  String get textSize => 'テキストサイズ';

  @override
  String get textSizeSubtitle => '記事やナビゲーションを含むアプリ全体に適用されます。';

  @override
  String get sampleText => 'すばしっこい茶色のキツネがのろまな犬を飛び越える。';

  @override
  String get sectionSubscriptions => '購読';

  @override
  String get manageSubscriptions => '購読を管理';

  @override
  String get manageSubscriptionsSubtitle => 'フォローしているフィードを追加または削除';

  @override
  String get importSubscriptions => '購読をインポート';

  @override
  String get importSubscriptionsSubtitle => 'OPMLファイルからインポート';

  @override
  String get exportSubscriptions => '購読をエクスポート';

  @override
  String get exportSubscriptionsSubtitle => 'フィードをOPMLにエクスポート';

  @override
  String get sectionThemes => 'テーマ';

  @override
  String get themes => 'テーマ';

  @override
  String get themesSubtitle => 'ライト / ダーク / システム';

  @override
  String get selectTheme => 'テーマを選択';

  @override
  String get system => 'システム';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get sectionLanguage => '言語';

  @override
  String get language => '言語';

  @override
  String get languageSubtitle => '日本語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get sectionLegal => '法的情報';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get noFeedsFoundOpml => 'OPMLにフィードが見つかりませんでした';

  @override
  String importedCount(num count) {
    return '$count フィードをインポートしました';
  }

  @override
  String get allFeedsAlreadyAdded => 'すべてのフィードは既に追加されています';

  @override
  String importFailed(Object error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get noSubscriptionsToExport => 'エクスポートする購読がありません';

  @override
  String exportedCount(Object count) {
    return '$count フィードをエクスポートしました';
  }

  @override
  String exportFailed(Object error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get exportShareText => 'Aware 購読エクスポート';

  @override
  String get exportShareSubject => 'Aware 購読エクスポート';

  @override
  String get savedArticlesTitle => '保存した記事';

  @override
  String get noSavedArticlesYet => '保存した記事はまだありません。';

  @override
  String error(Object error) {
    return 'エラー: $error';
  }

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get privacyPolicyLastUpdated => '最終更新: 2026年6月20日';

  @override
  String get privacyInfoWeCollect => '収集する情報';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware は個人データを収集、保存、送信しません。すべてのアプリデータ（フィード、記事、読書進行度、設定）はお使いのデバイスにローカルに保存され、サーバーに送信されることは決してありません。';

  @override
  String get privacyThirdParty => '第三者サービス';

  @override
  String get privacyThirdPartyBody =>
      'Aware は Google AdMob を使用して広告を表示します。AdMob は関連広告を配信するために、非個人の使用データおよびデバイス識別子を収集する場合があります。広告は非パーソナライズド広告リクエストでのみ配信されます。ユーザーデータが広告主と共有されることはありません。\n\nGoogle のプライバシーポリシーが AdMob によって収集されたデータに適用されます：\n';

  @override
  String get privacyDataStorage => 'データストレージ';

  @override
  String get privacyDataStorageBody =>
      'すべてのフィード購読、記事、読書進行度、アプリ設定は、お使いのデバイスの SQLite データベースにローカルに保存されます。設定の OPML エクスポート機能を使用して、いつでもデータをエクスポートできます。\n\nすべてのデータを削除するには、アプリをアンインストールするか、デバイス設定からアプリデータを消去してください。';

  @override
  String get privacyContact => 'お問い合わせ';

  @override
  String get privacyContactBody =>
      'このプライバシーポリシーについてご質問がある場合は、アプリのサポートチャネルからお問い合わせください。';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
