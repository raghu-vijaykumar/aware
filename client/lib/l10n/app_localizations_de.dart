// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Bleib informiert, mühelos';

  @override
  String get onboardingLanguageTitle => 'Wähle deine Sprache';

  @override
  String get onboardingLanguageDesc =>
      'Wähle deine bevorzugte Sprache für die App-Oberfläche.';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei aware';

  @override
  String get onboardingWelcomeDesc =>
      'Dein persönlicher Feed-Reader. Bleib informiert, was zählt – alles an einem Ort.';

  @override
  String get onboardingOfflineTitle => 'Offline lesen';

  @override
  String get onboardingOfflineDesc =>
      'Feeds werden heruntergeladen, damit du jederzeit und überall lesen kannst. Höre mit Text-to-Speech.';

  @override
  String get onboardingNotifyTitle => 'Verpasse keinen Beitrag';

  @override
  String get onboardingNotifyDesc =>
      'Erhalte Benachrichtigungen bei neuen Artikeln. Füge deinen ersten Feed hinzu.';

  @override
  String get next => 'Weiter';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get skip => 'Überspringen';

  @override
  String get tabFeeds => 'Feeds';

  @override
  String get tabMarketplace => 'Marktplatz';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get addFeedTitle => 'RSS-Feed hinzufügen';

  @override
  String get addFeedUrlLabel => 'Feed-URL';

  @override
  String get addFeedUrlHint => 'https://beispiel.de/feed.xml';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get feedAdded => 'Feed hinzugefügt';

  @override
  String failedToAddFeed(Object error) {
    return 'Feed konnte nicht hinzugefügt werden: $error';
  }

  @override
  String get feedUrlRequired => 'Feed-URL ist erforderlich';

  @override
  String get marketplaceTitle => 'Marktplatz';

  @override
  String get marketplaceSubtitle => 'Kuratierte RSS-Links nach Kategorie';

  @override
  String get marketplaceHeroTitle =>
      'Entdecke qualitativ hochwertige Feeds schnell';

  @override
  String get marketplaceHeroDesc =>
      'Durchsuche vertrauenswürdige Quellen nach Thema. Tippe auf Folgen, um sie sofort zu deinem Feed hinzuzufügen.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count Kategorien';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count Feeds';
  }

  @override
  String get marketplaceSearchHint => 'Feeds durchsuchen...';

  @override
  String get marketplaceUntitledFeed => 'Unbenannter Feed';

  @override
  String get marketplaceSubscribed => 'Abonniert';

  @override
  String get marketplaceFollow => 'Folgen';

  @override
  String marketplaceSubscribedTo(Object title) {
    return '$title abonniert';
  }

  @override
  String get marketplaceInvalidUrl => 'Ungültige Feed-URL';

  @override
  String get marketplaceUnreachable =>
      'Abonnieren fehlgeschlagen: Feed möglicherweise nicht erreichbar';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count kuratierte Quellen';
  }

  @override
  String get signIn => 'Anmelden';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get emailRequired => 'Gib deine E-Mail ein';

  @override
  String get passwordRequired => 'Gib dein Passwort ein';

  @override
  String get subscriptionsTitle => 'Abonnements';

  @override
  String get subscriptionsEmpty =>
      'Noch keine Abonnements. Füge Feeds vom Marktplatz hinzu!';

  @override
  String get untitledFeed => 'Unbenannter Feed';

  @override
  String get paused => 'Pausiert';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get pause => 'Pausieren';

  @override
  String get unsubscribe => 'Abonnieren beenden';

  @override
  String get unsubscribeTitle => 'Abonnieren beenden';

  @override
  String unsubscribeConfirm(Object title) {
    return '$title abbestellen?';
  }

  @override
  String get create => 'Erstellen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get delete => 'Löschen';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count Feed$_temp0';
  }

  @override
  String get filters => 'Filter';

  @override
  String get unread => 'Ungelesen';

  @override
  String get liked => 'Gefällt mir';

  @override
  String get saved => 'Gespeichert';

  @override
  String get last24h => 'Letzte 24h';

  @override
  String get last7d => 'Letzte 7d';

  @override
  String get last30d => 'Letzte 30d';

  @override
  String get engagement => 'Interaktion';

  @override
  String get unreadOnly => 'Nur ungelesene';

  @override
  String get lengthPreview => 'Länge / Vorschau';

  @override
  String get any => 'Alle';

  @override
  String get short => 'Kurz <100 W';

  @override
  String get medium => 'Mittel 100–300';

  @override
  String get long => 'Lang >300';

  @override
  String get multiParagraph => '2+ Absätze';

  @override
  String get timeWindow => 'Zeitraum';

  @override
  String get all => 'Alle';

  @override
  String get sources => 'Quellen';

  @override
  String get allSources => 'Alle Quellen';

  @override
  String get keyword => 'Stichwort';

  @override
  String get keywordHint => 'Titel, Zusammenfassung oder Inhalt';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get done => 'Fertig';

  @override
  String get searchArticlesHint => 'Artikel durchsuchen...';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noArticlesYet => 'Noch keine Artikel. Zum Aktualisieren ziehen.';

  @override
  String get noArticlesMatch =>
      'Keine Artikel entsprechen den aktuellen Filtern.';

  @override
  String get untitled => 'Unbenannt';

  @override
  String get removedLike => 'Gefällt mir entfernt';

  @override
  String get likedArticle => 'Artikel gefällt mir';

  @override
  String get removedFromSaved => 'Aus Gespeichert entfernt';

  @override
  String get savedForLater => 'Für später gespeichert';

  @override
  String get markedUnread => 'Als ungelesen markiert';

  @override
  String get markedRead => 'Als gelesen markiert';

  @override
  String get undo => 'Rückgängig';

  @override
  String get publishDateUnknown => 'Veröffentlichungsdatum unbekannt';

  @override
  String get justNow => 'Gerade eben';

  @override
  String minutesAgo(Object count) {
    return 'Vor $count Min.';
  }

  @override
  String hoursAgo(Object count) {
    return 'Vor $count Std.';
  }

  @override
  String daysAgo(Object count) {
    return 'Vor $count Tagen';
  }

  @override
  String weeksAgo(Object count) {
    return 'Vor $count Wo.';
  }

  @override
  String monthsAgo(Object count) {
    return 'Vor $count Mon.';
  }

  @override
  String yearsAgo(Object count) {
    return 'Vor $count J.';
  }

  @override
  String get fetched => 'abgerufen';

  @override
  String get continueReading => 'Weiterlesen';

  @override
  String get readerSavedForLater => 'Für später gespeichert';

  @override
  String get readerRemovedFromSaved => 'Aus Gespeichert entfernt';

  @override
  String get resumingLastRead => 'Letzten gelesenen Artikel fortsetzen';

  @override
  String get startingPlayback => 'Starte Wiedergabe für ungelesenen Artikel';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'Reader anzeigen';

  @override
  String get showWebView => 'Webansicht anzeigen';

  @override
  String get webviewUnsupported =>
      'Die In-App-WebView wird nur unter Android/iOS unterstützt.\nStattdessen wird die Textansicht angezeigt.';

  @override
  String byAuthor(Object author) {
    return 'Von $author';
  }

  @override
  String get markedReadSkipped =>
      'Als gelesen markiert & zum nächsten gesprungen';

  @override
  String get markUnread => 'Als ungelesen markieren';

  @override
  String get markReadPlay => 'Als gelesen markieren & nächstes abspielen';

  @override
  String get previousArticle => 'Vorheriger Artikel';

  @override
  String get nextArticle => 'Nächster Artikel';

  @override
  String playingSection(Object current, Object total) {
    return 'Abschnitt $current/$total wird abgespielt';
  }

  @override
  String get readAloudNotAvailable =>
      'Vorlesen für diesen Artikel nicht verfügbar.';

  @override
  String unreadCount(Object count) {
    return 'Ungelesen: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'Eingebettete Videos werden nur unter Android/iOS unterstützt.';

  @override
  String get loadVideo => 'Video laden';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get goAdFree => 'Werbefrei nutzen';

  @override
  String get goAdFreeSubtitle =>
      'Nur 1 €/Monat. Unterstütze einen Indie-Entwickler.';

  @override
  String get pricePerMonth => '1 €/Monat';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Für 1 €/Monat abonnieren und erhalten:';

  @override
  String get premiumRemoveAds => 'Alle Werbung entfernen';

  @override
  String get premiumCloudStorage => 'Cloud-Speicher für deine Daten';

  @override
  String get premiumCloudSubscriptions => 'Abonnements in der Cloud speichern';

  @override
  String get premiumSync => 'Anmelden & geräteübergreifend synchronisieren';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get subscribeNow => 'Abonnieren 1 €/Monat';

  @override
  String get subscriptionComingSoon =>
      'Abonnement demnächst verfügbar! Dir werden 1 €/Monat berechnet.';

  @override
  String get sectionAdvanced => 'Erweitert';

  @override
  String get readTracking => 'Lesestatus erfassen';

  @override
  String get readTrackingSubtitle =>
      'Artikel basierend auf Lesefortschritt automatisch als gelesen markieren';

  @override
  String get autoMarkRead => 'Auto-als-gelesen nach Fortschritt';

  @override
  String get autoMarkReadSubtitle =>
      'Markiert als gelesen, wenn Scrollen oder Audio deinen Schwellenwert erreicht';

  @override
  String get autoMarkThreshold => 'Auto-als-gelesen-Schwellenwert';

  @override
  String progressNeeded(Object percent) {
    return '$percent% Fortschritt erforderlich';
  }

  @override
  String get sectionVoice => 'Sprache & Vorlesen';

  @override
  String get narrationSpeed => 'Standard-Vorlesegeschwindigkeit';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = ruhiger Standard)';
  }

  @override
  String get defaultVoice => 'Standardstimme';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get autoPlayNext => 'Nächsten Artikel automatisch abspielen';

  @override
  String get autoPlayNextSubtitle =>
      'Wenn die Vorlesung endet, zum nächsten Element wechseln';

  @override
  String get sectionAccessibility => 'Barrierefreiheit';

  @override
  String get textSize => 'Textgröße';

  @override
  String get textSizeSubtitle =>
      'Gilt für die gesamte App, einschließlich Artikel und Navigation.';

  @override
  String get sampleText =>
      'Franz jagt im komplett verwahrlosten Taxi quer durch Bayern.';

  @override
  String get sectionSubscriptions => 'Abonnements';

  @override
  String get manageSubscriptions => 'Abonnements verwalten';

  @override
  String get manageSubscriptionsSubtitle =>
      'Feeds, denen du folgst, hinzufügen oder entfernen';

  @override
  String get importSubscriptions => 'Abonnements importieren';

  @override
  String get importSubscriptionsSubtitle => 'Import über OPML-Datei';

  @override
  String get exportSubscriptions => 'Abonnements exportieren';

  @override
  String get exportSubscriptionsSubtitle => 'Exportiere deine Feeds als OPML';

  @override
  String get sectionThemes => 'Designs';

  @override
  String get themes => 'Designs';

  @override
  String get themesSubtitle => 'Hell / Dunkel / System';

  @override
  String get selectTheme => 'Design auswählen';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get sectionLanguage => 'Sprache';

  @override
  String get language => 'Sprache';

  @override
  String get languageSubtitle => 'Deutsch';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get sectionLegal => 'Rechtliches';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get noFeedsFoundOpml => 'Keine Feeds in der OPML-Datei gefunden';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count Feed$_temp0 importiert';
  }

  @override
  String get allFeedsAlreadyAdded => 'Alle Feeds wurden bereits hinzugefügt';

  @override
  String importFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get noSubscriptionsToExport => 'Keine Abonnements zum Exportieren';

  @override
  String exportedCount(Object count) {
    return '$count Feed(s) exportiert';
  }

  @override
  String exportFailed(Object error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get exportShareText => 'Aware Abonnements-Export';

  @override
  String get exportShareSubject => 'Aware Abonnements-Export';

  @override
  String get savedArticlesTitle => 'Gespeicherte Artikel';

  @override
  String get noSavedArticlesYet => 'Noch keine gespeicherten Artikel.';

  @override
  String error(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get privacyPolicyLastUpdated => 'Zuletzt aktualisiert: 20. Juni 2026';

  @override
  String get privacyInfoWeCollect => 'Von uns erhobene Informationen';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware erhebt, speichert oder überträgt keine personenbezogenen Daten. Alle App-Daten (Feeds, Artikel, Lesefortschritt, Einstellungen) werden lokal auf deinem Gerät gespeichert und niemals an einen Server gesendet.';

  @override
  String get privacyThirdParty => 'Drittanbieter-Dienste';

  @override
  String get privacyThirdPartyBody =>
      'Aware verwendet Google AdMob zur Anzeige von Werbung. AdMob kann nicht-personenbezogene Nutzungsdaten und Geräte-IDs sammeln, um relevante Anzeigen auszuspielen. Anzeigen werden nur mit nicht-personalisierten Anzeigenanfragen ausgeliefert. Es werden keine Benutzerdaten an Werbetreibende weitergegeben.\n\nDie Datenschutzrichtlinie von Google gilt für die von AdMob erhobenen Daten:\n';

  @override
  String get privacyDataStorage => 'Datenspeicherung';

  @override
  String get privacyDataStorageBody =>
      'Alle Feed-Abonnements, Artikel, Lesefortschritte und App-Einstellungen werden lokal in einer SQLite-Datenbank auf deinem Gerät gespeichert. Du kannst deine Daten jederzeit über die OPML-Exportfunktion in den Einstellungen exportieren.\n\nUm alle Daten zu löschen, deinstalliere die App oder lösche die App-Daten in den Geräteeinstellungen.';

  @override
  String get privacyContact => 'Kontakt';

  @override
  String get privacyContactBody =>
      'Wenn du Fragen zu dieser Datenschutzrichtlinie hast, kontaktiere uns bitte über die Support-Kanäle der App.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
