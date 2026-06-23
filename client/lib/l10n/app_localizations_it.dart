// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Rimani informato, senza sforzo';

  @override
  String get onboardingLanguageTitle => 'Scegli la tua lingua';

  @override
  String get onboardingLanguageDesc =>
      'Seleziona la lingua preferita per l\'interfaccia dell\'app.';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in aware';

  @override
  String get onboardingWelcomeDesc =>
      'Il tuo feed reader personale. Rimani informato su ciò che conta, tutto in un unico posto.';

  @override
  String get onboardingOfflineTitle => 'Leggi offline';

  @override
  String get onboardingOfflineDesc =>
      'I feed vengono scaricati così puoi leggere sempre e ovunque. Ascolta con sintesi vocale.';

  @override
  String get onboardingNotifyTitle => 'Non perdere mai un articolo';

  @override
  String get onboardingNotifyDesc =>
      'Ricevi notifiche quando arrivano nuovi articoli. Aggiungi il tuo primo feed per iniziare.';

  @override
  String get next => 'Avanti';

  @override
  String get getStarted => 'Inizia';

  @override
  String get skip => 'Salta';

  @override
  String get tabFeeds => 'Feed';

  @override
  String get tabMarketplace => 'Marketplace';

  @override
  String get tabSettings => 'Impostazioni';

  @override
  String get addFeedTitle => 'Aggiungi feed RSS';

  @override
  String get addFeedUrlLabel => 'URL del feed';

  @override
  String get addFeedUrlHint => 'https://esempio.com/feed.xml';

  @override
  String get cancel => 'Annulla';

  @override
  String get add => 'Aggiungi';

  @override
  String get feedAdded => 'Feed aggiunto';

  @override
  String failedToAddFeed(Object error) {
    return 'Impossibile aggiungere il feed: $error';
  }

  @override
  String get feedUrlRequired => 'L\'URL del feed è obbligatoria';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get marketplaceSubtitle => 'Link RSS selezionati per categoria';

  @override
  String get marketplaceHeroTitle => 'Scopri feed di qualità velocemente';

  @override
  String get marketplaceHeroDesc =>
      'Esplora fonti affidabili per argomento. Tocca Segui per aggiungerle al tuo feed principale all\'istante.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count categorie';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count feed';
  }

  @override
  String get marketplaceSearchHint => 'Cerca feed...';

  @override
  String get marketplaceUntitledFeed => 'Feed senza titolo';

  @override
  String get marketplaceSubscribed => 'Iscritto';

  @override
  String get marketplaceFollow => 'Segui';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'Iscritto a $title';
  }

  @override
  String get marketplaceInvalidUrl => 'URL del feed non valida';

  @override
  String get marketplaceUnreachable =>
      'Iscrizione fallita: il feed potrebbe essere irraggiungibile';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count fonti selezionate';
  }

  @override
  String get signIn => 'Accedi';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequired => 'Inserisci la tua email';

  @override
  String get passwordRequired => 'Inserisci la tua password';

  @override
  String get subscriptionsTitle => 'Abbonamenti';

  @override
  String get subscriptionsEmpty =>
      'Ancora nessun abbonamento. Aggiungi feed dal Marketplace!';

  @override
  String get untitledFeed => 'Feed senza titolo';

  @override
  String get paused => 'In pausa';

  @override
  String get resume => 'Riprendi';

  @override
  String get pause => 'Pausa';

  @override
  String get unsubscribe => 'Annulla iscrizione';

  @override
  String get unsubscribeTitle => 'Annulla iscrizione';

  @override
  String unsubscribeConfirm(Object title) {
    return 'Annullare l\'iscrizione a $title?';
  }

  @override
  String get foldersTitle => 'Cartelle';

  @override
  String get createFolderTitle => 'Nuova cartella';

  @override
  String get folderNameHint => 'Nome cartella';

  @override
  String get create => 'Crea';

  @override
  String get rename => 'Rinomina';

  @override
  String get renameFolderTitle => 'Rinomina cartella';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteFolderTitle => 'Elimina cartella';

  @override
  String deleteFolderConfirm(Object name) {
    return 'Rimuovere \"$name\" e separare i suoi feed?';
  }

  @override
  String get createFolderTooltip => 'Crea cartella';

  @override
  String get noFoldersYet => 'Ancora nessuna cartella';

  @override
  String get createFirstFolder => 'Crea la tua prima cartella';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count feed$_temp0';
  }

  @override
  String get filters => 'Filtri';

  @override
  String get unread => 'Non letti';

  @override
  String get liked => 'Piaciuti';

  @override
  String get saved => 'Salvati';

  @override
  String get last24h => 'Ultime 24h';

  @override
  String get last7d => 'Ultimi 7g';

  @override
  String get last30d => 'Ultimi 30g';

  @override
  String get engagement => 'Interazione';

  @override
  String get unreadOnly => 'Solo non letti';

  @override
  String get lengthPreview => 'Lunghezza / anteprima';

  @override
  String get any => 'Qualsiasi';

  @override
  String get short => 'Corto <100p';

  @override
  String get medium => 'Medio 100–300';

  @override
  String get long => 'Lungo >300';

  @override
  String get multiParagraph => '2+ paragrafi';

  @override
  String get timeWindow => 'Intervallo di tempo';

  @override
  String get all => 'Tutti';

  @override
  String get sources => 'Fonti';

  @override
  String get allSources => 'Tutte le fonti';

  @override
  String get keyword => 'Parola chiave';

  @override
  String get keywordHint => 'Titolo, riassunto o contenuto';

  @override
  String get reset => 'Reimposta';

  @override
  String get done => 'Fatto';

  @override
  String get searchArticlesHint => 'Cerca articoli...';

  @override
  String get retry => 'Riprova';

  @override
  String get noArticlesYet => 'Ancora nessun articolo. Scorri per aggiornare.';

  @override
  String get noArticlesMatch =>
      'Nessun articolo corrisponde ai filtri correnti.';

  @override
  String get untitled => 'Senza titolo';

  @override
  String get removedLike => 'Mi piace rimosso';

  @override
  String get likedArticle => 'Articolo piaciuto';

  @override
  String get removedFromSaved => 'Rimosso dai salvati';

  @override
  String get savedForLater => 'Salvato per dopo';

  @override
  String get markedUnread => 'Segnato come non letto';

  @override
  String get markedRead => 'Segnato come letto';

  @override
  String get undo => 'Annulla';

  @override
  String get publishDateUnknown => 'Data di pubblicazione sconosciuta';

  @override
  String get justNow => 'Proprio ora';

  @override
  String minutesAgo(Object count) {
    return '$count min fa';
  }

  @override
  String hoursAgo(Object count) {
    return '$count h fa';
  }

  @override
  String daysAgo(Object count) {
    return '$count g fa';
  }

  @override
  String weeksAgo(Object count) {
    return '$count sett fa';
  }

  @override
  String monthsAgo(Object count) {
    return '$count mesi fa';
  }

  @override
  String yearsAgo(Object count) {
    return '$count anni fa';
  }

  @override
  String get fetched => 'recuperato';

  @override
  String get continueReading => 'Continua a leggere';

  @override
  String get readerSavedForLater => 'Salvato per dopo';

  @override
  String get readerRemovedFromSaved => 'Rimosso dai salvati';

  @override
  String get resumingLastRead => 'Riprendi ultimo articolo letto';

  @override
  String get startingPlayback => 'Avvio riproduzione per articolo non letto';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'Mostra lettore';

  @override
  String get showWebView => 'Mostra vista web';

  @override
  String get webviewUnsupported =>
      'La WebView nell\'app è supportata solo su Android/iOS.\nVerrà mostrata la vista testo.';

  @override
  String byAuthor(Object author) {
    return 'Di $author';
  }

  @override
  String get markedReadSkipped => 'Segnato come letto e passato al successivo';

  @override
  String get markUnread => 'Segna come non letto';

  @override
  String get markReadPlay => 'Segna come letto e riproduci il successivo';

  @override
  String get previousArticle => 'Articolo precedente';

  @override
  String get nextArticle => 'Articolo successivo';

  @override
  String playingSection(Object current, Object total) {
    return 'Riproduzione sezione $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'Lettura ad alta voce non disponibile per questo articolo.';

  @override
  String unreadCount(Object count) {
    return 'Non letti: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'Il video incorporato è supportato solo su Android/iOS.';

  @override
  String get loadVideo => 'Carica video';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get goAdFree => 'Niente pubblicità';

  @override
  String get goAdFreeSubtitle =>
      'Solo 1 €/mese. Supporta uno sviluppatore indipendente.';

  @override
  String get pricePerMonth => '1 €/mese';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Abbonati per 1 €/mese e ottieni:';

  @override
  String get premiumRemoveAds => 'Rimuovi tutte le pubblicità';

  @override
  String get premiumCloudStorage => 'Archiviazione cloud per i tuoi dati';

  @override
  String get premiumCloudSubscriptions => 'Salva gli abbonamenti nel cloud';

  @override
  String get premiumSync => 'Accedi e sincronizza tra dispositivi';

  @override
  String get premiumFolders => 'Organizzazione illimitata delle cartelle';

  @override
  String get notNow => 'Non ora';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get subscribeNow => 'Abbonati 1 €/mese';

  @override
  String get subscriptionComingSoon =>
      'Abbonamento in arrivo! Ti verrà addebitato 1 €/mese.';

  @override
  String get sectionAdvanced => 'Avanzate';

  @override
  String get readTracking => 'Tracciamento lettura';

  @override
  String get readTrackingSubtitle =>
      'Segna automaticamente gli articoli come letti in base al progresso';

  @override
  String get autoMarkRead => 'Segna automaticamente dal progresso';

  @override
  String get autoMarkReadSubtitle =>
      'Segna come letto quando lo scorrimento o l\'audio raggiunge la soglia';

  @override
  String get autoMarkThreshold => 'Soglia di segnatura automatica';

  @override
  String progressNeeded(Object percent) {
    return '$percent% di progresso necessario';
  }

  @override
  String get sectionVoice => 'Voce e lettura ad alta voce';

  @override
  String get narrationSpeed => 'Velocità di narrazione predefinita';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = calmo predefinito)';
  }

  @override
  String get defaultVoice => 'Voce predefinita';

  @override
  String get systemDefault => 'Predefinito del sistema';

  @override
  String get autoPlayNext => 'Riproduci automaticamente l\'articolo successivo';

  @override
  String get autoPlayNextSubtitle =>
      'Quando la narrazione termina, passa all\'elemento successivo';

  @override
  String get sectionData => 'Dati';

  @override
  String get lowDataMode => 'Precaricamento modalità dati ridotti';

  @override
  String get lowDataModeSubtitle =>
      'Precarica il testo degli articoli in background e preferisci i contenuti nella cache quando disponibili';

  @override
  String get sectionAccessibility => 'Accessibilità';

  @override
  String get textSize => 'Dimensione testo';

  @override
  String get textSizeSubtitle =>
      'Si applica a tutta l\'app, inclusi articoli e navigazione.';

  @override
  String get sampleText => 'La volpe marrone salta sopra il cane pigro.';

  @override
  String get sectionSubscriptions => 'Abbonamenti';

  @override
  String get manageSubscriptions => 'Gestisci abbonamenti';

  @override
  String get manageSubscriptionsSubtitle =>
      'Aggiungi o rimuovi i feed che segui';

  @override
  String get manageFolders => 'Gestisci cartelle';

  @override
  String get manageFoldersSubtitle => 'Organizza i feed in cartelle';

  @override
  String get importSubscriptions => 'Importa abbonamenti';

  @override
  String get importSubscriptionsSubtitle => 'Importa tramite file OPML';

  @override
  String get exportSubscriptions => 'Esporta abbonamenti';

  @override
  String get exportSubscriptionsSubtitle => 'Esporta i tuoi feed in OPML';

  @override
  String get sectionThemes => 'Temi';

  @override
  String get themes => 'Temi';

  @override
  String get themesSubtitle => 'Chiaro / Scuro / Sistema';

  @override
  String get selectTheme => 'Seleziona tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get sectionLanguage => 'Lingua';

  @override
  String get language => 'Lingua';

  @override
  String get languageSubtitle => 'Italiano';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageChinese => 'Cinese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Arabo';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get sectionLegal => 'Note legali';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get openSourceLicenses => 'Licenze open source';

  @override
  String get noFeedsFoundOpml => 'Nessun feed trovato nell\'OPML';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count feed$_temp0 importati';
  }

  @override
  String get allFeedsAlreadyAdded => 'Tutti i feed sono già stati aggiunti';

  @override
  String importFailed(Object error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get noSubscriptionsToExport => 'Nessun abbonamento da esportare';

  @override
  String exportedCount(Object count) {
    return '$count feed esportati';
  }

  @override
  String exportFailed(Object error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String get exportShareText => 'Esportazione abbonamenti Aware';

  @override
  String get exportShareSubject => 'Esportazione abbonamenti Aware';

  @override
  String get savedArticlesTitle => 'Articoli salvati';

  @override
  String get noSavedArticlesYet => 'Nessun articolo salvato ancora.';

  @override
  String error(Object error) {
    return 'Errore: $error';
  }

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get privacyPolicyLastUpdated => 'Ultimo aggiornamento: 20 giugno 2026';

  @override
  String get privacyInfoWeCollect => 'Informazioni che raccogliamo';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware non raccoglie, memorizza o trasmette dati personali. Tutti i dati dell\'app (feed, articoli, progresso di lettura, preferenze e impostazioni) sono memorizzati localmente sul tuo dispositivo e non vengono mai inviati a nessun server.';

  @override
  String get privacyThirdParty => 'Servizi di terze parti';

  @override
  String get privacyThirdPartyBody =>
      'Aware utilizza Google AdMob per mostrare annunci pubblicitari. AdMob può raccogliere dati di utilizzo non personali e identificatori del dispositivo per mostrare annunci pertinenti. Gli annunci vengono serviti solo con richieste non personalizzate. Nessun dato dell\'utente viene condiviso con gli inserzionisti.\n\nL\'informativa sulla privacy di Google si applica ai dati raccolti da AdMob:\n';

  @override
  String get privacyDataStorage => 'Archiviazione dei dati';

  @override
  String get privacyDataStorageBody =>
      'Tutti gli abbonamenti ai feed, articoli, progresso di lettura e preferenze dell\'app sono memorizzati localmente in un database SQLite sul tuo dispositivo. Puoi esportare i tuoi dati in qualsiasi momento tramite la funzione di esportazione OPML nelle Impostazioni.\n\nPer eliminare tutti i dati, disinstalla l\'app o cancella i dati dell\'app dalle impostazioni del dispositivo.';

  @override
  String get privacyContact => 'Contatto';

  @override
  String get privacyContactBody =>
      'Se hai domande su questa informativa sulla privacy, contattaci attraverso i canali di supporto dell\'app.';
}
