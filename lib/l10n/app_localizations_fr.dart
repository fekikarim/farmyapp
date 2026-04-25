// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get becomeAWorker => 'Devenir travailleur';

  @override
  String get joinTheWorkforce => 'Rejoindre la main-d\'œuvre';

  @override
  String get joinWorkforceDescription =>
      'Créez votre profil professionnel et\ncommencez à gagner de l\'argent dans les fermes voisines dès aujourd\'hui.';

  @override
  String get selectYourSkills => 'Sélectionnez vos compétences';

  @override
  String get aboutYou => 'À propos de vous';

  @override
  String get aboutYouHint => 'Parlez de votre expérience aux agriculteurs...';

  @override
  String get hourlyRateTnd => 'Taux horaire (TND)';

  @override
  String get hourlyRateHint => 'ex. 15,00';

  @override
  String get aiVerificationComingSoon => 'Vérification IA bientôt disponible';

  @override
  String get aiVerificationDescription =>
      'La vérification automatisée de l\'identité et des compétences accélérera votre approbation.';

  @override
  String get createWorkerProfile => 'Créer un profil de travailleur';

  @override
  String get selectAtLeastOneSkill =>
      'Veuillez sélectionner au moins une compétence';

  @override
  String get workerProfileCreated =>
      '🎉 Profil de travailleur créé ! En attente de vérification.';

  @override
  String get failedToCreateProfile => 'Échec de la création du profil';

  @override
  String get enterValidRate => 'Entrez un taux valide';

  @override
  String get watering => 'Arrosage';

  @override
  String get harvesting => 'Récolte';

  @override
  String get planting => 'Plantation';

  @override
  String get animalCare => 'Soins aux animaux';

  @override
  String get machineOperation => 'Utilisation de machines';

  @override
  String get soilManagement => 'Gestion des sols';

  @override
  String get structureInstallation => 'Installation de structures';

  @override
  String get qualityInspection => 'Inspection de la qualité';

  @override
  String get cropMonitoring => 'Surveillance des cultures';

  @override
  String get pestControl => 'Lutte antiparasitaire';

  @override
  String get viewManageLandInvestments =>
      'Voir et gérer vos investissements fonciers';

  @override
  String get enableGameEdgePanel => 'Activer le panneau latéral du jeu';

  @override
  String get accessFarmView => 'Accéder à la vue de la ferme en 2.5D';

  @override
  String get tasksProofs => 'Tâches et preuves';

  @override
  String get aiProofRequests => 'Demandes de preuves IA';

  @override
  String get viewManageProofRequests =>
      'Consulter et gérer les demandes de preuves';

  @override
  String get freeTier => 'Offre gratuite';

  @override
  String get upgradePremium =>
      'Passez au niveau supérieur pour les fonctionnalités premium';

  @override
  String get freeForever => 'Pas d\'expiration · Gratuit pour toujours';

  @override
  String validUntil(String date) {
    return 'Valable jusqu\'au $date';
  }

  @override
  String get editLandDetails => 'Modifier les détails de la terre';

  @override
  String get deleteLand => 'Supprimer la terre';

  @override
  String get deleteLandTitle => 'Supprimer la terre ?';

  @override
  String deleteLandConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get deleteLandActionWarning =>
      'Cette action ne peut pas être annulée. Toutes les données associées seront définitivement supprimées.';

  @override
  String get landDeletedSuccess => 'Terre supprimée avec succès';

  @override
  String get delete => 'Supprimer';

  @override
  String get comingSoon => 'À venir';

  @override
  String featureOptimizedDescription(String feature) {
    return 'Le module \"$feature\" est actuellement en cours d\'optimisation pour la gestion agricole personnelle.';
  }

  @override
  String get stayTunedSpatialTracking =>
      'Restez à l\'écoute pour le suivi avancé des actifs spatiaux !';

  @override
  String get gotIt => 'COMPRIS';

  @override
  String get live => 'EN DIRECT';

  @override
  String get failedToSyncBackend =>
      'Échec de la synchronisation avec le serveur';

  @override
  String get externalProperty => 'PROPRIÉTÉ EXTERNE';

  @override
  String get notYours => 'PAS À VOUS';

  @override
  String get dismiss => 'IGNORER';

  @override
  String get myLands => 'Mes terres';

  @override
  String get landDataSyncSuccess =>
      '✨ Données foncières synchronisées avec succès !';

  @override
  String get limitReached => 'Limite atteinte';

  @override
  String get newListing => 'Nouvelle annonce';

  @override
  String get landLimitReachedTitle => 'Limite de terres atteinte';

  @override
  String landLimitReachedDescription(String planName) {
    return 'Vous avez utilisé tous les emplacements de terre de votre forfait $planName. Passez à Farmer Pro pour débloquer des terres illimitées !';
  }

  @override
  String get landSlotsUsed => 'Emplacements de terre utilisés';

  @override
  String get synchronizingBoundaries => 'SYNCHRONISATION DES LIMITES';

  @override
  String get fetchingSpatialData =>
      'Récupération des données spatiales précises...';

  @override
  String get syncInterrupted => 'Synchronisation interrompue';

  @override
  String get tryToResync => 'Réessayer la synchronisation';

  @override
  String get noDescriptionProvided =>
      'Aucune description fournie pour cette terre.';

  @override
  String get area => 'Superficie';

  @override
  String get rentals => 'Locations';

  @override
  String get earnings => 'Gains';

  @override
  String get safety => 'Sécurité';

  @override
  String get workforce => 'Main-d\'œuvre';

  @override
  String get active => 'ACTIF';

  @override
  String get rented => 'LOUE';

  @override
  String get available => 'disponible';

  @override
  String owner(String id) {
    return 'Propriétaire : $id';
  }

  @override
  String get myBasket => 'Mon panier';

  @override
  String get clear => 'Effacer';

  @override
  String get yourBasketIsEmpty => 'Votre panier est vide';

  @override
  String get browseMarketplaceDescription =>
      'Parcourez le marché et ajoutez\ndes produits frais !';

  @override
  String get browseProducts => 'Parcourir les produits';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get tva => 'TVA (19%)';

  @override
  String get total => 'Total';

  @override
  String balanceWithCredits(String balance) {
    return 'Solde : $balance Crédits';
  }

  @override
  String checkoutWithItems(int count) {
    return 'Paiement ($count articles)';
  }

  @override
  String get insufficientFunds => 'Fonds insuffisants';

  @override
  String insufficientFundsDescription(String balance, String total) {
    return 'Votre solde est de $balance Crédits, mais le total est de $total TND.\n\nVeuillez recharger votre portefeuille.';
  }

  @override
  String get confirmPurchase => 'Confirmer l\'achat';

  @override
  String itemsCount(int count) {
    return '$count article(s)';
  }

  @override
  String includingTva(String tax) {
    return '(y compris 19% TVA : $tax TND)';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get orderPlaced => 'Commande passée !';

  @override
  String itemsPurchasedSuccess(int count) {
    return '$count article(s) acheté(s) avec succès.';
  }

  @override
  String get trackOrder => 'Suivre la commande';

  @override
  String get viewMyOrders => 'Voir mes commandes';

  @override
  String get backToMarketplace => 'Retour au marché';

  @override
  String checkoutResultFeedback(int successCount, int failCount) {
    return '$successCount achetés, $failCount échoués. Les articles échoués restent dans le panier.';
  }

  @override
  String get clearBasketTitle => 'Vider le panier ?';

  @override
  String get clearBasketDescription =>
      'Cela supprimera tous les articles de votre panier.';

  @override
  String get clearAll => 'Tout vider';

  @override
  String get twoFactorAuthentication => 'Authentification à deux facteurs';

  @override
  String get verificationRequired => 'Vérification requise';

  @override
  String get enter2faCode =>
      'Entrez le code à 6 chiffres de votre application d\'authentification pour continuer.';

  @override
  String get verify => 'Vérifier';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get user => 'Utilisateur';

  @override
  String get customerAccount => 'Compte client';

  @override
  String get dailyInspiration => 'Inspiration quotidienne';

  @override
  String get workerPlus => 'Worker Plus';

  @override
  String get workerPlusDescription =>
      'Boostez votre profil, obtenez une mise en relation prioritaire et des retraits instantanés.';

  @override
  String get farmboxSubscription => 'Abonnement FarmBox';

  @override
  String get farmboxDescription =>
      'Recevez chaque semaine des légumes frais cultivés localement à votre porte !';

  @override
  String upgradeWithPrice(String price) {
    return 'Mettre à niveau $price';
  }

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
  String get totalEarningsWallet => 'Gains totaux (Portefeuille)';

  @override
  String get totalSalesValue => 'Valeur totale des ventes';

  @override
  String get itemsSold => 'Articles vendus';

  @override
  String nTasksUpper(int count) {
    return '$count TÂCHES';
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
  String get advancedAnalytics => 'Analyses avancées';

  @override
  String get premium => 'PREMIUM';

  @override
  String get unlockDeepInsights => 'Débloquez des informations approfondies';

  @override
  String get unlockDeepInsightsDescription =>
      'Obtenez des prévisions de récolte alimentées par l\'IA, un historique détaillé de la santé des sols et des projections de ROI avancées.';

  @override
  String get productionStrategy => 'Stratégie de production';

  @override
  String get productionStrategyDescription =>
      'Obtenez une analyse approfondie de vos frais généraux de production, de votre rendement potentiel et des stratégies de maximisation des profits alimentées par l\'IA.';

  @override
  String get consultProductionGuru => 'Consulter le gourou de la production';

  @override
  String upgradeToPlan(String planName) {
    return 'Passer à $planName';
  }

  @override
  String get farmyUser => 'Utilisateur Farmy';

  @override
  String get latestSubmittedProof => 'Dernière preuve soumise';

  @override
  String get free => 'GRATUIT';

  @override
  String get pro => 'PRO';

  @override
  String get enabled => 'ACTIVÉ';

  @override
  String get off => 'DÉSACTIVÉ';

  @override
  String buyProductConfirmation(String title, double price) {
    return 'Voulez-vous acheter $title pour $price crédits ?';
  }

  @override
  String get buy => 'Acheter';

  @override
  String creditsCount(String count) {
    return 'Crédits : $count';
  }

  @override
  String priceCountCredits(double price) {
    return '$price Crédits';
  }

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String get pleaseSelectProductType =>
      'Veuillez sélectionner un type de produit';

  @override
  String get productUpdated => 'Produit mis à jour !';

  @override
  String get productListedSuccessfully => 'Produit listé avec succès !';

  @override
  String get failedToUpdateProduct => 'Échec de la mise à jour du produit.';

  @override
  String get failedToListProduct => 'Échec de la mise en liste du produit.';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get tapToAddImage => 'Appuyez pour ajouter une image';

  @override
  String get title => 'Titre';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get productType => 'Type de produit';

  @override
  String get description => 'Description';

  @override
  String get priceCredits => 'Prix (Crédits)';

  @override
  String get quantity => 'Quantité';

  @override
  String get unitHint => 'Unité (ex: kg, litre, pièce)';

  @override
  String get pleaseEnterUnit => 'Veuillez entrer une unité';

  @override
  String get updateProduct => 'Mettre à jour le produit';

  @override
  String get listProduct => 'Lister le produit';

  @override
  String get noCamerasFound => 'Aucune caméra trouvée sur cet appareil.';

  @override
  String get flipIdInstruction =>
      'Super ! Maintenant, retournez votre pièce d\'identité';

  @override
  String get selfieInstruction => 'Parfait ! Maintenant, prenons un selfie';

  @override
  String get uploadingDocuments => 'Téléchargement des documents...';

  @override
  String kycSuccess(String role) {
    return 'Succès ! Vous êtes maintenant un $role !';
  }

  @override
  String get scanFrontId => 'Scanner le recto de l\'ID';

  @override
  String get scanBackId => 'Scanner le verso de l\'ID';

  @override
  String get takeSelfie => 'Prendre un selfie';

  @override
  String get positionIdHint => 'Positionnez votre ID dans le cadre';

  @override
  String get flipIdHint => 'Retournez votre ID et scannez le verso';

  @override
  String get lookAtCameraHint =>
      'Regardez directement la caméra avec les yeux ouverts';

  @override
  String get verifying => 'Vérification...';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get accountBanned => 'Compte banni';

  @override
  String get bannedDescription =>
      'Votre compte a été suspendu en raison de violations spécifiques. Veuillez contacter le support si vous pensez qu\'il s\'agit d\'une erreur.';

  @override
  String get logout => 'Déconnexion';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get noInternetDescription =>
      'Nous n\'avons pas pu nous connecter au serveur. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get askFarmingQuestion => 'Posez votre question sur l\'agriculture...';

  @override
  String get sendMessage => 'Envoyer le message';

  @override
  String get voiceInput => 'Entrée vocale';

  @override
  String get rename => 'Renommer';

  @override
  String get startANewConversation => 'Démarrer une nouvelle conversation';

  @override
  String get createChatDescription =>
      'Créez une discussion pour demander des conseils agricoles pratiques.';

  @override
  String get askAnythingAboutFarm => 'Demandez n\'importe quoi sur votre ferme';

  @override
  String get aiAssistantDescription =>
      'Dates de semis, santé des cultures, engrais et conseils pratiques avec détection automatique de la langue.';

  @override
  String get noChatStateTitle => 'Bienvenue sur Farmy AI';

  @override
  String get noChatStateDescription =>
      'Commencez une nouvelle conversation pour obtenir des conseils d\'experts sur votre agriculture.';

  @override
  String get disableVoiceInput => 'Désactiver l\'entrée vocale';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get muteVoiceOutput => 'Couper la sortie vocale';

  @override
  String get enableVoiceOutput => 'Activer la sortie vocale';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get syncBackend => 'Synchroniser le backend';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get closeAssistant => 'Fermer l\'assistant';

  @override
  String get syncingWithBackend => 'Synchronisation avec le backend...';

  @override
  String get backendDisconnected =>
      'Backend déconnecté. Reconnexion automatique...';

  @override
  String get offlineModeCached =>
      'Mode hors ligne : les réponses en cache seront utilisées si disponibles.';

  @override
  String get noConversationsYet => 'Pas encore de conversations.';

  @override
  String get conversations => 'Conversations';

  @override
  String get renameChat => 'Renommer la discussion';

  @override
  String get deleteChat => 'Supprimer la discussion';

  @override
  String get chatTitle => 'Titre de la discussion';

  @override
  String get updateYourMessage => 'Mettre à jour votre message';

  @override
  String get resend => 'Renvoyer';

  @override
  String get save => 'Enregistrer';

  @override
  String deleteChatConfirmation(String title) {
    return 'Supprimer définitivement \"$title\" ?';
  }

  @override
  String get responseCopied => 'Réponse copiée dans le presse-papiers.';

  @override
  String get voiceInputNotAvailable =>
      'L\'entrée vocale n\'est pas disponible sur cet appareil.';

  @override
  String get unableToStartVoiceInput =>
      'Impossible de démarrer l\'entrée vocale. Veuillez vérifier les permissions.';

  @override
  String get voiceOutputMuted =>
      'La sortie vocale est coupée. Réactivez-la pour lire ce message.';

  @override
  String get messageNoReadableText =>
      'Ce message ne contient aucun texte lisible.';

  @override
  String get unableToPlayVoiceOutput =>
      'Impossible de lire la sortie vocale pour le moment.';

  @override
  String get couldNotSendMessage =>
      'Impossible d\'envoyer votre message. Veuillez réessayer.';

  @override
  String get upgradeRequired => 'Mise à niveau requise';

  @override
  String get upgrade => 'Mettre à jour';

  @override
  String get editAndResend => 'Modifier et renvoyer';

  @override
  String get copy => 'Copier';

  @override
  String get readAloud => 'Lire à haute voix';

  @override
  String get cached => 'Mis en cache';

  @override
  String get verifyEmailTitle => 'Vérifiez votre e-mail';

  @override
  String verificationCodeSentTo(String email) {
    return 'Nous avons envoyé un code de vérification à 6 chiffres à\n$email.';
  }

  @override
  String get verifyAccount => 'Vérifier le compte';

  @override
  String get resendNewCode => 'Renvoyer un nouveau code';

  @override
  String get newVerificationCodeSent => 'Nouveau code de vérification envoyé !';

  @override
  String get failedToSendCode => 'Échec de l\'envoi du code. Réessayez.';

  @override
  String get yourEmail => 'votre e-mail';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String resettingPasswordFor(String email) {
    return 'Réinitialisation du mot de passe pour $email';
  }

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get pleaseEnterAll6Digits => 'Veuillez entrer les 6 chiffres';

  @override
  String get passwordResetSuccess =>
      'Mot de passe réinitialisé avec succès ! Veuillez vous connecter.';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre adresse e-mail et nous vous enverrons un code à 6 chiffres pour réinitialiser votre mot de passe.';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get sendResetCode => 'Envoyer le code de réinitialisation';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get welcomeCustomerTitle => 'Bienvenue sur Farmy !';

  @override
  String get welcomeCustomerSubtitle =>
      'Soutenez les agriculteurs locaux et profitez de produits frais et durables directement à la source.';

  @override
  String get welcomeWorkerTitle => 'Rejoignez la main-d\'œuvre';

  @override
  String get welcomeWorkerSubtitle =>
      'Connectez-vous à des fermes modernes et commencez votre voyage productif dans l\'agriculture durable.';

  @override
  String get welcomeFarmerTitle => 'Autonomiser les agriculteurs';

  @override
  String get welcomeFarmerSubtitle =>
      'Votre voyage vers la gestion agricole numérique commence ici. Développons votre entreprise ensemble !';

  @override
  String get welcomeInvestorTitle => 'Investissez dans l\'avenir';

  @override
  String get welcomeInvestorSubtitle =>
      'Explorez des opportunités durables et développez votre portefeuille agricole vert avec nous.';

  @override
  String get skip => 'Passer';

  @override
  String get finish => 'Terminer';

  @override
  String get continueText => 'Continuer';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Espagnol';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get accountInformation => 'Informations sur le compte';

  @override
  String get verified => 'Vérifié';

  @override
  String get unverified => 'Non vérifié';

  @override
  String get subscription => 'Abonnement';

  @override
  String get payments => 'Paiements';

  @override
  String get walletCards => 'Portefeuille et cartes';

  @override
  String get manageCredits => 'Gérer les crédits et les modes de paiement';

  @override
  String get hederaRegistry => 'Registre Hedera';

  @override
  String get viewBlockchainRecords =>
      'Consultez vos enregistrements blockchain';

  @override
  String get general => 'Général';

  @override
  String get viewRecentActivity =>
      'Consultez votre activité récente et les mises à jour';

  @override
  String get security => 'Sécurité';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get disable2fa => 'Désactiver la 2FA';

  @override
  String get enable2fa => 'Activer la 2FA';

  @override
  String get strongSecurityActive => 'Sécurité renforcée active';

  @override
  String get addExtraSecurity =>
      'Ajouter une couche de sécurité supplémentaire';

  @override
  String get orders => 'Commandes';

  @override
  String get trackManagePurchases => 'Suivre et gérer vos achats';

  @override
  String get verification => 'Vérification';

  @override
  String get becomeFarmer => 'Devenir agriculteur';

  @override
  String get startSellingProduce => 'Commencez à vendre vos produits';

  @override
  String get becomeInvestor => 'Devenir investisseur';

  @override
  String get investSustainableFarming => 'Investir dans l\'agriculture durable';

  @override
  String get worker => 'Travailleur';

  @override
  String get becomeWorker => 'Devenir travailleur';

  @override
  String get offerSkillsFarms => 'Offrez vos compétences sur les fermes';

  @override
  String get workerDashboard => 'Tableau de bord du travailleur';

  @override
  String get viewAssignmentsTasks => 'Consultez vos affectations et tâches';

  @override
  String get gameFeatures => 'Fonctionnalités du jeu';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get aboutUs => 'À propos de nous - Équipe Farmy';

  @override
  String get featureUnderDevelopment =>
      'Cette fonctionnalité est actuellement en cours de développement.';

  @override
  String get home => 'Accueil';

  @override
  String get marketplace => 'Marché';

  @override
  String get subscriptions => 'Abonnements';

  @override
  String get settings => 'Paramètres';

  @override
  String get analytics => 'Analyses';

  @override
  String get land => 'Terre';

  @override
  String get products => 'Produits';

  @override
  String get myFarms => 'Mes fermes';

  @override
  String get explore => 'Explorer';

  @override
  String get investments => 'Investissements';

  @override
  String get revenue => 'Revenus';

  @override
  String get tasks => 'Tâches';

  @override
  String get openInvestmentAssistant => 'Ouvrir l\'assistant d\'investissement';

  @override
  String get openAiAssistant => 'Ouvrir l\'assistant IA';

  @override
  String get myWorkerTasks => 'Mes tâches de travailleur';

  @override
  String unknownRole(String role) {
    return 'Rôle inconnu : $role';
  }

  @override
  String get appName => 'Farmy';

  @override
  String get unknown => 'Inconnu';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get revenueTitle => 'Revenus';

  @override
  String get cancel => 'Annuler';

  @override
  String get login => 'Connexion';

  @override
  String get signup => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get welcomeToFarmy => 'Bienvenue sur Farmy';

  @override
  String get signInToFarmyAccount => 'Connectez-vous à votre compte Farmy';

  @override
  String get startJourneyWithFarmy =>
      'Commencez votre voyage avec Farmy aujourd\'hui';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get fullName => 'Nom complet';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get signingIn => 'Connexion en cours...';

  @override
  String get signingUp => 'Inscription en cours...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get orContinueWith => 'OU CONTINUER AVEC';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get signupFailed => 'Échec de l\'inscription';

  @override
  String get signIn => 'Se connecter';

  @override
  String get ok => 'OK';

  @override
  String get myProducts => 'Mes produits';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String deleteProductConfirmation(String title) {
    return 'Êtes-vous sûr de vouloir supprimer $title ?';
  }

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get failedToDeleteProduct => 'Échec de la suppression du produit';

  @override
  String get analyzeInventory => 'Analyser l\'inventaire';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get addProductFirst =>
      'Ajoutez votre premier produit pour le voir ici !';

  @override
  String get edit => 'Modifier';

  @override
  String get credits => 'Crédits';

  @override
  String get productLimitReached => 'Limite de produits atteinte';

  @override
  String get viewPlans => 'Voir les plans';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get oopsSomethingWentWrong => 'Oups ! Quelque chose s\'est mal passé';

  @override
  String get productListingsUsed => 'Annonces de produits utilisées';

  @override
  String get upgradePlanName => 'Farmer Pro';

  @override
  String get analyzeInventoryPrompt =>
      'Analysez mon inventaire actuel de produits. S\'agit-il de bons produits à conserver ou devrais-je me concentrer sur autre chose en fonction du marché ?';

  @override
  String get imageUnavailable => 'Image non disponible';

  @override
  String productLimitMessage(String planName) {
    return 'Vous avez utilisé tous les emplacements de produits sur votre plan $planName. Passez à Farmer Pro ou Investor Plus pour lister plus de produits !';
  }

  @override
  String get workerMarketplace => 'Marché des Travailleurs';

  @override
  String get searchWorkers => 'Rechercher des travailleurs...';

  @override
  String get noVerifiedWorkersFound => 'Aucun travailleur vérifié trouvé';

  @override
  String tasksCount(int count) {
    return '$count tâches';
  }

  @override
  String get perHour => '/heure';

  @override
  String workforceLandName(String landName) {
    return 'Main-d\'œuvre — $landName';
  }

  @override
  String get addWorker => 'Ajouter un Travailleur';

  @override
  String get inviteExistingWorker => 'Inviter un Travailleur Existant';

  @override
  String get searchWorkerMarketplace =>
      'Rechercher dans le marché des travailleurs';

  @override
  String get openJobRequest => 'Ouvrir une Demande d\'Emploi';

  @override
  String get soon => 'Bientôt';

  @override
  String get totalLabel => 'Total';

  @override
  String get activeLabel => 'Actif';

  @override
  String get suspendedLabel => 'Suspendu';

  @override
  String get monthlyCost => 'Coût Mensuel';

  @override
  String get productivity => 'Productivité';

  @override
  String totalSuffix(int count) {
    return '$count au total';
  }

  @override
  String get noWorkersYet => 'Pas encore de travailleurs';

  @override
  String get addWorkersMarketplaceHint =>
      'Appuyez sur le bouton + pour ajouter des travailleurs depuis le marché';

  @override
  String get unknownWorker => 'Travailleur Inconnu';

  @override
  String get tndMo => 'TND/mois';

  @override
  String get workersSyncIssue => 'Problème de synchronisation des travailleurs';

  @override
  String get invitationsSyncIssue =>
      'Problème de synchronisation des invitations';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String get waitingForWorkerResponse =>
      'En attente de la réponse du travailleur';

  @override
  String get invitationDecisions => 'Décisions d\'invitation';

  @override
  String get workersAcceptedDeclinedInvites =>
      'Travailleurs ayant accepté ou décliné vos invitations';

  @override
  String get aiAutoAssignTasks => '🤖 Auto-attribution des tâches par IA';

  @override
  String get gpsVerifiedWorkProof => '📍 Preuve de travail vérifiée par GPS';

  @override
  String get iotSensorDashboard => '🌡️ Tableau de bord des capteurs IoT';

  @override
  String get smartPayrollIntegration =>
      '💰 Intégration de la paie intelligente';

  @override
  String get freshProductsFarmers => 'Produits frais des agriculteurs locaux';

  @override
  String get myOrders => 'Mes Commandes';

  @override
  String get searchProducts => 'Rechercher des produits...';

  @override
  String get all => 'Tous';

  @override
  String get noProductsFoundMarketplace => 'Aucun produit trouvé';

  @override
  String get noProductsAvailableMarketplace => 'Aucun produit disponible';

  @override
  String get adjustSearchFilters =>
      'Essayez d\'ajuster votre recherche ou vos filtres';

  @override
  String get checkBackLaterFreshProducts =>
      'Revenez plus tard pour des produits frais';

  @override
  String get outOfStock => 'RUPTURE DE STOCK';

  @override
  String get inBasket => 'Dans le panier';

  @override
  String availableCount(int count, String unit) {
    return '$count $unit disponible(s)';
  }

  @override
  String subtotalLabel(String price) {
    return 'Sous-total : $price TND';
  }

  @override
  String get seller => 'Vendeur';

  @override
  String get farmer => 'Agriculteur';

  @override
  String get verifiedSeller => 'Vendeur Vérifié';

  @override
  String get updateBasket => 'Mettre à jour le panier';

  @override
  String get addToBasket => 'Ajouter au panier';

  @override
  String qtySetTo(String title, int qty) {
    return '$title — qté réglée à $qty';
  }

  @override
  String addedToBasket(String title) {
    return '$title ajouté au panier';
  }

  @override
  String get noOrdersYet => 'Pas encore de commandes';

  @override
  String get orderHistoryEmptyHint =>
      'Votre historique de commandes apparaîtra ici\naprès votre premier achat.';

  @override
  String get order => 'Commande';

  @override
  String get farmyPremium => 'Farmy Premium';

  @override
  String currentPlanLabel(String name) {
    return 'Actuel : $name';
  }

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearlySave => 'Annuel (Économisez 33 %)';

  @override
  String get failedToLoadSubscriptions => 'Échec du chargement des abonnements';

  @override
  String get failedToLoadWorkerProfile =>
      'Échec du chargement du profil de travailleur';

  @override
  String get currentPlan => 'Plan Actuel';

  @override
  String get upgradeToYearly => 'Passer à l\'annuel';

  @override
  String get switchToMonthly => 'Passer au mensuel';

  @override
  String get downgradeToFree => 'Rétrograder vers le gratuit';

  @override
  String get getStarted => 'Commencer';

  @override
  String activeOnCycle(String cycle) {
    return 'Actif sur $cycle';
  }

  @override
  String get confirmDowngrade => 'Confirmer la rétrogradation';

  @override
  String downgradeWarning(String name) {
    return 'Êtes-vous sûr de vouloir rétrograder vers $name ? Vous perdrez vos fonctionnalités premium et les avantages actifs associés à votre plan actuel.';
  }

  @override
  String get selectPaymentMethod => 'Sélectionner le mode de paiement';

  @override
  String totalWithCycle(String price, String cycle) {
    return 'Total : $price \$ · $cycle';
  }

  @override
  String get payWithCredits => 'Payer avec des crédits Farmy';

  @override
  String get loadingBalance => 'Chargement du solde...';

  @override
  String balanceValue(String amount) {
    return 'Solde : $amount \$';
  }

  @override
  String get payWithStripe => 'Payer par carte (Stripe)';

  @override
  String get secureCreditCardPayment => 'Paiement sécurisé par carte bancaire';

  @override
  String get unableToLoadTracking => 'Impossible de charger le suivi';

  @override
  String get noTrackingInformation => 'Aucune information de suivi';

  @override
  String get deliveryTrackingEmptyHint =>
      'Le suivi de livraison apparaîtra\nune fois votre commande traitée.';

  @override
  String get orderDelivered => 'Commande Livrée !';

  @override
  String get orderDeliveredSuccess =>
      'Votre commande a été livrée avec succès. Merci pour votre achat !';

  @override
  String get updating => 'Mise à jour';

  @override
  String get profileSyncIssue => 'Problème de synchronisation du profil';

  @override
  String get assignedLandsUnavailable => 'Terres assignées indisponibles';

  @override
  String get tasksUnavailable => 'Tâches indisponibles';

  @override
  String get invitationsUnavailable => 'Invitations indisponibles';

  @override
  String get contractsUnavailable => 'Contrats indisponibles';

  @override
  String get proofsUnavailable => 'Preuves indisponibles';

  @override
  String get viewAllHistory => 'Voir tout l\'historique';

  @override
  String get noLandAssignmentsYet =>
      'Aucune affectation de terre pour le moment';

  @override
  String get landAssignmentsEmptyHint => 'Vous verrez vos terres assignées ici';

  @override
  String get noTasksAssigned => 'Aucune tâche assignée';

  @override
  String get tasksEmptyHint => 'Les tâches apparaîtront ici une fois assignées';

  @override
  String get notifications => 'Notifications';

  @override
  String get realtimeNotificationsSoon =>
      'Notifications de tâches en temps réel bientôt disponibles';

  @override
  String get verifiedWorker => 'Travailleur Vérifié';

  @override
  String get pendingVerification => 'Vérification en Attente';

  @override
  String get invitationAcceptedSuccess => 'Invitation acceptée avec succès.';

  @override
  String get invitationDeclinedSuccess => 'Invitation déclinée avec succès.';

  @override
  String get unableToProcessInvitation =>
      'Impossible de traiter la réponse à l\'invitation.';

  @override
  String get landBoundary => 'Limite du terrain';

  @override
  String get landInformation => 'Informations sur le terrain';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible';

  @override
  String get grid => 'Grille';

  @override
  String get assignmentRole => 'Rôle d\'affectation';

  @override
  String get salaryLabel => 'Salaire';

  @override
  String salaryValue(String amount) {
    return '$amount \$ / mois';
  }

  @override
  String get assignmentStatus => 'Statut d\'affectation';

  @override
  String get farmerProfileUnavailable =>
      'Le profil de l\'agriculteur est indisponible pour le moment.';

  @override
  String get unableToOpenFarmerProfile =>
      'Impossible d\'ouvrir le profil de l\'agriculteur. Veuillez réessayer.';

  @override
  String get invitationApproved => 'Invitation Approuvée';

  @override
  String get invitationPending => 'Invitation en Attente';

  @override
  String get invitationDeclined => 'Invitation Refusée';

  @override
  String get invitationExpired => 'Invitation Expirée';

  @override
  String get assigned => 'Assigné';

  @override
  String get acceptThisOfferQuestion => 'Accepter cette offre ?';

  @override
  String acceptOfferConfirmation(String amount, String type) {
    return 'Vous êtes sur le point d\'accepter l\'offre de $amount $type. Cela établira un contrat légal.';
  }

  @override
  String get contractApproved =>
      'Contrat approuvé ! En attente du paiement de l\'investisseur.';

  @override
  String get failedToAccept => 'Échec de l\'acceptation de l\'offre.';

  @override
  String get declineThisOfferQuestion => 'Décliner cette offre ?';

  @override
  String declineOfferConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir décliner l\'offre de $name ?';
  }

  @override
  String get theInvestor => 'l\'investisseur';

  @override
  String get contractDeclined => 'Offre de contrat déclinée.';

  @override
  String get failedToDecline => 'Échec du refus de l\'offre.';

  @override
  String get pleaseEnterAMessage => 'Veuillez entrer un message';

  @override
  String get pleaseEnterValidSalary =>
      'Veuillez entrer un montant de salaire valide';

  @override
  String get counterOfferSent => 'Contre-offre envoyée avec succès !';

  @override
  String get failedToSendCounterOffer =>
      'Échec de l\'envoi de la contre-offre.';

  @override
  String get messageCannotBeEmpty => 'Le message ne peut pas être vide';

  @override
  String get messageUpdated => 'Message mis à jour avec succès';

  @override
  String get failedToEditMessage => 'Échec de la mise à jour du message';

  @override
  String get withdrawMessageQuestion => 'Retirer ce message ?';

  @override
  String get withdrawMessageConfirmation =>
      'Cela supprimera définitivement votre dernier message de négociation.';

  @override
  String get withdraw => 'Retirer';

  @override
  String get messageWithdrawn => 'Message retiré';

  @override
  String get failedToWithdrawMessage => 'Échec du retrait du message';

  @override
  String investorAcceptOfferConfirmation(
    String name,
    String amount,
    String type,
  ) {
    return 'Vous êtes sur le point d\'accepter la contre-offre de $name de $amount $type. Une fois acceptée, vous devrez payer le premier mois de salaire pour activer le contrat.';
  }

  @override
  String get theWorker => 'le travailleur';

  @override
  String get offerAcceptedProceedToPayment =>
      'Offre acceptée ! Veuillez procéder au paiement pour activer le contrat.';

  @override
  String get declineNegotiationQuestion => 'Décliner la négociation ?';

  @override
  String declineNegotiationConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir décliner toute négociation ultérieure avec $name ?';
  }

  @override
  String get thisWorker => 'ce travailleur';

  @override
  String get negotiationDeclined => 'Négociation déclinée et fermée.';

  @override
  String get failedToCreatePayment =>
      'Échec de la création de l\'intention de paiement.';

  @override
  String get contractActivated => 'Contrat activé avec succès !';

  @override
  String get invalidPaymentData =>
      'Données de paiement invalides reçues du serveur. Veuillez réessayer.';

  @override
  String get paymentSubmittedHint =>
      'Paiement soumis. Le contrat sera activé une fois confirmé.';

  @override
  String get paymentCancelled => 'Le paiement a été annulé.';

  @override
  String contractForWorker(String name) {
    return 'Contrat pour $name';
  }

  @override
  String get negotiationDeclinedBanner => 'Négociation déclinée';

  @override
  String get contractTerminatedBanner => 'Contrat résilié';

  @override
  String get contractExpiredBanner => 'Contrat expiré';

  @override
  String contractIsStatus(String status) {
    return 'Ce contrat est $status';
  }

  @override
  String get noMessagesYet => 'Pas encore de messages';

  @override
  String get startNegotiationHint =>
      'Commencez la négociation en envoyant un message.';

  @override
  String get systemOfferAccepted => 'Offre acceptée. Passage au paiement.';

  @override
  String get systemOfferDeclined =>
      'Offre déclinée. Cette négociation a été annulée.';

  @override
  String get you => 'Vous';

  @override
  String get otherParty => 'Autre partie';

  @override
  String proposedSalaryAmount(String amount) {
    return 'Salaire proposé : $amount';
  }

  @override
  String get editingYourMessage => 'Modification de votre message';

  @override
  String get editYourMessageHint => 'Modifiez votre message...';

  @override
  String get salaryOptional => 'Salaire (optionnel)';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(String mins) {
    return 'il y a $mins min';
  }

  @override
  String hoursAgo(String hours) {
    return 'il y a ${hours}h';
  }

  @override
  String get negotiateTerms => 'Négocier les termes';

  @override
  String get salaryAmount => 'Montant du salaire';

  @override
  String get addAMessageHint => 'Ajouter un message...';

  @override
  String get counter => 'Contre-offre';

  @override
  String get counterOffer => 'Contre-offre';

  @override
  String payAmountToActivate(String amount) {
    return 'Payer $amount pour activer';
  }

  @override
  String get hiringPending => 'Embauche en attente';

  @override
  String get negotiating => 'Négociation en cours';

  @override
  String get awaitingPayment => 'En attente de paiement';

  @override
  String get negotiate => 'Négocier';

  @override
  String get perTask => 'par tâche';

  @override
  String squareMeters(int count) {
    return '$count m²';
  }

  @override
  String amountPrefix(String amount) {
    return '$amount \$';
  }

  @override
  String get terminatedLabel => 'Résilié';

  @override
  String get hourlyLabel => 'par heure';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String get contract => 'Contrat';

  @override
  String get paymentFailedCancelled => 'Paiement échoué ou annulé.';

  @override
  String get farmerInfoSyncedFromAssignment =>
      'Informations synchronisées depuis l\'affectation';

  @override
  String get tapToViewProfile => 'Appuyez pour voir le profil';

  @override
  String salaryPerMonth(String amount) {
    return '$amount \$ / mois';
  }

  @override
  String get revenueAnalysisPrompt =>
      'Analysez mes sources de revenus et suggérez des moyens de maximiser mes profits en fonction des tendances actuelles du marché.';

  @override
  String get analyzeRevenueTooltip => 'Analyser les revenus';

  @override
  String get totalDetailsRevenue => 'Revenus détaillés totaux';

  @override
  String get creditsLabel => 'Crédits';

  @override
  String get productSales => 'Ventes de produits';

  @override
  String get unitsLabel => 'Unités';

  @override
  String get investmentRevenue => 'Revenus d\'investissement';

  @override
  String get viewInvestmentBreakdown => 'Voir le détail dans Investissements';

  @override
  String get portfolioInsights => 'Aperçu du portefeuille';

  @override
  String get premiumLabel => 'PREMIUM';

  @override
  String get unlockPortfolioMaster => 'Débloquer Portfolio Master';

  @override
  String get premiumPortfolioDesc =>
      'Obtenez un suivi du ROI en temps réel, des rapports de dividendes automatisés et des conseils d\'investissement optimisés par l\'IA.';

  @override
  String get investorPlus => 'Investisseur Plus';

  @override
  String get portfolioAnalyticsLoading =>
      'Chargement des analyses du portefeuille...';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès';

  @override
  String get changePasswordTitle => 'Modifier le mot de passe';

  @override
  String get createNewPassword => 'Créer un nouveau mot de passe';

  @override
  String get passwordPolicyHint =>
      'Votre nouveau mot de passe doit être différent des anciens.';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get enterCurrentPasswordError =>
      'Veuillez saisir votre mot de passe actuel';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String profileSyncFailed(String error) {
    return 'Échec de la synchronisation du profil : $error';
  }

  @override
  String get unsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get unsavedChangesDesc =>
      'Vous avez des modifications non enregistrées. Voulez-vous les abandonner ?';

  @override
  String get discard => 'Abandonner';

  @override
  String get waitUsernameCheck =>
      'Veuillez patienter pendant la vérification du nom d\'utilisateur';

  @override
  String get correctErrorsInForm =>
      'Veuillez corriger les erreurs dans le formulaire';

  @override
  String get usernameTaken => 'Ce nom d\'utilisateur est déjà pris';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès !';

  @override
  String get changeProfilePicture => 'Changer la photo de profil';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get takeAPhoto => 'Prendre une photo';

  @override
  String get profilePictureUpdated => 'Photo de profil mise à jour !';

  @override
  String uploadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get identityTab => 'Identité';

  @override
  String get trustTab => 'Confiance';

  @override
  String get rolePrivacyTab => 'Rôle et confidentialité';

  @override
  String get saveChangesTooltip => 'Enregistrer les modifications';

  @override
  String get profileCompleteness => 'Complétude du profil';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get nameTooShort => 'Le nom est trop court';

  @override
  String get onlyLettersAllowed =>
      'Seules les lettres et les espaces sont autorisés';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get publicUniqueHandle => 'Identifiant unique public';

  @override
  String get usernameRequired => 'Le nom d\'utilisateur est requis';

  @override
  String get tooShortMin3 => 'Trop court (min 3)';

  @override
  String get usernameFormatError =>
      'Utilisez des minuscules, des chiffres, des points, des tirets bas';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get invalidPhoneFormat => 'Format de téléphone invalide';

  @override
  String get countryLabel => 'Pays';

  @override
  String get cityLabel => 'Ville';

  @override
  String get headlineLabel => 'Slogan';

  @override
  String get headlineHint => 'Une courte description de ce que vous faites';

  @override
  String get aboutMe => 'À propos de moi';

  @override
  String get portfolioLinks => 'Portfolio et liens';

  @override
  String get linkedinProfile => 'Profil LinkedIn';

  @override
  String get linkedinUrlError =>
      'Entrez une URL ou un identifiant LinkedIn valide';

  @override
  String get personalWebsite => 'Site web personnel';

  @override
  String get websiteUrlError => 'Entrez une URL de site web valide';

  @override
  String get farmerDetailsTitle => 'Détails de l\'agriculteur';

  @override
  String get businessFarmName => 'Nom de l\'entreprise/ferme';

  @override
  String get investorDetailsTitle => 'Détails de l\'investisseur';

  @override
  String get expectedBudgetRange => 'Plage budgétaire prévue';

  @override
  String get budgetRangeHint => 'ex: 10 000 \$ - 50 000 \$';

  @override
  String get privacyControls => 'Contrôles de confidentialité';

  @override
  String get discoverableMarketplace => 'Découvrable sur le marché';

  @override
  String get discoverableSubtitle =>
      'Permettre aux autres de trouver et de voir votre profil';

  @override
  String get showContactInfoLabel => 'Afficher les coordonnées';

  @override
  String get showContactInfoSubtitle =>
      'Rendre le téléphone et l\'e-mail visibles par les relations';

  @override
  String get failedInitiate2FA =>
      'Échec de l\'initialisation de la configuration 2FA';

  @override
  String get twoFAEnabledSuccess => '2FA activé avec succès';

  @override
  String get twoFADisabledSuccess => '2FA désactivé avec succès';

  @override
  String get codeCopied => 'Code copié dans le presse-papiers';

  @override
  String get disable2FA => 'Désactiver la 2FA';

  @override
  String get enable2FA => 'Activer la 2FA';

  @override
  String get secureYourAccount => 'Sécurisez votre compte';

  @override
  String get twoFADesc =>
      'L\'authentification à deux facteurs ajoute une couche de sécurité supplémentaire à votre compte. Pour vous connecter, vous devrez fournir un code à 6 chiffres provenant de votre application d\'authentification.';

  @override
  String get startSetup => 'Démarrer la configuration';

  @override
  String get linkYourAppStep => 'Étape 1 : Lier votre application';

  @override
  String get scanQRCodeDesc =>
      'Scannez ce code QR avec votre application d\'authentification (Google Authenticator, Authy, etc.)';

  @override
  String get enterCodeManually => 'Ou entrez ce code manuellement :';

  @override
  String get copyToClipboardTooltip => 'Copier dans le presse-papiers';

  @override
  String get confirmEnablementStep => 'Étape 2 : Confirmer l\'activation';

  @override
  String get enter6DigitCodeConfirm =>
      'Saisissez le code à 6 chiffres de votre application pour confirmer :';

  @override
  String get backButton => 'Retour';

  @override
  String get enter6DigitCodeDisable =>
      'Saisissez le code à 6 chiffres de votre application d\'authentification pour désactiver l\'authentification à deux facteurs.';

  @override
  String get allNotificationsMarkedRead =>
      'Toutes les notifications sont marquées comme lues';

  @override
  String get failedToDeleteNotification =>
      'Échec de la suppression de la notification';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsReadTooltip => 'Tout marquer comme lu';

  @override
  String get noNotificationsYet => 'Pas encore de notifications';

  @override
  String get premiumAccess => 'Accès Premium';

  @override
  String get chooseYourPlan => 'Choisissez votre forfait';

  @override
  String get subscriptionHeadline =>
      'Sélectionnez un forfait pour débloquer l\'expérience complète Farmy.\nUn abonnement ouvre toutes les portes.';

  @override
  String get yearly => 'Annuel';

  @override
  String get alwaysFree => 'Toujours gratuit';

  @override
  String get freeLabel => 'Gratuit';

  @override
  String get monthlySuffix => '/mois';

  @override
  String get yearlySuffix => '/an';

  @override
  String savingsLabel(String oldPrice, String savings) {
    return 'Était $oldPrice/an — économisez $savings';
  }

  @override
  String get continueWithFree => 'Continuer avec le gratuit';

  @override
  String getPlan(String planName) {
    return 'Obtenir $planName';
  }

  @override
  String paymentSummary(String price, String cycle, String planName) {
    return '$price · $cycle · $planName';
  }

  @override
  String balanceStatusSuccess(String amount) {
    return 'Solde : $amount ✓';
  }

  @override
  String balanceStatusInsufficient(String amount) {
    return 'Solde : $amount — Insuffisant';
  }

  @override
  String get payWithCardStripe => 'Payer par carte (Stripe)';

  @override
  String get secureCardPaymentDesc =>
      'Paiement sécurisé par carte de crédit/débit';

  @override
  String get failedLoadPlans => 'Échec du chargement des forfaits';

  @override
  String get noPlansAvailable => 'Aucun forfait disponible';

  @override
  String get contactSupport => 'Veuillez contacter le support.';

  @override
  String get paymentPendingVerifying =>
      'Paiement soumis. Nous le vérifions en arrière-plan.';

  @override
  String get paymentProcessingSync =>
      'Le paiement est toujours en cours de traitement. Votre abonnement se synchronisera automatiquement.';

  @override
  String get paymentStatusDelay =>
      'La vérification du statut du paiement est retardée. Nous continuerons la synchronisation en arrière-plan.';

  @override
  String paymentError(String error) {
    return 'Erreur de paiement : $error';
  }

  @override
  String get deliveriesTitle => 'Livraisons';

  @override
  String get ordersTitle => 'Commandes';

  @override
  String totalCount(String total) {
    return '$total au total';
  }

  @override
  String get totalOrdersLabel => 'Total des commandes';

  @override
  String get deliveredLabel => 'Livré';

  @override
  String get noDeliveriesYet => 'Pas encore de livraisons';

  @override
  String get noDeliveriesDesc =>
      'Les livraisons de vos produits\napparaîtront ici quand les clients commanderont.';

  @override
  String get manageDeliveryTitle => 'Gérer la livraison';

  @override
  String get deliveryNotFound => 'Livraison non trouvée';

  @override
  String get deliveryTimeline => 'Chronologie de livraison';

  @override
  String get updateStatus => 'Mettre à jour le statut';

  @override
  String etaLabel(String time) {
    return 'Heure d\'arrivée prévue : $time';
  }

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get productLabel => 'Produit';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get orderIdLabel => 'ID de la commande';

  @override
  String get customerLabel => 'Client';

  @override
  String get deliveryInfo => 'Infos de livraison';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get createdLabel => 'Créé';

  @override
  String get startedLabel => 'Commencé';

  @override
  String get cancelDeliveryQuestion => 'Annuler la livraison ?';

  @override
  String updateToStatusQuestion(String status) {
    return 'Passer à $status ?';
  }

  @override
  String get cancelNotifyCustomer =>
      'Ceci annulera la livraison et en informera le client.';

  @override
  String advanceNotifyCustomer(String status) {
    return 'Ceci fera passer la livraison à \"$status\" et en informera le client.';
  }

  @override
  String get cancellationReasonHint => 'Raison de l\'annulation...';

  @override
  String get addNoteHint => 'Ajouter une note (optionnel)...';

  @override
  String get confirmUpdate => 'Confirmer';

  @override
  String get cancelDeliveryAction => 'Annuler la livraison';

  @override
  String statusUpdatedTo(String status) {
    return 'Statut mis à jour à $status';
  }

  @override
  String get failedUpdateStatus => 'Échec de la mise à jour du statut';

  @override
  String moveToStatus(String status) {
    return 'Passer à $status';
  }

  @override
  String get successfullyDelivered => 'Livré avec succès';

  @override
  String get deliveryCancelled => 'Livraison annulée';

  @override
  String completedOn(String date) {
    return 'Terminé le $date';
  }

  @override
  String dateTimeAt(String date, String time) {
    return '$date à $time';
  }

  @override
  String get cardAddedSuccess => 'Carte ajoutée avec succès';

  @override
  String get failedAddCard => 'Échec de l\'ajout de la carte';

  @override
  String get addCreditsTitle => 'Ajouter des crédits';

  @override
  String get selectAmount => 'Sélectionner le montant';

  @override
  String get customAmountLabel => 'Montant personnalisé';

  @override
  String get maxAmountError => 'Le montant maximum est de 999 999,99 \$';

  @override
  String payAmount(String amount) {
    return 'PAYER \$$amount';
  }

  @override
  String get enterAmount => 'SAISIR UN MONTANT';

  @override
  String successfullyAddedCredits(String amount) {
    return 'Ajout réussi de $amount \$';
  }

  @override
  String priceTnd(String price) {
    return '$price TND';
  }

  @override
  String get failedAddCredits => 'Échec de l\'ajout de crédits';

  @override
  String get walletPaymentsTitle => 'Portefeuille et paiements';

  @override
  String get currentBalance => 'Solde actuel';

  @override
  String get paymentMethods => 'Méthodes de paiement';

  @override
  String get addNewCard => 'Ajouter une nouvelle carte';

  @override
  String expiresLabel(String expiry) {
    return 'Expire le $expiry';
  }

  @override
  String get failedLoadTasks => 'Échec du chargement des tâches';

  @override
  String get errorFetchingTasks =>
      'Erreur lors de la récupération de vos tâches';

  @override
  String get taskCompletedSuccess =>
      'Tâche terminée ! Vous êtes maintenant disponible.';

  @override
  String get failedCompleteTask => 'Échec de la finalisation de la tâche';

  @override
  String errorWithPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get myTasksTitle => 'Mes tâches';

  @override
  String get noPendingTasks => 'Aucune tâche en attente !';

  @override
  String get availableForAssignments =>
      'Vous êtes disponible pour de nouvelles affectations.';

  @override
  String get taskLabel => 'Tâche';

  @override
  String get unknownCaps => 'INCONNU';

  @override
  String get minsSuffix => 'mins';

  @override
  String get markAsComplete => 'Marquer comme terminé';

  @override
  String get productionGuruTitle => 'Gourou de la production';

  @override
  String get sessionHistoryTooltip => 'Historique des sessions';

  @override
  String get newSessionTooltip => 'Nouvelle session';

  @override
  String get askGuruHint => 'Demandez à votre gourou...';

  @override
  String get harvestChroniclesTitle => 'Chroniques de récolte';

  @override
  String get noHistoryYet => 'Pas encore d\'historique';

  @override
  String get farmAnalysisDefault => 'Analyse de la ferme';

  @override
  String get assetsLabel => 'Actifs';

  @override
  String get failedReachAnalyst =>
      'Échec de la connexion à l\'analyste stratégique IA.';

  @override
  String get strategicPortfolioAnalystTitle =>
      'Analyste de portefeuille stratégique';

  @override
  String get investmentStrategyChroniclesTitle =>
      'Chroniques de stratégie d\'investissement';

  @override
  String get strategySessionDefault => 'Session stratégique';

  @override
  String get welcomeStrategicAnalysis =>
      'Bienvenue dans l\'analyse stratégique';

  @override
  String get investmentAgentWelcomeDesc =>
      'Dites-moi votre budget et votre préférence en matière de risques, ou posez des questions sur le marché actuel et les tendances météorologiques.';

  @override
  String get consultedLiveData => 'Données en direct consultées :';

  @override
  String get marketLabel => 'Marché';

  @override
  String get weatherLabel => 'Météo';

  @override
  String get suggestedRealEstate => 'Immobilier suggéré :';

  @override
  String get unknownFarm => 'Ferme inconnue';

  @override
  String get tndPerMeter => 'TND/m';

  @override
  String get enterPreferencesHint =>
      'Entrez vos préférences ou demandez une analyse...';

  @override
  String get laborMarketLabel => 'MARCHÉ DU TRAVAIL';

  @override
  String get specificationsLabel => 'Spécifications :';

  @override
  String get priceLabel => 'Prix';

  @override
  String get rateLabel => 'Taux';

  @override
  String get ratingLabel => 'Évaluation';

  @override
  String get closeButton => 'Fermer';

  @override
  String get estimatedDelivery => 'Livraison estimée';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get sellerLabel => 'Vendeur';

  @override
  String get cancellationReasonLabel => 'Raison d\'annulation';

  @override
  String get orderSummary => 'Récapitulatif de commande';

  @override
  String get arrivingSoon => 'Arrive bientôt';

  @override
  String etaMinutes(String mins) {
    return '~$mins min';
  }

  @override
  String etaHours(String hours, String mins) {
    return '~${hours}h ${mins}min';
  }

  @override
  String get driverNearby => 'Livreur à proximité !';

  @override
  String get onTheWay => 'En route';

  @override
  String get youLabel => 'Vous';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterNew => 'Nouveau';

  @override
  String get filterConfirmed => 'Confirmé';

  @override
  String get filterPreparing => 'En préparation';

  @override
  String get filterInTransit => 'En transit';

  @override
  String get filterDelivered => 'Livré';

  @override
  String get filterCancelled => 'Annulé';

  @override
  String get unknownCustomer => 'Client inconnu';

  @override
  String get orderLabel => 'Commande';

  @override
  String get manageButton => 'Gérer';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get addMore => 'Ajouter plus';

  @override
  String qtyUpdatedTo(String title, String qty) {
    return '$title — quantité mise à jour à $qty';
  }

  @override
  String get maximumStockReached => 'Stock maximum atteint';

  @override
  String pricePerUnit(String price, String unit) {
    return '$price TND / $unit';
  }

  @override
  String get premiumFeatureTitle => 'Fonctionnalité Premium';

  @override
  String get premiumFeatureDesc =>
      'Mettez à niveau votre abonnement pour débloquer cette fonctionnalité.';

  @override
  String get upgradeNow => 'Mettre à niveau';

  @override
  String upgradeRequiredDesc(String featureKey) {
    return 'Cette fonctionnalité ($featureKey) est disponible dans un plan premium. Mettez à niveau votre abonnement pour la débloquer.';
  }

  @override
  String get laterButton => 'Plus tard';

  @override
  String get myLandsTitle => 'Mes Terres';

  @override
  String get noLandsFound => 'Aucune terre trouvée';

  @override
  String get noLandsRented => 'Vous n\'avez encore loué aucune terre.';

  @override
  String get landActive => 'Actif';

  @override
  String get landInactive => 'Inactif';

  @override
  String get landsRented => 'Terres Louées';

  @override
  String get completenessLabel => 'Complétude';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get aboutLabel => 'À propos';

  @override
  String get directLinksLabel => 'Liens directs';

  @override
  String get websiteLabel => 'Site web';

  @override
  String farmyMemberSince(String date) {
    return 'Membre de la communauté Farmy depuis $date';
  }

  @override
  String get privacyRestricted => 'Accès restreint';

  @override
  String get profileNotFound => 'Profil introuvable ou privé';

  @override
  String get profileLoadError =>
      'Impossible de charger le profil. Vérifiez votre connexion.';

  @override
  String get retryButton => 'Réessayer';

  @override
  String upgradeForUnlimited(String plan) {
    return 'Passer$plan pour un accès illimité';
  }

  @override
  String get tapToViewPlans => 'Appuyez pour voir les plans →';

  @override
  String get assignTaskTitle => 'Assigner une tâche';

  @override
  String workersAvailable(String count) {
    return '$count Disponibles';
  }

  @override
  String get noTasksDefined => 'Aucune tâche définie pour cet élément.';

  @override
  String get noAvailableWorkers => 'Aucun travailleur disponible !';

  @override
  String get taskAssigned => 'Tâche assignée !';

  @override
  String get assignButton => 'Assigner';

  @override
  String get myTasksOnLand => 'Mes tâches sur cette terre';

  @override
  String get noPendingTasksHere => 'Aucune tâche en attente ici !';

  @override
  String get availableForAssignment =>
      'Vous êtes disponible pour des assignations.';

  @override
  String get taskCompleted =>
      'Tâche terminée ! Vous êtes maintenant disponible.';

  @override
  String get markCompleteButton => 'Marquer comme terminé';

  @override
  String get errorFetchingYourTasks =>
      'Erreur lors de la récupération de vos tâches';

  @override
  String get closeTip => 'Fermer';

  @override
  String get farmyStore => 'BOUTIQUE FARMY';

  @override
  String get nothingFoundHere => 'Rien trouvé ici';

  @override
  String get shopBack => 'RETOUR';

  @override
  String get shopVariants => 'VARIANTES';

  @override
  String get shopBuy => 'ACHETER';

  @override
  String get mustRentLand =>
      'Vous devez louer une terre pour acheter des articles.';

  @override
  String get selectLand => 'Sélectionner une terre';

  @override
  String get unknownLand => 'Terre inconnue';

  @override
  String get purchaseRequestSent =>
      'Demande envoyée ! Transaction enregistrée sur Hedera.';

  @override
  String get purchaseFailed => 'Achat échoué. Crédits insuffisants ?';

  @override
  String get topUpCredits => 'RECHARGER LES CRÉDITS';

  @override
  String get customAmount => 'Montant personnalisé';

  @override
  String maximumAmount(String max) {
    return 'Montant maximum : \$$max';
  }

  @override
  String creditsAdded(String amount) {
    return 'Ajout réussi de \$$amount !';
  }

  @override
  String get myInventory => 'MON INVENTAIRE';

  @override
  String get allLands => 'Toutes les terres';

  @override
  String get unknownLandFallback => 'Inconnu';

  @override
  String get tabAll => 'TOUT';

  @override
  String get tabPending => 'EN ATTENTE';

  @override
  String get tabApproved => 'APPROUVÉ';

  @override
  String get tabRejected => 'REJETÉ';

  @override
  String get noItemsFound => 'Aucun article trouvé';

  @override
  String noItemsFoundStatus(String status) {
    return 'Aucun article $status trouvé';
  }

  @override
  String get placedBadge => 'PLACÉ';

  @override
  String get itemActions => 'Actions sur l\'article';

  @override
  String get alreadyPlaced => 'Déjà placé';

  @override
  String get addToLand => 'Ajouter à la terre';

  @override
  String get wrongLand => 'Mauvaise terre';

  @override
  String get alreadyPlacedSubtitle => 'Cet article est déjà sur la carte.';

  @override
  String get wrongLandSubtitle => 'Cet article appartient à une autre terre.';

  @override
  String get buyMore => 'Acheter plus';

  @override
  String get failedToLoadData =>
      'Impossible de charger les données. Veuillez réessayer.';

  @override
  String get failedToLoadInventory =>
      'Impossible de charger l\'inventaire. Veuillez réessayer.';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonDesc =>
      'Cette fonctionnalité est en cours de développement. Vous pourrez bientôt placer des articles sur votre terre !';

  @override
  String get okButton => 'OK';

  @override
  String get gotItButton => 'Compris';

  @override
  String get placingItem => 'Placement de l\'article...';

  @override
  String get itemPlacedSuccess => 'Article placé avec succès !';

  @override
  String placingLabel(String name) {
    return 'Placement : $name';
  }

  @override
  String get loadingFootprint => 'Chargement de l\'empreinte...';

  @override
  String sizeLabel(String w, String h) {
    return 'Taille : ${w}x$h';
  }

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get failedToLoadFarm => 'Impossible de charger la ferme';

  @override
  String get goBackButton => 'Retour';

  @override
  String get menuWorkforce => 'Main-d\'œuvre';

  @override
  String get menuMyTasks => 'Mes tâches';

  @override
  String get menuAiAdvisor => 'Conseiller IA';

  @override
  String get menuInventory => 'Inventaire';

  @override
  String get menuShop => 'Boutique';

  @override
  String get menuExitGame => 'Quitter le jeu';

  @override
  String get mapTooltipInfo => 'Info';

  @override
  String get mapTooltipMove => 'Déplacer';

  @override
  String get mapTooltipTasks => 'Tâches';

  @override
  String placementFailed(String error) {
    return 'Échec du placement : $error';
  }

  @override
  String get placementFailedGeneric =>
      'Impossible de placer l\'article. Essayez ailleurs.';

  @override
  String daysAgo(String count) {
    return 'il y a ${count}j';
  }

  @override
  String get couldNotOpenHashScan => 'Impossible d\'ouvrir HashScan';

  @override
  String get setMonthlySalary => 'Définir le salaire mensuel';

  @override
  String get assign => 'Assigner';

  @override
  String get tasksLabelShort => 'Tâches';

  @override
  String get assignToLand => 'Assigner au terrain';

  @override
  String invitationSentTo(String worker) {
    return 'Invitation envoyée à $worker';
  }

  @override
  String get failedToSendInvitation => 'Échec de l\'envoi de l\'invitation';

  @override
  String get inviteWorker => 'Inviter un travailleur';

  @override
  String inviteWorkerMessage(String worker, String landName) {
    return 'Inviter $worker à $landName';
  }

  @override
  String get optionalMessageHint => 'Message optionnel...';

  @override
  String get sendInvite => 'Envoyer l\'invitation';

  @override
  String workerAssignedToLand(String worker, String landName) {
    return '$worker assigné à $landName';
  }

  @override
  String get failedToAssignWorker => 'Échec de l\'assignation du travailleur';

  @override
  String get directMessagingDescription =>
      'Description de la messagerie directe';

  @override
  String get readReviewsDescription => 'Description de la lecture des avis';

  @override
  String get messageWorker => 'Contacter le travailleur';

  @override
  String get viewReviews => 'Voir les avis';

  @override
  String get inviteToLand => 'Inviter sur le terrain';

  @override
  String amountPerHour(String amount) {
    return '$amount\$/h';
  }

  @override
  String get onTimeLabel => 'À l\'heure';

  @override
  String get disputesLabel => 'Litiges';

  @override
  String get skills => 'Compétences';

  @override
  String get about => 'À propos';

  @override
  String get performance => 'Performance';

  @override
  String get performanceGraphComingSoon =>
      'Graphique de performance bientôt disponible';

  @override
  String get manager => 'Manager';

  @override
  String get pendingLabel => 'En attente';

  @override
  String get inactiveLabel => 'Inactif';

  @override
  String get name => 'Nom';

  @override
  String get salary => 'Salaire';

  @override
  String get supervisor => 'Superviseur';

  @override
  String get landDetails => 'Détails du terrain';

  @override
  String amountPerMonth(String amount) {
    return '$amount\$/mois';
  }

  @override
  String get hourly => 'Horaire';

  @override
  String get listingPublished => 'Annonce publiée';

  @override
  String get listingPublishedHint =>
      'Votre annonce est maintenant visible publiquement.';

  @override
  String get continueLabelUpper => 'CONTINUER';

  @override
  String get failedToLoadProofs => 'Échec du chargement des preuves';

  @override
  String get aiVerifyingProof => 'L\'IA vérifie votre preuve...';

  @override
  String get proofVerifiedSuccessfully => 'Preuve vérifiée avec succès !';

  @override
  String get noProofRequestsFound => 'Aucune demande de preuve trouvée';

  @override
  String fromLabel(String name) {
    return 'De : $name';
  }

  @override
  String get investor => 'Investisseur';

  @override
  String toLabel(String name) {
    return 'À : $name';
  }

  @override
  String mustSubmitBefore(String date) {
    return 'Soumettre avant le $date';
  }

  @override
  String aiNotes(String notes) {
    return 'Notes IA : $notes';
  }

  @override
  String get submitPhotoProof => 'Soumettre une preuve photo';

  @override
  String get createNewTask => 'Créer une nouvelle tâche';

  @override
  String get taskTitle => 'Titre de la tâche';

  @override
  String get taskTitleHint => 'ex. Arroser les tomates';

  @override
  String get descriptionOptional => 'Description (Optionnel)';

  @override
  String get taskType => 'Type de tâche';

  @override
  String get rewardLabel => 'Récompense';

  @override
  String rewardAmountTnd(String amount) {
    return '$amount TND';
  }

  @override
  String get timeLabel => 'Temps';

  @override
  String get createTask => 'Créer la tâche';

  @override
  String get pleaseEnterTaskTitle => 'Veuillez entrer un titre';

  @override
  String get taskCreated => 'Tâche créée avec succès !';

  @override
  String tasksForLand(String landName) {
    return 'Tâches pour $landName';
  }

  @override
  String get open => 'Ouvert';

  @override
  String get done => 'Terminé';

  @override
  String get noTasksHere => 'Aucune tâche ici';

  @override
  String activeTasksCount(int count) {
    return '$count tâches actives';
  }

  @override
  String get activeTasksLabel => 'Tâches actives';

  @override
  String get farmerPro => 'Farmer Pro';

  @override
  String assignedTo(String name) {
    return 'Assigné à $name';
  }

  @override
  String get taskLimitReached => 'Limite de tâches atteinte';

  @override
  String taskLimitReachedMessage(String count) {
    return 'Vous ne pouvez avoir que $count tâches actives avec le plan gratuit.';
  }

  @override
  String get water => 'Arroser';

  @override
  String get harvest => 'Récolter';

  @override
  String get feed => 'Nourrir';

  @override
  String get install => 'Installer';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get inProgress => 'En cours';

  @override
  String get completed => 'Terminé';

  @override
  String get paymentFailedGeneric => 'Le paiement n\'a pas pu être effectué.';

  @override
  String paymentFailedWithError(String error) {
    return 'Paiement échoué : $error';
  }

  @override
  String get proofRequestedHint =>
      'Une demande de preuve a été envoyée au travailleur.';

  @override
  String get requestAIProof => 'Demander une preuve IA';

  @override
  String get noProofsRequestedUpper => 'AUCUNE PREUVE DEMANDÉE';

  @override
  String get requestProofHint =>
      'Demandez au travailleur de soumettre une preuve photographique de son travail.';

  @override
  String get removeWorker => 'Supprimer le travailleur';

  @override
  String get remove => 'Supprimer';

  @override
  String get workerRemovedSuccessfully => 'Travailleur supprimé avec succès';

  @override
  String get failedToRemoveWorker => 'Échec de la suppression du travailleur';

  @override
  String get systemErrorUpper => 'ERREUR SYSTÈME';

  @override
  String get retryConnectionUpper => 'RÉESSAYER LA CONNEXION';

  @override
  String get myInvestments => 'Mes investissements';

  @override
  String get rentalConfirmed => 'Location confirmée';

  @override
  String get rentalConfirmedDescription =>
      'Votre location a été confirmée et le matériel sera bientôt livré.';

  @override
  String get goToDashboardUpper => 'ALLER AU TABLEAU DE BORD';

  @override
  String get manageCards => 'Gérer les cartes';

  @override
  String get cardAddedSuccessfully => 'Carte ajoutée avec succès';

  @override
  String get cancelledOrFailedToAddCard =>
      'Annulé ou échec de l\'ajout de la carte.';

  @override
  String get allocatingSpatialResources =>
      'Allocation des ressources spatiales...';

  @override
  String get paymentFailedTryAgain => 'Paiement échoué. Veuillez réessayer.';

  @override
  String get paymentIssueHint =>
      'Un problème est survenu lors du traitement de votre paiement.';

  @override
  String get payNowUpper => 'PAYER MAINTENANT';

  @override
  String get pleaseSelectPaymentMethod =>
      'Veuillez sélectionner un mode de paiement';

  @override
  String get securingRental => 'Sécurisation de la location...';

  @override
  String get agreeToTermsAndPrivacy =>
      'J\'accepte les conditions et la politique de confidentialité';

  @override
  String get totalAmount => 'Montant total';

  @override
  String amountTND(String amount) {
    return '$amount TND';
  }

  @override
  String get duration => 'Durée';

  @override
  String nMonths(String count) {
    return '$count mois';
  }

  @override
  String get totalProject => 'Projet Total';

  @override
  String get walletCredits => 'Crédits du portefeuille';

  @override
  String get availableInstantPayment =>
      'Disponible pour un paiement instantané';

  @override
  String get monthlyRent => 'Loyer Mensuel';

  @override
  String get defaultMethod => 'Par défaut';

  @override
  String get savedCard => 'Carte enregistrée';

  @override
  String get changeAction => 'Modifier';

  @override
  String insufficientCredits(String amount) {
    return 'Crédits insuffisants: $amount disponible';
  }

  @override
  String get addPaymentMethod => 'Ajouter un mode de paiement';

  @override
  String balanceAmount(String amount) {
    return 'Solde: $amount TND';
  }

  @override
  String get startingFrom => 'À partir de';

  @override
  String get monthAbbreviation => 'mois';

  @override
  String monthsAbbreviation(String count) {
    return '$count mois';
  }

  @override
  String get paymentSecurity => 'Paiement sécurisé traité par Stripe.';

  @override
  String get availableUpper => 'DISPONIBLE';

  @override
  String organicPlotGrid(int w, int h) {
    return 'Parcelle biologique (grille ${w}x$h)';
  }

  @override
  String get checkout => 'Paiement';

  @override
  String get leaseStartDate => 'Date de début du bail';

  @override
  String get rentalDuration => 'Durée de location';

  @override
  String get failedToLoadRecords => 'Échec du chargement des enregistrements.';

  @override
  String get noBlockchainRecordsYet =>
      'Aucun enregistrement Blockchain pour le moment';

  @override
  String get makePurchaseImmutableRecordsHint =>
      'Effectuez un achat pour voir les enregistrements immuables ici.';

  @override
  String get pendingUpper => 'EN ATTENTE';

  @override
  String get rejectedUpper => 'REJETÉ';

  @override
  String get fetchingBlockchainRecords =>
      'Récupération des enregistrements blockchain...';

  @override
  String get transactionIdCopied =>
      'ID de transaction copié dans le presse-papiers';

  @override
  String get paidUpper => 'PAYÉ';

  @override
  String get approvedUpper => 'APPROUVÉ';

  @override
  String get rentalsLabel => 'Locations';

  @override
  String get purchasesLabel => 'Achats';

  @override
  String get hederaConsensusServiceUpper => 'SERVICE DE CONSENSUS HEDERA';

  @override
  String get proofSubmittedVerified =>
      'Preuve soumise et vérifiée avec succès.';

  @override
  String get hederaRegistryUpper => 'REGISTRE HEDERA';

  @override
  String get immutableOnChainRecords =>
      'Enregistrements immuables sur la chaîne';

  @override
  String get captureSubmit => 'Capturer et Soumettre';

  @override
  String get uploadingImage => 'Téléchargement de l\'image...';

  @override
  String get pleaseWaitAFewMoments => 'Veuillez patienter quelques instants...';

  @override
  String get orSelectAnItem => '[orSelectAnItem]';

  @override
  String itemIdUpper(String param) {
    return '[itemIdUpper]';
  }

  @override
  String gridPlots(int w, int h) {
    return '${w}x$h parcelles';
  }

  @override
  String get hireUpper => '[hireUpper]';

  @override
  String get size => '[size]';

  @override
  String get ownerLabel => '[ownerLabel]';

  @override
  String get draw => '[draw]';

  @override
  String get unknownItem => '[unknownItem]';

  @override
  String get moveAll => '[moveAll]';

  @override
  String plotNumber(String param) {
    return '[plotNumber]';
  }

  @override
  String get optimalSolarExposure => '[optimalSolarExposure]';

  @override
  String get cancelUpper => '[cancelUpper]';

  @override
  String get failedToRejectRequest => '[failedToRejectRequest]';

  @override
  String get hireWorkersUpper => '[hireWorkersUpper]';

  @override
  String get invalidGeometryAlert => '[invalidGeometryAlert]';

  @override
  String get activeTasks => '[activeTasks]';

  @override
  String get perTaskUpper => '[perTaskUpper]';

  @override
  String get analyzePortfolio => '[analyzePortfolio]';

  @override
  String get noPendingRequests => '[noPendingRequests]';

  @override
  String get heightAuto => '[heightAuto]';

  @override
  String rentAmountMonthly(String param) {
    return '[rentAmountMonthly]';
  }

  @override
  String get totalCapitalInvested => '[totalCapitalInvested]';

  @override
  String get currentLand => '[currentLand]';

  @override
  String get descriptionTooShort => '[descriptionTooShort]';

  @override
  String get landName => '[landName]';

  @override
  String get alreadyRentedUpper => '[alreadyRentedUpper]';

  @override
  String get requestRejectedRefunded => '[requestRejectedRefunded]';

  @override
  String get rejectionReasonPrompt => '[rejectionReasonPrompt]';

  @override
  String get negotiationsUpper => '[negotiationsUpper]';

  @override
  String get noWorkersFoundUpper => '[noWorkersFoundUpper]';

  @override
  String get unknownInvestor => '[unknownInvestor]';

  @override
  String hoursLeft(int count) {
    return '[hoursLeft]';
  }

  @override
  String get rentalSlotsUsage => '[rentalSlotsUsage]';

  @override
  String get selectAtLeast3Points => '[selectAtLeast3Points]';

  @override
  String get activeLabelUpper => '[activeLabelUpper]';

  @override
  String salaryAmountType(int amount, String type) {
    return '$amount / $type';
  }

  @override
  String get expiringSoon => '[expiringSoon]';

  @override
  String get checkBackLaterOpportunities => '[checkBackLaterOpportunities]';

  @override
  String get inactive => '[inactive]';

  @override
  String get endDateUpper => '[endDateUpper]';

  @override
  String farmerWithColon(String param) {
    return '[farmerWithColon]';
  }

  @override
  String get farmingActivity => '[farmingActivity]';

  @override
  String get noActiveFarmingActivities => '[noActiveFarmingActivities]';

  @override
  String get boundaries => '[boundaries]';

  @override
  String get noInvestmentsYet => '[noInvestmentsYet]';

  @override
  String get activeStatusUpper => '[activeStatusUpper]';

  @override
  String plotsCount(int w, int h) {
    return '[plotsCount]';
  }

  @override
  String get noPendingRequestsHint => '[noPendingRequestsHint]';

  @override
  String requestedDateUpper(String param) {
    return '[requestedDateUpper]';
  }

  @override
  String get priceCannotBeEmpty => '[priceCannotBeEmpty]';

  @override
  String get rentedUpper => '[rentedUpper]';

  @override
  String get rentalLimitReached => '[rentalLimitReached]';

  @override
  String get invitationUpdates => '[invitationUpdates]';

  @override
  String get priceStartingFrom => '[priceStartingFrom]';

  @override
  String get locationHighlights => '[locationHighlights]';

  @override
  String get amount => '[amount]';

  @override
  String get publishingFailed => '[publishingFailed]';

  @override
  String get securedWaterAccess => '[securedWaterAccess]';

  @override
  String get monthlyRentPriceTND => '[monthlyRentPriceTND]';

  @override
  String get geometryVerified => '[geometryVerified]';

  @override
  String landWithColon(String param) {
    return '[landWithColon]';
  }

  @override
  String get cannotPublishInvalidGeometry => '[cannotPublishInvalidGeometry]';

  @override
  String get retryUpper => '[retryUpper]';

  @override
  String get imageProofRequiredToApprove => '[imageProofRequiredToApprove]';

  @override
  String get sendProposalUpper => '[sendProposalUpper]';

  @override
  String get min => '[min]';

  @override
  String get pricePerMonth => '[pricePerMonth]';

  @override
  String get noActiveWorkersUpper => '[noActiveWorkersUpper]';

  @override
  String get reasonTooShort => '[reasonTooShort]';

  @override
  String get viewDetails => '[viewDetails]';

  @override
  String get proofsUpper => '[proofsUpper]';

  @override
  String get noActiveNegotiationsUpper => '[noActiveNegotiationsUpper]';

  @override
  String get plantCrops => '[plantCrops]';

  @override
  String get readyForActivityHint => '[readyForActivityHint]';

  @override
  String get irrigated => '[irrigated]';

  @override
  String get tryAdjustingFilters => '[tryAdjustingFilters]';

  @override
  String get occupiedUpper => '[occupiedUpper]';

  @override
  String get generalFarmingActivity => '[generalFarmingActivity]';

  @override
  String endsDate(String param) {
    return '[endsDate]';
  }

  @override
  String daysLeft(int count) {
    return '[daysLeft]';
  }

  @override
  String get hireActivateWorkersHint => '[hireActivateWorkersHint]';

  @override
  String get manageWorkers => '[manageWorkers]';

  @override
  String get onTime => '[onTime]';

  @override
  String removeWorkerConfirmation(String param) {
    return '[removeWorkerConfirmation]';
  }

  @override
  String get assignedLands => '[assignedLands]';

  @override
  String get limitReachedUpper => '[limitReachedUpper]';

  @override
  String get proofHistory => '[proofHistory]';

  @override
  String get farmerInvitations => '[farmerInvitations]';

  @override
  String get workforceUpper => '[workforceUpper]';

  @override
  String get descriptionRequired => '[descriptionRequired]';

  @override
  String get priceGreaterThanZero => '[priceGreaterThanZero]';

  @override
  String get saveChanges => '[saveChanges]';

  @override
  String get proofRequestQuestion => '[proofRequestQuestion]';

  @override
  String get rentalSlotsUsed => '[rentalSlotsUsed]';

  @override
  String get activeLands => '[activeLands]';

  @override
  String get widthAuto => '[widthAuto]';

  @override
  String get spatialDimensions => '[spatialDimensions]';

  @override
  String idLabel(String param) {
    return '[idLabel]';
  }

  @override
  String rentalExpires(String param) {
    return '[rentalExpires]';
  }

  @override
  String proofSubmissionHint(String param) {
    return '[proofSubmissionHint]';
  }

  @override
  String landPlotNumber(String param) {
    return '[landPlotNumber]';
  }

  @override
  String get messageOptionalUpper => '[messageOptionalUpper]';

  @override
  String get roiEst => '[roiEst]';

  @override
  String get paymentRequiredToActivate => '[paymentRequiredToActivate]';

  @override
  String get invalidNumericAmount => '[invalidNumericAmount]';

  @override
  String pointsDefined(int count) {
    return '$count points définis';
  }

  @override
  String nItemsSold(int count) {
    return '$count articles vendus';
  }

  @override
  String get itemVerification => '[itemVerification]';

  @override
  String get invalidGeometryHint => '[invalidGeometryHint]';

  @override
  String get declinedUpper => '[declinedUpper]';

  @override
  String get connectionError => '[connectionError]';

  @override
  String get startByListingPlot => '[startByListingPlot]';

  @override
  String get propertyDetails => '[propertyDetails]';

  @override
  String get invalidGeometry => '[invalidGeometry]';

  @override
  String get failedToLoadRequests => '[failedToLoadRequests]';

  @override
  String untilDate(String param) {
    return '[untilDate]';
  }

  @override
  String get drawInstructions => '[drawInstructions]';

  @override
  String get na => '[na]';

  @override
  String get noTasksAssignedHint => '[noTasksAssignedHint]';

  @override
  String get cannotPublishBoundaryConflicts =>
      '[cannotPublishBoundaryConflicts]';

  @override
  String get farmingActivities => '[farmingActivities]';

  @override
  String get listNewLand => '[listNewLand]';

  @override
  String get noApprovedWorkersUpper => '[noApprovedWorkersUpper]';

  @override
  String get expiredUpper => '[expiredUpper]';

  @override
  String get conflictDetected => '[conflictDetected]';

  @override
  String get rejectRequest => '[rejectRequest]';

  @override
  String get boundaryConflictAlert => '[boundaryConflictAlert]';

  @override
  String get requestProof => '[requestProof]';

  @override
  String get perHourUpper => '[perHourUpper]';

  @override
  String get exploreLands => '[exploreLands]';

  @override
  String get premiumFarmlandUpper => '[premiumFarmlandUpper]';

  @override
  String get newProposal => '[newProposal]';

  @override
  String get suspendedUpper => '[suspendedUpper]';

  @override
  String get aiPortfolioAnalysisHint => '[aiPortfolioAnalysisHint]';

  @override
  String get defineOnMap => '[defineOnMap]';

  @override
  String get itemUpper => '[itemUpper]';

  @override
  String amountPerType(String amount, String type) {
    return '[amountPerType]';
  }

  @override
  String get landDescriptionHint => '[landDescriptionHint]';

  @override
  String get autoFromBoundary => '[autoFromBoundary]';

  @override
  String get tryAgainUpper => '[tryAgainUpper]';

  @override
  String get landNameRequired => '[landNameRequired]';

  @override
  String get activeUpper => '[activeUpper]';

  @override
  String get hiringProposals => '[hiringProposals]';

  @override
  String get confirmReject => '[confirmReject]';

  @override
  String get movePoint => '[movePoint]';

  @override
  String get priceExceedsLimit => '[priceExceedsLimit]';

  @override
  String get egSalaryHint => '[egSalaryHint]';

  @override
  String hireWorkerUpper(String param) {
    return '[hireWorkerUpper]';
  }

  @override
  String get hiringProposalSent => '[hiringProposalSent]';

  @override
  String get entireLand => '[entireLand]';

  @override
  String get acceptedUpper => '[acceptedUpper]';

  @override
  String get fundsReleasedAfterVerification =>
      '[fundsReleasedAfterVerification]';

  @override
  String get enterRejectionReason => '[enterRejectionReason]';

  @override
  String get proofRequests => '[proofRequests]';

  @override
  String get enableVoiceInput => '[enableVoiceInput]';

  @override
  String get salaryAmountTNDUpper => '[salaryAmountTNDUpper]';

  @override
  String get unableToRetrieveLandDetails => '[unableToRetrieveLandDetails]';

  @override
  String get hourlyUpper => '[hourlyUpper]';

  @override
  String aiLandInvestmentHint(String param) {
    return '[aiLandInvestmentHint]';
  }

  @override
  String get askAiAnalyst => '[askAiAnalyst]';

  @override
  String get monthlyUpper => '[monthlyUpper]';

  @override
  String get activeContracts => '[activeContracts]';

  @override
  String get workerRespondedReviewCounterOffer =>
      '[workerRespondedReviewCounterOffer]';

  @override
  String get unlockUnlimitedSlotsInvestorPlus =>
      '[unlockUnlimitedSlotsInvestorPlus]';

  @override
  String get escrowBalance => '[escrowBalance]';

  @override
  String get pleaseEnterAName => '[pleaseEnterAName]';

  @override
  String get raiseLivestock => '[raiseLivestock]';

  @override
  String get noLandAssignments => '[noLandAssignments]';

  @override
  String get aiVerifyUpper => '[aiVerifyUpper]';

  @override
  String get requestExpired => '[requestExpired]';

  @override
  String get rejectUpper => '[rejectUpper]';

  @override
  String get landUpdatedSuccess => '[landUpdatedSuccess]';

  @override
  String get realTimeTaskNotificationsSoon => '[realTimeTaskNotificationsSoon]';

  @override
  String get approveUpper => '[approveUpper]';

  @override
  String untilDateUpper(String param) {
    return '[untilDateUpper]';
  }

  @override
  String get overlapsExistingLand => '[overlapsExistingLand]';

  @override
  String get itemRequests => '[itemRequests]';

  @override
  String get startDateUpper => '[startDateUpper]';

  @override
  String get generalLandProof => '[generalLandProof]';

  @override
  String get landNameTooShort => '[landNameTooShort]';

  @override
  String get verifiedUpper => '[verifiedUpper]';

  @override
  String minutesLeft(int count) {
    return '[minutesLeft]';
  }

  @override
  String get tapToDrawBoundaries => '[tapToDrawBoundaries]';

  @override
  String get directRoadAccess => '[directRoadAccess]';

  @override
  String invitationFrom(String param) {
    return '[invitationFrom]';
  }

  @override
  String get failedToLoadContracts => '[failedToLoadContracts]';

  @override
  String get verificationFailed => '[verificationFailed]';

  @override
  String get perimeterNotSet => '[perimeterNotSet]';

  @override
  String get requestApprovedItemPlaced => '[requestApprovedItemPlaced]';

  @override
  String get inviteWorkersMarketplaceHint => '[inviteWorkersMarketplaceHint]';

  @override
  String get landNameHint => '[landNameHint]';

  @override
  String get publishListing => '[publishListing]';

  @override
  String get hireApprovedWorkerNegotiationHint =>
      '[hireApprovedWorkerNegotiationHint]';

  @override
  String get request => '[request]';

  @override
  String get counterOfferUpper => '[counterOfferUpper]';

  @override
  String get proposedUpper => '[proposedUpper]';

  @override
  String get verificationSuccessful => '[verificationSuccessful]';

  @override
  String get rentLandToStartUpper => '[rentLandToStartUpper]';

  @override
  String get expiredLabel => '[expiredLabel]';

  @override
  String get salaryTypeUpper => '[salaryTypeUpper]';

  @override
  String get pleaseEnterRejectionReason => '[pleaseEnterRejectionReason]';

  @override
  String get negotiatingUpper => '[negotiatingUpper]';

  @override
  String get rentNowUpper => '[rentNowUpper]';

  @override
  String get noSpecialSkillsUpper => '[noSpecialSkillsUpper]';

  @override
  String get noLandAssignmentsHint => '[noLandAssignmentsHint]';
}
