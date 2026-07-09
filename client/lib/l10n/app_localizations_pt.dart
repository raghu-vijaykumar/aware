// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Mantenha-se informado, sem esforço';

  @override
  String get onboardingLanguageTitle => 'Escolha seu idioma';

  @override
  String get onboardingLanguageDesc =>
      'Selecione seu idioma preferido para a interface do aplicativo.';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao aware';

  @override
  String get onboardingWelcomeDesc =>
      'Seu leitor de feeds pessoal. Mantenha-se informado sobre o que importa, tudo em um só lugar.';

  @override
  String get onboardingOfflineTitle => 'Ler offline';

  @override
  String get onboardingOfflineDesc =>
      'Os feeds são baixados para você ler a qualquer hora, em qualquer lugar. Ouça com conversão de texto em fala.';

  @override
  String get onboardingNotifyTitle => 'Nunca perca uma publicação';

  @override
  String get onboardingNotifyDesc =>
      'Receba notificações quando novos artigos chegarem. Adicione seu primeiro feed para começar.';

  @override
  String get next => 'Próximo';

  @override
  String get getStarted => 'Começar';

  @override
  String get skip => 'Pular';

  @override
  String get tabFeeds => 'Feeds';

  @override
  String get tabMarketplace => 'Marketplace';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get addFeedTitle => 'Adicionar feed RSS';

  @override
  String get addFeedUrlLabel => 'URL do feed';

  @override
  String get addFeedUrlHint => 'https://exemplo.com/feed.xml';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Adicionar';

  @override
  String get feedAdded => 'Feed adicionado';

  @override
  String failedToAddFeed(Object error) {
    return 'Falha ao adicionar feed: $error';
  }

  @override
  String get feedUrlRequired => 'A URL do feed é obrigatória';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get marketplaceSubtitle => 'Links RSS selecionados por categoria';

  @override
  String get marketplaceHeroTitle => 'Descubra feeds de qualidade rapidamente';

  @override
  String get marketplaceHeroDesc =>
      'Navegue por fontes confiáveis por tópico. Toque em Seguir para adicioná-las ao seu feed inicial instantaneamente.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count categorias';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count feeds';
  }

  @override
  String get marketplaceSearchHint => 'Pesquisar feeds...';

  @override
  String get marketplaceUntitledFeed => 'Feed sem título';

  @override
  String get marketplaceSubscribed => 'Inscrito';

  @override
  String get marketplaceFollow => 'Seguir';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'Inscrito em $title';
  }

  @override
  String get marketplaceInvalidUrl => 'URL de feed inválida';

  @override
  String get marketplaceUnreachable =>
      'Falha ao inscrever: o feed pode estar inacessível';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count fontes selecionadas';
  }

  @override
  String get signIn => 'Entrar';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get emailRequired => 'Digite seu e-mail';

  @override
  String get passwordRequired => 'Digite sua senha';

  @override
  String get subscriptionsTitle => 'Inscrições';

  @override
  String get subscriptionsEmpty =>
      'Nenhuma inscrição ainda. Adicione feeds do Marketplace!';

  @override
  String get untitledFeed => 'Feed sem título';

  @override
  String get paused => 'Pausado';

  @override
  String get resume => 'Continuar';

  @override
  String get pause => 'Pausar';

  @override
  String get unsubscribe => 'Cancelar inscrição';

  @override
  String get unsubscribeTitle => 'Cancelar inscrição';

  @override
  String unsubscribeConfirm(Object title) {
    return 'Cancelar inscrição em $title?';
  }

  @override
  String get foldersTitle => 'Pastas';

  @override
  String get createFolderTitle => 'Nova pasta';

  @override
  String get folderNameHint => 'Nome da pasta';

  @override
  String get create => 'Criar';

  @override
  String get rename => 'Renomear';

  @override
  String get renameFolderTitle => 'Renomear pasta';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteFolderTitle => 'Excluir pasta';

  @override
  String deleteFolderConfirm(Object name) {
    return 'Remover \"$name\" e desagrupar seus feeds?';
  }

  @override
  String get createFolderTooltip => 'Criar pasta';

  @override
  String get noFoldersYet => 'Nenhuma pasta ainda';

  @override
  String get createFirstFolder => 'Crie sua primeira pasta';

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
  String get filters => 'Filtros';

  @override
  String get unread => 'Não lidos';

  @override
  String get liked => 'Curtidos';

  @override
  String get saved => 'Salvos';

  @override
  String get last24h => 'Últimas 24h';

  @override
  String get last7d => 'Últimos 7d';

  @override
  String get last30d => 'Últimos 30d';

  @override
  String get engagement => 'Engajamento';

  @override
  String get unreadOnly => 'Apenas não lidos';

  @override
  String get lengthPreview => 'Tamanho / prévia';

  @override
  String get any => 'Qualquer';

  @override
  String get short => 'Curto <100p';

  @override
  String get medium => 'Médio 100–300';

  @override
  String get long => 'Longo >300';

  @override
  String get multiParagraph => '2+ parágrafos';

  @override
  String get timeWindow => 'Período';

  @override
  String get all => 'Todos';

  @override
  String get sources => 'Fontes';

  @override
  String get allSources => 'Todas as fontes';

  @override
  String get keyword => 'Palavra-chave';

  @override
  String get keywordHint => 'Título, resumo ou conteúdo';

  @override
  String get reset => 'Redefinir';

  @override
  String get done => 'Concluído';

  @override
  String get searchArticlesHint => 'Pesquisar artigos...';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noArticlesYet => 'Nenhum artigo ainda. Puxe para atualizar.';

  @override
  String get noArticlesMatch => 'Nenhum artigo corresponde aos filtros atuais.';

  @override
  String get untitled => 'Sem título';

  @override
  String get removedLike => 'Curtida removida';

  @override
  String get likedArticle => 'Artigo curtido';

  @override
  String get removedFromSaved => 'Removido dos salvos';

  @override
  String get savedForLater => 'Salvo para depois';

  @override
  String get markedUnread => 'Marcado como não lido';

  @override
  String get markedRead => 'Marcado como lido';

  @override
  String get undo => 'Desfazer';

  @override
  String get publishDateUnknown => 'Data de publicação desconhecida';

  @override
  String get justNow => 'Agora mesmo';

  @override
  String minutesAgo(Object count) {
    return 'Há $count min';
  }

  @override
  String hoursAgo(Object count) {
    return 'Há $count h';
  }

  @override
  String daysAgo(Object count) {
    return 'Há $count d';
  }

  @override
  String weeksAgo(Object count) {
    return 'Há $count sem';
  }

  @override
  String monthsAgo(Object count) {
    return 'Há $count meses';
  }

  @override
  String yearsAgo(Object count) {
    return 'Há $count anos';
  }

  @override
  String get fetched => 'obtido';

  @override
  String get continueReading => 'Continuar lendo';

  @override
  String get readerSavedForLater => 'Salvo para depois';

  @override
  String get readerRemovedFromSaved => 'Removido dos salvos';

  @override
  String get resumingLastRead => 'Retomando último artigo lido';

  @override
  String get startingPlayback => 'Iniciando reprodução para artigo não lido';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'Mostrar leitor';

  @override
  String get showWebView => 'Mostrar visualização web';

  @override
  String get webviewUnsupported =>
      'A WebView no aplicativo é compatível apenas com Android/iOS.\nMostrando visualização de texto como alternativa.';

  @override
  String byAuthor(Object author) {
    return 'Por $author';
  }

  @override
  String get markedReadSkipped => 'Marcado como lido e pulado para o próximo';

  @override
  String get markUnread => 'Marcar como não lido';

  @override
  String get markReadPlay => 'Marcar como lido e reproduzir próximo';

  @override
  String get previousArticle => 'Artigo anterior';

  @override
  String get nextArticle => 'Próximo artigo';

  @override
  String playingSection(Object current, Object total) {
    return 'Reproduzindo seção $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'Leitura em voz alta não disponível para este artigo.';

  @override
  String unreadCount(Object count) {
    return 'Não lidos: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'Vídeo incorporado é compatível apenas com Android/iOS.';

  @override
  String get loadVideo => 'Carregar vídeo';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get goAdFree => 'Sem anúncios';

  @override
  String get goAdFreeSubtitle =>
      'Apenas R\$ 5/mês. Apoie um desenvolvedor independente.';

  @override
  String get pricePerMonth => 'R\$ 5/mês';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Assine por R\$ 5/mês e obtenha:';

  @override
  String get premiumRemoveAds => 'Remover todos os anúncios';

  @override
  String get premiumCloudStorage => 'Armazenamento em nuvem para seus dados';

  @override
  String get premiumCloudSubscriptions => 'Salvar inscrições na nuvem';

  @override
  String get premiumSync => 'Faça login e sincronize entre dispositivos';

  @override
  String get premiumFolders => 'Organização ilimitada de pastas';

  @override
  String get notNow => 'Agora não';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get subscribeNow => 'Assinar R\$ 5/mês';

  @override
  String get subscriptionComingSoon =>
      'Assinatura em breve! Será cobrado R\$ 5/mês.';

  @override
  String get sectionAdvanced => 'Avançado';

  @override
  String get readTracking => 'Rastreamento de leitura';

  @override
  String get readTrackingSubtitle =>
      'Marcar artigos como lidos automaticamente com base no progresso da leitura';

  @override
  String get autoMarkRead => 'Marcar automaticamente por progresso';

  @override
  String get autoMarkReadSubtitle =>
      'Marca como lido quando a rolagem ou áudio atinge seu limite';

  @override
  String get autoMarkThreshold => 'Limite de marcação automática';

  @override
  String progressNeeded(Object percent) {
    return '$percent% de progresso necessário';
  }

  @override
  String get sectionVoice => 'Voz e leitura em voz alta';

  @override
  String get narrationSpeed => 'Velocidade de narração padrão';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = calmo padrão)';
  }

  @override
  String get defaultVoice => 'Voz padrão';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get autoPlayNext => 'Reproduzir próximo artigo automaticamente';

  @override
  String get autoPlayNextSubtitle =>
      'Quando a narração terminar, passar para o próximo item';

  @override
  String get sectionData => 'Dados';

  @override
  String get lowDataMode => 'Pré-carregamento em modo de dados reduzidos';

  @override
  String get lowDataModeSubtitle =>
      'Pré-carregar texto de artigos em segundo plano e preferir conteúdo em cache quando disponível';

  @override
  String get sectionAccessibility => 'Acessibilidade';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get textSizeSubtitle =>
      'Aplica-se a todo o aplicativo, incluindo artigos e navegação.';

  @override
  String get sampleText =>
      'A rápida raposa marrom pula sobre o cão preguiçoso.';

  @override
  String get sectionSubscriptions => 'Inscrições';

  @override
  String get manageSubscriptions => 'Gerenciar inscrições';

  @override
  String get manageSubscriptionsSubtitle =>
      'Adicionar ou remover os feeds que você segue';

  @override
  String get manageFolders => 'Gerenciar pastas';

  @override
  String get manageFoldersSubtitle => 'Organizar feeds em pastas';

  @override
  String get importSubscriptions => 'Importar inscrições';

  @override
  String get importSubscriptionsSubtitle => 'Importar via arquivo OPML';

  @override
  String get exportSubscriptions => 'Exportar inscrições';

  @override
  String get exportSubscriptionsSubtitle => 'Exportar seus feeds para OPML';

  @override
  String get sectionThemes => 'Temas';

  @override
  String get themes => 'Temas';

  @override
  String get themesSubtitle => 'Claro / Escuro / Sistema';

  @override
  String get selectTheme => 'Selecionar tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Português';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageChinese => 'Chinês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get sectionLegal => 'Legal';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get openSourceLicenses => 'Licenças de código aberto';

  @override
  String get noFeedsFoundOpml => 'Nenhum feed encontrado no OPML';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count feed$_temp0 importados';
  }

  @override
  String get allFeedsAlreadyAdded => 'Todos os feeds já foram adicionados';

  @override
  String importFailed(Object error) {
    return 'Falha na importação: $error';
  }

  @override
  String get noSubscriptionsToExport => 'Nenhuma inscrição para exportar';

  @override
  String exportedCount(Object count) {
    return '$count feed(s) exportados';
  }

  @override
  String exportFailed(Object error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get exportShareText => 'Exportação de inscrições do Aware';

  @override
  String get exportShareSubject => 'Exportação de inscrições do Aware';

  @override
  String get savedArticlesTitle => 'Artigos salvos';

  @override
  String get noSavedArticlesYet => 'Nenhum artigo salvo ainda.';

  @override
  String error(Object error) {
    return 'Erro: $error';
  }

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get privacyPolicyLastUpdated =>
      'Última atualização: 20 de junho de 2026';

  @override
  String get privacyInfoWeCollect => 'Informações que coletamos';

  @override
  String get privacyInfoWeCollectBody =>
      'O Aware não coleta, armazena ou transmite dados pessoais. Todos os dados do aplicativo (feeds, artigos, progresso de leitura, preferências e configurações) são armazenados localmente no seu dispositivo e nunca são enviados a nenhum servidor.';

  @override
  String get privacyThirdParty => 'Serviços de terceiros';

  @override
  String get privacyThirdPartyBody =>
      'O Aware usa o Google AdMob para exibir anúncios. O AdMob pode coletar dados de uso não pessoais e identificadores de dispositivo para veicular anúncios relevantes. Os anúncios são veiculados apenas com solicitações de anúncios não personalizadas. Nenhum dado do usuário é compartilhado com anunciantes.\n\nA Política de Privacidade do Google se aplica aos dados coletados pelo AdMob:\n';

  @override
  String get privacyDataStorage => 'Armazenamento de dados';

  @override
  String get privacyDataStorageBody =>
      'Todas as inscrições de feeds, artigos, progresso de leitura e preferências do aplicativo são armazenados localmente em um banco de dados SQLite no seu dispositivo. Você pode exportar seus dados a qualquer momento através do recurso de exportação OPML nas Configurações.\n\nPara excluir todos os dados, desinstale o aplicativo ou limpe os dados do aplicativo nas configurações do dispositivo.';

  @override
  String get privacyContact => 'Contato';

  @override
  String get privacyContactBody =>
      'Se você tiver dúvidas sobre esta política de privacidade, entre em contato conosco através dos canais de suporte do aplicativo.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
