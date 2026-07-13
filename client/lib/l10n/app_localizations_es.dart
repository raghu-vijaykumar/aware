// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'aware';

  @override
  String get appTitle => 'Aware';

  @override
  String get appVersion => '1.0.0';

  @override
  String get splashTagline => 'Mantente informado, sin esfuerzo';

  @override
  String get onboardingLanguageTitle => 'Elige tu idioma';

  @override
  String get onboardingLanguageDesc =>
      'Selecciona tu idioma preferido para la interfaz de la aplicación.';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a aware';

  @override
  String get onboardingWelcomeDesc =>
      'Tu lector de feeds personal. Mantente informado sobre lo que importa, todo en un solo lugar.';

  @override
  String get onboardingOfflineTitle => 'Leer sin conexión';

  @override
  String get onboardingOfflineDesc =>
      'Los feeds se descargan para que puedas leer en cualquier momento y lugar. Escucha con texto a voz.';

  @override
  String get onboardingNotifyTitle => 'No te pierdas ninguna publicación';

  @override
  String get onboardingNotifyDesc =>
      'Recibe notificaciones cuando lleguen nuevos artículos. Agrega tu primer feed para comenzar.';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get skip => 'Omitir';

  @override
  String get tabFeeds => 'Feeds';

  @override
  String get tabMarketplace => 'Mercado';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get addFeedTitle => 'Agregar feed RSS';

  @override
  String get addFeedUrlLabel => 'URL del feed';

  @override
  String get addFeedUrlHint => 'https://ejemplo.com/feed.xml';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Agregar';

  @override
  String get feedAdded => 'Feed agregado';

  @override
  String failedToAddFeed(Object error) {
    return 'Error al agregar feed: $error';
  }

  @override
  String get feedUrlRequired => 'La URL del feed es obligatoria';

  @override
  String get marketplaceTitle => 'Mercado';

  @override
  String get marketplaceSubtitle => 'Enlaces RSS seleccionados por categoría';

  @override
  String get marketplaceHeroTitle => 'Descubre feeds de calidad rápidamente';

  @override
  String get marketplaceHeroDesc =>
      'Explora fuentes confiables por tema. Toca Seguir para añadirlas a tu feed principal al instante.';

  @override
  String marketplaceCategoriesCount(Object count) {
    return '$count categorías';
  }

  @override
  String marketplaceFeedsCount(Object count) {
    return '$count feeds';
  }

  @override
  String get marketplaceSearchHint => 'Buscar feeds...';

  @override
  String get marketplaceUntitledFeed => 'Feed sin título';

  @override
  String get marketplaceSubscribed => 'Suscrito';

  @override
  String get marketplaceFollow => 'Seguir';

  @override
  String marketplaceSubscribedTo(Object title) {
    return 'Suscrito a $title';
  }

  @override
  String get marketplaceInvalidUrl => 'URL de feed no válida';

  @override
  String get marketplaceUnreachable =>
      'Error al suscribirse: el feed puede no estar accesible';

  @override
  String marketplaceCuratedSources(Object count) {
    return '$count fuentes seleccionadas';
  }

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get emailRequired => 'Introduce tu correo electrónico';

  @override
  String get passwordRequired => 'Introduce tu contraseña';

  @override
  String get subscriptionsTitle => 'Suscripciones';

  @override
  String get subscriptionsEmpty =>
      'Aún no hay suscripciones. ¡Agrega feeds desde el Mercado!';

  @override
  String get untitledFeed => 'Feed sin título';

  @override
  String get paused => 'Pausado';

  @override
  String get resume => 'Reanudar';

  @override
  String get pause => 'Pausar';

  @override
  String get unsubscribe => 'Cancelar suscripción';

  @override
  String get unsubscribeTitle => 'Cancelar suscripción';

  @override
  String unsubscribeConfirm(Object title) {
    return '¿Cancelar suscripción a $title?';
  }

  @override
  String get create => 'Crear';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

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
  String get unread => 'No leídos';

  @override
  String get liked => 'Me gusta';

  @override
  String get saved => 'Guardados';

  @override
  String get last24h => 'Últimas 24h';

  @override
  String get last7d => 'Últimos 7d';

  @override
  String get last30d => 'Últimos 30d';

  @override
  String get engagement => 'Interacción';

  @override
  String get unreadOnly => 'Solo no leídos';

  @override
  String get lengthPreview => 'Extensión / vista previa';

  @override
  String get any => 'Cualquiera';

  @override
  String get short => 'Corto <100p';

  @override
  String get medium => 'Medio 100–300';

  @override
  String get long => 'Largo >300';

  @override
  String get multiParagraph => '2+ párrafos';

  @override
  String get timeWindow => 'Período de tiempo';

  @override
  String get all => 'Todo';

  @override
  String get sources => 'Fuentes';

  @override
  String get allSources => 'Todas las fuentes';

  @override
  String get keyword => 'Palabra clave';

  @override
  String get keywordHint => 'Título, resumen o contenido';

  @override
  String get reset => 'Restablecer';

  @override
  String get done => 'Hecho';

  @override
  String get searchArticlesHint => 'Buscar artículos...';

  @override
  String get retry => 'Reintentar';

  @override
  String get noArticlesYet => 'Aún no hay artículos. Desliza para actualizar.';

  @override
  String get noArticlesMatch =>
      'Ningún artículo coincide con los filtros actuales.';

  @override
  String get untitled => 'Sin título';

  @override
  String get removedLike => 'Me gusta eliminado';

  @override
  String get likedArticle => 'Artículo marcado como Me gusta';

  @override
  String get removedFromSaved => 'Eliminado de guardados';

  @override
  String get savedForLater => 'Guardado para después';

  @override
  String get markedUnread => 'Marcado como no leído';

  @override
  String get markedRead => 'Marcado como leído';

  @override
  String get undo => 'Deshacer';

  @override
  String get publishDateUnknown => 'Fecha de publicación desconocida';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(Object count) {
    return 'Hace $count min';
  }

  @override
  String hoursAgo(Object count) {
    return 'Hace $count h';
  }

  @override
  String daysAgo(Object count) {
    return 'Hace $count d';
  }

  @override
  String weeksAgo(Object count) {
    return 'Hace $count sem';
  }

  @override
  String monthsAgo(Object count) {
    return 'Hace $count meses';
  }

  @override
  String yearsAgo(Object count) {
    return 'Hace $count años';
  }

  @override
  String get fetched => 'obtenido';

  @override
  String get continueReading => 'Seguir leyendo';

  @override
  String get readerSavedForLater => 'Guardado para después';

  @override
  String get readerRemovedFromSaved => 'Eliminado de guardados';

  @override
  String get resumingLastRead => 'Reanudando último artículo leído';

  @override
  String get startingPlayback =>
      'Iniciando reproducción para artículo no leído';

  @override
  String get save => 'Save';

  @override
  String get unsave => 'Unsave';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get showReader => 'Mostrar lector';

  @override
  String get showWebView => 'Mostrar vista web';

  @override
  String get webviewUnsupported =>
      'La vista web integrada solo es compatible con Android/iOS.\nMostrando vista de texto en su lugar.';

  @override
  String byAuthor(Object author) {
    return 'Por $author';
  }

  @override
  String get markedReadSkipped => 'Marcado como leído y saltado al siguiente';

  @override
  String get markUnread => 'Marcar como no leído';

  @override
  String get markReadPlay => 'Marcar como leído y reproducir siguiente';

  @override
  String get previousArticle => 'Artículo anterior';

  @override
  String get nextArticle => 'Artículo siguiente';

  @override
  String playingSection(Object current, Object total) {
    return 'Reproduciendo sección $current/$total';
  }

  @override
  String get readAloudNotAvailable =>
      'La lectura en voz alta no está disponible para este artículo.';

  @override
  String unreadCount(Object count) {
    return 'No leídos: $count';
  }

  @override
  String get embeddedVideoUnsupported =>
      'El video incrustado solo es compatible con Android/iOS.';

  @override
  String get loadVideo => 'Cargar video';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get goAdFree => 'Sin anuncios';

  @override
  String get goAdFreeSubtitle =>
      'Solo 1 €/mes. Apoya al desarrollador independiente.';

  @override
  String get pricePerMonth => '1 €/mes';

  @override
  String get premiumTitle => 'Aware Premium';

  @override
  String get premiumSubscribeDesc => 'Suscríbete por 1 €/mes y obtén:';

  @override
  String get premiumRemoveAds => 'Eliminar todos los anuncios';

  @override
  String get premiumCloudStorage => 'Almacenamiento en la nube para tus datos';

  @override
  String get premiumCloudSubscriptions => 'Guardar suscripciones en la nube';

  @override
  String get premiumSync => 'Inicia sesión y sincroniza entre dispositivos';

  @override
  String get notNow => 'Ahora no';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get subscribeNow => 'Suscribirse 1 €/mes';

  @override
  String get subscriptionComingSoon =>
      '¡Suscripción próximamente! Se te cobrarán 1 €/mes.';

  @override
  String get sectionAdvanced => 'Avanzado';

  @override
  String get readTracking => 'Seguimiento de lectura';

  @override
  String get readTrackingSubtitle =>
      'Marcar artículos como leídos automáticamente según el progreso de lectura';

  @override
  String get autoMarkRead => 'Marcado automático por progreso';

  @override
  String get autoMarkReadSubtitle =>
      'Marca como leído cuando el desplazamiento o audio alcanza tu umbral';

  @override
  String get autoMarkThreshold => 'Umbral de marcado automático';

  @override
  String progressNeeded(Object percent) {
    return '$percent% de progreso necesario';
  }

  @override
  String get sectionVoice => 'Voz y lectura en voz alta';

  @override
  String get narrationSpeed => 'Velocidad de narración predeterminada';

  @override
  String speedLabel(Object speed) {
    return '${speed}x (1x = normal tranquilo)';
  }

  @override
  String get defaultVoice => 'Voz predeterminada';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get autoPlayNext => 'Reproducir siguiente artículo automáticamente';

  @override
  String get autoPlayNextSubtitle =>
      'Cuando termine la narración, pasar al siguiente elemento';

  @override
  String get sectionAccessibility => 'Accesibilidad';

  @override
  String get textSize => 'Tamaño de texto';

  @override
  String get textSizeSubtitle =>
      'Se aplica en toda la aplicación, incluidos artículos y navegación.';

  @override
  String get sampleText =>
      'El veloz murciélago hindú comía feliz cardillo y kiwi.';

  @override
  String get sectionSubscriptions => 'Suscripciones';

  @override
  String get manageSubscriptions => 'Gestionar suscripciones';

  @override
  String get manageSubscriptionsSubtitle =>
      'Agregar o eliminar los feeds que sigues';

  @override
  String get importSubscriptions => 'Importar suscripciones';

  @override
  String get importSubscriptionsSubtitle => 'Importar mediante archivo OPML';

  @override
  String get exportSubscriptions => 'Exportar suscripciones';

  @override
  String get exportSubscriptionsSubtitle => 'Exportar tus feeds a OPML';

  @override
  String get sectionThemes => 'Temas';

  @override
  String get themes => 'Temas';

  @override
  String get themesSubtitle => 'Claro / Oscuro / Sistema';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Español';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get sectionLegal => 'Legal';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get noFeedsFoundOpml => 'No se encontraron feeds en el OPML';

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
  String get allFeedsAlreadyAdded => 'Todos los feeds ya fueron agregados';

  @override
  String importFailed(Object error) {
    return 'Importación fallida: $error';
  }

  @override
  String get noSubscriptionsToExport => 'No hay suscripciones para exportar';

  @override
  String exportedCount(Object count) {
    return '$count feed(s) exportados';
  }

  @override
  String exportFailed(Object error) {
    return 'Exportación fallida: $error';
  }

  @override
  String get exportShareText => 'Exportación de suscripciones de Aware';

  @override
  String get exportShareSubject => 'Exportación de suscripciones de Aware';

  @override
  String get savedArticlesTitle => 'Artículos guardados';

  @override
  String get noSavedArticlesYet => 'Aún no hay artículos guardados.';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get privacyPolicyLastUpdated =>
      'Última actualización: 20 de junio de 2026';

  @override
  String get privacyInfoWeCollect => 'Información que recopilamos';

  @override
  String get privacyInfoWeCollectBody =>
      'Aware no recopila, almacena ni transmite datos personales. Todos los datos de la aplicación (feeds, artículos, progreso de lectura, preferencias y ajustes) se almacenan localmente en tu dispositivo y nunca se envían a ningún servidor.';

  @override
  String get privacyThirdParty => 'Servicios de terceros';

  @override
  String get privacyThirdPartyBody =>
      'Aware utiliza Google AdMob para mostrar anuncios. AdMob puede recopilar datos de uso no personales e identificadores de dispositivo para servir anuncios relevantes. Los anuncios se sirven solo con solicitudes de anuncios no personalizadas. No se comparten datos de usuario con los anunciantes.\n\nLa Política de privacidad de Google se aplica a los datos recopilados por AdMob:\n';

  @override
  String get privacyDataStorage => 'Almacenamiento de datos';

  @override
  String get privacyDataStorageBody =>
      'Todas las suscripciones a feeds, artículos, progreso de lectura y preferencias de la aplicación se almacenan localmente en una base de datos SQLite en tu dispositivo. Puedes exportar tus datos en cualquier momento mediante la función de exportación OPML en Ajustes.\n\nPara eliminar todos los datos, desinstala la aplicación o borra los datos de la aplicación desde los ajustes del dispositivo.';

  @override
  String get privacyContact => 'Contacto';

  @override
  String get privacyContactBody =>
      'Si tienes preguntas sobre esta política de privacidad, contáctanos a través de los canales de soporte de la aplicación.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
