// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get becomeAWorker => 'Convertirse en trabajador';

  @override
  String get joinTheWorkforce => 'Unirse a la fuerza laboral';

  @override
  String get joinWorkforceDescription =>
      'Crea tu perfil profesional y\ncomienza a ganar dinero en granjas cercanas hoy mismo.';

  @override
  String get selectYourSkills => 'Selecciona tus habilidades';

  @override
  String get aboutYou => 'Sobre ti';

  @override
  String get aboutYouHint =>
      'Cuéntale a los agricultores sobre tu experiencia...';

  @override
  String get hourlyRateTnd => 'Tarifa por hora (TND)';

  @override
  String get hourlyRateHint => 'ej. 15.00';

  @override
  String get aiVerificationComingSoon => 'Verificación por IA próximamente';

  @override
  String get aiVerificationDescription =>
      'La verificación automatizada de identidad y habilidades acelerará tu aprobación.';

  @override
  String get createWorkerProfile => 'Crear perfil de trabajador';

  @override
  String get selectAtLeastOneSkill =>
      'Por favor, selecciona al menos una habilidad';

  @override
  String get workerProfileCreated =>
      '¡🎉 Perfil de trabajador creado! Pendiente de verificación.';

  @override
  String get failedToCreateProfile => 'Error al crear el perfil';

  @override
  String get enterValidRate => 'Ingresa una tarifa válida';

  @override
  String get watering => 'Riego';

  @override
  String get harvesting => 'Cosecha';

  @override
  String get planting => 'Plantación';

  @override
  String get animalCare => 'Cuidado de animales';

  @override
  String get machineOperation => 'Operación de maquinaria';

  @override
  String get soilManagement => 'Gestión del suelo';

  @override
  String get structureInstallation => 'Instalación de estructuras';

  @override
  String get qualityInspection => 'Inspección de calidad';

  @override
  String get cropMonitoring => 'Monitoreo de cultivos';

  @override
  String get pestControl => 'Control de plagas';

  @override
  String get viewManageLandInvestments =>
      'Ver y gestionar sus inversiones en tierras';

  @override
  String get enableGameEdgePanel => 'Activar panel lateral del juego';

  @override
  String get accessFarmView => 'Acceder a la vista de la granja en 2.5D';

  @override
  String get tasksProofs => 'Tareas y pruebas';

  @override
  String get aiProofRequests => 'Solicitudes de prueba de IA';

  @override
  String get viewManageProofRequests => 'Ver y gestionar solicitudes de prueba';

  @override
  String get freeTier => 'Nivel gratuito';

  @override
  String get upgradePremium => 'Actualiza para funciones premium';

  @override
  String get freeForever => 'Sin vencimiento · Gratis para siempre';

  @override
  String validUntil(String date) {
    return 'Válido hasta el $date';
  }

  @override
  String get editLandDetails => 'Editar detalles de la tierra';

  @override
  String get deleteLand => 'Eliminar tierra';

  @override
  String get deleteLandTitle => '¿Eliminar tierra?';

  @override
  String deleteLandConfirmation(String name) {
    return '¿Estás seguro de que deseas eliminar \"$name\"?';
  }

  @override
  String get deleteLandActionWarning =>
      'Esta acción no se puede deshacer. Todos los datos asociados se eliminarán permanentemente.';

  @override
  String get landDeletedSuccess => 'Tierra eliminada con éxito';

  @override
  String get delete => 'Eliminar';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String featureOptimizedDescription(String feature) {
    return 'El módulo \"$feature\" se está optimizando actualmente para la gestión agrícola personal.';
  }

  @override
  String get stayTunedSpatialTracking =>
      '¡Manténgase atento al seguimiento avanzado de activos espaciales!';

  @override
  String get gotIt => 'ENTENDIDO';

  @override
  String get live => 'EN VIVO';

  @override
  String get failedToSyncBackend => 'Error al sincronizar con el backend';

  @override
  String get externalProperty => 'PROPIEDAD EXTERNA';

  @override
  String get notYours => 'NO ES TUYA';

  @override
  String get dismiss => 'DESCARTAR';

  @override
  String get myLands => 'Mis tierras';

  @override
  String get landDataSyncSuccess =>
      '¡✨ Datos de tierra sincronizados con éxito!';

  @override
  String get limitReached => 'Límite alcanzado';

  @override
  String get newListing => 'Nueva publicación';

  @override
  String get landLimitReachedTitle => 'Límite de tierras alcanzado';

  @override
  String landLimitReachedDescription(String planName) {
    return 'Has usado todos los espacios de tierra en tu plan $planName. ¡Actualiza a Farmer Pro para desbloquear tierras ilimitadas!';
  }

  @override
  String get landSlotsUsed => 'Espacios de tierra usados';

  @override
  String get synchronizingBoundaries => 'SINCRONIZANDO LÍMITES';

  @override
  String get fetchingSpatialData => 'Obteniendo datos espaciales precisos...';

  @override
  String get syncInterrupted => 'Sincronización interrumpida';

  @override
  String get tryToResync => 'Intentar resincronizar';

  @override
  String get noDescriptionProvided =>
      'No se proporcionó descripción para esta tierra.';

  @override
  String get area => 'Área';

  @override
  String get rentals => 'Alquileres';

  @override
  String get earnings => 'Ganancias';

  @override
  String get safety => 'Seguridad';

  @override
  String get workforce => 'Fuerza laboral';

  @override
  String get active => 'ACTIVO';

  @override
  String get rented => 'ALQUILADO';

  @override
  String get available => 'disponible';

  @override
  String owner(String id) {
    return 'Propietario: $id';
  }

  @override
  String get myBasket => 'Mi cesta';

  @override
  String get clear => 'Limpiar';

  @override
  String get yourBasketIsEmpty => 'Tu cesta está vacía';

  @override
  String get browseMarketplaceDescription =>
      '¡Explora el mercado y añade\nalgunos productos frescos!';

  @override
  String get browseProducts => 'Explorar productos';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tva => 'IVA (19%)';

  @override
  String get total => 'Total';

  @override
  String balanceWithCredits(String balance) {
    return 'Saldo: $balance Créditos';
  }

  @override
  String checkoutWithItems(int count) {
    return 'Pagar ($count artículos)';
  }

  @override
  String get insufficientFunds => 'Fondos insuficientes';

  @override
  String insufficientFundsDescription(String balance, String total) {
    return 'Tu saldo es de $balance Créditos, pero el total es de $total TND.\n\nPor favor, recarga tu billetera.';
  }

  @override
  String get confirmPurchase => 'Confirmar compra';

  @override
  String itemsCount(int count) {
    return '$count artículo(s)';
  }

  @override
  String includingTva(String tax) {
    return '(incluyendo 19% IVA: $tax TND)';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String get orderPlaced => '¡Pedido realizado!';

  @override
  String itemsPurchasedSuccess(int count) {
    return '$count artículo(s) comprado(s) con éxito.';
  }

  @override
  String get trackOrder => 'Seguir pedido';

  @override
  String get viewMyOrders => 'Ver mis pedidos';

  @override
  String get backToMarketplace => 'Volver al mercado';

  @override
  String checkoutResultFeedback(int successCount, int failCount) {
    return '$successCount comprados, $failCount fallidos. Los artículos fallidos permanecen en la cesta.';
  }

  @override
  String get clearBasketTitle => '¿Vaciar cesta?';

  @override
  String get clearBasketDescription =>
      'Esto eliminará todos los artículos de tu cesta.';

  @override
  String get clearAll => 'Vaciar todo';

  @override
  String get twoFactorAuthentication => 'Autenticación de dos factores';

  @override
  String get verificationRequired => 'Verificación requerida';

  @override
  String get enter2faCode =>
      'Ingresa el código de 6 dígitos de tu aplicación de autenticación para continuar.';

  @override
  String get verify => 'Verificar';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get user => 'Usuario';

  @override
  String get customerAccount => 'Cuenta de cliente';

  @override
  String get dailyInspiration => 'Inspiración diaria';

  @override
  String get workerPlus => 'Worker Plus';

  @override
  String get workerPlusDescription =>
      'Impulsa tu perfil, obtén coincidencias prioritarias y retiros instantáneos.';

  @override
  String get farmboxSubscription => 'Suscripción FarmBox';

  @override
  String get farmboxDescription =>
      '¡Recibe verduras frescas cultivadas localmente en tu puerta semanalmente!';

  @override
  String upgradeWithPrice(String price) {
    return 'Actualizar $price';
  }

  @override
  String get quote1 => 'El futuro de la agricultura está en tus manos.';

  @override
  String get quote2 => 'Apoya lo local, come fresco, vive sano.';

  @override
  String get quote3 => 'Conectándote con las raíces de tu comida.';

  @override
  String get quote4 =>
      'Cada inversión en la naturaleza rinde el mejor interés.';

  @override
  String get quote5 =>
      'Pequeñas elecciones tienen un gran impacto en nuestro planeta.';

  @override
  String get quote6 => 'Fresco de la granja, directo a tu mesa.';

  @override
  String get quote7 => 'Empoderando a los agricultores, alimentando al mundo.';

  @override
  String get quote8 =>
      'La sostenibilidad no es una meta, es un estilo de vida.';

  @override
  String get totalEarningsWallet => 'Ganancias totales (Billetera)';

  @override
  String get totalSalesValue => 'Valor total de ventas';

  @override
  String get itemsSold => 'Artículos vendidos';

  @override
  String nTasksUpper(int count) {
    return '$count TAREAS';
  }

  @override
  String minutesCount(int count) {
    return '$count min';
  }

  @override
  String hoursCount(int count) {
    return '$count h';
  }

  @override
  String get advancedAnalytics => 'Análisis avanzado';

  @override
  String get premium => 'PREMIUM';

  @override
  String get unlockDeepInsights => 'Desbloquea información profunda';

  @override
  String get unlockDeepInsightsDescription =>
      'Obtén pronósticos de cultivos impulsados por IA, historial detallado de la salud del suelo y proyecciones de ROI avanzadas.';

  @override
  String get productionStrategy => 'Estrategia de producción';

  @override
  String get productionStrategyDescription =>
      'Obtén un análisis profundo de tus costos de producción, rendimiento potencial y estrategias de maximización de ganancias impulsadas por IA.';

  @override
  String get consultProductionGuru => 'Consultar al gurú de producción';

  @override
  String upgradeToPlan(String planName) {
    return 'Actualizar a $planName';
  }

  @override
  String get farmyUser => 'Usuario de Farmy';

  @override
  String get latestSubmittedProof => 'Última prueba enviada';

  @override
  String get free => 'GRATIS';

  @override
  String get pro => 'PRO';

  @override
  String get enabled => 'ACTIVADO';

  @override
  String get off => 'DESACTIVADO';

  @override
  String buyProductConfirmation(String title, double price) {
    return '¿Quieres comprar $title por $price créditos?';
  }

  @override
  String get buy => 'Comprar';

  @override
  String creditsCount(String count) {
    return 'Créditos: $count';
  }

  @override
  String priceCountCredits(double price) {
    return '$price Créditos';
  }

  @override
  String get buyNow => 'Comprar ahora';

  @override
  String get pleaseSelectProductType =>
      'Por favor selecciona un tipo de producto';

  @override
  String get productUpdated => '¡Producto actualizado!';

  @override
  String get productListedSuccessfully => '¡Producto listado con éxito!';

  @override
  String get failedToUpdateProduct => 'Error al actualizar el producto.';

  @override
  String get failedToListProduct => 'Error al listar el producto.';

  @override
  String get editProduct => 'Editar producto';

  @override
  String get addProduct => 'Añadir producto';

  @override
  String get tapToAddImage => 'Toca para añadir imagen';

  @override
  String get title => 'Título';

  @override
  String get pleaseEnterTitle => 'Por favor ingresa un título';

  @override
  String get productType => 'Tipo de producto';

  @override
  String get description => 'Descripción';

  @override
  String get priceCredits => 'Precio (Créditos)';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unitHint => 'Unidad (ej: kg, litro, pieza)';

  @override
  String get pleaseEnterUnit => 'Por favor ingresa una unidad';

  @override
  String get updateProduct => 'Actualizar producto';

  @override
  String get listProduct => 'Listar producto';

  @override
  String get noCamerasFound => 'No se encontraron cámaras en este dispositivo.';

  @override
  String get flipIdInstruction => '¡Genial! Ahora voltea tu identificación';

  @override
  String get selfieInstruction => '¡Perfecto! Ahora tomemos una selfie';

  @override
  String get uploadingDocuments => 'Subiendo documentos...';

  @override
  String kycSuccess(String role) {
    return '¡Éxito! ¡Ahora eres un $role!';
  }

  @override
  String get scanFrontId => 'Escanear el frente de la ID';

  @override
  String get scanBackId => 'Escanear el dorso de la ID';

  @override
  String get takeSelfie => 'Tomar una selfie';

  @override
  String get positionIdHint => 'Coloca tu identificación dentro del marco';

  @override
  String get flipIdHint => 'Voltea tu identificación y escanea el dorso';

  @override
  String get lookAtCameraHint =>
      'Mira directamente a la cámara con los ojos abiertos';

  @override
  String get verifying => 'Verificando...';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get accountBanned => 'Cuenta baneada';

  @override
  String get bannedDescription =>
      'Tu cuenta ha sido suspendida debido a violaciones específicas. Por favor, contacta con el soporte si crees que esto es un error.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get noInternetConnection => 'Sin conexión a Internet';

  @override
  String get noInternetDescription =>
      'No pudimos conectarnos al servidor. Por favor, verifica tu conexión a Internet e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get askFarmingQuestion => 'Haz tu pregunta agrícola...';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String get rename => 'Renombrar';

  @override
  String get startANewConversation => 'Iniciar una nueva conversación';

  @override
  String get createChatDescription =>
      'Crea un chat para pedir orientación agrícola práctica.';

  @override
  String get askAnythingAboutFarm => 'Pregunta cualquier cosa sobre tu granja';

  @override
  String get aiAssistantDescription =>
      'Tiempos de siembra, salud de los cultivos, fertilizantes y orientación práctica con detección automática de idioma.';

  @override
  String get noChatStateTitle => 'Bienvenido a Farmy AI';

  @override
  String get noChatStateDescription =>
      'Inicia una nueva conversación para obtener asesoramiento experto sobre tu agricultura.';

  @override
  String get disableVoiceInput => 'Desactivar entrada de voz';

  @override
  String get aiAssistant => 'Asistente de IA';

  @override
  String get muteVoiceOutput => 'Silenciar salida de voz';

  @override
  String get enableVoiceOutput => 'Activar salida de voz';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get syncBackend => 'Sincronizar backend';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get closeAssistant => 'Cerrar asistente';

  @override
  String get syncingWithBackend => 'Sincronizando con el backend...';

  @override
  String get backendDisconnected =>
      'Backend desconectado. Reconectando automáticamente...';

  @override
  String get offlineModeCached =>
      'Modo fuera de línea: se usarán respuestas en caché cuando estén disponibles.';

  @override
  String get noConversationsYet => 'Aún no hay conversaciones.';

  @override
  String get conversations => 'Conversaciones';

  @override
  String get renameChat => 'Renombrar chat';

  @override
  String get deleteChat => 'Eliminar chat';

  @override
  String get chatTitle => 'Título del chat';

  @override
  String get updateYourMessage => 'Actualiza tu mensaje';

  @override
  String get resend => 'Reenviar';

  @override
  String get save => 'Guardar';

  @override
  String deleteChatConfirmation(String title) {
    return '¿Eliminar \"$title\" permanentemente?';
  }

  @override
  String get responseCopied => 'Respuesta copiada al portapapeles.';

  @override
  String get voiceInputNotAvailable =>
      'La entrada de voz no está disponible en este dispositivo.';

  @override
  String get unableToStartVoiceInput =>
      'No se pudo iniciar la entrada de voz. Por favor verifica los permisos.';

  @override
  String get voiceOutputMuted =>
      'La salida de voz está silenciada. Desactiva el silencio para leer este mensaje.';

  @override
  String get messageNoReadableText => 'Este mensaje no tiene texto legible.';

  @override
  String get unableToPlayVoiceOutput =>
      'No se pudo reproducir la salida de voz ahora.';

  @override
  String get couldNotSendMessage =>
      'No se pudo enviar tu mensaje. Por favor inténtalo de nuevo.';

  @override
  String get upgradeRequired => 'Actualización requerida';

  @override
  String get upgrade => 'Actualizar';

  @override
  String get editAndResend => 'Editar y reenviar';

  @override
  String get copy => 'Copiar';

  @override
  String get readAloud => 'Leer en voz alta';

  @override
  String get cached => 'En caché';

  @override
  String get verifyEmailTitle => 'Verifica tu correo electrónico';

  @override
  String verificationCodeSentTo(String email) {
    return 'Enviamos un código de verificación de 6 dígitos a\n$email.';
  }

  @override
  String get verifyAccount => 'Verificar cuenta';

  @override
  String get resendNewCode => 'Reenviar código nuevo';

  @override
  String get newVerificationCodeSent =>
      '¡Nuevo código de verificación enviado!';

  @override
  String get failedToSendCode =>
      'Error al enviar el código. Inténtalo de nuevo.';

  @override
  String get yourEmail => 'tu correo electrónico';

  @override
  String get resetPasswordTitle => 'Restablecer contraseña';

  @override
  String resettingPasswordFor(String email) {
    return 'Restableciendo contraseña para $email';
  }

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get pleaseEnterAll6Digits => 'Por favor ingresa los 6 dígitos';

  @override
  String get passwordResetSuccess =>
      '¡Contraseña restablecida con éxito! Por favor inicia sesión.';

  @override
  String get forgotPasswordTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu dirección de correo electrónico y te enviaremos un código de 6 dígitos para restablecer tu contraseña.';

  @override
  String get emailAddress => 'Dirección de correo electrónico';

  @override
  String get sendResetCode => 'Enviar código de restablecimiento';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get welcomeCustomerTitle => '¡Bienvenido a Farmy!';

  @override
  String get welcomeCustomerSubtitle =>
      'Apoya a los agricultores locales y disfruta de productos frescos y sostenibles directamente de la fuente.';

  @override
  String get welcomeWorkerTitle => 'Únete a la fuerza laboral';

  @override
  String get welcomeWorkerSubtitle =>
      'Conéctate con granjas modernas y comienza tu viaje productivo en la agricultura sostenible.';

  @override
  String get welcomeFarmerTitle => 'Empoderando a los agricultores';

  @override
  String get welcomeFarmerSubtitle =>
      'Tu viaje hacia la gestión agrícola digital comienza aquí. ¡Hagamos crecer tu negocio juntos!';

  @override
  String get welcomeInvestorTitle => 'Invierte en el futuro';

  @override
  String get welcomeInvestorSubtitle =>
      'Explora oportunidades sostenibles y haz crecer tu cartera agrícola verde con nosotros.';

  @override
  String get skip => 'Saltar';

  @override
  String get finish => 'Finalizar';

  @override
  String get continueText => 'Continuar';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get french => 'Francés';

  @override
  String get spanish => 'Español';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get accountInformation => 'Información de la cuenta';

  @override
  String get verified => 'Verificado';

  @override
  String get unverified => 'No verificado';

  @override
  String get subscription => 'Suscripción';

  @override
  String get payments => 'Pagos';

  @override
  String get walletCards => 'Cartera y tarjetas';

  @override
  String get manageCredits => 'Gestionar créditos y métodos de pago';

  @override
  String get hederaRegistry => 'Registro Hedera';

  @override
  String get viewBlockchainRecords =>
      'Ver tus registros en la cadena de bloques';

  @override
  String get general => 'General';

  @override
  String get viewRecentActivity =>
      'Ver tu actividad reciente y actualizaciones';

  @override
  String get security => 'Seguridad';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get disable2fa => 'Desactivar 2FA';

  @override
  String get enable2fa => 'Activar 2FA';

  @override
  String get strongSecurityActive => 'Seguridad sólida activa';

  @override
  String get addExtraSecurity => 'Añadir una capa extra de seguridad';

  @override
  String get orders => 'Pedidos';

  @override
  String get trackManagePurchases => 'Seguimiento y gestión de tus compras';

  @override
  String get verification => 'Verificación';

  @override
  String get becomeFarmer => 'Convertirse en agricultor';

  @override
  String get startSellingProduce => 'Comienza a vender tus productos';

  @override
  String get becomeInvestor => 'Convertirse en inversor';

  @override
  String get investSustainableFarming => 'Invertir en agricultura sostenible';

  @override
  String get worker => 'Trabajador';

  @override
  String get becomeWorker => 'Convertirse en trabajador';

  @override
  String get offerSkillsFarms => 'Ofrece tus habilidades en granjas';

  @override
  String get workerDashboard => 'Tablero del trabajador';

  @override
  String get viewAssignmentsTasks => 'Ver tus asignaciones y tareas';

  @override
  String get gameFeatures => 'Funciones del juego';

  @override
  String get appearance => 'Apariencia';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get aboutUs => 'Sobre nosotros - Equipo Farmy';

  @override
  String get featureUnderDevelopment =>
      'Esta función está actualmente en desarrollo.';

  @override
  String get home => 'Inicio';

  @override
  String get marketplace => 'Mercado';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get settings => 'Ajustes';

  @override
  String get analytics => 'Análisis';

  @override
  String get land => 'Tierra';

  @override
  String get products => 'Productos';

  @override
  String get myFarms => 'Mis granjas';

  @override
  String get explore => 'Explorar';

  @override
  String get investments => 'Inversiones';

  @override
  String get revenue => 'Ingresos';

  @override
  String get tasks => 'Tareas';

  @override
  String get openInvestmentAssistant => 'Abrir asistente de inversión';

  @override
  String get openAiAssistant => 'Abrir asistente de IA';

  @override
  String get myWorkerTasks => 'Mis tareas de trabajador';

  @override
  String unknownRole(String role) {
    return 'Rol desconocido: $role';
  }

  @override
  String get appName => 'Farmy';

  @override
  String get unknown => 'Desconocido';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get revenueTitle => 'Ingresos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get signup => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get welcomeToFarmy => 'Bienvenido a Farmy';

  @override
  String get signInToFarmyAccount => 'Inicia sesión en tu cuenta de Farmy';

  @override
  String get startJourneyWithFarmy => 'Comienza tu viaje con Farmy hoy';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get signingIn => 'Iniciando sesión...';

  @override
  String get signingUp => 'Registrándose...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get orContinueWith => 'O CONTINUAR CON';

  @override
  String get loginFailed => 'Error de inicio de sesión';

  @override
  String get signupFailed => 'Error de registro';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get ok => 'Aceptar';

  @override
  String get myProducts => 'Mis productos';

  @override
  String get deleteProduct => 'Eliminar producto';

  @override
  String deleteProductConfirmation(String title) {
    return '¿Estás seguro de que deseas eliminar $title?';
  }

  @override
  String get productDeleted => 'Producto eliminado';

  @override
  String get failedToDeleteProduct => 'Error al eliminar el producto';

  @override
  String get analyzeInventory => 'Analizar inventario';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get addProductFirst => '¡Añade tu primer producto para verlo aquí!';

  @override
  String get edit => 'Editar';

  @override
  String get credits => 'Créditos';

  @override
  String get productLimitReached => 'Límite de productos alcanzado';

  @override
  String get viewPlans => 'Ver planes';

  @override
  String get maybeLater => 'Más tarde';

  @override
  String get oopsSomethingWentWrong => '¡Ups! Algo salió mal';

  @override
  String get productListingsUsed => 'Listados de productos usados';

  @override
  String get upgradePlanName => 'Farmer Pro';

  @override
  String get analyzeInventoryPrompt =>
      'Analiza mi inventario de productos actual. ¿Son estos buenos productos para mantener o debería centrarme en otra cosa según el mercado?';

  @override
  String get imageUnavailable => 'Imagen no disponible';

  @override
  String productLimitMessage(String planName) {
    return 'Has usado todos los espacios de productos en tu plan $planName. ¡Actualiza a Farmer Pro o Investor Plus para listar más productos!';
  }

  @override
  String get workerMarketplace => 'Mercado de Trabajadores';

  @override
  String get searchWorkers => 'Buscar trabajadores...';

  @override
  String get noVerifiedWorkersFound =>
      'No se encontraron trabajadores verificados';

  @override
  String tasksCount(int count) {
    return '$count tareas';
  }

  @override
  String get perHour => '/hora';

  @override
  String workforceLandName(String landName) {
    return 'Mano de obra — $landName';
  }

  @override
  String get addWorker => 'Añadir Trabajador';

  @override
  String get inviteExistingWorker => 'Inviter Trabajador Existente';

  @override
  String get searchWorkerMarketplace => 'Buscar en el mercado de trabajadores';

  @override
  String get openJobRequest => 'Abrir Solicitud de Trabajo';

  @override
  String get soon => 'Pronto';

  @override
  String get totalLabel => 'Total';

  @override
  String get activeLabel => 'Activo';

  @override
  String get suspendedLabel => 'Suspendido';

  @override
  String get monthlyCost => 'Costo Mensuel';

  @override
  String get productivity => 'Productividad';

  @override
  String totalSuffix(int count) {
    return '$count en total';
  }

  @override
  String get noWorkersYet => 'Aún no hay trabajadores';

  @override
  String get addWorkersMarketplaceHint =>
      'Toca el botón + para añadir trabajadores del mercado';

  @override
  String get unknownWorker => 'Trabajador Desconocido';

  @override
  String get tndMo => 'TND/mes';

  @override
  String get workersSyncIssue => 'Problema de sincronización de trabajadores';

  @override
  String get invitationsSyncIssue =>
      'Problema de sincronización de invitaciones';

  @override
  String get pendingInvitations => 'Invitaciones Pendientes';

  @override
  String get waitingForWorkerResponse => 'Esperando respuesta del trabajador';

  @override
  String get invitationDecisions => 'Decisiones de Invitación';

  @override
  String get workersAcceptedDeclinedInvites =>
      'Trabajadores que aceptaron o rechazaron sus invitaciones';

  @override
  String get aiAutoAssignTasks => '🤖 Asignación Automática de Tareas por IA';

  @override
  String get gpsVerifiedWorkProof => '📍 Prueba de Trabajo Verificada por GPS';

  @override
  String get iotSensorDashboard => '🌡️ Panel de Control de Sensores IoT';

  @override
  String get smartPayrollIntegration => '💰 Integración de Nómina Inteligente';

  @override
  String get freshProductsFarmers =>
      'Productos frescos de agricultores locales';

  @override
  String get myOrders => 'Mis Pedidos';

  @override
  String get searchProducts => 'Buscar productos...';

  @override
  String get all => 'Todos';

  @override
  String get noProductsFoundMarketplace => 'No se encontraron productos';

  @override
  String get noProductsAvailableMarketplace => 'No hay productos disponibles';

  @override
  String get adjustSearchFilters => 'Intenta ajustar tu búsqueda o filtros';

  @override
  String get checkBackLaterFreshProducts =>
      'Vuelve más tarde para ver productos frescos';

  @override
  String get outOfStock => 'SIN STOCK';

  @override
  String get inBasket => 'En la cesta';

  @override
  String availableCount(int count, String unit) {
    return '$count $unit disponible(s)';
  }

  @override
  String subtotalLabel(String price) {
    return 'Subtotal: $price TND';
  }

  @override
  String get seller => 'Vendedor';

  @override
  String get farmer => 'Agricultor';

  @override
  String get verifiedSeller => 'Vendedor Verificado';

  @override
  String get updateBasket => 'Actualizar Cesta';

  @override
  String get addToBasket => 'Añadir al carrito';

  @override
  String qtySetTo(String title, int qty) {
    return '$title — cantidad ajustada a $qty';
  }

  @override
  String addedToBasket(String title) {
    return '$title añadido al carrito';
  }

  @override
  String get noOrdersYet => 'Aún no hay pedidos';

  @override
  String get orderHistoryEmptyHint =>
      'Tu historial de pedidos aparecerá aquí\ndespués de tu primera compra.';

  @override
  String get order => 'Pedido';

  @override
  String get farmyPremium => 'Farmy Premium';

  @override
  String currentPlanLabel(String name) {
    return 'Actual: $name';
  }

  @override
  String get monthly => 'Mensual';

  @override
  String get yearlySave => 'Anual (Ahorra un 33%)';

  @override
  String get failedToLoadSubscriptions => 'Error al cargar suscripciones';

  @override
  String get failedToLoadWorkerProfile =>
      'Error al cargar perfil de trabajador';

  @override
  String get currentPlan => 'Plan Actual';

  @override
  String get upgradeToYearly => 'Pasar a Anual';

  @override
  String get switchToMonthly => 'Pasar a Mensual';

  @override
  String get downgradeToFree => 'Bajar a Gratuito';

  @override
  String get getStarted => 'Comenzar';

  @override
  String activeOnCycle(String cycle) {
    return 'Activo en $cycle';
  }

  @override
  String get confirmDowngrade => 'Confirmar Cambio a Plan Inferior';

  @override
  String downgradeWarning(String name) {
    return '¿Estás seguro de que quieres bajar a $name? Perderás tus funciones premium y las ventajas activas asociadas a tu plan actual.';
  }

  @override
  String get selectPaymentMethod => 'Seleccionar método de pago';

  @override
  String totalWithCycle(String price, String cycle) {
    return 'Total: $price \$ · $cycle';
  }

  @override
  String get payWithCredits => 'Pagar con créditos Farmy';

  @override
  String get loadingBalance => 'Cargando saldo...';

  @override
  String balanceValue(String amount) {
    return 'Saldo: $amount \$';
  }

  @override
  String get payWithStripe => 'Pagar con Tarjeta (Stripe)';

  @override
  String get secureCreditCardPayment => 'Pago seguro con tarjeta de crédito';

  @override
  String get unableToLoadTracking => 'No se pudo cargar el seguimiento';

  @override
  String get noTrackingInformation => 'No hay información de seguimiento';

  @override
  String get deliveryTrackingEmptyHint =>
      'El seguimiento del envío aparecerá\nuna vez que se procese su pedido.';

  @override
  String get orderDelivered => '¡Pedido Entregado!';

  @override
  String get orderDeliveredSuccess =>
      'Su pedido ha sido entregado con éxito. ¡Gracias por su compra!';

  @override
  String get updating => 'Actualizando';

  @override
  String get profileSyncIssue => 'Problema de sincronización de perfil';

  @override
  String get assignedLandsUnavailable => 'Tierras asignadas no disponibles';

  @override
  String get tasksUnavailable => 'Tareas no disponibles';

  @override
  String get invitationsUnavailable => 'Invitaciones no disponibles';

  @override
  String get contractsUnavailable => 'Contratos no disponibles';

  @override
  String get proofsUnavailable => 'Pruebas no disponibles';

  @override
  String get viewAllHistory => 'Ver Todo el Historial';

  @override
  String get noLandAssignmentsYet => 'No hay asignaciones de tierra todavía';

  @override
  String get landAssignmentsEmptyHint => 'Verás tus tierras asignadas aquí';

  @override
  String get noTasksAssigned => 'No hay tareas asignadas';

  @override
  String get tasksEmptyHint =>
      'Las tareas aparecerán aquí cuando sean asignadas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get realtimeNotificationsSoon =>
      'Notificaciones de tareas en tiempo real próximamente';

  @override
  String get verifiedWorker => 'Trabajador Verificado';

  @override
  String get pendingVerification => 'Verificación Pendiente';

  @override
  String get invitationAcceptedSuccess => 'Invitación aceptada con éxito.';

  @override
  String get invitationDeclinedSuccess => 'Invitación rechazada con éxito.';

  @override
  String get unableToProcessInvitation =>
      'No se pudo procesar la respuesta a la invitación.';

  @override
  String get landBoundary => 'Límite del terreno';

  @override
  String get landInformation => 'Información del terreno';

  @override
  String get noDescriptionAvailable => 'No hay descripción disponible';

  @override
  String get grid => 'Cuadrícula';

  @override
  String get assignmentRole => 'Rol de asignación';

  @override
  String get salaryLabel => 'Salario';

  @override
  String salaryValue(String amount) {
    return '$amount \$ / mes';
  }

  @override
  String get assignmentStatus => 'Estado de asignación';

  @override
  String get farmerProfileUnavailable =>
      'El perfil del agricultor no está disponible ahora mismo.';

  @override
  String get unableToOpenFarmerProfile =>
      'No se pudo abrir el perfil del agricultor. Por favor, reinténtalo.';

  @override
  String get invitationApproved => 'Invitación Aprobada';

  @override
  String get invitationPending => 'Invitación Pendiente';

  @override
  String get invitationDeclined => 'Invitación Rechazada';

  @override
  String get invitationExpired => 'Invitación Expirada';

  @override
  String get assigned => 'Asignado';

  @override
  String get acceptThisOfferQuestion => '¿Aceptar esta oferta?';

  @override
  String acceptOfferConfirmation(String amount, String type) {
    return 'Estás a punto de aceptar la oferta de \$$amount $type. Esto establecerá un contrato legal.';
  }

  @override
  String get contractApproved =>
      '¡Contrato aprobado! Esperando el pago del inversor.';

  @override
  String get failedToAccept => 'Error al aceptar la oferta.';

  @override
  String get declineThisOfferQuestion => '¿Rechazar esta oferta?';

  @override
  String declineOfferConfirmation(String name) {
    return '¿Estás seguro de que deseas rechazar la oferta de $name?';
  }

  @override
  String get theInvestor => 'el inversor';

  @override
  String get contractDeclined => 'Oferta de contrato rechazada.';

  @override
  String get failedToDecline => 'Error al rechazar la oferta.';

  @override
  String get pleaseEnterAMessage => 'Por favor ingresa un mensaje';

  @override
  String get pleaseEnterValidSalary =>
      'Por favor ingresa un monto de salario válido';

  @override
  String get counterOfferSent => '¡Contraoferta enviada con éxito!';

  @override
  String get failedToSendCounterOffer => 'Error al enviar la contraoferta.';

  @override
  String get messageCannotBeEmpty => 'El mensaje no puede estar vacío';

  @override
  String get messageUpdated => 'Mensaje actualizado con éxito';

  @override
  String get failedToEditMessage => 'Error al actualizar el mensaje';

  @override
  String get withdrawMessageQuestion => '¿Retirar este mensaje?';

  @override
  String get withdrawMessageConfirmation =>
      'Esto eliminará permanentemente tu último mensaje de negociación.';

  @override
  String get withdraw => 'Retirar';

  @override
  String get messageWithdrawn => 'Mensaje retirado';

  @override
  String get failedToWithdrawMessage => 'Error al retirar el mensaje';

  @override
  String investorAcceptOfferConfirmation(
    String name,
    String amount,
    String type,
  ) {
    return 'Estás a punto de aceptar la contraoferta de $name de \$$amount $type. Una vez aceptada, deberás pagar el primer mes de salario para activar el contrato.';
  }

  @override
  String get theWorker => 'el trabajador';

  @override
  String get offerAcceptedProceedToPayment =>
      '¡Oferta aceptada! Por favor procede al pago para activar el contrato.';

  @override
  String get declineNegotiationQuestion => '¿Rechazar negociación?';

  @override
  String declineNegotiationConfirmation(String name) {
    return '¿Estás seguro de que deseas rechazar más negociaciones con $name?';
  }

  @override
  String get thisWorker => 'este trabajador';

  @override
  String get negotiationDeclined => 'Negociación rechazada y cerrada.';

  @override
  String get failedToCreatePayment => 'Error al crear el intento de pago.';

  @override
  String get contractActivated => '¡Contrato activado con éxito!';

  @override
  String get invalidPaymentData =>
      'Datos de pago inválidos recibidos del servidor. Por favor, inténtelo de nuevo.';

  @override
  String get paymentSubmittedHint =>
      'Pago enviado. El contrato se activará una vez confirmado.';

  @override
  String get paymentCancelled => 'El pago fue cancelado.';

  @override
  String contractForWorker(String name) {
    return 'Contrato para $name';
  }

  @override
  String get negotiationDeclinedBanner => 'Negociación Rechazada';

  @override
  String get contractTerminatedBanner => 'Contrato Terminado';

  @override
  String get contractExpiredBanner => 'Contrato Expirado';

  @override
  String contractIsStatus(String status) {
    return 'Este contrato está $status';
  }

  @override
  String get noMessagesYet => 'Aún no hay mensajes';

  @override
  String get startNegotiationHint =>
      'Inicia la negociación enviando un mensaje.';

  @override
  String get systemOfferAccepted => 'Oferta aceptada. Procediendo al pago.';

  @override
  String get systemOfferDeclined =>
      'Oferta rechazada. Esta negociación ha sido cancelada.';

  @override
  String get you => 'Tú';

  @override
  String get otherParty => 'Otra parte';

  @override
  String proposedSalaryAmount(String amount) {
    return 'Salario propuesto: \$$amount';
  }

  @override
  String get editingYourMessage => 'Editando tu mensaje';

  @override
  String get editYourMessageHint => 'Edita tu mensaje...';

  @override
  String get salaryOptional => 'Salario (opcional)';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(String mins) {
    return 'hace $mins min';
  }

  @override
  String hoursAgo(String hours) {
    return 'hace ${hours}h';
  }

  @override
  String get negotiateTerms => 'Negociar términos';

  @override
  String get salaryAmount => 'Monto del salario';

  @override
  String get addAMessageHint => 'Añadir un mensaje...';

  @override
  String get counter => 'Contraoferta';

  @override
  String get counterOffer => 'Contraoferta';

  @override
  String payAmountToActivate(String amount) {
    return 'Pagar \$$amount para activar';
  }

  @override
  String get hiringPending => 'Contratación Pendiente';

  @override
  String get negotiating => 'Negociando';

  @override
  String get awaitingPayment => 'Esperando Pago';

  @override
  String get negotiate => 'Negociar';

  @override
  String get perTask => 'por tarea';

  @override
  String squareMeters(int count) {
    return '$count m²';
  }

  @override
  String amountPrefix(String amount) {
    return '\$$amount';
  }

  @override
  String get terminatedLabel => 'Terminado';

  @override
  String get hourlyLabel => 'por hora';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get contract => 'Contrato';

  @override
  String get paymentFailedCancelled => 'Pago fallido o cancelado.';

  @override
  String get farmerInfoSyncedFromAssignment =>
      'Información sincronizada de la asignación';

  @override
  String get tapToViewProfile => 'Toca para ver el perfil';

  @override
  String salaryPerMonth(String amount) {
    return '\$$amount / mes';
  }

  @override
  String get revenueAnalysisPrompt =>
      'Analice mis fuentes de ingresos y sugiera formas de maximizar mis ganancias basadas en las tendencias actuales del mercado.';

  @override
  String get analyzeRevenueTooltip => 'Analizar ingresos';

  @override
  String get totalDetailsRevenue => 'Ingresos detallados totales';

  @override
  String get creditsLabel => 'Créditos';

  @override
  String get productSales => 'Ventas de productos';

  @override
  String get unitsLabel => 'Unidades';

  @override
  String get investmentRevenue => 'Ingresos de inversión';

  @override
  String get viewInvestmentBreakdown => 'Ver desglose detallado en Inversiones';

  @override
  String get portfolioInsights => 'Información de la cartera';

  @override
  String get premiumLabel => 'PREMIUM';

  @override
  String get unlockPortfolioMaster => 'Desbloquear Portfolio Master';

  @override
  String get premiumPortfolioDesc =>
      'Obtenga seguimiento de ROI en tiempo real, informes de dividendos automatizados y consejos de inversión impulsados por IA.';

  @override
  String get investorPlus => 'Inversor Plus';

  @override
  String get portfolioAnalyticsLoading => 'Cargando análisis de cartera...';

  @override
  String get passwordChangedSuccess => 'Contraseña cambiada con éxito';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get createNewPassword => 'Crear una nueva contraseña';

  @override
  String get passwordPolicyHint =>
      'Su nueva contraseña debe ser diferente de las contraseñas anteriores utilizadas.';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get enterCurrentPasswordError =>
      'Por favor ingrese su contraseña actual';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String profileSyncFailed(String error) {
    return 'Error al sincronizar el perfil: $error';
  }

  @override
  String get unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get unsavedChangesDesc =>
      'Tienes cambios sin guardar. ¿Quieres descartarlos?';

  @override
  String get discard => 'Descartar';

  @override
  String get waitUsernameCheck =>
      'Por favor espere la verificación de disponibilidad del nombre de usuario';

  @override
  String get correctErrorsInForm =>
      'Por favor corrija los errores en el formulario';

  @override
  String get usernameTaken => 'Este nombre de usuario ya está ocupado';

  @override
  String get profileUpdatedSuccess => '¡Perfil actualizado con éxito!';

  @override
  String get changeProfilePicture => 'Cambiar foto de perfil';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get takeAPhoto => 'Tomar una foto';

  @override
  String get profilePictureUpdated => '¡Foto de perfil actualizada!';

  @override
  String uploadFailed(String error) {
    return 'Error al cargar: $error';
  }

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get identityTab => 'Identidad';

  @override
  String get trustTab => 'Confianza';

  @override
  String get rolePrivacyTab => 'Rol y privacidad';

  @override
  String get saveChangesTooltip => 'Guardar cambios';

  @override
  String get profileCompleteness => 'Integridad del perfil';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get nameTooShort => 'El nombre es demasiado corto';

  @override
  String get onlyLettersAllowed => 'Solo se permiten letras y espacios';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get publicUniqueHandle => 'Identificador único público';

  @override
  String get usernameRequired => 'El nombre de usuario es obligatorio';

  @override
  String get tooShortMin3 => 'Demasiado corto (mín. 3)';

  @override
  String get usernameFormatError =>
      'Usa minúsculas, números, puntos, guiones bajos';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get invalidPhoneFormat => 'Formato de teléfono inválido';

  @override
  String get countryLabel => 'País';

  @override
  String get cityLabel => 'Ciudad';

  @override
  String get headlineLabel => 'Titular';

  @override
  String get headlineHint => 'Una breve descripción de lo que haces';

  @override
  String get aboutMe => 'Acerca de mí';

  @override
  String get portfolioLinks => 'Portafolio y enlaces';

  @override
  String get linkedinProfile => 'Perfil de LinkedIn';

  @override
  String get linkedinUrlError =>
      'Ingrese una URL o identificador de LinkedIn válido';

  @override
  String get personalWebsite => 'Sitio web personal';

  @override
  String get websiteUrlError => 'Ingrese una URL de sitio web válida';

  @override
  String get farmerDetailsTitle => 'Detalles del agricultor';

  @override
  String get businessFarmName => 'Nombre de la empresa/granja';

  @override
  String get investorDetailsTitle => 'Detalles del inversor';

  @override
  String get expectedBudgetRange => 'Rango de presupuesto esperado';

  @override
  String get budgetRangeHint => 'ej: \$10,000 - \$50,000';

  @override
  String get privacyControls => 'Controles de privacidad';

  @override
  String get discoverableMarketplace => 'Descubrible en el mercado';

  @override
  String get discoverableSubtitle =>
      'Permitir que otros encuentren y vean tu perfil';

  @override
  String get showContactInfoLabel => 'Mostrar información de contacto';

  @override
  String get showContactInfoSubtitle =>
      'Hacer visibles el teléfono y el correo electrónico para las conexiones';

  @override
  String get failedInitiate2FA => 'Error al iniciar la configuración de 2FA';

  @override
  String get twoFAEnabledSuccess => '2FA habilitado con éxito';

  @override
  String get twoFADisabledSuccess => '2FA deshabilitado con éxito';

  @override
  String get codeCopied => 'Código copiado al portapapeles';

  @override
  String get disable2FA => 'Deshabilitar 2FA';

  @override
  String get enable2FA => 'Habilitar 2FA';

  @override
  String get secureYourAccount => 'Proteja su cuenta';

  @override
  String get twoFADesc =>
      'La autenticación de dos factores agrega una capa adicional de seguridad a su cuenta. Para iniciar sesión, deberá proporcionar un código de 6 dígitos de su aplicación de autenticación.';

  @override
  String get startSetup => 'Iniciar configuración';

  @override
  String get linkYourAppStep => 'Paso 1: Vincule su aplicación';

  @override
  String get scanQRCodeDesc =>
      'Escanee este código QR con su aplicación de autenticación (Google Authenticator, Authy, etc.)';

  @override
  String get enterCodeManually => 'O ingrese este código manualmente:';

  @override
  String get copyToClipboardTooltip => 'Copiar al portapapeles';

  @override
  String get confirmEnablementStep => 'Paso 2: Confirmar habilitación';

  @override
  String get enter6DigitCodeConfirm =>
      'Ingrese el código de 6 dígitos de su aplicación para confirmar:';

  @override
  String get backButton => 'Volver';

  @override
  String get enter6DigitCodeDisable =>
      'Ingrese el código de 6 dígitos de su aplicación de autenticación para deshabilitar la autenticación de dos factores.';

  @override
  String get allNotificationsMarkedRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String get failedToDeleteNotification => 'Error al eliminar la notificación';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsReadTooltip => 'Marcar todo como leído';

  @override
  String get noNotificationsYet => 'No hay notificaciones todavía';

  @override
  String get premiumAccess => 'Acceso Premium';

  @override
  String get chooseYourPlan => 'Elige tu plan';

  @override
  String get subscriptionHeadline =>
      'Selecciona un plan para desbloquear la experiencia completa de Farmy.\nUna suscripción abre todas las puertas.';

  @override
  String get yearly => 'Anual';

  @override
  String get alwaysFree => 'Siempre gratis';

  @override
  String get freeLabel => 'Gratis';

  @override
  String get monthlySuffix => '/mes';

  @override
  String get yearlySuffix => '/año';

  @override
  String savingsLabel(String oldPrice, String savings) {
    return 'Antes $oldPrice/año — ahorra $savings';
  }

  @override
  String get continueWithFree => 'Continuar con el gratuito';

  @override
  String getPlan(String planName) {
    return 'Obtener $planName';
  }

  @override
  String paymentSummary(String price, String cycle, String planName) {
    return '$price · $cycle · $planName';
  }

  @override
  String balanceStatusSuccess(String amount) {
    return 'Saldo: $amount ✓';
  }

  @override
  String balanceStatusInsufficient(String amount) {
    return 'Saldo: $amount — Insuficiente';
  }

  @override
  String get payWithCardStripe => 'Pagar con tarjeta (Stripe)';

  @override
  String get secureCardPaymentDesc =>
      'Pago seguro con tarjeta de crédito / débito';

  @override
  String get failedLoadPlans => 'Error al cargar los planes';

  @override
  String get noPlansAvailable => 'No hay planes disponibles';

  @override
  String get contactSupport => 'Por favor, contacte con soporte.';

  @override
  String get paymentPendingVerifying =>
      'Pago enviado. Lo estamos verificando en segundo plano.';

  @override
  String get paymentProcessingSync =>
      'El pago aún se está procesando. Su suscripción se sincronizará automáticamente.';

  @override
  String get paymentStatusDelay =>
      'La verificación del estado del pago se ha retrasado. Seguiremos sincronizando en segundo plano.';

  @override
  String paymentError(String error) {
    return 'Error de pago: $error';
  }

  @override
  String get deliveriesTitle => 'Entregas';

  @override
  String get ordersTitle => 'Pedidos';

  @override
  String totalCount(String total) {
    return '$total en total';
  }

  @override
  String get totalOrdersLabel => 'Total de pedidos';

  @override
  String get deliveredLabel => 'Entregado';

  @override
  String get noDeliveriesYet => 'No hay entregas todavía';

  @override
  String get noDeliveriesDesc =>
      'Las entregas de sus productos\naparecerán aquí cuando los clientes realicen pedidos.';

  @override
  String get manageDeliveryTitle => 'Gestionar entrega';

  @override
  String get deliveryNotFound => 'Entrega no encontrada';

  @override
  String get deliveryTimeline => 'Cronología de entrega';

  @override
  String get updateStatus => 'Actualizar estado';

  @override
  String etaLabel(String time) {
    return 'ETA: $time';
  }

  @override
  String get orderDetails => 'Detalles del pedido';

  @override
  String get productLabel => 'Producto';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get orderIdLabel => 'ID del pedido';

  @override
  String get customerLabel => 'Cliente';

  @override
  String get deliveryInfo => 'Información de entrega';

  @override
  String get addressLabel => 'Dirección';

  @override
  String get createdLabel => 'Creado';

  @override
  String get startedLabel => 'Iniciado';

  @override
  String get cancelDeliveryQuestion => '¿Cancelar entrega?';

  @override
  String updateToStatusQuestion(String status) {
    return '¿Pasar a $status?';
  }

  @override
  String get cancelNotifyCustomer =>
      'Esto cancelará la entrega y notificará al cliente.';

  @override
  String advanceNotifyCustomer(String status) {
    return 'Esto avanzará la entrega a \"$status\" y notificará al cliente.';
  }

  @override
  String get cancellationReasonHint => 'Motivo de la cancelación...';

  @override
  String get addNoteHint => 'Añadir una nota (opcional)...';

  @override
  String get confirmUpdate => 'Confirmar';

  @override
  String get cancelDeliveryAction => 'Cancelar entrega';

  @override
  String statusUpdatedTo(String status) {
    return 'Estado actualizado a $status';
  }

  @override
  String get failedUpdateStatus => 'Error al actualizar el estado';

  @override
  String moveToStatus(String status) {
    return 'Pasar a $status';
  }

  @override
  String get successfullyDelivered => 'Entregado con éxito';

  @override
  String get deliveryCancelled => 'Entrega cancelada';

  @override
  String completedOn(String date) {
    return 'Completado el $date';
  }

  @override
  String dateTimeAt(String date, String time) {
    return '$date a las $time';
  }

  @override
  String get cardAddedSuccess => 'Tarjeta añadida con éxito';

  @override
  String get failedAddCard => 'Error al añadir la tarjeta';

  @override
  String get addCreditsTitle => 'Añadir créditos';

  @override
  String get selectAmount => 'Seleccionar cantidad';

  @override
  String get customAmountLabel => 'Cantidad personalizada';

  @override
  String get maxAmountError => 'La cantidad máxima es \$999,999.99';

  @override
  String payAmount(String amount) {
    return 'PAGAR \$$amount';
  }

  @override
  String get enterAmount => 'INGRESAR MONTO';

  @override
  String successfullyAddedCredits(String amount) {
    return 'Añadido con éxito $amount \$';
  }

  @override
  String priceTnd(String price) {
    return '$price TND';
  }

  @override
  String get failedAddCredits => 'Error al añadir créditos';

  @override
  String get walletPaymentsTitle => 'Billetera y pagos';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get paymentMethods => 'Métodos de pago';

  @override
  String get addNewCard => 'Añadir nueva tarjeta';

  @override
  String expiresLabel(String expiry) {
    return 'Expira el $expiry';
  }

  @override
  String get failedLoadTasks => 'Error al cargar las tareas';

  @override
  String get errorFetchingTasks => 'Error al obtener sus tareas';

  @override
  String get taskCompletedSuccess =>
      '¡Tarea completada! Ahora estás disponible.';

  @override
  String get failedCompleteTask => 'Error al completar la tarea';

  @override
  String errorWithPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get myTasksTitle => 'Mis tareas';

  @override
  String get noPendingTasks => '¡No hay tareas pendientes!';

  @override
  String get availableForAssignments =>
      'Estás disponible para nuevas asignaciones.';

  @override
  String get taskLabel => 'Tarea';

  @override
  String get unknownCaps => 'DESCONOCIDO';

  @override
  String get minsSuffix => 'mins';

  @override
  String get markAsComplete => 'Marcar como completa';

  @override
  String get productionGuruTitle => 'Gurú de producción';

  @override
  String get sessionHistoryTooltip => 'Historial de sesiones';

  @override
  String get newSessionTooltip => 'Nueva sesión';

  @override
  String get askGuruHint => 'Pregunta a tu gurú...';

  @override
  String get harvestChroniclesTitle => 'Crónicas de la cosecha';

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get farmAnalysisDefault => 'Análisis de la granja';

  @override
  String get assetsLabel => 'Activos';

  @override
  String get failedReachAnalyst =>
      'Error al contactar al analista de estrategia de IA.';

  @override
  String get strategicPortfolioAnalystTitle =>
      'Analista de cartera estratégica';

  @override
  String get investmentStrategyChroniclesTitle =>
      'Crónicas de estrategia de inversión';

  @override
  String get strategySessionDefault => 'Sesión de estrategia';

  @override
  String get welcomeStrategicAnalysis => 'Bienvenido al análisis estratégico';

  @override
  String get investmentAgentWelcomeDesc =>
      'Dime tu presupuesto y preferencia de riesgo, o pregunta sobre el mercado actual y las tendencias meteorológicas.';

  @override
  String get consultedLiveData => 'Datos en vivo consultados:';

  @override
  String get marketLabel => 'Mercado';

  @override
  String get weatherLabel => 'Clima';

  @override
  String get suggestedRealEstate => 'Bienes raíces sugeridos:';

  @override
  String get unknownFarm => 'Granja desconocida';

  @override
  String get tndPerMeter => 'TND/m';

  @override
  String get enterPreferencesHint =>
      'Introduce preferencias o pide un análisis...';

  @override
  String get laborMarketLabel => 'MERCADO LABORAL';

  @override
  String get specificationsLabel => 'Especificaciones:';

  @override
  String get priceLabel => 'Precio';

  @override
  String get rateLabel => 'Tarifa';

  @override
  String get ratingLabel => 'Calificación';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get estimatedDelivery => 'Entrega estimada';

  @override
  String get deliveryAddress => 'Dirección de entrega';

  @override
  String get sellerLabel => 'Vendedor';

  @override
  String get cancellationReasonLabel => 'Motivo de cancelación';

  @override
  String get orderSummary => 'Resumen del pedido';

  @override
  String get arrivingSoon => 'Llegando pronto';

  @override
  String etaMinutes(String mins) {
    return '~$mins min';
  }

  @override
  String etaHours(String hours, String mins) {
    return '~${hours}h ${mins}min';
  }

  @override
  String get driverNearby => '¡Conductor cerca!';

  @override
  String get onTheWay => 'En camino';

  @override
  String get youLabel => 'Tú';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterNew => 'Nuevo';

  @override
  String get filterConfirmed => 'Confirmado';

  @override
  String get filterPreparing => 'Preparando';

  @override
  String get filterInTransit => 'En tránsito';

  @override
  String get filterDelivered => 'Entregado';

  @override
  String get filterCancelled => 'Cancelado';

  @override
  String get unknownCustomer => 'Cliente desconocido';

  @override
  String get orderLabel => 'Pedido';

  @override
  String get manageButton => 'Gestionar';

  @override
  String get unavailable => 'No disponible';

  @override
  String get addMore => 'Añadir más';

  @override
  String qtyUpdatedTo(String title, String qty) {
    return '$title — cantidad actualizada a $qty';
  }

  @override
  String get maximumStockReached => 'Stock máximo alcanzado';

  @override
  String pricePerUnit(String price, String unit) {
    return '$price TND / $unit';
  }

  @override
  String get premiumFeatureTitle => 'Función Premium';

  @override
  String get premiumFeatureDesc =>
      'Actualiza tu suscripción para desbloquear esta función.';

  @override
  String get upgradeNow => 'Actualizar ahora';

  @override
  String upgradeRequiredDesc(String featureKey) {
    return 'Esta función ($featureKey) está disponible en un plan premium. Actualiza tu suscripción para desbloquearla.';
  }

  @override
  String get laterButton => 'Después';

  @override
  String get myLandsTitle => 'Mis Tierras';

  @override
  String get noLandsFound => 'No se encontraron tierras';

  @override
  String get noLandsRented => 'Todavía no has alquilado ninguna tierra.';

  @override
  String get landActive => 'Activo';

  @override
  String get landInactive => 'Inactivo';

  @override
  String get landsRented => 'Tierras Alquiladas';

  @override
  String get completenessLabel => 'Completitud';

  @override
  String get roleLabel => 'Rol';

  @override
  String get aboutLabel => 'Acerca de';

  @override
  String get directLinksLabel => 'Enlaces directos';

  @override
  String get websiteLabel => 'Sitio web';

  @override
  String farmyMemberSince(String date) {
    return 'Miembro de la comunidad Farmy desde $date';
  }

  @override
  String get privacyRestricted => 'Acceso restringido';

  @override
  String get profileNotFound => 'Perfil no encontrado o privado';

  @override
  String get profileLoadError =>
      'No se pudo cargar el perfil. Verifica tu conexión.';

  @override
  String get retryButton => 'Reintentar';

  @override
  String upgradeForUnlimited(String plan) {
    return 'Actualizar$plan para acceso ilimitado';
  }

  @override
  String get tapToViewPlans => 'Toca para ver los planes →';

  @override
  String get assignTaskTitle => 'Asignar tarea';

  @override
  String workersAvailable(String count) {
    return '$count Disponibles';
  }

  @override
  String get noTasksDefined => 'No hay tareas definidas para este elemento.';

  @override
  String get noAvailableWorkers => '¡No hay trabajadores disponibles!';

  @override
  String get taskAssigned => '¡Tarea asignada!';

  @override
  String get assignButton => 'Asignar';

  @override
  String get myTasksOnLand => 'Mis tareas en esta tierra';

  @override
  String get noPendingTasksHere => '¡No hay tareas pendientes aquí!';

  @override
  String get availableForAssignment => 'Estás disponible para asignaciones.';

  @override
  String get taskCompleted => '¡Tarea completada! Ahora estás disponible.';

  @override
  String get markCompleteButton => 'Marcar como completada';

  @override
  String get errorFetchingYourTasks => 'Error al obtener tus tareas';

  @override
  String get closeTip => 'Cerrar';

  @override
  String get farmyStore => 'TIENDA FARMY';

  @override
  String get nothingFoundHere => 'Nada encontrado aquí';

  @override
  String get shopBack => 'VOLVER';

  @override
  String get shopVariants => 'VARIANTES';

  @override
  String get shopBuy => 'COMPRAR';

  @override
  String get mustRentLand =>
      'Debes alquilar una tierra para comprar artículos.';

  @override
  String get selectLand => 'Seleccionar tierra';

  @override
  String get unknownLand => 'Tierra desconocida';

  @override
  String get purchaseRequestSent =>
      '¡Solicitud enviada! Transacción registrada en Hedera.';

  @override
  String get purchaseFailed => 'Compra fallida. ¿Créditos insuficientes?';

  @override
  String get topUpCredits => 'RECARGAR CRÉDITOS';

  @override
  String get customAmount => 'Monto personalizado';

  @override
  String maximumAmount(String max) {
    return 'El monto máximo es \$$max';
  }

  @override
  String creditsAdded(String amount) {
    return '¡Se agregaron \$$amount exitosamente!';
  }

  @override
  String get myInventory => 'MI INVENTARIO';

  @override
  String get allLands => 'Todas las tierras';

  @override
  String get unknownLandFallback => 'Desconocido';

  @override
  String get tabAll => 'TODO';

  @override
  String get tabPending => 'PENDIENTE';

  @override
  String get tabApproved => 'APROBADO';

  @override
  String get tabRejected => 'RECHAZADO';

  @override
  String get noItemsFound => 'No se encontraron artículos';

  @override
  String noItemsFoundStatus(String status) {
    return 'No se encontraron artículos $status';
  }

  @override
  String get placedBadge => 'COLOCADO';

  @override
  String get itemActions => 'Acciones del artículo';

  @override
  String get alreadyPlaced => 'Ya colocado';

  @override
  String get addToLand => 'Agregar a la tierra';

  @override
  String get wrongLand => 'Tierra incorrecta';

  @override
  String get alreadyPlacedSubtitle => 'Este artículo ya está en el mapa.';

  @override
  String get wrongLandSubtitle => 'Este artículo pertenece a otra tierra.';

  @override
  String get buyMore => 'Comprar más';

  @override
  String get failedToLoadData =>
      'No se pudieron cargar los datos. Por favor, intenta de nuevo.';

  @override
  String get failedToLoadInventory =>
      'No se pudo cargar el inventario. Por favor, intenta de nuevo.';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonDesc =>
      '¡Esta función está en desarrollo. Pronto podrás colocar artículos en tu tierra!';

  @override
  String get okButton => 'Aceptar';

  @override
  String get gotItButton => 'Entendido';

  @override
  String get placingItem => 'Colocando artículo...';

  @override
  String get itemPlacedSuccess => '¡Artículo colocado exitosamente!';

  @override
  String placingLabel(String name) {
    return 'Colocando: $name';
  }

  @override
  String get loadingFootprint => 'Cargando huella...';

  @override
  String sizeLabel(String w, String h) {
    return 'Tamaño: ${w}x$h';
  }

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get failedToLoadFarm => 'No se pudo cargar la granja';

  @override
  String get goBackButton => 'Volver';

  @override
  String get menuWorkforce => 'Mano de obra';

  @override
  String get menuMyTasks => 'Mis tareas';

  @override
  String get menuAiAdvisor => 'Asesor IA';

  @override
  String get menuInventory => 'Inventario';

  @override
  String get menuShop => 'Tienda';

  @override
  String get menuExitGame => 'Salir del juego';

  @override
  String get mapTooltipInfo => 'Info';

  @override
  String get mapTooltipMove => 'Mover';

  @override
  String get mapTooltipTasks => 'Tareas';

  @override
  String placementFailed(String error) {
    return 'Error al colocar: $error';
  }

  @override
  String get placementFailedGeneric =>
      'No se pudo colocar el artículo. Intenta en otro lugar.';

  @override
  String daysAgo(String count) {
    return 'hace ${count}d';
  }

  @override
  String get couldNotOpenHashScan => 'No se pudo abrir HashScan';

  @override
  String get setMonthlySalary => 'Establecer salario mensual';

  @override
  String get assign => 'Asignar';

  @override
  String get tasksLabelShort => 'Tareas';

  @override
  String get assignToLand => 'Asignar al terreno';

  @override
  String invitationSentTo(String worker) {
    return 'Invitación enviada a $worker';
  }

  @override
  String get failedToSendInvitation => 'Error al enviar la invitación';

  @override
  String get inviteWorker => 'Invitar trabajador';

  @override
  String inviteWorkerMessage(String worker, String landName) {
    return 'Invitar a $worker a $landName';
  }

  @override
  String get optionalMessageHint => 'Mensaje opcional...';

  @override
  String get sendInvite => 'Enviar invitación';

  @override
  String workerAssignedToLand(String worker, String landName) {
    return '$worker asignado a $landName';
  }

  @override
  String get failedToAssignWorker => 'Error al asignar trabajador';

  @override
  String get directMessagingDescription => 'Descripción de mensajería directa';

  @override
  String get readReviewsDescription => 'Descripción de leer reseñas';

  @override
  String get messageWorker => 'Contactar trabajador';

  @override
  String get viewReviews => 'Ver reseñas';

  @override
  String get inviteToLand => 'Invitar al terreno';

  @override
  String amountPerHour(String amount) {
    return '\$$amount/h';
  }

  @override
  String get onTimeLabel => 'A tiempo';

  @override
  String get disputesLabel => 'Disputas';

  @override
  String get skills => 'Habilidades';

  @override
  String get about => 'Acerca de';

  @override
  String get performance => 'Rendimiento';

  @override
  String get performanceGraphComingSoon =>
      'Gráfico de rendimiento próximamente';

  @override
  String get manager => 'Gerente';

  @override
  String get pendingLabel => 'Pendiente';

  @override
  String get inactiveLabel => 'Inactivo';

  @override
  String get name => 'Nombre';

  @override
  String get salary => 'Salario';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get landDetails => 'Detalles del terreno';

  @override
  String amountPerMonth(String amount) {
    return '\$$amount/mes';
  }

  @override
  String get hourly => 'Por hora';

  @override
  String get listingPublished => 'Anuncio publicado';

  @override
  String get listingPublishedHint =>
      'Tu anuncio ahora es visible públicamente.';

  @override
  String get continueLabelUpper => 'CONTINUAR';

  @override
  String get failedToLoadProofs => 'Error al cargar las pruebas';

  @override
  String get aiVerifyingProof => 'La IA está verificando tu prueba...';

  @override
  String get proofVerifiedSuccessfully => '¡Prueba verificada con éxito!';

  @override
  String get noProofRequestsFound => 'No se encontraron solicitudes de prueba';

  @override
  String fromLabel(String name) {
    return 'De: $name';
  }

  @override
  String get investor => 'Inversor';

  @override
  String toLabel(String name) {
    return 'A: $name';
  }

  @override
  String mustSubmitBefore(String date) {
    return 'Debe enviar antes de $date';
  }

  @override
  String aiNotes(String notes) {
    return 'Notas de IA: $notes';
  }

  @override
  String get submitPhotoProof => 'Enviar prueba fotográfica';

  @override
  String get createNewTask => 'Crear nueva tarea';

  @override
  String get taskTitle => 'Título de la tarea';

  @override
  String get taskTitleHint => 'ej., Regar los tomates';

  @override
  String get descriptionOptional => 'Descripción (Opcional)';

  @override
  String get taskType => 'Tipo de tarea';

  @override
  String get rewardLabel => 'Recompensa';

  @override
  String rewardAmountTnd(String amount) {
    return '$amount TND';
  }

  @override
  String get timeLabel => 'Tiempo';

  @override
  String get createTask => 'Crear tarea';

  @override
  String get pleaseEnterTaskTitle => 'Por favor ingresa un título';

  @override
  String get taskCreated => '¡Tarea creada con éxito!';

  @override
  String tasksForLand(String landName) {
    return 'Tareas para $landName';
  }

  @override
  String get open => 'Abierto';

  @override
  String get done => 'Hecho';

  @override
  String get noTasksHere => 'No hay tareas aquí';

  @override
  String activeTasksCount(int count) {
    return '$count tareas activas';
  }

  @override
  String get activeTasksLabel => 'Tareas activas';

  @override
  String get farmerPro => 'Farmer Pro';

  @override
  String assignedTo(String name) {
    return 'Asignado a $name';
  }

  @override
  String get taskLimitReached => 'Límite de tareas alcanzado';

  @override
  String taskLimitReachedMessage(String count) {
    return 'Solo puedes tener $count tareas activas en el plan gratuito.';
  }

  @override
  String get water => 'Regar';

  @override
  String get harvest => 'Cosechar';

  @override
  String get feed => 'Alimentar';

  @override
  String get install => 'Instalar';

  @override
  String get maintenance => 'Mantenimiento';

  @override
  String get inProgress => 'En progreso';

  @override
  String get completed => 'Completado';

  @override
  String get paymentFailedGeneric => 'El pago no pudo ser completado.';

  @override
  String paymentFailedWithError(String error) {
    return 'Pago fallido: $error';
  }

  @override
  String get proofRequestedHint =>
      'Se ha enviado una solicitud de prueba al trabajador.';

  @override
  String get requestAIProof => 'Solicitar prueba de IA';

  @override
  String get noProofsRequestedUpper => 'SIN PRUEBAS SOLICITADAS';

  @override
  String get requestProofHint =>
      'Pide al trabajador que envíe pruebas fotográficas de su trabajo.';

  @override
  String get removeWorker => 'Eliminar trabajador';

  @override
  String get remove => 'Eliminar';

  @override
  String get workerRemovedSuccessfully => 'Trabajador eliminado con éxito';

  @override
  String get failedToRemoveWorker => 'Error al eliminar al trabajador';

  @override
  String get systemErrorUpper => 'ERROR DEL SISTEMA';

  @override
  String get retryConnectionUpper => 'REINTENTAR CONEXIÓN';

  @override
  String get myInvestments => 'Mis inversiones';

  @override
  String get rentalConfirmed => 'Alquiler confirmado';

  @override
  String get rentalConfirmedDescription =>
      'Su alquiler ha sido confirmado y el equipo será entregado pronto.';

  @override
  String get goToDashboardUpper => 'IR AL PANEL';

  @override
  String get manageCards => 'Gestionar tarjetas';

  @override
  String get cardAddedSuccessfully => 'Tarjeta añadida con éxito';

  @override
  String get cancelledOrFailedToAddCard =>
      'Cancelado o error al añadir la tarjeta.';

  @override
  String get allocatingSpatialResources => 'Asignando recursos espaciales...';

  @override
  String get paymentFailedTryAgain =>
      'El pago falló. Por favor, inténtelo de nuevo.';

  @override
  String get paymentIssueHint => 'Hubo un problema al procesar su pago.';

  @override
  String get payNowUpper => 'PAGAR AHORA';

  @override
  String get pleaseSelectPaymentMethod =>
      'Por favor, seleccione un método de pago';

  @override
  String get securingRental => 'Asegurando el alquiler...';

  @override
  String get agreeToTermsAndPrivacy =>
      'Acepto los términos y la política de privacidad';

  @override
  String get totalAmount => 'Cantidad total';

  @override
  String amountTND(String amount) {
    return '$amount TND';
  }

  @override
  String get duration => 'Duración';

  @override
  String nMonths(String count) {
    return '$count meses';
  }

  @override
  String get totalProject => 'Proyecto Total';

  @override
  String get walletCredits => 'Créditos de la cartera';

  @override
  String get availableInstantPayment => 'Disponible para pago instantáneo';

  @override
  String get monthlyRent => 'Renta Mensual';

  @override
  String get defaultMethod => 'Predeterminado';

  @override
  String get savedCard => 'Tarjeta guardada';

  @override
  String get changeAction => 'Cambiar';

  @override
  String insufficientCredits(String amount) {
    return 'Créditos insuficientes: $amount disponible';
  }

  @override
  String get addPaymentMethod => 'Agregar método de pago';

  @override
  String balanceAmount(String amount) {
    return 'Saldo: $amount TND';
  }

  @override
  String get startingFrom => 'A partir de';

  @override
  String get monthAbbreviation => 'mes';

  @override
  String monthsAbbreviation(String count) {
    return '$count meses';
  }

  @override
  String get paymentSecurity => 'Pago seguro procesado por Stripe.';

  @override
  String get availableUpper => 'DISPONIBLE';

  @override
  String organicPlotGrid(int w, int h) {
    return 'Parcela orgánica (cuadrícula ${w}x$h)';
  }

  @override
  String get checkout => 'Pago';

  @override
  String get leaseStartDate => 'Fecha de inicio del contrato';

  @override
  String get rentalDuration => 'Duración del alquiler';

  @override
  String get failedToLoadRecords => 'Error al cargar los registros.';

  @override
  String get noBlockchainRecordsYet => 'Aún no hay registros de Blockchain';

  @override
  String get makePurchaseImmutableRecordsHint =>
      'Realiza una compra para ver registros inmutables aquí.';

  @override
  String get pendingUpper => 'PENDIENTE';

  @override
  String get rejectedUpper => 'RECHAZADO';

  @override
  String get fetchingBlockchainRecords =>
      'Obteniendo registros de la cadena de bloques...';

  @override
  String get transactionIdCopied => 'ID de transacción copiado al portapapeles';

  @override
  String get paidUpper => 'PAGADO';

  @override
  String get approvedUpper => 'APROBADO';

  @override
  String get rentalsLabel => 'Alquileres';

  @override
  String get purchasesLabel => 'Compras';

  @override
  String get hederaConsensusServiceUpper => 'SERVICIO DE CONSENSO DE HEDERA';

  @override
  String get proofSubmittedVerified => 'Prueba enviada y verificada con éxito.';

  @override
  String get hederaRegistryUpper => 'REGISTRO HEDERA';

  @override
  String get immutableOnChainRecords => 'Registros inmutables en cadena';

  @override
  String get captureSubmit => 'Capturar y Enviar';

  @override
  String get uploadingImage => 'Subiendo imagen...';

  @override
  String get pleaseWaitAFewMoments => 'Por favor, espere unos momentos...';

  @override
  String get orSelectAnItem => 'O seleccione un artículo';

  @override
  String itemIdUpper(String param) {
    return 'ID DEL ARTÍCULO';
  }

  @override
  String gridPlots(int w, int h) {
    return '${w}x$h parcelas';
  }

  @override
  String get hireUpper => 'CONTRATAR';

  @override
  String get size => 'Tamaño';

  @override
  String get ownerLabel => 'Propietario';

  @override
  String get draw => 'Dibujar';

  @override
  String get unknownItem => 'Artículo desconocido';

  @override
  String get moveAll => 'Mover todo';

  @override
  String plotNumber(String param) {
    return 'Nº de parcela';
  }

  @override
  String get optimalSolarExposure => 'Exposición solar óptima';

  @override
  String get cancelUpper => 'CANCELAR';

  @override
  String get failedToRejectRequest => 'Error al rechazar la solicitud';

  @override
  String get hireWorkersUpper => 'CONTRATAR TRABAJADORES';

  @override
  String get invalidGeometryAlert => 'Alerta de geometría inválida';

  @override
  String get activeTasks => 'Tareas activas';

  @override
  String get perTaskUpper => 'POR TAREA';

  @override
  String get analyzePortfolio => 'Analizar cartera';

  @override
  String get noPendingRequests => 'No hay solicitudes pendientes';

  @override
  String get heightAuto => 'Altura auto';

  @override
  String rentAmountMonthly(String param) {
    return 'Alquiler mensual: $param';
  }

  @override
  String get totalCapitalInvested => 'Capital total invertido';

  @override
  String get currentLand => 'Tierra actual';

  @override
  String get descriptionTooShort => 'Descripción demasiado corta';

  @override
  String get landName => 'Nombre de la tierra';

  @override
  String get alreadyRentedUpper => 'YA ALQUILADO';

  @override
  String get requestRejectedRefunded => 'Solicitud rechazada y reembolsada';

  @override
  String get rejectionReasonPrompt =>
      'Por favor, indique el motivo del rechazo';

  @override
  String get negotiationsUpper => 'NEGOCIACIONES';

  @override
  String get noWorkersFoundUpper => 'NO SE ENCONTRARON TRABAJADORES';

  @override
  String get unknownInvestor => 'Inversor desconocido';

  @override
  String hoursLeft(int count) {
    return '$count horas restantes';
  }

  @override
  String get rentalSlotsUsage => 'Uso de espacios de alquiler';

  @override
  String get selectAtLeast3Points => 'Seleccione al menos 3 puntos';

  @override
  String get activeLabelUpper => 'ACTIVO';

  @override
  String salaryAmountType(int amount, String type) {
    return '$amount / $type';
  }

  @override
  String get expiringSoon => 'Expira pronto';

  @override
  String get checkBackLaterOpportunities =>
      'Vuelva más tarde para ver nuevas oportunidades';

  @override
  String get inactive => 'Inactivo';

  @override
  String get endDateUpper => 'FECHA DE FIN';

  @override
  String farmerWithColon(String param) {
    return 'Agricultor: $param';
  }

  @override
  String get farmingActivity => 'Actividad agrícola';

  @override
  String get noActiveFarmingActivities =>
      'No hay actividades agrícolas activas';

  @override
  String get boundaries => 'Límites';

  @override
  String get noInvestmentsYet => 'Aún no hay inversiones';

  @override
  String get activeStatusUpper => 'ESTADO ACTIVO';

  @override
  String plotsCount(int w, int h) {
    return '${w}x$h parcelas';
  }

  @override
  String get noPendingRequestsHint =>
      'No tienes solicitudes pendientes en este momento.';

  @override
  String requestedDateUpper(String param) {
    return 'FECHA SOLICITADA: $param';
  }

  @override
  String get priceCannotBeEmpty => 'El precio no puede estar vacío';

  @override
  String get rentedUpper => 'ALQUILADO';

  @override
  String get rentalLimitReached => 'Límite de alquiler alcanzado';

  @override
  String get invitationUpdates => 'Actualizaciones de invitaciones';

  @override
  String get priceStartingFrom => 'Precio desde';

  @override
  String get locationHighlights => 'Lo más destacado de la ubicación';

  @override
  String get amount => 'Monto';

  @override
  String get publishingFailed => 'Error al publicar';

  @override
  String get securedWaterAccess => 'Acceso seguro al agua';

  @override
  String get monthlyRentPriceTND => 'Precio de alquiler mensual (TND)';

  @override
  String get geometryVerified => 'Geometría verificada';

  @override
  String landWithColon(String param) {
    return 'Tierra: $param';
  }

  @override
  String get cannotPublishInvalidGeometry =>
      'No se puede publicar con una geometría inválida';

  @override
  String get retryUpper => 'REINTENTAR';

  @override
  String get imageProofRequiredToApprove =>
      'Se requiere prueba de imagen para aprobar';

  @override
  String get sendProposalUpper => 'ENVIAR PROPUESTA';

  @override
  String get min => 'min';

  @override
  String get pricePerMonth => 'Precio por mes';

  @override
  String get noActiveWorkersUpper => 'NO HAY TRABAJADORES ACTIVOS';

  @override
  String get reasonTooShort => 'El motivo es demasiado corto';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get proofsUpper => 'PRUEBAS';

  @override
  String get noActiveNegotiationsUpper => 'NO HAY NEGOCIACIONES ACTIVAS';

  @override
  String get plantCrops => 'Plantar cultivos';

  @override
  String get readyForActivityHint => 'Listo para la actividad';

  @override
  String get irrigated => 'Irrigado';

  @override
  String get tryAdjustingFilters => 'Intente ajustar los filtros';

  @override
  String get occupiedUpper => 'OCUPADO';

  @override
  String get generalFarmingActivity => 'Actividad agrícola general';

  @override
  String endsDate(String param) {
    return 'Finaliza el: $param';
  }

  @override
  String daysLeft(int count) {
    return '$count días restantes';
  }

  @override
  String get hireActivateWorkersHint => 'Contratar y activar trabajadores';

  @override
  String get manageWorkers => 'Gestionar trabajadores';

  @override
  String get onTime => 'A tiempo';

  @override
  String removeWorkerConfirmation(String param) {
    return '¿Eliminar al trabajador $param?';
  }

  @override
  String get assignedLands => 'Tierras asignadas';

  @override
  String get limitReachedUpper => 'LÍMITE ALCANZADO';

  @override
  String get proofHistory => 'Historial de pruebas';

  @override
  String get farmerInvitations => 'Invitaciones de agricultores';

  @override
  String get workforceUpper => 'FUERZA LABORAL';

  @override
  String get descriptionRequired => 'Descripción requerida';

  @override
  String get priceGreaterThanZero => 'El precio debe ser mayor que cero';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get proofRequestQuestion => 'Pregunta de solicitud de prueba';

  @override
  String get rentalSlotsUsed => 'Espacios de alquiler utilizados';

  @override
  String get activeLands => 'Tierras activas';

  @override
  String get widthAuto => 'Ancho auto';

  @override
  String get spatialDimensions => 'Dimensiones espaciales';

  @override
  String idLabel(String param) {
    return 'ID: $param';
  }

  @override
  String rentalExpires(String param) {
    return 'El alquiler vence el: $param';
  }

  @override
  String proofSubmissionHint(String param) {
    return 'Envío de prueba: $param';
  }

  @override
  String landPlotNumber(String param) {
    return 'Nº de parcela: $param';
  }

  @override
  String get messageOptionalUpper => 'MENSAJE (OPCIONAL)';

  @override
  String get roiEst => 'ROI estimado';

  @override
  String get paymentRequiredToActivate => 'Pago requerido para activar';

  @override
  String get invalidNumericAmount => 'Monto numérico inválido';

  @override
  String pointsDefined(int count) {
    return '$count puntos definidos';
  }

  @override
  String nItemsSold(int count) {
    return '$count artículos vendidos';
  }

  @override
  String get itemVerification => '[itemVerification]';

  @override
  String get invalidGeometryHint => 'Se detectó una geometría inválida';

  @override
  String get declinedUpper => 'RECHAZADO';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get startByListingPlot => 'Comience por listar una parcela';

  @override
  String get propertyDetails => 'Detalles de la propiedad';

  @override
  String get invalidGeometry => 'Géometría inválida';

  @override
  String get failedToLoadRequests => 'Error al cargar las solicitudes';

  @override
  String untilDate(String param) {
    return 'hasta $param';
  }

  @override
  String get drawInstructions => 'Toque en el mapa para dibujar los límites';

  @override
  String get na => 'N/A';

  @override
  String get noTasksAssignedHint => 'Aún no hay tareas asignadas';

  @override
  String get cannotPublishBoundaryConflicts =>
      'No se puede publicar: se detectaron conflictos de límites';

  @override
  String get farmingActivities => 'Actividades agrícolas';

  @override
  String get listNewLand => 'Listar nueva tierra';

  @override
  String get noApprovedWorkersUpper => 'NO HAY TRABAJADORES APROBADOS';

  @override
  String get expiredUpper => 'EXPIRADO';

  @override
  String get conflictDetected => 'Conflicto detectado';

  @override
  String get rejectRequest => 'Rechazar solicitud';

  @override
  String get boundaryConflictAlert => 'Alerta de conflicto de límites';

  @override
  String get requestProof => 'Solicitar prueba';

  @override
  String get perHourUpper => 'POR HORA';

  @override
  String get exploreLands => 'Explorar tierras';

  @override
  String get premiumFarmlandUpper => 'TIERRA AGRÍCOLA PREMIUM';

  @override
  String get newProposal => 'Nueva propuesta';

  @override
  String get suspendedUpper => 'SUSPENDIDO';

  @override
  String get aiPortfolioAnalysisHint => 'Análisis de cartera IA';

  @override
  String get defineOnMap => 'Definir en el mapa';

  @override
  String get itemUpper => 'ARTÍCULO';

  @override
  String amountPerType(String amount, String type) {
    return '$amount / $type';
  }

  @override
  String get landDescriptionHint => 'Describa su tierra...';

  @override
  String get autoFromBoundary => 'Auto desde el límite';

  @override
  String get tryAgainUpper => 'REINTENTAR';

  @override
  String get landNameRequired => 'El nombre de la tierra es obligatorio';

  @override
  String get activeUpper => 'ACTIVO';

  @override
  String get hiringProposals => 'Propuestas de contratación';

  @override
  String get confirmReject => 'Confirmar rechazo';

  @override
  String get movePoint => 'Mover punto';

  @override
  String get priceExceedsLimit => 'El precio excede el límite';

  @override
  String get egSalaryHint => 'ej. 15,00';

  @override
  String hireWorkerUpper(String param) {
    return 'CONTRATAR A $param';
  }

  @override
  String get hiringProposalSent => 'Propuesta de contratación enviada';

  @override
  String get entireLand => 'Tierra entera';

  @override
  String get acceptedUpper => 'ACEPTADO';

  @override
  String get fundsReleasedAfterVerification =>
      'Fondos liberados después de la verificación';

  @override
  String get enterRejectionReason => 'Ingrese el motivo del rechazo';

  @override
  String get proofRequests => 'Solicitudes de prueba';

  @override
  String get enableVoiceInput => 'Activar entrada de voz';

  @override
  String get salaryAmountTNDUpper => 'MONTO DEL SALARIO (TND)';

  @override
  String get unableToRetrieveLandDetails =>
      'No se pudieron obtener los detalles de la tierra';

  @override
  String get hourlyUpper => 'POR HORA';

  @override
  String aiLandInvestmentHint(String param) {
    return 'Sugerencia de inversión de IA: $param';
  }

  @override
  String get askAiAnalyst => 'Preguntar al analista de IA';

  @override
  String get monthlyUpper => 'MENSUAL';

  @override
  String get activeContracts => 'Contratos activos';

  @override
  String get workerRespondedReviewCounterOffer =>
      'El trabajador respondió, revise la contraoferta';

  @override
  String get unlockUnlimitedSlotsInvestorPlus =>
      'Desbloquee espacios ilimitados con Investor+';

  @override
  String get escrowBalance => 'Saldo de depósito en garantía';

  @override
  String get pleaseEnterAName => 'Por favor, ingrese un nombre';

  @override
  String get raiseLivestock => 'Criar ganado';

  @override
  String get noLandAssignments => 'No hay asignaciones de tierra';

  @override
  String get aiVerifyUpper => 'VERIFICAR POR IA';

  @override
  String get requestExpired => 'Solicitud expirada';

  @override
  String get rejectUpper => 'RECHAZAR';

  @override
  String get landUpdatedSuccess => 'Tierra actualizada con éxito';

  @override
  String get realTimeTaskNotificationsSoon =>
      'Notificaciones de tareas en tiempo real pronto';

  @override
  String get approveUpper => 'APROBAR';

  @override
  String untilDateUpper(String param) {
    return 'HASTA $param';
  }

  @override
  String get overlapsExistingLand => 'Se superpone con tierra existente';

  @override
  String get itemRequests => 'Solicitudes de artículos';

  @override
  String get startDateUpper => 'FECHA DE INICIO';

  @override
  String get generalLandProof => 'Prueba general de la tierra';

  @override
  String get landNameTooShort => 'Nombre de la tierra demasiado corto';

  @override
  String get verifiedUpper => 'VERIFICADO';

  @override
  String minutesLeft(int count) {
    return '$count minutos restantes';
  }

  @override
  String get tapToDrawBoundaries => 'Toque para dibujar límites';

  @override
  String get directRoadAccess => 'Acceso directo por carretera';

  @override
  String invitationFrom(String param) {
    return 'Invitación de $param';
  }

  @override
  String get failedToLoadContracts => 'Error al cargar los contratos';

  @override
  String get verificationFailed => 'Error de verificación';

  @override
  String get perimeterNotSet => 'Perímetro no definido';

  @override
  String get requestApprovedItemPlaced =>
      'Solicitud aprobada, artículo colocado';

  @override
  String get inviteWorkersMarketplaceHint => 'Invitar trabajadores del mercado';

  @override
  String get landNameHint => 'ej. Granja Valle Soleado';

  @override
  String get publishListing => 'Publicar anuncio';

  @override
  String get hireApprovedWorkerNegotiationHint =>
      'Contratar trabajador aprobado para iniciar negociación';

  @override
  String get request => 'Solicitud';

  @override
  String get counterOfferUpper => 'CONTRAOFERTA';

  @override
  String get proposedUpper => 'PROPUESTO';

  @override
  String get verificationSuccessful => 'Verificación exitosa';

  @override
  String get rentLandToStartUpper => 'ALQUILAR TIERRA PARA EMPEZAR';

  @override
  String get expiredLabel => 'Expirado';

  @override
  String get salaryTypeUpper => 'TIPO DE SALARIO';

  @override
  String get pleaseEnterRejectionReason =>
      'Por favor, ingrese el motivo del rechazo';

  @override
  String get negotiatingUpper => 'NEGOCIANDO';

  @override
  String get rentNowUpper => 'ALQUILAR AHORA';

  @override
  String get noSpecialSkillsUpper => 'SIN HABILIDADES ESPECIALES';

  @override
  String get noLandAssignmentsHint => 'Aún no hay asignaciones de tierra';
}
