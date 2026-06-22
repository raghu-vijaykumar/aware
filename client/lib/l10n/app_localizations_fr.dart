// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Restez informé, en toute simplicité';

  @override
  String get onboardingLanguageTitle => 'Choisissez votre langue';

  @override
  String get onboardingLanguageDesc =>
      'Sélectionnez votre langue préférée pour l\'interface de l\'application.';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur aware';

  @override
  String get onboardingWelcomeDesc =>
      'Votre lecteur de flux personnel. Restez informé de ce qui compte, le tout au même endroit.';

  @override
  String get onboardingOfflineTitle => 'Lire hors ligne';

  @override
  String get onboardingOfflineDesc =>
      'Les flux sont téléchargés pour que vous puissiez lire à tout moment, n\'importe où. Écoutez avec la synthèse vocale.';

  @override
  String get onboardingNotifyTitle => 'Ne manquez aucun article';

  @override
  String get onboardingNotifyDesc =>
      'Soyez averti lorsque de nouveaux articles arrivent. Ajoutez votre premier flux pour commencer.';

  @override
  String get next => 'Suivant';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get tabFeeds => 'Flux';

  @override
  String get tabMarketplace => 'Marché';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get addFeedTitle => 'Ajouter un flux RSS';

  @override
  String get addFeedUrlLabel => 'URL du flux';

  @override
  String get addFeedUrlHint => 'https://exemple.com/feed.xml';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get feedAdded => 'Flux ajouté';

  @override
  String failedToAddFeed(Object error) {
    return 'Échec de l\'ajout du flux : $error';
  }

  @override
  String get feedUrlRequired => 'L\'URL du flux est requise';

  @override
  String get marketplaceTitle => 'Marché';

  @override
  String get marketplaceSubtitle => 'Liens RSS sélectionnés par catégorie';

  @override
  String get marketplaceHeroTitle => 'Découvrez rapidement des flux de qualité';

  @override
  String get marketplaceHeroDesc =>
      'Parcourez des sources fiables par sujet. Appuyez sur Suivre pour les ajouter instantanément à votre fil d\'accueil.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count catégories';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count flux';
  }

  @override
  String get marketplaceSearchHint => 'Rechercher des flux...';

  @override
  String get marketplaceUntitledFeed => 'Flux sans titre';

  @override
  String get marketplaceSubscribed => 'Abonné';

  @override
  String get marketplaceFollow => 'Suivre';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'Abonné à $title';
  }

  @override
  String get marketplaceInvalidUrl => 'URL de flux invalide';

  @override
  String get marketplaceUnreachable =>
      'Échec de l\'abonnement : le flux est peut-être inaccessible';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count sources sélectionnées';
  }

  @override
  String get signIn => 'Connexion';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get emailRequired => 'Saisissez votre e-mail';

  @override
  String get passwordRequired => 'Saisissez votre mot de passe';

  @override
  String get subscriptionsTitle => 'Abonnements';

  @override
  String get subscriptionsEmpty =>
      'Pas encore d\'abonnements. Ajoutez des flux depuis le Marché !';

  @override
  String get untitledFeed => 'Flux sans titre';

  @override
  String get paused => 'En pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get pause => 'Pause';

  @override
  String get unsubscribe => 'Se désabonner';

  @override
  String get unsubscribeTitle => 'Se désabonner';

  @override
  String unsubscribeConfirm(Object title) {
    return 'Se désabonner de $title ?';
  }

  @override
  String get foldersTitle => 'Dossiers';

  @override
  String get createFolderTitle => 'Nouveau dossier';

  @override
  String get folderNameHint => 'Nom du dossier';

  @override
  String get create => 'Créer';

  @override
  String get rename => 'Renommer';

  @override
  String get renameFolderTitle => 'Renommer le dossier';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteFolderTitle => 'Supprimer le dossier';

  @override
  String deleteFolderConfirm(Object name) {
    return 'Supprimer « $name » et dissocier ses flux ?';
  }

  @override
  String get createFolderTooltip => 'Créer un dossier';

  @override
  String get noFoldersYet => 'Pas encore de dossiers';

  @override
  String get createFirstFolder => 'Créez votre premier dossier';

  @override
  String feedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count flux$_temp0';
  }

  @override
  String get filters => 'Filtres';

  @override
  String get unread => 'Non lus';

  @override
  String get liked => 'J\'aime';

  @override
  String get saved => 'Enregistrés';

  @override
  String get last24h => '24 dernières h';

  @override
  String get last7d => '7 derniers j';

  @override
  String get last30d => '30 derniers j';

  @override
  String get engagement => 'Engagement';

  @override
  String get unreadOnly => 'Non lus uniquement';

  @override
  String get lengthPreview => 'Longueur / aperçu';

  @override
  String get any => 'Tout';

  @override
  String get short => 'Court <100m';

  @override
  String get medium => 'Moyen 100–300';

  @override
  String get long => 'Long >300';

  @override
  String get multiParagraph => '2+ paragraphes';

  @override
  String get timeWindow => 'Période';

  @override
  String get all => 'Tout';

  @override
  String get sources => 'Sources';

  @override
  String get allSources => 'Toutes les sources';

  @override
  String get keyword => 'Mot-clé';

  @override
  String get keywordHint => 'Titre, résumé ou contenu';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get done => 'Terminé';

  @override
  String get searchArticlesHint => 'Rechercher des articles...';

  @override
  String get retry => 'Réessayer';

  @override
  String get noArticlesYet => 'Pas encore d\'articles. Tirez pour actualiser.';

  @override
  String get noArticlesMatch =>
      'Aucun article ne correspond aux filtres actuels.';

  @override
  String get untitled => 'Sans titre';

  @override
  String get removedLike => 'J\'aime retiré';

  @override
  String get likedArticle => 'Article aimé';

  @override
  String get removedFromSaved => 'Retiré des enregistrés';

  @override
  String get savedForLater => 'Enregistré pour plus tard';

  @override
  String get markedUnread => 'Marqué comme non lu';

  @override
  String get markedRead => 'Marqué comme lu';

  @override
  String get undo => 'Annuler';

  @override
  String get publishDateUnknown => 'Date de publication inconnue';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(Object count) {
    return 'Il y a $count min';
  }

  @override
  String hoursAgo(Object count) {
    return 'Il y a $count h';
  }

  @override
  String daysAgo(Object count) {
    return 'Il y a $count j';
  }

  @override
  String weeksAgo(Object count) {
    return 'Il y a $count sem';
  }

  @override
  String monthsAgo(Object count) {
    return 'Il y a $count mois';
  }

  @override
  String yearsAgo(Object count) {
    return 'Il y a $count ans';
  }

  @override
  String get fetched => 'récupéré';

  @override
  String get continueReading => 'Continuer la lecture';

  @override
  String get readerSavedForLater => 'Enregistré pour plus tard';

  @override
  String get readerRemovedFromSaved => 'Retiré des enregistrés';

  @override
  String get resumingLastRead => 'Reprise du dernier article lu';

  @override
  String get startingPlayback =>
      'Démarrage de la lecture pour l\'article non lu';

  @override
  String get showReader => 'Afficher le lecteur';

  @override
  String get showWebView => 'Afficher la vue web';

  @override
  String get webviewUnsupported =>
      'La vue Web intégrée n\'est prise en charge que sur Android/iOS.\nAffichage de la vue texte à la place.';

  @override
  String byAuthor(Object author) {
    return 'Par $author';
  }

  @override
  String get markedReadSkipped => 'Marqué comme lu et passé au suivant';

  @override
  String get markUnread => 'Marquer comme non lu';

  @override
  String get markReadPlay => 'Marquer comme lu et lire le suivant';

  @override
  String get previousArticle => 'Article précédent';

  @override
  String get nextArticle => 'Article suivant';

  @override
  String playingSection(Object current, Object total) {
    return 'Lecture de la section $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'La lecture à voix haute n\'est pas disponible pour cet article.';

  @override
  String unreadCount(Object count) {
    return 'Non lus : $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'La vidéo intégrée n\'est prise en charge que sur Android/iOS.';

  @override
  String get loadVideo => 'Charger la vidéo';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get goAdFree => 'Sans publicité';

  @override
  String get goAdFreeSubtitle =>
      'Seulement 1 €/mois. Soutenez un développeur indépendant.';

  @override
  String get pricePerMonth => '1 €/mois';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Abonnez-vous pour 1 €/mois et obtenez :';

  @override
  String get premiumRemoveAds => 'Supprimer toutes les publicités';

  @override
  String get premiumCloudStorage => 'Stockage cloud pour vos données';

  @override
  String get premiumCloudSubscriptions =>
      'Sauvegarder les abonnements dans le cloud';

  @override
  String get premiumSync => 'Connectez-vous et synchronisez entre appareils';

  @override
  String get premiumFolders => 'Organisation illimitée des dossiers';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get comingSoon => 'Prochainement';

  @override
  String get subscribeNow => 'S\'abonner 1 €/mois';

  @override
  String get subscriptionComingSoon =>
      'Abonnement bientôt disponible ! 1 €/mois vous sera facturé.';

  @override
  String get sectionAdvanced => 'Avancé';

  @override
  String get readTracking => 'Suivi de lecture';

  @override
  String get readTrackingSubtitle =>
      'Marquer automatiquement les articles comme lus en fonction de la progression';

  @override
  String get autoMarkRead => 'Marquage auto selon la progression';

  @override
  String get autoMarkReadSubtitle =>
      'Marque comme lu lorsque le défilement ou l\'audio atteint votre seuil';

  @override
  String get autoMarkThreshold => 'Seuil de marquage automatique';

  @override
  String progressNeeded(Object percent) {
    return '$percent% de progression nécessaire';
  }

  @override
  String get sectionVoice => 'Voix et lecture à voix haute';

  @override
  String get narrationSpeed => 'Vitesse de narration par défaut';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = calme par défaut)';
  }

  @override
  String get defaultVoice => 'Voix par défaut';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get autoPlayNext => 'Lire automatiquement l\'article suivant';

  @override
  String get autoPlayNextSubtitle =>
      'Lorsque la narration se termine, passer à l\'élément suivant';

  @override
  String get sectionData => 'Données';

  @override
  String get lowDataMode => 'Préchargement en mode faible consommation';

  @override
  String get lowDataModeSubtitle =>
      'Précharger le texte des articles en arrière-plan et privilégier le contenu mis en cache lorsqu\'il est disponible';

  @override
  String get sectionAccessibility => 'Accessibilité';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get textSizeSubtitle =>
      'S\'applique à toute l\'application, y compris les articles et la navigation.';

  @override
  String get sampleText => 'Portez ce vieux whisky au juge blond qui fume.';

  @override
  String get sectionSubscriptions => 'Abonnements';

  @override
  String get manageSubscriptions => 'Gérer les abonnements';

  @override
  String get manageSubscriptionsSubtitle =>
      'Ajouter ou supprimer les flux que vous suivez';

  @override
  String get manageFolders => 'Gérer les dossiers';

  @override
  String get manageFoldersSubtitle => 'Organiser les flux dans des dossiers';

  @override
  String get importSubscriptions => 'Importer des abonnements';

  @override
  String get importSubscriptionsSubtitle => 'Importer via fichier OPML';

  @override
  String get exportSubscriptions => 'Exporter des abonnements';

  @override
  String get exportSubscriptionsSubtitle => 'Exporter vos flux vers OPML';

  @override
  String get sectionThemes => 'Thèmes';

  @override
  String get themes => 'Thèmes';

  @override
  String get themesSubtitle => 'Clair / Sombre / Système';

  @override
  String get selectTheme => 'Choisir le thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get sectionLanguage => 'Langue';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Français';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageFrench => 'Français';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageItalian => 'Italien';

  @override
  String get sectionLegal => 'Mentions légales';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get openSourceLicenses => 'Licences open source';

  @override
  String get noFeedsFoundOpml => 'Aucun flux trouvé dans l\'OPML';

  @override
  String importedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count flux$_temp0 importés';
  }

  @override
  String get allFeedsAlreadyAdded => 'Tous les flux ont déjà été ajoutés';

  @override
  String importFailed(Object error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get noSubscriptionsToExport => 'Aucun abonnement à exporter';

  @override
  String exportedCount(Object count) {
    return '$count flux exportés';
  }

  @override
  String exportFailed(Object error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get exportShareText => 'Exportation des abonnements Aware';

  @override
  String get exportShareSubject => 'Exportation des abonnements Aware';

  @override
  String get savedArticlesTitle => 'Articles enregistrés';

  @override
  String get noSavedArticlesYet => 'Pas encore d\'articles enregistrés.';

  @override
  String error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyPolicyLastUpdated => 'Dernière mise à jour : 20 juin 2026';

  @override
  String get privacyInfoWeCollect => 'Informations que nous collectons';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware ne collecte, ne stocke ni ne transmet aucune donnée personnelle. Toutes les données de l\'application (flux, articles, progression de lecture, préférences et paramètres) sont stockées localement sur votre appareil et ne sont jamais envoyées à un serveur.';

  @override
  String get privacyThirdParty => 'Services tiers';

  @override
  String get privacyThirdPartyBody =>
      'Aware utilise Google AdMob pour afficher des publicités. AdMob peut collecter des données d\'utilisation non personnelles et des identifiants d\'appareil pour diffuser des annonces pertinentes. Les annonces sont diffusées uniquement avec des demandes non personnalisées. Aucune donnée utilisateur n\'est partagée avec les annonceurs.\n\nLa politique de confidentialité de Google s\'applique aux données collectées par AdMob :\n';

  @override
  String get privacyDataStorage => 'Stockage des données';

  @override
  String get privacyDataStorageBody =>
      'Tous les abonnements aux flux, articles, progression de lecture et préférences de l\'application sont stockés localement dans une base de données SQLite sur votre appareil. Vous pouvez exporter vos données à tout moment via la fonction d\'exportation OPML dans les Paramètres.\n\nPour supprimer toutes les données, désinstallez l\'application ou effacez les données de l\'application depuis les paramètres de votre appareil.';

  @override
  String get privacyContact => 'Contact';

  @override
  String get privacyContactBody =>
      'Si vous avez des questions concernant cette politique de confidentialité, veuillez nous contacter via les canaux d\'assistance de l\'application.';
}
