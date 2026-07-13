// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => '쉽게 정보를 받아보세요';

  @override
  String get onboardingLanguageTitle => '언어를 선택하세요';

  @override
  String get onboardingLanguageDesc => '앱 인터페이스에 사용할 선호 언어를 선택하세요.';

  @override
  String get onboardingWelcomeTitle => 'aware에 오신 것을 환영합니다';

  @override
  String get onboardingWelcomeDesc => '나만의 피드 리더입니다. 중요한 정보를 한 곳에서 확인하세요.';

  @override
  String get onboardingOfflineTitle => '오프라인으로 읽기';

  @override
  String get onboardingOfflineDesc =>
      '피드가 다운로드되어 언제 어디서나 읽을 수 있습니다. 텍스트 음성 변환으로 들어보세요.';

  @override
  String get onboardingNotifyTitle => '게시물을 놓치지 마세요';

  @override
  String get onboardingNotifyDesc =>
      '새 기사가 도착하면 알림을 받습니다. 첫 번째 피드를 추가하여 시작하세요.';

  @override
  String get next => '다음';

  @override
  String get getStarted => '시작하기';

  @override
  String get skip => '건너뛰기';

  @override
  String get tabFeeds => '피드';

  @override
  String get tabMarketplace => '마켓';

  @override
  String get tabSettings => '설정';

  @override
  String get addFeedTitle => 'RSS 피드 추가';

  @override
  String get addFeedUrlLabel => '피드 URL';

  @override
  String get addFeedUrlHint => 'https://example.com/feed.xml';

  @override
  String get cancel => '취소';

  @override
  String get add => '추가';

  @override
  String get feedAdded => '피드가 추가되었습니다';

  @override
  String failedToAddFeed(Object error) {
    return '피드를 추가하지 못했습니다: $error';
  }

  @override
  String get feedUrlRequired => '피드 URL이 필요합니다';

  @override
  String get marketplaceTitle => '마켓';

  @override
  String get marketplaceSubtitle => '카테고리별 큐레이션 RSS 링크';

  @override
  String get marketplaceHeroTitle => '양질의 피드를 빠르게 찾아보세요';

  @override
  String get marketplaceHeroDesc =>
      '신뢰할 수 있는 소스를 주제별로 둘러보세요. 팔로우를 탭하여 홈 피드에 즉시 추가하세요.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count 카테고리';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count 피드';
  }

  @override
  String get marketplaceSearchHint => '피드 검색...';

  @override
  String get marketplaceUntitledFeed => '제목 없는 피드';

  @override
  String get marketplaceSubscribed => '구독 중';

  @override
  String get marketplaceFollow => '팔로우';

  @override
  String marketplaceSubscribedTo(Object title) {
    return '$title 구독 중';
  }

  @override
  String get marketplaceInvalidUrl => '잘못된 피드 URL';

  @override
  String get marketplaceUnreachable => '구독 실패: 피드에 접근할 수 없을 수 있습니다';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count 선별된 소스';
  }

  @override
  String get signIn => '로그인';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get emailRequired => '이메일을 입력하세요';

  @override
  String get passwordRequired => '비밀번호를 입력하세요';

  @override
  String get subscriptionsTitle => '구독';

  @override
  String get subscriptionsEmpty => '아직 구독이 없습니다. 마켓에서 피드를 추가하세요!';

  @override
  String get untitledFeed => '제목 없는 피드';

  @override
  String get paused => '일시 중지됨';

  @override
  String get resume => '재개';

  @override
  String get pause => '일시 중지';

  @override
  String get unsubscribe => '구독 취소';

  @override
  String get unsubscribeTitle => '구독 취소';

  @override
  String unsubscribeConfirm(Object title) {
    return '$title 구독을 취소하시겠습니까?';
  }

  @override
  String get create => '만들기';

  @override
  String get rename => '이름 변경';

  @override
  String get delete => '삭제';

  @override
  String feedCount(num count) {
    return '피드 $count개';
  }

  @override
  String get filters => '필터';

  @override
  String get unread => '읽지 않음';

  @override
  String get liked => '좋아요';

  @override
  String get saved => '저장됨';

  @override
  String get last24h => '지난 24시간';

  @override
  String get last7d => '지난 7일';

  @override
  String get last30d => '지난 30일';

  @override
  String get engagement => '참여';

  @override
  String get unreadOnly => '읽지 않은 항목만';

  @override
  String get lengthPreview => '길이 / 미리보기';

  @override
  String get any => '모두';

  @override
  String get short => '짧음 <100단어';

  @override
  String get medium => '중간 100-300';

  @override
  String get long => '김 >300';

  @override
  String get multiParagraph => '2+ 문단';

  @override
  String get timeWindow => '시간 범위';

  @override
  String get all => '전체';

  @override
  String get sources => '소스';

  @override
  String get allSources => '모든 소스';

  @override
  String get keyword => '키워드';

  @override
  String get keywordHint => '제목, 요약 또는 내용';

  @override
  String get reset => '초기화';

  @override
  String get done => '완료';

  @override
  String get searchArticlesHint => '기사 검색...';

  @override
  String get retry => '재시도';

  @override
  String get noArticlesYet => '아직 기사가 없습니다. 당겨서 새로고침하세요.';

  @override
  String get noArticlesMatch => '현재 필터와 일치하는 기사가 없습니다.';

  @override
  String get untitled => '제목 없음';

  @override
  String get removedLike => '좋아요 취소됨';

  @override
  String get likedArticle => '기사에 좋아요를 표시했습니다';

  @override
  String get removedFromSaved => '저장 목록에서 제거됨';

  @override
  String get savedForLater => '나중을 위해 저장됨';

  @override
  String get markedUnread => '읽지 않음으로 표시';

  @override
  String get markedRead => '읽음으로 표시';

  @override
  String get undo => '실행 취소';

  @override
  String get publishDateUnknown => '게시 날짜를 알 수 없음';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(Object count) {
    return '$count분 전';
  }

  @override
  String hoursAgo(Object count) {
    return '$count시간 전';
  }

  @override
  String daysAgo(Object count) {
    return '$count일 전';
  }

  @override
  String weeksAgo(Object count) {
    return '$count주 전';
  }

  @override
  String monthsAgo(Object count) {
    return '$count개월 전';
  }

  @override
  String yearsAgo(Object count) {
    return '$count년 전';
  }

  @override
  String get fetched => '가져옴';

  @override
  String get continueReading => '계속 읽기';

  @override
  String get readerSavedForLater => '나중을 위해 저장됨';

  @override
  String get readerRemovedFromSaved => '저장 목록에서 제거됨';

  @override
  String get resumingLastRead => '마지막으로 읽은 기사 재개';

  @override
  String get startingPlayback => '읽지 않은 기사 재생 시작';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => '리더 보기';

  @override
  String get showWebView => '웹 보기';

  @override
  String get webviewUnsupported =>
      '앱 내 WebView는 Android/iOS에서만 지원됩니다.\n대신 텍스트 보기를 표시합니다.';

  @override
  String byAuthor(Object author) {
    return '$author 작성';
  }

  @override
  String get markedReadSkipped => '읽음 표시 및 다음으로 건너뛰기';

  @override
  String get markUnread => '읽지 않음으로 표시';

  @override
  String get markReadPlay => '읽음으로 표시 및 다음 재생';

  @override
  String get previousArticle => '이전 기사';

  @override
  String get nextArticle => '다음 기사';

  @override
  String playingSection(Object current, Object total) {
    return '섹션 $current/$total 재생 중';
  }

  @override
  String get readAloudNotAvailable => '이 기사에서는 소리내어 읽기를 사용할 수 없습니다.';

  @override
  String unreadCount(Object count) {
    return '읽지 않음: $count';
  }

  @override
  String get embeddedVideoUnsupported => '임베디드 비디오는 Android/iOS에서만 지원됩니다.';

  @override
  String get loadVideo => '비디오 로드';

  @override
  String get settingsTitle => '설정';

  @override
  String get goAdFree => '광고 제거';

  @override
  String get goAdFreeSubtitle => '월 \$1만 있습니다. 인디 개발자를 지원하세요.';

  @override
  String get pricePerMonth => '\$1/월';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => '월 \$1에 구독하고 다음을 받으세요:';

  @override
  String get premiumRemoveAds => '모든 광고 제거';

  @override
  String get premiumCloudStorage => '데이터 클라우드 저장소';

  @override
  String get premiumCloudSubscriptions => '클라우드에 구독 저장';

  @override
  String get premiumSync => '로그인하여 기기 간 동기화';

  @override
  String get notNow => '나중에';

  @override
  String get comingSoon => '출시 예정';

  @override
  String get subscribeNow => '구독 \$1/월';

  @override
  String get subscriptionComingSoon => '구독 기능이 곧 출시됩니다! 월 \$1이 청구됩니다.';

  @override
  String get sectionAdvanced => '고급';

  @override
  String get readTracking => '읽기 추적';

  @override
  String get readTrackingSubtitle => '읽기 진행률에 따라 기사를 자동으로 읽음으로 표시';

  @override
  String get autoMarkRead => '진행률에 따라 자동 읽음 표시';

  @override
  String get autoMarkReadSubtitle => '스크롤 또는 오디오가 임계값에 도달하면 읽음으로 표시';

  @override
  String get autoMarkThreshold => '자동 표시 임계값';

  @override
  String progressNeeded(Object percent) {
    return '$percent% 진행 필요';
  }

  @override
  String get sectionVoice => '음성 및 소리내어 읽기';

  @override
  String get narrationSpeed => '기본 읽어주기 속도';

  @override
  String speedLabel(Object speed) {
    return '$speed배 (1x = 기본값)';
  }

  @override
  String get defaultVoice => '기본 음성';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get autoPlayNext => '다음 기사 자동 재생';

  @override
  String get autoPlayNextSubtitle => '읽어주기가 종료되면 다음 항목으로 이동';

  @override
  String get sectionAccessibility => '접근성';

  @override
  String get textSize => '텍스트 크기';

  @override
  String get textSizeSubtitle => '기사 및 탐색을 포함한 앱 전체에 적용됩니다.';

  @override
  String get sampleText => '빠른 갈색 여우가 게으른 개를 뛰어넘습니다.';

  @override
  String get sectionSubscriptions => '구독';

  @override
  String get manageSubscriptions => '구독 관리';

  @override
  String get manageSubscriptionsSubtitle => '팔로우하는 피드 추가 또는 제거';

  @override
  String get importSubscriptions => '구독 가져오기';

  @override
  String get importSubscriptionsSubtitle => 'OPML 파일을 통해 가져오기';

  @override
  String get exportSubscriptions => '구독 내보내기';

  @override
  String get exportSubscriptionsSubtitle => '피드를 OPML로 내보내기';

  @override
  String get sectionThemes => '테마';

  @override
  String get themes => '테마';

  @override
  String get themesSubtitle => '라이트 / 다크 / 시스템';

  @override
  String get selectTheme => '테마 선택';

  @override
  String get system => '시스템';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get sectionLanguage => '언어';

  @override
  String get language => '언어';

  @override
  String get languageSubtitle => '한국어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get sectionLegal => '법적 고지';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get openSourceLicenses => '오픈소스 라이선스';

  @override
  String get noFeedsFoundOpml => 'OPML에서 피드를 찾을 수 없습니다';

  @override
  String importedCount(num count) {
    return '피드 $count개를 가져왔습니다';
  }

  @override
  String get allFeedsAlreadyAdded => '모든 피드가 이미 추가되었습니다';

  @override
  String importFailed(Object error) {
    return '가져오기 실패: $error';
  }

  @override
  String get noSubscriptionsToExport => '내보낼 구독이 없습니다';

  @override
  String exportedCount(Object count) {
    return '피드 $count개를 내보냈습니다';
  }

  @override
  String exportFailed(Object error) {
    return '내보내기 실패: $error';
  }

  @override
  String get exportShareText => 'Aware 구독 내보내기';

  @override
  String get exportShareSubject => 'Aware 구독 내보내기';

  @override
  String get savedArticlesTitle => '저장된 기사';

  @override
  String get noSavedArticlesYet => '아직 저장된 기사가 없습니다.';

  @override
  String error(Object error) {
    return '오류: $error';
  }

  @override
  String get privacyPolicyTitle => '개인정보 처리방침';

  @override
  String get privacyPolicyLastUpdated => '최종 업데이트: 2026년 6월 20일';

  @override
  String get privacyInfoWeCollect => '수집하는 정보';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware는 개인 데이터를 수집, 저장 또는 전송하지 않습니다. 모든 앱 데이터(피드, 기사, 읽기 진행률, 기본 설정)는 기기에 로컬로 저장되며 서버로 전송되지 않습니다.';

  @override
  String get privacyThirdParty => '타사 서비스';

  @override
  String get privacyThirdPartyBody =>
      'Aware는 Google AdMob을 사용하여 광고를 표시합니다. AdMob은 관련 광고를 제공하기 위해 비개인 사용 데이터 및 기기 식별자를 수집할 수 있습니다. 광고는 비개인화 광고 요청으로만 제공됩니다. 사용자 데이터가 광고주와 공유되지 않습니다.\n\nGoogle의 개인정보 처리방침이 AdMob에서 수집한 데이터에 적용됩니다:\n';

  @override
  String get privacyDataStorage => '데이터 저장';

  @override
  String get privacyDataStorageBody =>
      '모든 피드 구독, 기사, 읽기 진행률 및 앱 기본 설정은 기기의 SQLite 데이터베이스에 로컬로 저장됩니다. 설정의 OPML 내보내기 기능을 통해 언제든지 데이터를 내보낼 수 있습니다.\n\n모든 데이터를 삭제하려면 앱을 제거하거나 기기 설정에서 앱 데이터를 지우세요.';

  @override
  String get privacyContact => '문의';

  @override
  String get privacyContactBody =>
      '이 개인정보 처리방침에 대해 문의사항이 있으면 앱의 지원 채널을 통해 문의해 주세요.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
