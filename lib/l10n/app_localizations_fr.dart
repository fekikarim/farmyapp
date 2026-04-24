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
  String get area => 'Surface';

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
  String itemsSold(int count) {
    return '$count Articles vendus';
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
    return 'Mettre à niveau vers $planName';
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
  String get upgradeRequired =>
      'Mise à jour requise pour accéder à cette fonctionnalité.';

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
  String get appTitle => 'Farmy';

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
  String get cancel => 'Annuler';

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
  String get viewPlans => 'VOIR LES PLANS';

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
  String get outOfStock => 'EN RUPTURE DE STOCK';

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
  String get payWithCredits => 'Payer avec les crédits Farmy';

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
  String get landBoundary => 'Limite de la Terre';

  @override
  String get landInformation => 'Informations sur la Terre';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible';

  @override
  String get grid => 'Grille';

  @override
  String get assignmentRole => 'Rôle d\'Affectation';

  @override
  String get salaryLabel => 'Salaire';

  @override
  String salaryValue(String amount) {
    return '$amount \$ / mois';
  }

  @override
  String get assignmentStatus => 'Statut de l\'Affectation';

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
  String get invitationDeclined => 'Invitation Déclinée';

  @override
  String get invitationExpired => 'Invitation Expirée';

  @override
  String get assigned => 'Assigné';
}
