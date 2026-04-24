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
  String itemsSold(int count) {
    return '$count Artículos vendidos';
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
  String get upgradeRequired =>
      'Se requiere actualización para acceder a esta función.';

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
  String get appTitle => 'Farmy';

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
  String get cancel => 'Cancelar';

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
  String get viewPlans => 'VER PLANES';

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
  String get outOfStock => 'AGOTADO';

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
  String get addToBasket => 'Añadir a la Cesta';

  @override
  String qtySetTo(String title, int qty) {
    return '$title — cantidad ajustada a $qty';
  }

  @override
  String addedToBasket(String title) {
    return '$title añadido a la cesta';
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
  String get selectPaymentMethod => 'Seleccionar Método de Pago';

  @override
  String totalWithCycle(String price, String cycle) {
    return 'Total: $price \$ · $cycle';
  }

  @override
  String get payWithCredits => 'Pagar con Créditos Farmy';

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
  String get landBoundary => 'Límite de Tierra';

  @override
  String get landInformation => 'Información de la Tierra';

  @override
  String get noDescriptionAvailable => 'No hay descripción disponible';

  @override
  String get grid => 'Cuadrícula';

  @override
  String get assignmentRole => 'Rol de Asignación';

  @override
  String get salaryLabel => 'Salario';

  @override
  String salaryValue(String amount) {
    return '$amount \$ / mes';
  }

  @override
  String get assignmentStatus => 'Estado de Asignación';

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
}
