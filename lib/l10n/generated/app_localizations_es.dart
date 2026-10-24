// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Questboard';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get back => 'Atrás';

  @override
  String get done => 'Hecho';

  @override
  String get search => 'Buscar';

  @override
  String get all => 'Todo';

  @override
  String get loading => 'Cargando…';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get offlineShowingCached => 'Sin conexión — mostrando datos en caché';

  @override
  String get syncIdle => 'Sincronizado';

  @override
  String syncPending(int count) {
    return 'Pendiente ($count)';
  }

  @override
  String get syncSyncing => 'Sincronizando…';

  @override
  String get syncError => 'Error de sincronización';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get none => 'Ninguno';

  @override
  String get connectTitle => 'Conectar';

  @override
  String get serverEndpoint => 'Servidor';

  @override
  String get endpointHint => 'http://127.0.0.1:4010';

  @override
  String get testingConnection => 'Probando conexión…';

  @override
  String get endpointRequired => 'Introduce una URL del servidor.';

  @override
  String get endpointInvalid => 'Esa URL no parece válida.';

  @override
  String get endpointUnreachable =>
      'No se pudo conectar con este servidor. Revisa la URL e inténtalo de nuevo.';

  @override
  String get languageTitle => 'Elige tu idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get usernameOptional => 'Nombre de usuario (opcional)';

  @override
  String get avatarOptional => 'Avatar (opcional)';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get emailInvalid => 'Introduce un correo válido.';

  @override
  String get passwordTooShort => 'Usa al menos 8 caracteres.';

  @override
  String get authFailed => 'No se pudo iniciar sesión. Revisa tus datos.';

  @override
  String get haveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get noAccount => '¿Eres nuevo? Crea una cuenta';

  @override
  String get guildBoard => 'Tablero de gremios';

  @override
  String get available => 'Disponibles';

  @override
  String get inProgress => 'En curso';

  @override
  String get completed => 'Completadas';

  @override
  String get createQuest => 'Crear misión';

  @override
  String get totalXp => 'XP total';

  @override
  String get guildXp => 'XP de gremio';

  @override
  String levelShort(int level) {
    return 'NIVEL $level';
  }

  @override
  String get maxLevel => 'MÁX';

  @override
  String xpProgress(String current, String next) {
    return '$current / $next XP';
  }

  @override
  String get noGuilds => 'Aún no hay gremios';

  @override
  String get searchQuests => 'Buscar misiones…';

  @override
  String get sortBy => 'Ordenar';

  @override
  String get sortGuild => 'Gremio';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortRecentlyCompleted => 'Completadas recientemente';

  @override
  String get sortXp => 'Recompensa XP';

  @override
  String get sortName => 'Nombre';

  @override
  String questCount(int count) {
    return '$count misiones';
  }

  @override
  String get noQuestsTitle => 'Aún no hay misiones aquí';

  @override
  String get noQuestsBody =>
      'El tablero está tranquilo. Crea una misión para empezar.';

  @override
  String get createFirstQuest => 'Crea tu primera misión';

  @override
  String get pendingSync => 'Sincronización pendiente';

  @override
  String byAuthor(String name) {
    return 'por $name';
  }

  @override
  String completedBy(String name) {
    return 'Completada por $name';
  }

  @override
  String createdOn(String date) {
    return 'Creada $date';
  }

  @override
  String get xpReward => 'Recompensa XP';

  @override
  String get start => 'Empezar';

  @override
  String get markComplete => 'Marcar completada';

  @override
  String get cancelQuest => 'Cancelar misión';

  @override
  String get editQuest => 'Editar misión';

  @override
  String get deleteQuest => 'Eliminar misión';

  @override
  String get deleteConfirmTitle => '¿Eliminar esta misión?';

  @override
  String get deleteConfirmBody =>
      'Se eliminará de todos los tableros. La XP ganada se conserva.';

  @override
  String get questDetails => 'Detalles de la misión';

  @override
  String get description => 'Descripción';

  @override
  String get author => 'Autor';

  @override
  String get created => 'Creada';

  @override
  String get completedLabel => 'Completada';

  @override
  String get completedByLabel => 'Completada por';

  @override
  String get repeatable => 'Repetible';

  @override
  String get noDescription => 'Sin descripción.';

  @override
  String get questName => 'Nombre';

  @override
  String get questNameHint => 'Limpiar la cocina';

  @override
  String get questDescription => 'Descripción';

  @override
  String get questDescriptionHint => '¿Qué hay que hacer?';

  @override
  String get icon => 'Icono';

  @override
  String get clearIcon => 'Quitar icono';

  @override
  String get guild => 'Gremio';

  @override
  String get guildHint => 'Tareas, Trabajo, Recados…';

  @override
  String get xpRewardLabel => 'Recompensa XP';

  @override
  String get quickPick => 'Elección rápida';

  @override
  String get repeatableHelper =>
      'Las misiones repetibles vuelven a Disponible al completarse y pueden ganarse otra vez.';

  @override
  String get questType => 'Tipo de misión';

  @override
  String get questTypeTask => 'Tarea';

  @override
  String get questTypeChallenge => 'Desafío';

  @override
  String get questTypeRaid => 'Incursión';

  @override
  String get questTypeEvent => 'Evento';

  @override
  String get questTypeBounty => 'Recompensa';

  @override
  String get createQuestButton => 'Crear misión';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get nameRequired => 'Ponle nombre a tu misión.';

  @override
  String get xpInvalid => 'La recompensa XP debe estar entre 1 y 10000.';

  @override
  String get questCreated => 'Misión creada';

  @override
  String get questStarted => 'Misión iniciada';

  @override
  String get questCompleted => '¡Misión completada!';

  @override
  String levelUp(int level) {
    return '¡Subiste de nivel! Ahora eres nivel $level.';
  }

  @override
  String get questCancelled => 'La misión volvió a Disponible';

  @override
  String get questDeleted => 'Misión eliminada';

  @override
  String get questUpdated => 'Misión actualizada';

  @override
  String get chooseIcon => 'Elige un icono';

  @override
  String get bannerEditor => 'Editor de estandarte';

  @override
  String get preview => 'Vista previa';

  @override
  String get artPresets => 'Estilos de arte';

  @override
  String get avatar => 'Avatar';

  @override
  String get bannerSaved => 'Estandarte actualizado';

  @override
  String get leaderboards => 'Clasificaciones';

  @override
  String get global => 'Global';

  @override
  String get guildScope => 'Gremio';

  @override
  String get you => 'TÚ';

  @override
  String get myGuilds => 'Mis gremios';

  @override
  String get noLeaderboard => 'Aún no hay clasificación';

  @override
  String get settings => 'Ajustes';

  @override
  String get connection => 'Conexión';

  @override
  String get account => 'Cuenta';

  @override
  String get preferences => 'Preferencias';

  @override
  String get data => 'Datos';

  @override
  String get about => 'Acerca de';

  @override
  String get testConnection => 'Probar conexión';

  @override
  String get changeEndpoint => 'Cambiar servidor';

  @override
  String get changeEndpointBody =>
      'Cambiar el servidor borra los datos en caché y cierra tu sesión.';

  @override
  String get language => 'Idioma';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get clearCache => 'Borrar datos en caché';

  @override
  String get clearCacheConfirm =>
      'Esto elimina las misiones en caché y los cambios pendientes de este dispositivo.';

  @override
  String get forceResync => 'Forzar resincronización completa';

  @override
  String get exportData => 'Exportar mis datos';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountBody =>
      'Esto elimina permanentemente tu cuenta, misiones y completaciones. No se puede deshacer.';

  @override
  String get deleteAccountHint => 'Escribe DELETE MY ACCOUNT para confirmar';

  @override
  String get deleteAccountConfirm => 'DELETE MY ACCOUNT';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get emailReadOnly => 'Correo (solo lectura)';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutBuild => 'Compilación';

  @override
  String get aboutSpec => 'Especificación de API';

  @override
  String get endpointChanged => 'Servidor cambiado. Vuelve a conectar.';

  @override
  String get cacheCleared => 'Caché borrada';

  @override
  String get resyncDone => 'Resincronización completa';

  @override
  String exportReady(String path) {
    return 'Exportación guardada en $path';
  }

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get accountDeleted => 'Cuenta eliminada';

  @override
  String get connectionOk => 'Conectado';

  @override
  String get connectionFailed => 'Error de conexión';

  @override
  String anonymousHint(String name) {
    return 'Sin nombre de usuario — apareces como $name';
  }

  @override
  String get profilePicture => 'Foto de perfil';

  @override
  String get guildFilter => 'Filtro de gremio';

  @override
  String levelTitle(int level) {
    return 'Nivel $level';
  }

  @override
  String questTypeLabel(String type) {
    return 'Misión de $type';
  }

  @override
  String get signOutConfirm => '¿Cerrar sesión en esta cuenta?';

  @override
  String get requiredField => 'Este campo es obligatorio.';

  @override
  String tooLong(int max) {
    return 'Demasiado largo (máx. $max).';
  }

  @override
  String get bannerLockedNote =>
      'Los estilos son procedurales y se adaptan a cualquier tamaño.';

  @override
  String get filterByGuild => 'Filtrar por gremio';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get emptySearch => 'Ninguna misión coincide con tu búsqueda.';

  @override
  String get offlineBannerTitle => 'Estás sin conexión';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get exportFailed => 'Error al exportar.';

  @override
  String endpointTestOk(String version) {
    return 'Servidor accesible — versión $version';
  }

  @override
  String get specVersion => '1.0.0';

  @override
  String get questTypeNone => 'Sin categoría';

  @override
  String get level => 'Nivel';

  @override
  String get title => 'Título';

  @override
  String get guilds => 'Gremios';

  @override
  String get noGuildXp =>
      'Completa una misión de gremio para ganar XP de gremio.';

  @override
  String get leaderboardGlobalHint => 'Clasificado por XP total';

  @override
  String get leaderboardGuildHint => 'Clasificado por XP en este gremio';

  @override
  String get chooseGuild => 'Elige un gremio';

  @override
  String get createQuestHint => 'El nombre y la XP son obligatorios.';

  @override
  String get offlineQueueNote =>
      'Los cambios se guardan en cola y se sincronizan automáticamente.';

  @override
  String get newQuest => 'Nueva misión';

  @override
  String defaultEndpoint(String endpoint) {
    return 'Predeterminado: $endpoint';
  }

  @override
  String get licenses => 'Licencias';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get appTagline => 'Convierte las tareas diarias en misiones de neón.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get questsDone => 'Misiones hechas';

  @override
  String guildCount(int count) {
    return '$count gremios';
  }

  @override
  String get noGuildsHint =>
      'Etiqueta misiones con un gremio para empezar a ganar XP de gremio.';

  @override
  String get noAvailableQuests => 'Nada disponible ahora mismo.';

  @override
  String get noActiveQuests => 'No hay misiones en curso.';

  @override
  String get noCompletedQuests => 'Aún no hay victorias.';

  @override
  String get notFoundTitle => 'Perdido en la red';

  @override
  String get notFoundBody => 'Esa ruta no existe.';

  @override
  String get goHome => 'Volver al tablero';

  @override
  String get justNow => 'Ahora mismo';
}
