// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get aboutLabel => 'À propos';

  @override
  String get aboutMe => 'À propos de moi';

  @override
  String get aboutUs => 'À propos de nous - Équipe Farmy';

  @override
  String get aboutYou => 'À propos de vous';

  @override
  String get aboutYouHint => 'Parlez de votre expérience aux agriculteurs...';

  @override
  String get accept => 'Accepter';

  @override
  String acceptOfferConfirmation(String amount, String type) {
    return 'Vous êtes sur le point d\'accepter l\'offre de $amount $type. Cela établira un contrat légal.';
  }

  @override
  String get acceptThisOfferQuestion => 'Accepter cette offre ?';

  @override
  String get acceptedUpper => 'ACCEPTÉ';

  @override
  String get accessFarmView => 'Accéder à la vue de la ferme en 2.5D';

  @override
  String get accountBanned => 'Compte banni';

  @override
  String get accountInformation => 'Informations sur le compte';

  @override
  String get active => 'ACTIF';

  @override
  String get activeContracts => 'Contrats actifs';

  @override
  String get activeLabel => 'Actif';

  @override
  String get activeLabelUpper => 'ACTIF';

  @override
  String get activeLands => 'Terres actives';

  @override
  String activeOnCycle(String cycle) {
    return 'Actif sur $cycle';
  }

  @override
  String get activeStatusUpper => 'STATUT ACTIF';

  @override
  String get activeTasks => 'Tâches actives';

  @override
  String activeTasksCount(int count) {
    return '$count tâches actives';
  }

  @override
  String get activeTasksLabel => 'Tâches actives';

  @override
  String get activeUpper => 'ACTIF';

  @override
  String get addAMessageHint => 'Ajouter un message...';

  @override
  String get addCreditsTitle => 'Ajouter des crédits';

  @override
  String get addExtraSecurity =>
      'Ajouter une couche de sécurité supplémentaire';

  @override
  String get addMore => 'Ajouter plus';

  @override
  String get addNewCard => 'Ajouter une nouvelle carte';

  @override
  String get addNoteHint => 'Ajouter une note (optionnel)...';

  @override
  String get addPaymentMethod => 'Ajouter un mode de paiement';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get addProductFirst =>
      'Ajoutez votre premier produit pour le voir ici !';

  @override
  String get addToBasket => 'Ajouter au panier';

  @override
  String get addToLand => 'Ajouter à la terre';

  @override
  String get addWorker => 'Ajouter un Travailleur';

  @override
  String get addWorkersMarketplaceHint =>
      'Appuyez sur le bouton + pour ajouter des travailleurs depuis le marché';

  @override
  String addedToBasket(String title) {
    return '$title ajouté au panier';
  }

  @override
  String get addressLabel => 'Adresse';

  @override
  String get adjustSearchFilters =>
      'Essayez d\'ajuster votre recherche ou vos filtres';

  @override
  String advanceNotifyCustomer(String status) {
    return 'Ceci fera passer la livraison à \"$status\" et en informera le client.';
  }

  @override
  String get advancedAnalytics => 'Analyses avancées';

  @override
  String get agreeToTermsAndPrivacy =>
      'J\'accepte les conditions et la politique de confidentialité';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get aiAssistantDescription =>
      'Dates de semis, santé des cultures, engrais et conseils pratiques avec détection automatique de la langue.';

  @override
  String get aiAutoAssignTasks => '🤖 Auto-attribution des tâches par IA';

  @override
  String aiLandInvestmentHint(String param) {
    return 'Conseil d\'investissement IA : $param';
  }

  @override
  String aiNotes(String notes) {
    return 'Notes IA : $notes';
  }

  @override
  String get aiPortfolioAnalysisHint => 'Analyse de portefeuille IA';

  @override
  String get aiProofRequests => 'Demandes de preuves IA';

  @override
  String get aiVerificationComingSoon => 'Vérification IA bientôt disponible';

  @override
  String get aiVerificationDescription =>
      'La vérification automatisée de l\'identité et des compétences accélérera votre approbation.';

  @override
  String get aiVerifyUpper => 'VÉRIFIER PAR IA';

  @override
  String get aiVerifyingProof => 'L\'IA vérifie votre preuve...';

  @override
  String get all => 'Tous';

  @override
  String get allLands => 'Tous les Terrains';

  @override
  String get allNotificationsMarkedRead =>
      'Toutes les notifications sont marquées comme lues';

  @override
  String get allocatingSpatialResources =>
      'Allocation des ressources spatiales...';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get alreadyPlaced => 'Déjà placé';

  @override
  String get alreadyPlacedSubtitle => 'Cet article est déjà sur la carte.';

  @override
  String get alreadyRentedUpper => 'DÉJÀ LOUÉ';

  @override
  String get alwaysFree => 'Toujours gratuit';

  @override
  String get amount => 'Montant';

  @override
  String amountPerHour(String amount) {
    return '$amount\$/h';
  }

  @override
  String amountPerMonth(String amount) {
    return '$amount\$/mois';
  }

  @override
  String amountPerType(String amount, String type) {
    return '$amount / $type';
  }

  @override
  String amountPrefix(String amount) {
    return '$amount \$';
  }

  @override
  String amountTND(String amount) {
    return '$amount TND';
  }

  @override
  String get analytics => 'Analyses';

  @override
  String get analyzeInventory => 'Analyser l\'inventaire';

  @override
  String get analyzeInventoryPrompt =>
      'Analysez mon inventaire actuel de produits. S\'agit-il de bons produits à conserver ou devrais-je me concentrer sur autre chose en fonction du marché ?';

  @override
  String get analyzePortfolio => 'Analyser le portefeuille';

  @override
  String get analyzeRevenueTooltip => 'Analyser les revenus';

  @override
  String get animal => 'Animal';

  @override
  String get animalCare => 'Soins aux animaux';

  @override
  String get appName => 'Farmy';

  @override
  String get appearance => 'Apparence';

  @override
  String get approveUpper => 'APPROUVER';

  @override
  String get approvedUpper => 'APPROUVÉ';

  @override
  String get area => 'Superficie';

  @override
  String get arrivingSoon => 'Arrive bientôt';

  @override
  String get askAiAnalyst => 'Demander à l\'analyste IA';

  @override
  String get askAnythingAboutFarm => 'Demandez n\'importe quoi sur votre ferme';

  @override
  String get askFarmingQuestion => 'Posez votre question sur l\'agriculture...';

  @override
  String get askGuruHint => 'Demandez à votre gourou...';

  @override
  String get assetsLabel => 'Actifs';

  @override
  String get assign => 'Assigner';

  @override
  String get assignButton => 'Assigner';

  @override
  String get assignTaskTitle => 'Assigner une tâche';

  @override
  String get assignToLand => 'Assigner au terrain';

  @override
  String get assigned => 'Assigné';

  @override
  String get assignedLands => 'Terres assignées';

  @override
  String get assignedLandsUnavailable => 'Terres assignées indisponibles';

  @override
  String assignedTo(String name) {
    return 'Assigné à $name';
  }

  @override
  String get assignmentRole => 'Rôle d\'affectation';

  @override
  String get assignmentStatus => 'Statut d\'affectation';

  @override
  String get autoFromBoundary => 'Auto à partir des limites';

  @override
  String get available => 'disponible';

  @override
  String availableCount(int count, String unit) {
    return '$count $unit disponible(s)';
  }

  @override
  String get availableForAssignment =>
      'Vous êtes disponible pour des assignations.';

  @override
  String get availableForAssignments =>
      'Vous êtes disponible pour de nouvelles affectations.';

  @override
  String get availableInstantPayment =>
      'Disponible pour un paiement instantané';

  @override
  String get availableUpper => 'DISPONIBLE';

  @override
  String get awaitingPayment => 'En attente de paiement';

  @override
  String get backButton => 'Retour';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get backToMarketplace => 'Retour au marché';

  @override
  String get backendDisconnected =>
      'Backend déconnecté. Reconnexion automatique...';

  @override
  String balanceAmount(String amount) {
    return 'Solde: $amount TND';
  }

  @override
  String balanceStatusInsufficient(String amount) {
    return 'Solde : $amount — Insuffisant';
  }

  @override
  String balanceStatusSuccess(String amount) {
    return 'Solde : $amount ✓';
  }

  @override
  String balanceValue(String amount) {
    return 'Solde : $amount \$';
  }

  @override
  String balanceWithCredits(String balance) {
    return 'Solde : $balance Crédits';
  }

  @override
  String get bannedDescription =>
      'Votre compte a été suspendu en raison de violations spécifiques. Veuillez contacter le support si vous pensez qu\'il s\'agit d\'une erreur.';

  @override
  String get becomeAWorker => 'Devenir travailleur';

  @override
  String get becomeFarmer => 'Devenir agriculteur';

  @override
  String get becomeInvestor => 'Devenir investisseur';

  @override
  String get becomeWorker => 'Devenir travailleur';

  @override
  String get boundaries => 'Limites';

  @override
  String get boundaryConflictAlert => 'Alerte de conflit de limites';

  @override
  String get browseMarketplaceDescription =>
      'Parcourez le marché et ajoutez\ndes produits frais !';

  @override
  String get browseProducts => 'Parcourir les produits';

  @override
  String get budgetRangeHint => 'ex: 10 000 \$ - 50 000 \$';

  @override
  String get businessFarmName => 'Nom de l\'entreprise/ferme';

  @override
  String get buy => 'Acheter';

  @override
  String get buyMore => 'Acheter plus';

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String buyProductConfirmation(String title, double price) {
    return 'Voulez-vous acheter $title pour $price crédits ?';
  }

  @override
  String get cached => 'Mis en cache';

  @override
  String get cancel => 'Annuler';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get cancelDeliveryAction => 'Annuler la livraison';

  @override
  String get cancelDeliveryQuestion => 'Annuler la livraison ?';

  @override
  String get cancelNotifyCustomer =>
      'Ceci annulera la livraison et en informera le client.';

  @override
  String get cancelUpper => 'ANNULER';

  @override
  String get cancellationReasonHint => 'Raison de l\'annulation...';

  @override
  String get cancellationReasonLabel => 'Raison d\'annulation';

  @override
  String get cancelledOrFailedToAddCard =>
      'Annulé ou échec de l\'ajout de la carte.';

  @override
  String get cannotPublishBoundaryConflicts =>
      'Impossible de publier : conflits de limites détectés';

  @override
  String get cannotPublishInvalidGeometry =>
      'Impossible de publier avec une géométrie invalide';

  @override
  String get captureSubmit => 'Capturer et Soumettre';

  @override
  String get cardAddedSuccess => 'Carte ajoutée avec succès';

  @override
  String get cardAddedSuccessfully => 'Carte ajoutée avec succès';

  @override
  String get changeAction => 'Modifier';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get changePasswordTitle => 'Modifier le mot de passe';

  @override
  String get changeProfilePicture => 'Changer la photo de profil';

  @override
  String get chatTitle => 'Titre de la discussion';

  @override
  String get checkBackLaterFreshProducts =>
      'Revenez plus tard pour des produits frais';

  @override
  String get checkBackLaterOpportunities =>
      'Revenez plus tard pour de nouvelles opportunités';

  @override
  String get checkout => 'Paiement';

  @override
  String checkoutResultFeedback(int successCount, int failCount) {
    return '$successCount achetés, $failCount échoués. Les articles échoués restent dans le panier.';
  }

  @override
  String checkoutWithItems(int count) {
    return 'Paiement ($count articles)';
  }

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get chooseYourPlan => 'Choisissez votre forfait';

  @override
  String get cityLabel => 'Ville';

  @override
  String get clear => 'Effacer';

  @override
  String get clearAll => 'Tout vider';

  @override
  String get clearBasketDescription =>
      'Cela supprimera tous les articles de votre panier.';

  @override
  String get clearBasketTitle => 'Vider le panier ?';

  @override
  String get closeAssistant => 'Fermer l\'assistant';

  @override
  String get closeButton => 'Fermer';

  @override
  String get closeTip => 'Fermer';

  @override
  String get codeCopied => 'Code copié dans le presse-papiers';

  @override
  String get comingSoon => 'À venir';

  @override
  String get comingSoonDesc =>
      'Cette fonctionnalité est en cours de développement. Vous pourrez bientôt placer des articles sur votre terre !';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get completed => 'Terminé';

  @override
  String completedOn(String date) {
    return 'Terminé le $date';
  }

  @override
  String get completenessLabel => 'Complétude';

  @override
  String get confirm => 'Confirmer';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get confirmDowngrade => 'Confirmer la rétrogradation';

  @override
  String get confirmEnablementStep => 'Étape 2 : Confirmer l\'activation';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmPurchase => 'Confirmer l\'achat';

  @override
  String get confirmReject => 'Confirmer le rejet';

  @override
  String get confirmUpdate => 'Confirmer';

  @override
  String get conflictDetected => 'Conflit détecté';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get consultProductionGuru => 'Consulter le gourou de la production';

  @override
  String get consultedLiveData => 'Données en direct consultées :';

  @override
  String get contactSupport => 'Veuillez contacter le support.';

  @override
  String get continueLabelUpper => 'CONTINUER';

  @override
  String get continueText => 'Continuer';

  @override
  String get continueWithFree => 'Continuer avec le gratuit';

  @override
  String get contract => 'Contrat';

  @override
  String get contractActivated => 'Contrat activé avec succès !';

  @override
  String get contractApproved =>
      'Contrat approuvé ! En attente du paiement de l\'investisseur.';

  @override
  String get contractDeclined => 'Offre de contrat déclinée.';

  @override
  String get contractExpiredBanner => 'Contrat expiré';

  @override
  String contractForWorker(String name) {
    return 'Contrat pour $name';
  }

  @override
  String contractIsStatus(String status) {
    return 'Ce contrat est $status';
  }

  @override
  String get contractTerminatedBanner => 'Contrat résilié';

  @override
  String get contractsUnavailable => 'Contrats indisponibles';

  @override
  String get conversations => 'Conversations';

  @override
  String get copy => 'Copier';

  @override
  String get copyToClipboardTooltip => 'Copier dans le presse-papiers';

  @override
  String get correctErrorsInForm =>
      'Veuillez corriger les erreurs dans le formulaire';

  @override
  String get couldNotOpenHashScan => 'Impossible d\'ouvrir HashScan';

  @override
  String get couldNotSendMessage =>
      'Impossible d\'envoyer votre message. Veuillez réessayer.';

  @override
  String get counter => 'Contre-offre';

  @override
  String get counterOffer => 'Contre-offre';

  @override
  String get counterOfferSent => 'Contre-offre envoyée avec succès !';

  @override
  String get counterOfferUpper => 'CONTRE-OFFRE';

  @override
  String get countryLabel => 'Pays';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createChatDescription =>
      'Créez une discussion pour demander des conseils agricoles pratiques.';

  @override
  String get createNewPassword => 'Créer un nouveau mot de passe';

  @override
  String get createNewTask => 'Créer une nouvelle tâche';

  @override
  String get createTask => 'Créer la tâche';

  @override
  String get createWorkerProfile => 'Créer un profil de travailleur';

  @override
  String get createdLabel => 'Créé';

  @override
  String get credits => 'Crédits';

  @override
  String creditsAdded(String amount) {
    return 'Ajout réussi de \$$amount !';
  }

  @override
  String creditsCount(String count) {
    return 'Crédits : $count';
  }

  @override
  String get creditsLabel => 'Crédits';

  @override
  String get cropMonitoring => 'Surveillance des cultures';

  @override
  String get currentBalance => 'Solde actuel';

  @override
  String get currentLand => 'Terre actuelle';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get currentPlan => 'Plan Actuel';

  @override
  String currentPlanLabel(String name) {
    return 'Actuel : $name';
  }

  @override
  String get customAmount => 'Montant personnalisé';

  @override
  String get customAmountLabel => 'Montant personnalisé';

  @override
  String get customerAccount => 'Compte client';

  @override
  String get customerLabel => 'Client';

  @override
  String get dailyInspiration => 'Inspiration quotidienne';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String dateTimeAt(String date, String time) {
    return '$date à $time';
  }

  @override
  String daysAgo(String count) {
    return 'il y a ${count}j';
  }

  @override
  String daysLeft(int count) {
    return '$count jours restants';
  }

  @override
  String get decline => 'Refuser';

  @override
  String declineNegotiationConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir décliner toute négociation ultérieure avec $name ?';
  }

  @override
  String get declineNegotiationQuestion => 'Décliner la négociation ?';

  @override
  String declineOfferConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir décliner l\'offre de $name ?';
  }

  @override
  String get declineThisOfferQuestion => 'Décliner cette offre ?';

  @override
  String get declinedUpper => 'REFUSÉ';

  @override
  String get defaultMethod => 'Par défaut';

  @override
  String get defineOnMap => 'Définir sur la carte';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteChat => 'Supprimer la discussion';

  @override
  String deleteChatConfirmation(String title) {
    return 'Supprimer définitivement \"$title\" ?';
  }

  @override
  String get deleteLand => 'Supprimer la terre';

  @override
  String get deleteLandActionWarning =>
      'Cette action ne peut pas être annulée. Toutes les données associées seront définitivement supprimées.';

  @override
  String deleteLandConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get deleteLandTitle => 'Supprimer la terre ?';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String deleteProductConfirmation(String title) {
    return 'Êtes-vous sûr de vouloir supprimer $title ?';
  }

  @override
  String get deliveredLabel => 'Livré';

  @override
  String get deliveriesTitle => 'Livraisons';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get deliveryCancelled => 'Livraison annulée';

  @override
  String get deliveryInfo => 'Infos de livraison';

  @override
  String get deliveryNotFound => 'Livraison non trouvée';

  @override
  String get deliveryTimeline => 'Chronologie de livraison';

  @override
  String get deliveryTrackingEmptyHint =>
      'Le suivi de livraison apparaîtra\nune fois votre commande traitée.';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (Optionnel)';

  @override
  String get descriptionRequired => 'Description requise';

  @override
  String get descriptionTooShort => 'Description trop courte';

  @override
  String get directLinksLabel => 'Liens directs';

  @override
  String get directMessagingDescription =>
      'Description de la messagerie directe';

  @override
  String get directRoadAccess => 'Accès routier direct';

  @override
  String get disable2FA => 'Désactiver la 2FA';

  @override
  String get disable2fa => 'Désactiver la 2FA';

  @override
  String get disableVoiceInput => 'Désactiver l\'entrée vocale';

  @override
  String get discard => 'Abandonner';

  @override
  String get discoverableMarketplace => 'Découvrable sur le marché';

  @override
  String get discoverableSubtitle =>
      'Permettre aux autres de trouver et de voir votre profil';

  @override
  String get dismiss => 'IGNORER';

  @override
  String get disputesLabel => 'Litiges';

  @override
  String get done => 'Terminé';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get downgradeToFree => 'Rétrograder vers le gratuit';

  @override
  String downgradeWarning(String name) {
    return 'Êtes-vous sûr de vouloir rétrograder vers $name ? Vous perdrez vos fonctionnalités premium et les avantages actifs associés à votre plan actuel.';
  }

  @override
  String get draw => 'Dessiner';

  @override
  String get drawInstructions =>
      'Appuyez sur la carte pour dessiner les limites';

  @override
  String get driverNearby => 'Livreur à proximité !';

  @override
  String get duration => 'Durée';

  @override
  String get earnings => 'Gains';

  @override
  String get edit => 'Modifier';

  @override
  String get editAndResend => 'Modifier et renvoyer';

  @override
  String get editLandDetails => 'Modifier les détails de la terre';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editYourMessageHint => 'Modifiez votre message...';

  @override
  String get editingYourMessage => 'Modification de votre message';

  @override
  String get egSalaryHint => 'ex: 15,00';

  @override
  String get email => 'E-mail';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get enable2FA => 'Activer la 2FA';

  @override
  String get enable2fa => 'Activer la 2FA';

  @override
  String get enableGameEdgePanel => 'Activer le panneau latéral du jeu';

  @override
  String get enableVoiceInput => 'Activer la saisie vocale';

  @override
  String get enableVoiceOutput => 'Activer la sortie vocale';

  @override
  String get enabled => 'ACTIVÉ';

  @override
  String get endDateUpper => 'DATE DE FIN';

  @override
  String endsDate(String param) {
    return 'Se termine le : $param';
  }

  @override
  String get english => 'Anglais';

  @override
  String get enter2faCode =>
      'Entrez le code à 6 chiffres de votre application d\'authentification pour continuer.';

  @override
  String get enter6DigitCodeConfirm =>
      'Saisissez le code à 6 chiffres de votre application pour confirmer :';

  @override
  String get enter6DigitCodeDisable =>
      'Saisissez le code à 6 chiffres de votre application d\'authentification pour désactiver l\'authentification à deux facteurs.';

  @override
  String get enterAmount => 'SAISIR UN MONTANT';

  @override
  String get enterCodeManually => 'Ou entrez ce code manuellement :';

  @override
  String get enterCurrentPasswordError =>
      'Veuillez saisir votre mot de passe actuel';

  @override
  String get enterPreferencesHint =>
      'Entrez vos préférences ou demandez une analyse...';

  @override
  String get enterRejectionReason => 'Saisir le motif du rejet';

  @override
  String get enterValidRate => 'Entrez un taux valide';

  @override
  String get entireLand => 'Terre entière';

  @override
  String get error => 'Erreur';

  @override
  String get errorFetchingTasks =>
      'Erreur lors de la récupération de vos tâches';

  @override
  String get errorFetchingYourTasks =>
      'Erreur lors de la récupération de vos tâches';

  @override
  String errorWithPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get escrowBalance => 'Solde du séquestre';

  @override
  String get estimatedDelivery => 'Livraison estimée';

  @override
  String etaHours(String hours, String mins) {
    return '~${hours}h ${mins}min';
  }

  @override
  String etaLabel(String time) {
    return 'Heure d\'arrivée prévue : $time';
  }

  @override
  String etaMinutes(String mins) {
    return '~$mins min';
  }

  @override
  String get expectedBudgetRange => 'Plage budgétaire prévue';

  @override
  String get expiredLabel => 'Expiré';

  @override
  String get expiredUpper => 'EXPIRÉ';

  @override
  String expiresLabel(String expiry) {
    return 'Expire le $expiry';
  }

  @override
  String get expiringSoon => 'Expire bientôt';

  @override
  String get explore => 'Explorer';

  @override
  String get exploreLands => 'Explorer les terres';

  @override
  String get externalProperty => 'PROPRIÉTÉ EXTERNE';

  @override
  String get failedAddCard => 'Échec de l\'ajout de la carte';

  @override
  String get failedAddCredits => 'Échec de l\'ajout de crédits';

  @override
  String get failedCompleteTask => 'Échec de la finalisation de la tâche';

  @override
  String get failedInitiate2FA =>
      'Échec de l\'initialisation de la configuration 2FA';

  @override
  String get failedLoadPlans => 'Échec du chargement des forfaits';

  @override
  String get failedLoadTasks => 'Échec du chargement des tâches';

  @override
  String get failedReachAnalyst =>
      'Échec de la connexion à l\'analyste stratégique IA.';

  @override
  String get failedToAccept => 'Échec de l\'acceptation de l\'offre.';

  @override
  String get failedToAssignWorker => 'Échec de l\'assignation du travailleur';

  @override
  String get failedToCreatePayment =>
      'Échec de la création de l\'intention de paiement.';

  @override
  String get failedToCreateProfile => 'Échec de la création du profil';

  @override
  String get failedToDecline => 'Échec du refus de l\'offre.';

  @override
  String get failedToDeleteNotification =>
      'Échec de la suppression de la notification';

  @override
  String get failedToDeleteProduct => 'Échec de la suppression du produit';

  @override
  String get failedToEditMessage => 'Échec de la mise à jour du message';

  @override
  String get failedToListProduct => 'Échec de la mise en liste du produit.';

  @override
  String get failedToLoadContracts => 'Échec du chargement des contrats';

  @override
  String get failedToLoadData =>
      'Impossible de charger les données. Veuillez réessayer.';

  @override
  String get failedToLoadFarm => 'Impossible de charger la ferme';

  @override
  String get failedToLoadInventory =>
      'Impossible de charger l\'inventaire. Veuillez réessayer.';

  @override
  String get failedToLoadProofs => 'Échec du chargement des preuves';

  @override
  String get failedToLoadRecords => 'Échec du chargement des enregistrements.';

  @override
  String get failedToLoadRequests => 'Échec du chargement des demandes';

  @override
  String get failedToLoadSubscriptions => 'Échec du chargement des abonnements';

  @override
  String get failedToLoadWorkerProfile =>
      'Échec du chargement du profil de travailleur';

  @override
  String get failedToRejectRequest => 'Échec du rejet de la demande';

  @override
  String get failedToRemoveWorker => 'Échec de la suppression du travailleur';

  @override
  String get failedToSendCode => 'Échec de l\'envoi du code. Réessayez.';

  @override
  String get failedToSendCounterOffer =>
      'Échec de l\'envoi de la contre-offre.';

  @override
  String get failedToSendInvitation => 'Échec de l\'envoi de l\'invitation';

  @override
  String get failedToSyncBackend =>
      'Échec de la synchronisation avec le serveur';

  @override
  String get failedToUpdateProduct => 'Échec de la mise à jour du produit.';

  @override
  String get failedToWithdrawMessage => 'Échec du retrait du message';

  @override
  String get failedUpdateStatus => 'Échec de la mise à jour du statut';

  @override
  String get farmAnalysisDefault => 'Analyse de la ferme';

  @override
  String get farmboxDescription =>
      'Recevez chaque semaine des légumes frais cultivés localement à votre porte !';

  @override
  String get farmboxSubscription => 'Abonnement FarmBox';

  @override
  String get farmer => 'Agriculteur';

  @override
  String get farmerDetailsTitle => 'Détails de l\'agriculteur';

  @override
  String get farmerInfoSyncedFromAssignment =>
      'Informations synchronisées depuis l\'affectation';

  @override
  String get farmerInvitations => 'Invitations d\'agriculteurs';

  @override
  String get farmerPro => 'Farmer Pro';

  @override
  String get farmerProfileUnavailable =>
      'Le profil de l\'agriculteur est indisponible pour le moment.';

  @override
  String farmerWithColon(String param) {
    return 'Agriculteur : $param';
  }

  @override
  String get farmingActivities => 'Activités agricoles';

  @override
  String get farmingActivity => 'Activité agricole';

  @override
  String farmyMemberSince(String date) {
    return 'Membre de la communauté Farmy depuis $date';
  }

  @override
  String get farmyPremium => 'Farmy Premium';

  @override
  String get farmyStore => 'BOUTIQUE FARMY';

  @override
  String get farmyUser => 'Utilisateur Farmy';

  @override
  String featureOptimizedDescription(String feature) {
    return 'Le module \"$feature\" est actuellement en cours d\'optimisation pour la gestion agricole personnelle.';
  }

  @override
  String get featureUnderDevelopment =>
      'Cette fonctionnalité est actuellement en cours de développement.';

  @override
  String get feed => 'Nourrir';

  @override
  String get fetchingBlockchainRecords =>
      'Récupération des enregistrements blockchain...';

  @override
  String get fetchingSpatialData =>
      'Récupération des données spatiales précises...';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterCancelled => 'Annulé';

  @override
  String get filterConfirmed => 'Confirmé';

  @override
  String get filterDelivered => 'Livré';

  @override
  String get filterInTransit => 'En transit';

  @override
  String get filterNew => 'Nouveau';

  @override
  String get filterPreparing => 'En préparation';

  @override
  String get finish => 'Terminer';

  @override
  String get flipIdHint => 'Retournez votre ID et scannez le verso';

  @override
  String get flipIdInstruction =>
      'Super ! Maintenant, retournez votre pièce d\'identité';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre adresse e-mail et nous vous enverrons un code à 6 chiffres pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get free => 'GRATUIT';

  @override
  String get freeForever => 'Pas d\'expiration · Gratuit pour toujours';

  @override
  String get freeLabel => 'Gratuit';

  @override
  String get freeTier => 'Offre gratuite';

  @override
  String get french => 'Français';

  @override
  String get freshProductsFarmers => 'Produits frais des agriculteurs locaux';

  @override
  String fromLabel(String name) {
    return 'De : $name';
  }

  @override
  String get fullName => 'Nom complet';

  @override
  String get fundsReleasedAfterVerification =>
      'Fonds libérés après vérification';

  @override
  String get gameFeatures => 'Fonctionnalités du jeu';

  @override
  String get general => 'Général';

  @override
  String get generalFarmingActivity => 'Activité agricole générale';

  @override
  String get generalLandProof => 'Preuve générale de la terre';

  @override
  String get geometryVerified => 'Géométrie vérifiée';

  @override
  String getPlan(String planName) {
    return 'Obtenir $planName';
  }

  @override
  String get getStarted => 'Commencer';

  @override
  String get goBackButton => 'Retour';

  @override
  String get goToDashboardUpper => 'ALLER AU TABLEAU DE BORD';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get gotIt => 'COMPRIS';

  @override
  String get gotItButton => 'Compris';

  @override
  String get gpsVerifiedWorkProof => '📍 Preuve de travail vérifiée par GPS';

  @override
  String get grid => 'Grille';

  @override
  String gridPlots(int w, int h) {
    return '${w}x$h parcelles';
  }

  @override
  String get harvest => 'Récolter';

  @override
  String get harvestChroniclesTitle => 'Chroniques de récolte';

  @override
  String get harvesting => 'Récolte';

  @override
  String get headlineHint => 'Une courte description de ce que vous faites';

  @override
  String get headlineLabel => 'Slogan';

  @override
  String get hederaConsensusServiceUpper => 'SERVICE DE CONSENSUS HEDERA';

  @override
  String get hederaRegistry => 'Registre Hedera';

  @override
  String get hederaRegistryUpper => 'REGISTRE HEDERA';

  @override
  String get heightAuto => 'Hauteur auto';

  @override
  String get hiddenUpper => 'MASQUÉ';

  @override
  String get hireActivateWorkersHint => 'Embaucher et activer des travailleurs';

  @override
  String get hireApprovedWorkerNegotiationHint =>
      'Embaucher un travailleur approuvé pour commencer la négociation';

  @override
  String get hireUpper => 'EMBAUCHER';

  @override
  String hireWorkerUpper(String param) {
    return 'EMBAUCHER $param';
  }

  @override
  String get hireWorkersUpper => 'EMBAUCHER DES TRAVAILLEURS';

  @override
  String get hiringPending => 'Embauche en attente';

  @override
  String get hiringProposalSent => 'Proposition d\'embauche envoyée';

  @override
  String get hiringProposals => 'Propositions d\'embauche';

  @override
  String get home => 'Accueil';

  @override
  String get hourly => 'Horaire';

  @override
  String get hourlyLabel => 'par heure';

  @override
  String get hourlyRateHint => 'ex. 15,00';

  @override
  String get hourlyRateTnd => 'Taux horaire (TND)';

  @override
  String get hourlyUpper => 'HORAIRE';

  @override
  String hoursAgo(String hours) {
    return 'il y a ${hours}h';
  }

  @override
  String hoursCount(int count) {
    return '$count h';
  }

  @override
  String hoursLeft(int count) {
    return '$count heures restantes';
  }

  @override
  String idLabel(String param) {
    return 'ID : $param';
  }

  @override
  String get identityTab => 'Identité';

  @override
  String get imageProofRequiredToApprove =>
      'Preuve en image requise pour approuver';

  @override
  String get imageUnavailable => 'Image non disponible';

  @override
  String get immutableOnChainRecords =>
      'Enregistrements immuables sur la chaîne';

  @override
  String get inBasket => 'Dans le panier';

  @override
  String get inProgress => 'En cours';

  @override
  String get inactive => 'Inactif';

  @override
  String get inactiveLabel => 'Inactif';

  @override
  String includingTva(String tax) {
    return '(y compris 19% TVA : $tax TND)';
  }

  @override
  String get install => 'Installer';

  @override
  String insufficientCredits(String amount) {
    return 'Crédits insuffisants: $amount disponible';
  }

  @override
  String get insufficientFunds => 'Fonds insuffisants';

  @override
  String insufficientFundsDescription(String balance, String total) {
    return 'Votre solde est de $balance Crédits, mais le total est de $total TND.\n\nVeuillez recharger votre portefeuille.';
  }

  @override
  String get invalidGeometry => 'Géométrie invalide';

  @override
  String get invalidGeometryAlert => 'Alerte de géométrie invalide';

  @override
  String get invalidGeometryHint => 'Géométrie invalide détectée';

  @override
  String get invalidNumericAmount => 'Montant numérique invalide';

  @override
  String get invalidPaymentData =>
      'Données de paiement invalides reçues du serveur. Veuillez réessayer.';

  @override
  String get invalidPhoneFormat => 'Format de téléphone invalide';

  @override
  String get investSustainableFarming => 'Investir dans l\'agriculture durable';

  @override
  String get investmentAgentWelcomeDesc =>
      'Dites-moi votre budget et votre préférence en matière de risques, ou posez des questions sur le marché actuel et les tendances météorologiques.';

  @override
  String get investmentRevenue => 'Revenus d\'investissement';

  @override
  String get investmentStrategyChroniclesTitle =>
      'Chroniques de stratégie d\'investissement';

  @override
  String get investments => 'Investissements';

  @override
  String get investor => 'Investisseur';

  @override
  String investorAcceptOfferConfirmation(
    String name,
    String amount,
    String type,
  ) {
    return 'Vous êtes sur le point d\'accepter la contre-offre de $name de $amount $type. Une fois acceptée, vous devrez payer le premier mois de salaire pour activer le contrat.';
  }

  @override
  String get investorDetailsTitle => 'Détails de l\'investisseur';

  @override
  String get investorPlus => 'Investisseur Plus';

  @override
  String get invitationAcceptedSuccess => 'Invitation acceptée avec succès.';

  @override
  String get invitationApproved => 'Invitation Approuvée';

  @override
  String get invitationDecisions => 'Décisions d\'invitation';

  @override
  String get invitationDeclined => 'Invitation Refusée';

  @override
  String get invitationDeclinedSuccess => 'Invitation déclinée avec succès.';

  @override
  String get invitationExpired => 'Invitation Expirée';

  @override
  String invitationFrom(String param) {
    return 'Invitation de $param';
  }

  @override
  String get invitationPending => 'Invitation en Attente';

  @override
  String invitationSentTo(String worker) {
    return 'Invitation envoyée à $worker';
  }

  @override
  String get invitationUpdates => 'Mises à jour des invitations';

  @override
  String get invitationsSyncIssue =>
      'Problème de synchronisation des invitations';

  @override
  String get invitationsUnavailable => 'Invitations indisponibles';

  @override
  String get inviteExistingWorker => 'Inviter un Travailleur Existant';

  @override
  String get inviteToLand => 'Inviter sur le terrain';

  @override
  String get inviteWorker => 'Inviter un travailleur';

  @override
  String inviteWorkerMessage(String worker, String landName) {
    return 'Inviter $worker à $landName';
  }

  @override
  String get inviteWorkersMarketplaceHint =>
      'Inviter des travailleurs du marketplace';

  @override
  String get iotSensorDashboard => '🌡️ Tableau de bord des capteurs IoT';

  @override
  String get irrigated => 'Irrigué';

  @override
  String get itemActions => 'Actions sur l\'article';

  @override
  String itemIdUpper(String param) {
    return 'ID DE L\'ARTICLE';
  }

  @override
  String get itemPlacedSuccess => 'Article placé avec succès !';

  @override
  String get itemRequests => 'Demandes d\'articles';

  @override
  String get itemUpper => 'ARTICLE';

  @override
  String get itemVerification => '[itemVerification]';

  @override
  String itemsCount(int count) {
    return '$count article(s)';
  }

  @override
  String itemsPurchasedSuccess(int count) {
    return '$count article(s) acheté(s) avec succès.';
  }

  @override
  String get itemsSold => 'Articles vendus';

  @override
  String get joinTheWorkforce => 'Rejoindre la main-d\'œuvre';

  @override
  String get joinWorkforceDescription =>
      'Créez votre profil professionnel et\ncommencez à gagner de l\'argent dans les fermes voisines dès aujourd\'hui.';

  @override
  String get justNow => 'À l\'instant';

  @override
  String kycSuccess(String role) {
    return 'Succès ! Vous êtes maintenant un $role !';
  }

  @override
  String get laborMarketLabel => 'MARCHÉ DU TRAVAIL';

  @override
  String get land => 'Terre';

  @override
  String get landActive => 'Actif';

  @override
  String get landAssignmentsEmptyHint => 'Vous verrez vos terres assignées ici';

  @override
  String get landBoundary => 'Limite du terrain';

  @override
  String get landDataSyncSuccess =>
      '✨ Données foncières synchronisées avec succès !';

  @override
  String get landDeletedSuccess => 'Terre supprimée avec succès';

  @override
  String get landDescriptionHint => 'Décrivez votre terre...';

  @override
  String get landDetails => 'Détails du terrain';

  @override
  String get landInactive => 'Inactif';

  @override
  String get landInformation => 'Informations sur le terrain';

  @override
  String landLimitReachedDescription(String planName) {
    return 'Vous avez utilisé tous les emplacements de terre de votre forfait $planName. Passez à Farmer Pro pour débloquer des terres illimitées !';
  }

  @override
  String get landLimitReachedTitle => 'Limite de terres atteinte';

  @override
  String get landName => 'Nom de la terre';

  @override
  String get landNameHint => 'ex : Ferme de la Vallée Ensoleillée';

  @override
  String get landNameRequired => 'Le nom de la terre est requis';

  @override
  String get landNameTooShort => 'Nom de la terre trop court';

  @override
  String landPlotNumber(String param) {
    return 'N° de parcelle : $param';
  }

  @override
  String get landSlotsUsed => 'Emplacements de terre utilisés';

  @override
  String get landUpdatedSuccess => 'Terre mise à jour avec succès';

  @override
  String landWithColon(String param) {
    return 'Terre : $param';
  }

  @override
  String get landsRented => 'Terres Louées';

  @override
  String get language => 'Langue';

  @override
  String get laterButton => 'Plus tard';

  @override
  String get latestSubmittedProof => 'Dernière preuve soumise';

  @override
  String get leaseStartDate => 'Date de début du bail';

  @override
  String get limitReached => 'Limite atteinte';

  @override
  String get limitReachedUpper => 'LIMITE ATTEINTE';

  @override
  String get linkYourAppStep => 'Étape 1 : Lier votre application';

  @override
  String get linkedinProfile => 'Profil LinkedIn';

  @override
  String get linkedinUrlError =>
      'Entrez une URL ou un identifiant LinkedIn valide';

  @override
  String get listNewLand => 'Lister une nouvelle terre';

  @override
  String get listProduct => 'Lister le produit';

  @override
  String get listingPublished => 'Annonce publiée';

  @override
  String get listingPublishedHint =>
      'Votre annonce est maintenant visible publiquement.';

  @override
  String get live => 'EN DIRECT';

  @override
  String get loadingBalance => 'Chargement du solde...';

  @override
  String get loadingFootprint => 'Chargement de l\'empreinte...';

  @override
  String get locationHighlights => 'Points forts de l\'emplacement';

  @override
  String get login => 'Connexion';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get lookAtCameraHint =>
      'Regardez directement la caméra avec les yeux ouverts';

  @override
  String get machineOperation => 'Utilisation de machines';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get makePurchaseImmutableRecordsHint =>
      'Effectuez un achat pour voir les enregistrements immuables ici.';

  @override
  String get manageButton => 'Gérer';

  @override
  String get manageCards => 'Gérer les cartes';

  @override
  String get manageCredits => 'Gérer les crédits et les modes de paiement';

  @override
  String get manageDeliveryTitle => 'Gérer la livraison';

  @override
  String get manageWorkers => 'Gérer les travailleurs';

  @override
  String get manager => 'Manager';

  @override
  String get mapTooltipInfo => 'Info';

  @override
  String get mapTooltipMove => 'Déplacer';

  @override
  String get mapTooltipTasks => 'Tâches';

  @override
  String get markAllAsReadTooltip => 'Tout marquer comme lu';

  @override
  String get markAsComplete => 'Marquer comme terminé';

  @override
  String get markCompleteButton => 'Marquer comme terminé';

  @override
  String get marketLabel => 'Marché';

  @override
  String get marketplace => 'Marché';

  @override
  String get maxAmountError => 'Le montant maximum est de 999 999,99 \$';

  @override
  String maximumAmount(String max) {
    return 'Montant maximum : \$$max';
  }

  @override
  String get maximumStockReached => 'Stock maximum atteint';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get menuAiAdvisor => 'Conseiller IA';

  @override
  String get menuExitGame => 'Quitter le jeu';

  @override
  String get menuInventory => 'Inventaire';

  @override
  String get menuMyTasks => 'Mes tâches';

  @override
  String get menuShop => 'Boutique';

  @override
  String get menuWorkforce => 'Main-d\'œuvre';

  @override
  String get messageCannotBeEmpty => 'Le message ne peut pas être vide';

  @override
  String get messageNoReadableText =>
      'Ce message ne contient aucun texte lisible.';

  @override
  String get messageOptionalUpper => 'MESSAGE (OPTIONNEL)';

  @override
  String get messageUpdated => 'Message mis à jour avec succès';

  @override
  String get messageWithdrawn => 'Message retiré';

  @override
  String get messageWorker => 'Contacter le travailleur';

  @override
  String get min => 'min';

  @override
  String get minsSuffix => 'mins';

  @override
  String minutesAgo(String mins) {
    return 'il y a $mins min';
  }

  @override
  String minutesCount(int count) {
    return '$count min';
  }

  @override
  String minutesLeft(int count) {
    return '$count minutes restantes';
  }

  @override
  String get monthAbbreviation => 'mois';

  @override
  String get monthly => 'Mensuel';

  @override
  String get monthlyCost => 'Coût Mensuel';

  @override
  String get monthlyRent => 'Loyer Mensuel';

  @override
  String get monthlyRentPriceTND => 'Loyer mensuel (TND)';

  @override
  String get monthlySuffix => '/mois';

  @override
  String get monthlyUpper => 'MENSUEL';

  @override
  String monthsAbbreviation(String count) {
    return '$count mois';
  }

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get moveAll => 'Tout déplacer';

  @override
  String get movePoint => 'Déplacer le point';

  @override
  String moveToStatus(String status) {
    return 'Passer à $status';
  }

  @override
  String get mustRentLand =>
      'Vous devez louer une terre pour acheter des articles.';

  @override
  String mustSubmitBefore(String date) {
    return 'Soumettre avant le $date';
  }

  @override
  String get muteVoiceOutput => 'Couper la sortie vocale';

  @override
  String get myBasket => 'Mon panier';

  @override
  String get myFarms => 'Mes fermes';

  @override
  String get myInventory => 'MON INVENTAIRE';

  @override
  String get myInvestments => 'Mes investissements';

  @override
  String get myLands => 'Mes terres';

  @override
  String get myLandsTitle => 'Mes Terres';

  @override
  String get myOrders => 'Mes Commandes';

  @override
  String get myProducts => 'Mes produits';

  @override
  String get myTasksOnLand => 'Mes tâches sur cette terre';

  @override
  String get myTasksTitle => 'Mes tâches';

  @override
  String get myWorkerTasks => 'Mes tâches de travailleur';

  @override
  String nItemsSold(int count) {
    return '$count articles vendus';
  }

  @override
  String nMonths(String count) {
    return '$count mois';
  }

  @override
  String nTasksUpper(int count) {
    return '$count TÂCHES';
  }

  @override
  String get na => 'N/A';

  @override
  String get name => 'Nom';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get nameTooShort => 'Le nom est trop court';

  @override
  String get negotiate => 'Négocier';

  @override
  String get negotiateTerms => 'Négocier les termes';

  @override
  String get negotiating => 'Négociation en cours';

  @override
  String get negotiatingUpper => 'EN NÉGOCIATION';

  @override
  String get negotiationDeclined => 'Négociation déclinée et fermée.';

  @override
  String get negotiationDeclinedBanner => 'Négociation déclinée';

  @override
  String get negotiationsUpper => 'NÉGOCIATIONS';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get newListing => 'Nouvelle annonce';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get newProposal => 'Nouvelle proposition';

  @override
  String get newSessionTooltip => 'Nouvelle session';

  @override
  String get newVerificationCodeSent => 'Nouveau code de vérification envoyé !';

  @override
  String get noActiveFarmingActivities => 'Aucune activité agricole active';

  @override
  String get noActiveNegotiationsUpper => 'AUCUNE NÉGOCIATION ACTIVE';

  @override
  String get noActiveWorkersUpper => 'AUCUN TRAVAILLEUR ACTIF';

  @override
  String get noApprovedWorkersUpper => 'AUCUN TRAVAILLEUR APPROUVÉ';

  @override
  String get noAvailableWorkers => 'Aucun travailleur disponible !';

  @override
  String get noBlockchainRecordsYet =>
      'Aucun enregistrement Blockchain pour le moment';

  @override
  String get noCamerasFound => 'Aucune caméra trouvée sur cet appareil.';

  @override
  String get noChatStateDescription =>
      'Commencez une nouvelle conversation pour obtenir des conseils d\'experts sur votre agriculture.';

  @override
  String get noChatStateTitle => 'Bienvenue sur Farmy AI';

  @override
  String get noConversationsYet => 'Pas encore de conversations.';

  @override
  String get noDeliveriesDesc =>
      'Les livraisons de vos produits\napparaîtront ici quand les clients commanderont.';

  @override
  String get noDeliveriesYet => 'Pas encore de livraisons';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible';

  @override
  String get noDescriptionProvided =>
      'Aucune description fournie pour cette terre.';

  @override
  String get noHistoryYet => 'Pas encore d\'historique';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get noInternetDescription =>
      'Nous n\'avons pas pu nous connecter au serveur. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get noInvestmentsYet => 'Aucun investissement pour le moment';

  @override
  String get noItemsFound => 'Aucun article trouvé';

  @override
  String noItemsFoundStatus(String status) {
    return 'Aucun article $status trouvé';
  }

  @override
  String get noLandAssignments => 'Aucune assignation de terre';

  @override
  String get noLandAssignmentsHint =>
      'Aucune assignation de terre pour le moment';

  @override
  String get noLandAssignmentsYet =>
      'Aucune affectation de terre pour le moment';

  @override
  String get noLandsFound => 'Aucune terre trouvée';

  @override
  String get noLandsRented => 'Vous n\'avez encore loué aucune terre.';

  @override
  String get noMessagesYet => 'Pas encore de messages';

  @override
  String get noNotificationsYet => 'Pas encore de notifications';

  @override
  String get noOrdersYet => 'Pas encore de commandes';

  @override
  String get noPendingRequests => 'Aucune demande en attente';

  @override
  String get noPendingRequestsHint =>
      'Vous n\'avez aucune demande en attente pour le moment.';

  @override
  String get noPendingTasks => 'Aucune tâche en attente !';

  @override
  String get noPendingTasksHere => 'Aucune tâche en attente ici !';

  @override
  String get noPlansAvailable => 'Aucun forfait disponible';

  @override
  String get noProductsAvailableMarketplace => 'Aucun produit disponible';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get noProductsFoundMarketplace => 'Aucun produit trouvé';

  @override
  String get noProofRequestsFound => 'Aucune demande de preuve trouvée';

  @override
  String get noProofsRequestedUpper => 'AUCUNE PREUVE DEMANDÉE';

  @override
  String get noSpecialSkillsUpper => 'AUCUNE COMPÉTENCE SPÉCIALE';

  @override
  String get noTasksAssigned => 'Aucune tâche assignée';

  @override
  String get noTasksAssignedHint => 'Aucune tâche assignée pour le moment';

  @override
  String get noTasksDefined => 'Aucune tâche définie pour cet élément.';

  @override
  String get noTasksHere => 'Aucune tâche ici';

  @override
  String get noTrackingInformation => 'Aucune information de suivi';

  @override
  String get noVerifiedWorkersFound => 'Aucun travailleur vérifié trouvé';

  @override
  String get noWorkersFoundUpper => 'AUCUN TRAVAILLEUR TROUVÉ';

  @override
  String get noWorkersYet => 'Pas encore de travailleurs';

  @override
  String get notYours => 'PAS À VOUS';

  @override
  String get nothingFoundHere => 'Rien trouvé ici';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get occupiedUpper => 'OCCUPÉ';

  @override
  String get off => 'DÉSACTIVÉ';

  @override
  String get offerAcceptedProceedToPayment =>
      'Offre acceptée ! Veuillez procéder au paiement pour activer le contrat.';

  @override
  String get offerSkillsFarms => 'Offrez vos compétences sur les fermes';

  @override
  String get offlineModeCached =>
      'Mode hors ligne : les réponses en cache seront utilisées si disponibles.';

  @override
  String get ok => 'OK';

  @override
  String get okButton => 'OK';

  @override
  String get onTheWay => 'En route';

  @override
  String get onTime => 'À l\'heure';

  @override
  String get onTimeLabel => 'À l\'heure';

  @override
  String get onlyLettersAllowed =>
      'Seules les lettres et les espaces sont autorisés';

  @override
  String get oopsSomethingWentWrong => 'Oups ! Quelque chose s\'est mal passé';

  @override
  String get open => 'Ouvert';

  @override
  String get openAiAssistant => 'Ouvrir l\'assistant IA';

  @override
  String get openInvestmentAssistant => 'Ouvrir l\'assistant d\'investissement';

  @override
  String get openJobRequest => 'Ouvrir une Demande d\'Emploi';

  @override
  String get optimalSolarExposure => 'Exposition solaire optimale';

  @override
  String get optionalMessageHint => 'Message optionnel...';

  @override
  String get orContinueWith => 'OU CONTINUER AVEC';

  @override
  String get orSelectAnItem => 'Ou sélectionnez un article';

  @override
  String get order => 'Commande';

  @override
  String get orderDelivered => 'Commande Livrée !';

  @override
  String get orderDeliveredSuccess =>
      'Votre commande a été livrée avec succès. Merci pour votre achat !';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get orderHistoryEmptyHint =>
      'Votre historique de commandes apparaîtra ici\naprès votre premier achat.';

  @override
  String get orderIdLabel => 'ID de la commande';

  @override
  String get orderLabel => 'Commande';

  @override
  String get orderPlaced => 'Commande passée !';

  @override
  String get orderSummary => 'Récapitulatif de commande';

  @override
  String get orders => 'Commandes';

  @override
  String get ordersTitle => 'Commandes';

  @override
  String organicPlotGrid(int w, int h) {
    return 'Parcelle biologique (grille ${w}x$h)';
  }

  @override
  String get otherParty => 'Autre partie';

  @override
  String get outOfStock => 'RUPTURE DE STOCK';

  @override
  String get overlapsExistingLand => 'Chevauche une terre existante';

  @override
  String owner(String id) {
    return 'Propriétaire : $id';
  }

  @override
  String get ownerLabel => 'Propriétaire';

  @override
  String get paidUpper => 'PAYÉ';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès';

  @override
  String get passwordPolicyHint =>
      'Votre nouveau mot de passe doit être différent des anciens.';

  @override
  String get passwordResetSuccess =>
      'Mot de passe réinitialisé avec succès ! Veuillez vous connecter.';

  @override
  String payAmount(String amount) {
    return 'PAYER \$$amount';
  }

  @override
  String payAmountToActivate(String amount) {
    return 'Payer $amount pour activer';
  }

  @override
  String get payNowUpper => 'PAYER MAINTENANT';

  @override
  String get payWithCardStripe => 'Payer par carte (Stripe)';

  @override
  String get payWithCredits => 'Payer avec des crédits Farmy';

  @override
  String get payWithStripe => 'Payer par carte (Stripe)';

  @override
  String get paymentCancelled => 'Le paiement a été annulé.';

  @override
  String paymentError(String error) {
    return 'Erreur de paiement : $error';
  }

  @override
  String get paymentFailedCancelled => 'Paiement échoué ou annulé.';

  @override
  String get paymentFailedGeneric => 'Le paiement n\'a pas pu être effectué.';

  @override
  String get paymentFailedTryAgain => 'Paiement échoué. Veuillez réessayer.';

  @override
  String paymentFailedWithError(String error) {
    return 'Paiement échoué : $error';
  }

  @override
  String get paymentIssueHint =>
      'Un problème est survenu lors du traitement de votre paiement.';

  @override
  String get paymentMethods => 'Méthodes de paiement';

  @override
  String get paymentPendingVerifying =>
      'Paiement soumis. Nous le vérifions en arrière-plan.';

  @override
  String get paymentProcessingSync =>
      'Le paiement est toujours en cours de traitement. Votre abonnement se synchronisera automatiquement.';

  @override
  String get paymentRequiredToActivate => 'Paiement requis pour activer';

  @override
  String get paymentSecurity => 'Paiement sécurisé traité par Stripe.';

  @override
  String get paymentStatusDelay =>
      'La vérification du statut du paiement est retardée. Nous continuerons la synchronisation en arrière-plan.';

  @override
  String get paymentSubmittedHint =>
      'Paiement soumis. Le contrat sera activé une fois confirmé.';

  @override
  String paymentSummary(String price, String cycle, String planName) {
    return '$price · $cycle · $planName';
  }

  @override
  String get payments => 'Paiements';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String get pendingLabel => 'En attente';

  @override
  String get pendingUpper => 'EN ATTENTE';

  @override
  String get pendingVerification => 'Vérification en Attente';

  @override
  String get perHour => '/heure';

  @override
  String get perHourUpper => 'PAR HEURE';

  @override
  String get perTask => 'par tâche';

  @override
  String get perTaskUpper => 'PAR TÂCHE';

  @override
  String get performance => 'Performance';

  @override
  String get performanceGraphComingSoon =>
      'Graphique de performance bientôt disponible';

  @override
  String get perimeterNotSet => 'Périmètre non défini';

  @override
  String get personalWebsite => 'Site web personnel';

  @override
  String get pestControl => 'Lutte antiparasitaire';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get placedBadge => 'PLACÉ';

  @override
  String placementFailed(String error) {
    return 'Échec du placement : $error';
  }

  @override
  String get placementFailedGeneric =>
      'Impossible de placer l\'article. Essayez ailleurs.';

  @override
  String get placingItem => 'Placement de l\'article...';

  @override
  String placingLabel(String name) {
    return 'Placement : $name';
  }

  @override
  String get plantCrops => 'Planter des cultures';

  @override
  String get planting => 'Plantation';

  @override
  String get pleaseEnterAMessage => 'Veuillez entrer un message';

  @override
  String get pleaseEnterAName => 'Veuillez saisir un nom';

  @override
  String get pleaseEnterAll6Digits => 'Veuillez entrer les 6 chiffres';

  @override
  String get pleaseEnterRejectionReason => 'Veuillez saisir le motif du rejet';

  @override
  String get pleaseEnterTaskTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterUnit => 'Veuillez entrer une unité';

  @override
  String get pleaseEnterValidSalary =>
      'Veuillez entrer un montant de salaire valide';

  @override
  String get pleaseSelectPaymentMethod =>
      'Veuillez sélectionner un mode de paiement';

  @override
  String get pleaseSelectProductType =>
      'Veuillez sélectionner un type de produit';

  @override
  String get pleaseWaitAFewMoments => 'Veuillez patienter quelques instants...';

  @override
  String plotNumber(String param) {
    return 'N° de parcelle';
  }

  @override
  String plotsCount(int w, int h) {
    return '${w}x$h parcelles';
  }

  @override
  String pointsDefined(int count) {
    return '$count points définis';
  }

  @override
  String get portfolioAnalyticsLoading =>
      'Chargement des analyses du portefeuille...';

  @override
  String get portfolioInsights => 'Aperçu du portefeuille';

  @override
  String get portfolioLinks => 'Portfolio et liens';

  @override
  String get positionIdHint => 'Positionnez votre ID dans le cadre';

  @override
  String get premium => 'PREMIUM';

  @override
  String get premiumAccess => 'Accès Premium';

  @override
  String get premiumFarmlandUpper => 'TERRE AGRICOLE PREMIUM';

  @override
  String get premiumFeatureDesc =>
      'Mettez à niveau votre abonnement pour débloquer cette fonctionnalité.';

  @override
  String get premiumFeatureTitle => 'Fonctionnalité Premium';

  @override
  String get premiumLabel => 'PREMIUM';

  @override
  String get premiumPortfolioDesc =>
      'Obtenez un suivi du ROI en temps réel, des rapports de dividendes automatisés et des conseils d\'investissement optimisés par l\'IA.';

  @override
  String get priceCannotBeEmpty => 'Le prix ne peut pas être vide';

  @override
  String priceCountCredits(double price) {
    return '$price Crédits';
  }

  @override
  String get priceCredits => 'Prix (Crédits)';

  @override
  String get priceExceedsLimit => 'Le prix dépasse la limite';

  @override
  String get priceGreaterThanZero => 'Le prix doit être supérieur à zéro';

  @override
  String get priceLabel => 'Prix';

  @override
  String get pricePerMonth => 'Prix par mois';

  @override
  String pricePerUnit(String price, String unit) {
    return '$price TND / $unit';
  }

  @override
  String get priceStartingFrom => 'Prix à partir de';

  @override
  String priceTnd(String price) {
    return '$price TND';
  }

  @override
  String get privacyControls => 'Contrôles de confidentialité';

  @override
  String get privacyRestricted => 'Accès restreint';

  @override
  String get pro => 'PRO';

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get productLabel => 'Produit';

  @override
  String productLimitMessage(String planName) {
    return 'Vous avez utilisé tous les emplacements de produits sur votre plan $planName. Passez à Farmer Pro ou Investor Plus pour lister plus de produits !';
  }

  @override
  String get productLimitReached => 'Limite de produits atteinte';

  @override
  String get productListedSuccessfully => 'Produit listé avec succès !';

  @override
  String get productListingsUsed => 'Annonces de produits utilisées';

  @override
  String get productSales => 'Ventes de produits';

  @override
  String get productType => 'Type de produit';

  @override
  String get productUpdated => 'Produit mis à jour !';

  @override
  String get productionGuruTitle => 'Gourou de la production';

  @override
  String get productionStrategy => 'Stratégie de production';

  @override
  String get productionStrategyDescription =>
      'Obtenez une analyse approfondie de vos frais généraux de production, de votre rendement potentiel et des stratégies de maximisation des profits alimentées par l\'IA.';

  @override
  String get productivity => 'Productivité';

  @override
  String get products => 'Produits';

  @override
  String get profileCompleteness => 'Complétude du profil';

  @override
  String get profileLoadError =>
      'Impossible de charger le profil. Vérifiez votre connexion.';

  @override
  String get profileNotFound => 'Profil introuvable ou privé';

  @override
  String get profilePictureUpdated => 'Photo de profil mise à jour !';

  @override
  String profileSyncFailed(String error) {
    return 'Échec de la synchronisation du profil : $error';
  }

  @override
  String get profileSyncIssue => 'Problème de synchronisation du profil';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès !';

  @override
  String get proofHistory => 'Historique des preuves';

  @override
  String get proofRequestQuestion => 'Question de demande de preuve';

  @override
  String get proofRequestedHint =>
      'Une demande de preuve a été envoyée au travailleur.';

  @override
  String get proofRequests => 'Demandes de preuves';

  @override
  String proofSubmissionHint(String param) {
    return 'Soumission de preuve : $param';
  }

  @override
  String get proofSubmittedVerified =>
      'Preuve soumise et vérifiée avec succès.';

  @override
  String get proofVerifiedSuccessfully => 'Preuve vérifiée avec succès !';

  @override
  String get proofsUnavailable => 'Preuves indisponibles';

  @override
  String get proofsUpper => 'PREUVES';

  @override
  String get propertyDetails => 'Détails de la propriété';

  @override
  String proposedSalaryAmount(String amount) {
    return 'Salaire proposé : $amount';
  }

  @override
  String get proposedUpper => 'PROPOSÉ';

  @override
  String get publicUniqueHandle => 'Identifiant unique public';

  @override
  String get publishListing => 'Publier l\'annonce';

  @override
  String get publishingFailed => 'Échec de la publication';

  @override
  String get purchaseFailed => 'Achat échoué. Crédits insuffisants ?';

  @override
  String get purchaseRequestSent =>
      'Demande envoyée ! Transaction enregistrée sur Hedera.';

  @override
  String get purchasesLabel => 'Achats';

  @override
  String qtySetTo(String title, int qty) {
    return '$title — qté réglée à $qty';
  }

  @override
  String qtyUpdatedTo(String title, String qty) {
    return '$title — quantité mise à jour à $qty';
  }

  @override
  String get qualityInspection => 'Inspection de la qualité';

  @override
  String get quantity => 'Quantité';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get quote1 => 'L\'avenir de l\'agriculture est entre vos mains.';

  @override
  String get quote2 => 'Soutenez le local, mangez frais, vivez sainement.';

  @override
  String get quote3 => 'Vous connecter aux racines de votre alimentation.';

  @override
  String get quote4 =>
      'Chaque investissement dans la nature rapporte le meilleur intérêt.';

  @override
  String get quote5 => 'De petits choix ont un grand impact sur notre planète.';

  @override
  String get quote6 => 'Frais de la ferme, directement à votre table.';

  @override
  String get quote7 => 'Autonomiser les agriculteurs, nourrir le monde.';

  @override
  String get quote8 =>
      'La durabilité n\'est pas un objectif, c\'est un mode de vie.';

  @override
  String get raiseLivestock => 'Élever du bétail';

  @override
  String get rateLabel => 'Taux';

  @override
  String get ratingLabel => 'Évaluation';

  @override
  String get readAloud => 'Lire à haute voix';

  @override
  String get readReviewsDescription => 'Description de la lecture des avis';

  @override
  String get readyForActivityHint => 'Prêt pour l\'activité';

  @override
  String get realTimeTaskNotificationsSoon =>
      'Notifications de tâches en temps réel bientôt';

  @override
  String get realtimeNotificationsSoon =>
      'Notifications de tâches en temps réel bientôt disponibles';

  @override
  String get reasonTooShort => 'Le motif est trop court';

  @override
  String get rejectRequest => 'Rejeter la demande';

  @override
  String get rejectUpper => 'REJETER';

  @override
  String get rejectedUpper => 'REJETÉ';

  @override
  String get rejectionReasonPrompt => 'Veuillez indiquer le motif du rejet';

  @override
  String get remove => 'Supprimer';

  @override
  String get removeWorker => 'Supprimer le travailleur';

  @override
  String removeWorkerConfirmation(String param) {
    return 'Supprimer le travailleur $param ?';
  }

  @override
  String get rename => 'Renommer';

  @override
  String get renameChat => 'Renommer la discussion';

  @override
  String rentAmountMonthly(String param) {
    return 'Loyer mensuel : $param';
  }

  @override
  String get rentLandToStartUpper => 'LOUER UNE TERRE POUR COMMENCER';

  @override
  String get rentNowUpper => 'LOUER MAINTENANT';

  @override
  String get rentalConfirmed => 'Location confirmée';

  @override
  String get rentalConfirmedDescription =>
      'Votre location a été confirmée et le matériel sera bientôt livré.';

  @override
  String get rentalDuration => 'Durée de location';

  @override
  String rentalExpires(String param) {
    return 'La location expire le : $param';
  }

  @override
  String get rentalLimitReached => 'Limite de location atteinte';

  @override
  String get rentalSlotsUsage => 'Utilisation des emplacements';

  @override
  String get rentalSlotsUsed => 'Emplacements de location utilisés';

  @override
  String get rentals => 'Locations';

  @override
  String get rentalsLabel => 'Locations';

  @override
  String get rented => 'LOUE';

  @override
  String get rentedUpper => 'LOUÉ';

  @override
  String get request => 'Demande';

  @override
  String get requestAIProof => 'Demander une preuve IA';

  @override
  String get requestApprovedItemPlaced => 'Demande approuvée, article placé';

  @override
  String get requestExpired => 'Demande expirée';

  @override
  String get requestProof => 'Demander une preuve';

  @override
  String get requestProofHint =>
      'Demandez au travailleur de soumettre une preuve photographique de son travail.';

  @override
  String get requestRejectedRefunded => 'Demande rejetée et remboursée';

  @override
  String requestedDateUpper(String param) {
    return 'DATE DEMANDÉE : $param';
  }

  @override
  String get resend => 'Renvoyer';

  @override
  String get resendNewCode => 'Renvoyer un nouveau code';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String resettingPasswordFor(String email) {
    return 'Réinitialisation du mot de passe pour $email';
  }

  @override
  String get responseCopied => 'Réponse copiée dans le presse-papiers.';

  @override
  String get retry => 'Réessayer';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get retryConnectionUpper => 'RÉESSAYER LA CONNEXION';

  @override
  String get retryUpper => 'RÉESSAYER';

  @override
  String get revenue => 'Revenus';

  @override
  String get revenueAnalysisPrompt =>
      'Analysez mes sources de revenus et suggérez des moyens de maximiser mes profits en fonction des tendances actuelles du marché.';

  @override
  String get revenueTitle => 'Revenus';

  @override
  String rewardAmountTnd(String amount) {
    return '$amount TND';
  }

  @override
  String get rewardLabel => 'Récompense';

  @override
  String get roiEst => 'ROI estimé';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get rolePrivacyTab => 'Rôle et confidentialité';

  @override
  String get safety => 'Sécurité';

  @override
  String get salary => 'Salaire';

  @override
  String get salaryAmount => 'Montant du salaire';

  @override
  String get salaryAmountTNDUpper => 'MONTANT DU SALAIRE (TND)';

  @override
  String salaryAmountType(int amount, String type) {
    return '$amount / $type';
  }

  @override
  String get salaryLabel => 'Salaire';

  @override
  String get salaryOptional => 'Salaire (optionnel)';

  @override
  String salaryPerMonth(String amount) {
    return '$amount \$ / mois';
  }

  @override
  String get salaryTypeUpper => 'TYPE DE SALAIRE';

  @override
  String salaryValue(String amount) {
    return '$amount \$ / mois';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get saveChangesTooltip => 'Enregistrer les modifications';

  @override
  String get savedCard => 'Carte enregistrée';

  @override
  String savingsLabel(String oldPrice, String savings) {
    return 'Était $oldPrice/an — économisez $savings';
  }

  @override
  String get scanBackId => 'Scanner le verso de l\'ID';

  @override
  String get scanFrontId => 'Scanner le recto de l\'ID';

  @override
  String get scanQRCodeDesc =>
      'Scannez ce code QR avec votre application d\'authentification (Google Authenticator, Authy, etc.)';

  @override
  String get searchProducts => 'Rechercher des produits...';

  @override
  String get searchWorkerMarketplace =>
      'Rechercher dans le marché des travailleurs';

  @override
  String get searchWorkers => 'Rechercher des travailleurs...';

  @override
  String get secureCardPaymentDesc =>
      'Paiement sécurisé par carte de crédit/débit';

  @override
  String get secureCreditCardPayment => 'Paiement sécurisé par carte bancaire';

  @override
  String get secureYourAccount => 'Sécurisez votre compte';

  @override
  String get securedWaterAccess => 'Accès sécurisé à l\'eau';

  @override
  String get securingRental => 'Sécurisation de la location...';

  @override
  String get security => 'Sécurité';

  @override
  String get selectAmount => 'Sélectionner le montant';

  @override
  String get selectAtLeast3Points => 'Sélectionnez au moins 3 points';

  @override
  String get selectAtLeastOneSkill =>
      'Veuillez sélectionner au moins une compétence';

  @override
  String get selectLand => 'Sélectionner une Terre';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get selectPaymentMethod => 'Sélectionner le mode de paiement';

  @override
  String get selectYourSkills => 'Sélectionnez vos compétences';

  @override
  String get selfieInstruction => 'Parfait ! Maintenant, prenons un selfie';

  @override
  String get seller => 'Vendeur';

  @override
  String get sellerLabel => 'Vendeur';

  @override
  String get sendInvite => 'Envoyer l\'invitation';

  @override
  String get sendMessage => 'Envoyer le message';

  @override
  String get sendProposalUpper => 'ENVOYER LA PROPOSITION';

  @override
  String get sendResetCode => 'Envoyer le code de réinitialisation';

  @override
  String get sessionHistoryTooltip => 'Historique des sessions';

  @override
  String get setMonthlySalary => 'Définir le salaire mensuel';

  @override
  String get settings => 'Paramètres';

  @override
  String get shopBack => 'RETOUR';

  @override
  String get shopBuy => 'ACHETER';

  @override
  String get shopVariants => 'VARIANTES';

  @override
  String get showContactInfoLabel => 'Afficher les coordonnées';

  @override
  String get showContactInfoSubtitle =>
      'Rendre le téléphone et l\'e-mail visibles par les relations';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInToFarmyAccount => 'Connectez-vous à votre compte Farmy';

  @override
  String get signingIn => 'Connexion en cours...';

  @override
  String get signingUp => 'Inscription en cours...';

  @override
  String get signup => 'S\'inscrire';

  @override
  String get signupFailed => 'Échec de l\'inscription';

  @override
  String get size => 'Taille';

  @override
  String sizeLabel(String w, String h) {
    return 'Taille : ${w}x$h';
  }

  @override
  String get skills => 'Compétences';

  @override
  String get skip => 'Passer';

  @override
  String get smartPayrollIntegration =>
      '💰 Intégration de la paie intelligente';

  @override
  String get soilManagement => 'Gestion des sols';

  @override
  String get soldUpper => 'VENDU';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get soon => 'Bientôt';

  @override
  String get spanish => 'Espagnol';

  @override
  String get spatialDimensions => 'Dimensions spatiales';

  @override
  String get specificationsLabel => 'Spécifications :';

  @override
  String squareMeters(int count) {
    return '$count m²';
  }

  @override
  String get startANewConversation => 'Démarrer une nouvelle conversation';

  @override
  String get startByListingPlot => 'Commencez par lister une parcelle';

  @override
  String get startDateUpper => 'DATE DE DÉBUT';

  @override
  String get startJourneyWithFarmy =>
      'Commencez votre voyage avec Farmy aujourd\'hui';

  @override
  String get startNegotiationHint =>
      'Commencez la négociation en envoyant un message.';

  @override
  String get startSellingProduce => 'Commencez à vendre vos produits';

  @override
  String get startSetup => 'Démarrer la configuration';

  @override
  String get startedLabel => 'Commencé';

  @override
  String get startingFrom => 'À partir de';

  @override
  String statusUpdatedTo(String status) {
    return 'Statut mis à jour à $status';
  }

  @override
  String get stayTunedSpatialTracking =>
      'Restez à l\'écoute pour le suivi avancé des actifs spatiaux !';

  @override
  String get strategicPortfolioAnalystTitle =>
      'Analyste de portefeuille stratégique';

  @override
  String get strategySessionDefault => 'Session stratégique';

  @override
  String get strongSecurityActive => 'Sécurité renforcée active';

  @override
  String get structureInstallation => 'Installation de structures';

  @override
  String get submitPhotoProof => 'Soumettre une preuve photo';

  @override
  String get subscription => 'Abonnement';

  @override
  String get subscriptionHeadline =>
      'Sélectionnez un forfait pour débloquer l\'expérience complète Farmy.\nUn abonnement ouvre toutes les portes.';

  @override
  String get subscriptions => 'Abonnements';

  @override
  String get subtotal => 'Sous-total';

  @override
  String subtotalLabel(String price) {
    return 'Sous-total : $price TND';
  }

  @override
  String get success => 'Succès';

  @override
  String successfullyAddedCredits(String amount) {
    return 'Ajout réussi de $amount \$';
  }

  @override
  String get successfullyDelivered => 'Livré avec succès';

  @override
  String get suggestedRealEstate => 'Immobilier suggéré :';

  @override
  String get supervisor => 'Superviseur';

  @override
  String get suspendedLabel => 'Suspendu';

  @override
  String get suspendedUpper => 'SUSPENDU';

  @override
  String get switchToMonthly => 'Passer au mensuel';

  @override
  String get syncBackend => 'Synchroniser le backend';

  @override
  String get syncInterrupted => 'Synchronisation interrompue';

  @override
  String get synchronizingBoundaries => 'SYNCHRONISATION DES LIMITES';

  @override
  String get syncingWithBackend => 'Synchronisation avec le backend...';

  @override
  String get systemErrorUpper => 'ERREUR SYSTÈME';

  @override
  String get systemOfferAccepted => 'Offre acceptée. Passage au paiement.';

  @override
  String get systemOfferDeclined =>
      'Offre déclinée. Cette négociation a été annulée.';

  @override
  String get tabAll => 'TOUT';

  @override
  String get tabApproved => 'APPROUVÉ';

  @override
  String get tabPending => 'EN ATTENTE';

  @override
  String get tabRejected => 'REJETÉ';

  @override
  String get takeAPhoto => 'Prendre une photo';

  @override
  String get takeSelfie => 'Prendre un selfie';

  @override
  String get tapToAddImage => 'Appuyez pour ajouter une image';

  @override
  String get tapToDrawBoundaries => 'Appuyez pour dessiner les limites';

  @override
  String get tapToViewPlans => 'Appuyez pour voir les plans →';

  @override
  String get tapToViewProfile => 'Appuyez pour voir le profil';

  @override
  String get taskAssigned => 'Tâche assignée !';

  @override
  String get taskCompleted =>
      'Tâche terminée ! Vous êtes maintenant disponible.';

  @override
  String get taskCompletedSuccess =>
      'Tâche terminée ! Vous êtes maintenant disponible.';

  @override
  String get taskCreated => 'Tâche créée avec succès !';

  @override
  String get taskLabel => 'Tâche';

  @override
  String get taskLimitReached => 'Limite de tâches atteinte';

  @override
  String taskLimitReachedMessage(String count) {
    return 'Vous ne pouvez avoir que $count tâches actives avec le plan gratuit.';
  }

  @override
  String get taskTitle => 'Titre de la tâche';

  @override
  String get taskTitleHint => 'ex. Arroser les tomates';

  @override
  String get taskType => 'Type de tâche';

  @override
  String get tasks => 'Tâches';

  @override
  String tasksCount(int count) {
    return '$count tâches';
  }

  @override
  String get tasksEmptyHint => 'Les tâches apparaîtront ici une fois assignées';

  @override
  String tasksForLand(String landName) {
    return 'Tâches pour $landName';
  }

  @override
  String get tasksLabelShort => 'Tâches';

  @override
  String get tasksProofs => 'Tâches et preuves';

  @override
  String get tasksUnavailable => 'Tâches indisponibles';

  @override
  String get terminatedLabel => 'Résilié';

  @override
  String get theInvestor => 'l\'investisseur';

  @override
  String get theWorker => 'le travailleur';

  @override
  String get thisWorker => 'ce travailleur';

  @override
  String get timeLabel => 'Temps';

  @override
  String get title => 'Titre';

  @override
  String get tndMo => 'TND/mois';

  @override
  String get tndPerMeter => 'TND/m';

  @override
  String toLabel(String name) {
    return 'À : $name';
  }

  @override
  String get tooShortMin3 => 'Trop court (min 3)';

  @override
  String get topUpCredits => 'RECHARGER LES CRÉDITS';

  @override
  String get total => 'Total';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get totalCapitalInvested => 'Capital total investi';

  @override
  String totalCount(String total) {
    return '$total au total';
  }

  @override
  String get totalDetailsRevenue => 'Revenus détaillés totaux';

  @override
  String get totalEarningsWallet => 'Gains totaux (Portefeuille)';

  @override
  String get totalLabel => 'Total';

  @override
  String get totalOrdersLabel => 'Total des commandes';

  @override
  String get totalProject => 'Projet Total';

  @override
  String get totalSalesValue => 'Valeur totale des ventes';

  @override
  String totalSuffix(int count) {
    return '$count au total';
  }

  @override
  String totalWithCycle(String price, String cycle) {
    return 'Total : $price \$ · $cycle';
  }

  @override
  String get trackManagePurchases => 'Suivre et gérer vos achats';

  @override
  String get trackOrder => 'Suivre la commande';

  @override
  String get transactionIdCopied =>
      'ID de transaction copié dans le presse-papiers';

  @override
  String get trustTab => 'Confiance';

  @override
  String get tryAdjustingFilters => 'Essayez d\'ajuster les filtres';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get tryAgainUpper => 'RÉESSAYER';

  @override
  String get tryToResync => 'Réessayer la synchronisation';

  @override
  String get tva => 'TVA (19%)';

  @override
  String get twoFADesc =>
      'L\'authentification à deux facteurs ajoute une couche de sécurité supplémentaire à votre compte. Pour vous connecter, vous devrez fournir un code à 6 chiffres provenant de votre application d\'authentification.';

  @override
  String get twoFADisabledSuccess => '2FA désactivé avec succès';

  @override
  String get twoFAEnabledSuccess => '2FA activé avec succès';

  @override
  String get twoFactorAuthentication => 'Authentification à deux facteurs';

  @override
  String get unableToLoadTracking => 'Impossible de charger le suivi';

  @override
  String get unableToOpenFarmerProfile =>
      'Impossible d\'ouvrir le profil de l\'agriculteur. Veuillez réessayer.';

  @override
  String get unableToPlayVoiceOutput =>
      'Impossible de lire la sortie vocale pour le moment.';

  @override
  String get unableToProcessInvitation =>
      'Impossible de traiter la réponse à l\'invitation.';

  @override
  String get unableToRetrieveLandDetails =>
      'Impossible de récupérer les détails de la terre';

  @override
  String get unableToStartVoiceInput =>
      'Impossible de démarrer l\'entrée vocale. Veuillez vérifier les permissions.';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get unitHint => 'Unité (ex: kg, litre, pièce)';

  @override
  String get unitsLabel => 'Unités';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unknownCaps => 'INCONNU';

  @override
  String get unknownCustomer => 'Client inconnu';

  @override
  String get unknownFarm => 'Ferme inconnue';

  @override
  String get unknownInvestor => 'Investisseur inconnu';

  @override
  String get unknownItem => 'Article inconnu';

  @override
  String get unknownLand => 'Terre inconnue';

  @override
  String get unknownLandFallback => 'Inconnu';

  @override
  String unknownRole(String role) {
    return 'Rôle inconnu : $role';
  }

  @override
  String get unknownWorker => 'Travailleur Inconnu';

  @override
  String get unlockDeepInsights => 'Débloquez des informations approfondies';

  @override
  String get unlockDeepInsightsDescription =>
      'Obtenez des prévisions de récolte alimentées par l\'IA, un historique détaillé de la santé des sols et des projections de ROI avancées.';

  @override
  String get unlockPortfolioMaster => 'Débloquer Portfolio Master';

  @override
  String get unlockUnlimitedSlotsInvestorPlus =>
      'Débloquez des emplacements illimités avec Investor+';

  @override
  String get unsavedChangesDesc =>
      'Vous avez des modifications non enregistrées. Voulez-vous les abandonner ?';

  @override
  String get unsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String untilDate(String param) {
    return 'jusqu\'au $param';
  }

  @override
  String untilDateUpper(String param) {
    return 'JUSQU\'AU $param';
  }

  @override
  String get unverified => 'Non vérifié';

  @override
  String get updateBasket => 'Mettre à jour le panier';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get updateProduct => 'Mettre à jour le produit';

  @override
  String get updateStatus => 'Mettre à jour le statut';

  @override
  String updateToStatusQuestion(String status) {
    return 'Passer à $status ?';
  }

  @override
  String get updateYourMessage => 'Mettre à jour votre message';

  @override
  String get updating => 'Mise à jour';

  @override
  String get upgrade => 'Mettre à jour';

  @override
  String upgradeForUnlimited(String plan) {
    return 'Passer$plan pour un accès illimité';
  }

  @override
  String get upgradeNow => 'Mettre à niveau';

  @override
  String get upgradePlanName => 'Farmer Pro';

  @override
  String get upgradePremium =>
      'Passez au niveau supérieur pour les fonctionnalités premium';

  @override
  String get upgradeRequired => 'Mise à niveau requise';

  @override
  String upgradeRequiredDesc(String featureKey) {
    return 'Cette fonctionnalité ($featureKey) est disponible dans un plan premium. Mettez à niveau votre abonnement pour la débloquer.';
  }

  @override
  String upgradeToPlan(String planName) {
    return 'Passer à $planName';
  }

  @override
  String get upgradeToYearly => 'Passer à l\'annuel';

  @override
  String upgradeWithPrice(String price) {
    return 'Mettre à niveau $price';
  }

  @override
  String uploadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get uploadingDocuments => 'Téléchargement des documents...';

  @override
  String get uploadingImage => 'Téléchargement de l\'image...';

  @override
  String get user => 'Utilisateur';

  @override
  String get usernameFormatError =>
      'Utilisez des minuscules, des chiffres, des points, des tirets bas';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get usernameRequired => 'Le nom d\'utilisateur est requis';

  @override
  String get usernameTaken => 'Ce nom d\'utilisateur est déjà pris';

  @override
  String validUntil(String date) {
    return 'Valable jusqu\'au $date';
  }

  @override
  String get verification => 'Vérification';

  @override
  String verificationCodeSentTo(String email) {
    return 'Nous avons envoyé un code de vérification à 6 chiffres à\n$email.';
  }

  @override
  String get verificationFailed => 'Échec de la vérification';

  @override
  String get verificationRequired => 'Vérification requise';

  @override
  String get verificationSuccessful => 'Vérification réussie';

  @override
  String get verified => 'Vérifié';

  @override
  String get verifiedSeller => 'Vendeur Vérifié';

  @override
  String get verifiedUpper => 'VÉRIFIÉ';

  @override
  String get verifiedWorker => 'Travailleur Vérifié';

  @override
  String get verify => 'Vérifier';

  @override
  String get verifyAccount => 'Vérifier le compte';

  @override
  String get verifyEmailTitle => 'Vérifiez votre e-mail';

  @override
  String get verifying => 'Vérification...';

  @override
  String get viewAllHistory => 'Voir tout l\'historique';

  @override
  String get viewAssignmentsTasks => 'Consultez vos affectations et tâches';

  @override
  String get viewBlockchainRecords =>
      'Consultez vos enregistrements blockchain';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get viewInvestmentBreakdown => 'Voir le détail dans Investissements';

  @override
  String get viewManageLandInvestments =>
      'Voir et gérer vos investissements fonciers';

  @override
  String get viewManageProofRequests =>
      'Consulter et gérer les demandes de preuves';

  @override
  String get viewMyOrders => 'Voir mes commandes';

  @override
  String get viewPlans => 'Voir les plans';

  @override
  String get viewRecentActivity =>
      'Consultez votre activité récente et les mises à jour';

  @override
  String get viewReviews => 'Voir les avis';

  @override
  String get voiceInput => 'Entrée vocale';

  @override
  String get voiceInputNotAvailable =>
      'L\'entrée vocale n\'est pas disponible sur cet appareil.';

  @override
  String get voiceOutputMuted =>
      'La sortie vocale est coupée. Réactivez-la pour lire ce message.';

  @override
  String get waitUsernameCheck =>
      'Veuillez patienter pendant la vérification du nom d\'utilisateur';

  @override
  String get waitingForWorkerResponse =>
      'En attente de la réponse du travailleur';

  @override
  String get walletCards => 'Portefeuille et cartes';

  @override
  String get walletCredits => 'Crédits du portefeuille';

  @override
  String get walletPaymentsTitle => 'Portefeuille et paiements';

  @override
  String get water => 'Arroser';

  @override
  String get watering => 'Arrosage';

  @override
  String get weatherLabel => 'Météo';

  @override
  String get websiteLabel => 'Site web';

  @override
  String get websiteUrlError => 'Entrez une URL de site web valide';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get welcomeCustomerSubtitle =>
      'Soutenez les agriculteurs locaux et profitez de produits frais et durables directement à la source.';

  @override
  String get welcomeCustomerTitle => 'Bienvenue sur Farmy !';

  @override
  String get welcomeFarmerSubtitle =>
      'Votre voyage vers la gestion agricole numérique commence ici. Développons votre entreprise ensemble !';

  @override
  String get welcomeFarmerTitle => 'Autonomiser les agriculteurs';

  @override
  String get welcomeInvestorSubtitle =>
      'Explorez des opportunités durables et développez votre portefeuille agricole vert avec nous.';

  @override
  String get welcomeInvestorTitle => 'Investissez dans l\'avenir';

  @override
  String get welcomeStrategicAnalysis =>
      'Bienvenue dans l\'analyse stratégique';

  @override
  String get welcomeToFarmy => 'Bienvenue sur Farmy';

  @override
  String get welcomeWorkerSubtitle =>
      'Connectez-vous à des fermes modernes et commencez votre voyage productif dans l\'agriculture durable.';

  @override
  String get welcomeWorkerTitle => 'Rejoignez la main-d\'œuvre';

  @override
  String get widthAuto => 'Largeur auto';

  @override
  String get withdraw => 'Retirer';

  @override
  String get withdrawMessageConfirmation =>
      'Cela supprimera définitivement votre dernier message de négociation.';

  @override
  String get withdrawMessageQuestion => 'Retirer ce message ?';

  @override
  String get worker => 'Travailleur';

  @override
  String workerAssignedToLand(String worker, String landName) {
    return '$worker assigné à $landName';
  }

  @override
  String get workerDashboard => 'Tableau de bord du travailleur';

  @override
  String get workerMarketplace => 'Marché des Travailleurs';

  @override
  String get workerPlus => 'Worker Plus';

  @override
  String get workerPlusDescription =>
      'Boostez votre profil, obtenez une mise en relation prioritaire et des retraits instantanés.';

  @override
  String get workerProfileCreated =>
      '🎉 Profil de travailleur créé ! En attente de vérification.';

  @override
  String get workerRemovedSuccessfully => 'Travailleur supprimé avec succès';

  @override
  String get workerRespondedReviewCounterOffer =>
      'Le travailleur a répondu, examinez la contre-offre';

  @override
  String get workersAcceptedDeclinedInvites =>
      'Travailleurs ayant accepté ou décliné vos invitations';

  @override
  String workersAvailable(String count) {
    return '$count Disponibles';
  }

  @override
  String get workersSyncIssue => 'Problème de synchronisation des travailleurs';

  @override
  String get workforce => 'Main-d\'œuvre';

  @override
  String workforceLandName(String landName) {
    return 'Main-d\'œuvre — $landName';
  }

  @override
  String get workforceUpper => 'MAIN-D\'ŒUVRE';

  @override
  String get wrongLand => 'Mauvaise terre';

  @override
  String get wrongLandSubtitle => 'Cet article appartient à une autre terre.';

  @override
  String get yearly => 'Annuel';

  @override
  String get yearlySave => 'Annuel (Économisez 33 %)';

  @override
  String get yearlySuffix => '/an';

  @override
  String get you => 'Vous';

  @override
  String get youLabel => 'Vous';

  @override
  String get yourBasketIsEmpty => 'Votre panier est vide';

  @override
  String get yourEmail => 'votre e-mail';

  @override
  String get failedUpper => 'ÉCHOUÉ';

  @override
  String get cancelledUpper => 'ANNULÉ';

  @override
  String get fetchingFarmData => 'Récupération des données de la ferme...';

  @override
  String get preparingLandGeometry =>
      'Préparation de la géométrie du terrain...';

  @override
  String get finalizingWorld => 'Finalisation du monde...';

  @override
  String get warmingUpAssets => 'Chauffage des actifs à proximité...';

  @override
  String get position => 'Position';

  @override
  String get tiles => 'tuiles';

  @override
  String get basePrice => 'Prix de base';

  @override
  String get workingUpper => 'EN TRAVAIL';

  @override
  String get busyUpper => 'OCCUPÉ';

  @override
  String get vegetation => 'végétation';

  @override
  String get tree => 'arbre';

  @override
  String get structure => 'structure';

  @override
  String get machine => 'machine';

  @override
  String get aboutFarmyTitle => 'À propos de Farmy';

  @override
  String get farmyTagline =>
      'Donner du pouvoir à l\'agriculture grâce à l\'innovation, la gestion et des expériences immersives';

  @override
  String get farmyDescription =>
      'Farmy est une plateforme agricole complète qui comble le fossé entre l\'agriculture traditionnelle et la technologie moderne. Nous fournissons des outils de gestion agricole, des connexions marketplace, des opportunités d\'investissement et des expériences gamifiées pour rendre l\'agriculture accessible et engageante pour tous.';

  @override
  String get missionTitle => 'Notre Mission';

  @override
  String get missionDescription =>
      'Révolutionner l\'agriculture en créant un écosystème connecté où les agriculteurs, les investisseurs, les travailleurs et les consommateurs collaborent de manière fluide grâce à des solutions technologiques innovantes.';

  @override
  String get visionTitle => 'Notre Vision';

  @override
  String get visionDescription =>
      'Un monde où l\'agriculture durable prospère grâce à l\'autonomisation numérique, rendant l\'agriculture plus efficace, plus rentable et accessible aux communautés du monde entier.';

  @override
  String get meetTheTeamTitle => 'Rencontrez l\'équipe';

  @override
  String get meetTheTeamSubtitle => 'L\'équipe Be.net derrière Farmy';

  @override
  String get leadDeveloperRole => 'Développeur Principal';

  @override
  String get developerRole => 'Développeur';

  @override
  String get faqTitle => 'Questions fréquemment posées';

  @override
  String get faqWhatIsFarmy => 'Qu\'est-ce que Farmy ?';

  @override
  String get faqWhatIsFarmyAnswer =>
      'Farmy est une plateforme agricole tout-en-un combinant des outils de gestion de ferme, des fonctionnalités marketplace, des opportunités d\'investissement et des expériences gamifiées. Elle connecte les agriculteurs, les investisseurs, les travailleurs et les clients dans un écosystème numérique fluide.';

  @override
  String get faqWhoIsBehind => 'Qui est derrière Farmy ?';

  @override
  String get faqWhoIsBehindAnswer =>
      'Farmy a été construit par l\'équipe Be.net - un groupe de développeurs passionnés de Tunisie dédiés à transformer l\'agriculture grâce à la technologie. Notre équipe comprend Karim Feki, Nesrine Derouiche, Mohamed Abidi, Oussema Issaoui et Fatma Hidoussi.';

  @override
  String get faqTechnologies => 'Quelles technologies sont utilisées ?';

  @override
  String get faqTechnologiesAnswer =>
      'Farmy est construit avec Flutter pour des expériences mobiles et web cross-plateforme, un backend Node.js, Firebase pour les fonctionnalités temps réel, la blockchain Hedera pour des transactions sécurisées, et intègre des fonctionnalités alimentées par l\'IA pour l\'analyse des cultures et les recommandations.';

  @override
  String get faqContribute =>
      'Comment puis-je contribuer ou contacter l\'équipe ?';

  @override
  String get faqContributeAnswer =>
      'Vous pouvez contacter notre équipe via GitHub en contribuant à nos projets open-source, vous connecter avec nous sur LinkedIn, ou visiter nos sites web portfolio. Nous accueillons les commentaires, suggestions et opportunités de collaboration !';

  @override
  String get madeWithLove => 'Fait avec ❤️ par l\'équipe Be.net';

  @override
  String get cropCalendarTitle => 'Calendrier des Cultures';

  @override
  String get monthView => 'Mois';

  @override
  String get yearView => 'Année';

  @override
  String get plantingDate => 'Date de Plantation';

  @override
  String get expectedHarvest => 'Récolte Prévue';

  @override
  String get cropRotation => 'Rotation des Cultures';

  @override
  String get addCropPlan => 'Ajouter un Plan';

  @override
  String get noCropsMessage => 'Aucune culture programmée';

  @override
  String get growingStatus => 'En Croissance';

  @override
  String get readyStatus => 'Prêt';

  @override
  String get completedStatus => 'Terminé';

  @override
  String get plannedStatus => 'Planifié';

  @override
  String get activeStatus => 'Actif';

  @override
  String get harvestedStatus => 'Récolté';

  @override
  String get overdueStatus => 'En Retard';

  @override
  String daysUntilHarvest(Object days) {
    return '$days jours avant la récolte';
  }

  @override
  String get readyToHarvest => 'Prêt à récolter';

  @override
  String get selectCrop => 'Sélectionner une Culture';

  @override
  String get newCropPlan => 'Nouveau Plan de Culture';

  @override
  String get schedulePlanting => 'Planifiez votre prochaine plantation';

  @override
  String get expectedHarvestDate => 'Date de Récolte Prévue';

  @override
  String get cropCycle => 'Cycle de Culture';

  @override
  String get days => 'jours';

  @override
  String get perennial => 'vivace';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get cropPlanCreated => 'Plan de culture créé avec succès';

  @override
  String get cropPlanFailed => 'Échec de la création du plan';

  @override
  String get activeCrops => 'Actifs';

  @override
  String get readySoon => 'Bientôt Prêts';

  @override
  String get plannedCrops => 'Planifiés';

  @override
  String get loading => 'Chargement';

  @override
  String get notesOptional => 'Notes (Optionnel)';

  @override
  String get addNotesHint => 'Ajoutez des notes sur ce plan de culture...';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get createPlan => 'Créer le Plan';

  @override
  String get selectALand => 'Sélectionner une terre';

  @override
  String get pleaseSelectLand => 'Veuillez sélectionner une terre';

  @override
  String get pleaseSelectCrop => 'Veuillez sélectionner une culture';

  @override
  String get loadingCrops => 'Chargement des cultures disponibles...';

  @override
  String get noCropsAvailable => 'Aucune culture disponible';

  @override
  String get addCropsFirst =>
      'Ajoutez d\'abord des cultures à la boutique, ou essayez de recharger.';

  @override
  String get reload => 'Recharger';

  @override
  String get noCropVariantsFound => 'Aucune variante de culture trouvée';

  @override
  String cycleDaysLabel(Object days) {
    return 'Cycle: $days jours';
  }

  @override
  String get perennialSuffix => '(vivace)';

  @override
  String get failedToLoadCrops => 'Échec du chargement des cultures';

  @override
  String get cropPlanCreatedSuccess => 'Plan de culture créé avec succès';

  @override
  String get failedToCreatePlan => 'Échec de la création du plan';

  @override
  String get fillAllRequiredFields =>
      'Veuillez remplir tous les champs obligatoires';

  @override
  String get legendTitle => 'Légende';

  @override
  String get plantedLabel => 'Planté';

  @override
  String get plantingLabel => 'Plantation';

  @override
  String get harvestLabel => 'Récolte';

  @override
  String get readyLabel => 'Prêt!';

  @override
  String get nowLabel => 'Maintenant';

  @override
  String get harvestButton => 'Récolter';

  @override
  String get plantButton => 'Planter';

  @override
  String cropCount(Object count) {
    return '$count culture';
  }

  @override
  String cropCount_plural(Object count) {
    return '$count cultures';
  }

  @override
  String get noCropsThisMonth => 'Aucune culture ce mois';

  @override
  String overdueByDays(Object days) {
    return 'En retard de $days jours';
  }

  @override
  String get plantToday => 'Planter aujourd\'hui!';

  @override
  String plantInDays(Object days) {
    return 'Planter dans $days jours';
  }

  @override
  String get readyToHarvestStatus => 'Prêt à récolter';

  @override
  String get growingStatusShort => 'En croissance';

  @override
  String get producesLabel => 'Produit';

  @override
  String get perCycle => 'par cycle';

  @override
  String get workerPerformanceTitle => 'Travailleurs';

  @override
  String get totalWorkers => 'Travailleurs Total';

  @override
  String get avgPerformanceScore => 'Score Moyen';

  @override
  String get totalTasksCompleted => 'Tâches Terminées';

  @override
  String get overallVerificationRate => 'Taux de Vérification';

  @override
  String get verifiedProofs => 'Vérifié';

  @override
  String get rejectedProofs => 'Rejeté';

  @override
  String get averageCompletionTime => 'Temps Moyen';

  @override
  String get performanceScore => 'Score de Performance';

  @override
  String get topPerformers => 'Meilleurs Performeurs';

  @override
  String get needsAttention => 'Besoin d\'Attention';

  @override
  String get filterByLand => 'Filtrer par Terrain';

  @override
  String get filterByDate => 'Filtrer par Date';

  @override
  String get sortBy => 'Trier par';

  @override
  String get noWorkersFound => 'Aucun travailleur trouvé';

  @override
  String get noDataForFilters => 'Aucune donnée pour les filtres sélectionnés';

  @override
  String get errorLoadingPerformance => 'Erreur lors du chargement des données';

  @override
  String get allTime => 'Tout le Temps';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get scoreHighToLow => 'Score: Élevé à Faible';

  @override
  String get scoreLowToHigh => 'Score: Faible à Élevé';

  @override
  String get tasksHighToLow => 'Tâches: Plus à Moins';

  @override
  String get nameAZ => 'Nom: A-Z';

  @override
  String get workerListTitle => 'Performance des Travailleurs';

  @override
  String get workersCount => 'travailleurs';

  @override
  String get tasksCompleted => 'Tâches';

  @override
  String get verificationRate => 'Taux de Vérification';
}
