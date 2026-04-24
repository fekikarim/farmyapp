// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get becomeAWorker => 'Become a Worker';

  @override
  String get joinTheWorkforce => 'Join the Workforce';

  @override
  String get joinWorkforceDescription =>
      'Create your professional profile and\nstart earning on nearby farms today.';

  @override
  String get selectYourSkills => 'Select Your Skills';

  @override
  String get aboutYou => 'About You';

  @override
  String get aboutYouHint => 'Tell farmers about your experience...';

  @override
  String get hourlyRateTnd => 'Hourly Rate (TND)';

  @override
  String get hourlyRateHint => 'e.g. 15.00';

  @override
  String get aiVerificationComingSoon => 'AI Verification Coming Soon';

  @override
  String get aiVerificationDescription =>
      'Automated identity & skill verification will speed up your approval.';

  @override
  String get createWorkerProfile => 'Create Worker Profile';

  @override
  String get selectAtLeastOneSkill => 'Please select at least one skill';

  @override
  String get workerProfileCreated =>
      '🎉 Worker profile created! Pending verification.';

  @override
  String get failedToCreateProfile => 'Failed to create profile';

  @override
  String get enterValidRate => 'Enter a valid rate';

  @override
  String get watering => 'Watering';

  @override
  String get harvesting => 'Harvesting';

  @override
  String get planting => 'Planting';

  @override
  String get animalCare => 'Animal Care';

  @override
  String get machineOperation => 'Machine Operation';

  @override
  String get soilManagement => 'Soil Management';

  @override
  String get structureInstallation => 'Structure Installation';

  @override
  String get qualityInspection => 'Quality Inspection';

  @override
  String get cropMonitoring => 'Crop Monitoring';

  @override
  String get pestControl => 'Pest Control';

  @override
  String get viewManageLandInvestments =>
      'View and manage your land investments';

  @override
  String get enableGameEdgePanel => 'Enable Game Edge Panel';

  @override
  String get accessFarmView => 'Access the 2.5D farm view';

  @override
  String get tasksProofs => 'Tasks & Proofs';

  @override
  String get aiProofRequests => 'AI Proof Requests';

  @override
  String get viewManageProofRequests => 'View and manage proof requests';

  @override
  String get freeTier => 'Free Tier';

  @override
  String get upgradePremium => 'Upgrade for premium features';

  @override
  String get freeForever => 'No expiration · Free forever';

  @override
  String validUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get editLandDetails => 'Edit Land Details';

  @override
  String get deleteLand => 'Delete Land';

  @override
  String get deleteLandTitle => 'Delete Land?';

  @override
  String deleteLandConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deleteLandActionWarning =>
      'This action cannot be undone. All associated data will be permanently removed.';

  @override
  String get landDeletedSuccess => 'Land deleted successfully';

  @override
  String get delete => 'Delete';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String featureOptimizedDescription(String feature) {
    return 'The \"$feature\" module is currently being optimized for personal farming management.';
  }

  @override
  String get stayTunedSpatialTracking =>
      'Stay tuned for advanced spatial asset tracking!';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get live => 'LIVE';

  @override
  String get failedToSyncBackend => 'Failed to sync with backend';

  @override
  String get externalProperty => 'EXTERNAL PROPERTY';

  @override
  String get notYours => 'NOT YOURS';

  @override
  String get dismiss => 'DISMISS';

  @override
  String get myLands => 'My Lands';

  @override
  String get landDataSyncSuccess => '✨ Land Data Synchronized Successfully!';

  @override
  String get limitReached => 'Limit Reached';

  @override
  String get newListing => 'New Listing';

  @override
  String get landLimitReachedTitle => 'Land Limit Reached';

  @override
  String landLimitReachedDescription(String planName) {
    return 'You\'ve used all land slots on your $planName plan. Upgrade to Farmer Pro to unlock unlimited lands!';
  }

  @override
  String get landSlotsUsed => 'Land Slots Used';

  @override
  String get synchronizingBoundaries => 'SYNCHRONIZING BOUNDARIES';

  @override
  String get fetchingSpatialData => 'Fetching precise spatial data...';

  @override
  String get syncInterrupted => 'Sync Interrupted';

  @override
  String get tryToResync => 'Try to Re-sync';

  @override
  String get noDescriptionProvided => 'No description provided for this land.';

  @override
  String get area => 'Area';

  @override
  String get rentals => 'Rentals';

  @override
  String get earnings => 'Earnings';

  @override
  String get safety => 'Safety';

  @override
  String get workforce => 'Workforce';

  @override
  String get active => 'ACTIVE';

  @override
  String get rented => 'RENTED';

  @override
  String get available => 'available';

  @override
  String owner(String id) {
    return 'Owner: $id';
  }

  @override
  String get myBasket => 'My Basket';

  @override
  String get clear => 'Clear';

  @override
  String get yourBasketIsEmpty => 'Your basket is empty';

  @override
  String get browseMarketplaceDescription =>
      'Browse the marketplace and add\nsome fresh products!';

  @override
  String get browseProducts => 'Browse Products';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tva => 'TVA (19%)';

  @override
  String get total => 'Total';

  @override
  String balanceWithCredits(String balance) {
    return 'Balance: $balance Credits';
  }

  @override
  String checkoutWithItems(int count) {
    return 'Checkout ($count items)';
  }

  @override
  String get insufficientFunds => 'Insufficient Funds';

  @override
  String insufficientFundsDescription(String balance, String total) {
    return 'Your balance is $balance Credits, but the total is $total TND.\n\nPlease top up your wallet.';
  }

  @override
  String get confirmPurchase => 'Confirm Purchase';

  @override
  String itemsCount(int count) {
    return '$count item(s)';
  }

  @override
  String includingTva(String tax) {
    return '(including 19% TVA: $tax TND)';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String itemsPurchasedSuccess(int count) {
    return '$count item(s) purchased successfully.';
  }

  @override
  String get trackOrder => 'Track Order';

  @override
  String get viewMyOrders => 'View My Orders';

  @override
  String get backToMarketplace => 'Back to Marketplace';

  @override
  String checkoutResultFeedback(int successCount, int failCount) {
    return '$successCount purchased, $failCount failed. Failed items remain in basket.';
  }

  @override
  String get clearBasketTitle => 'Clear Basket?';

  @override
  String get clearBasketDescription =>
      'This will remove all items from your basket.';

  @override
  String get clearAll => 'Clear All';

  @override
  String get twoFactorAuthentication => 'Two-Factor Authentication';

  @override
  String get verificationRequired => 'Verification Required';

  @override
  String get enter2faCode =>
      'Enter the 6-digit code from your authenticator app to continue.';

  @override
  String get verify => 'Verify';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get user => 'User';

  @override
  String get customerAccount => 'Customer Account';

  @override
  String get dailyInspiration => 'Daily Inspiration';

  @override
  String get workerPlus => 'Worker Plus';

  @override
  String get workerPlusDescription =>
      'Boost your profile, get priority matching, and instant withdrawals.';

  @override
  String get farmboxSubscription => 'FarmBox Subscription';

  @override
  String get farmboxDescription =>
      'Get fresh, locally grown vegetables delivered to your doorstep weekly!';

  @override
  String upgradeWithPrice(String price) {
    return 'Upgrade $price';
  }

  @override
  String get quote1 => 'The future of agriculture is in your hands.';

  @override
  String get quote2 => 'Support local, eat fresh, live healthy.';

  @override
  String get quote3 => 'Connecting you to the roots of your food.';

  @override
  String get quote4 => 'Every investment in nature yields the best interest.';

  @override
  String get quote5 => 'Small choices make a big impact on our planet.';

  @override
  String get quote6 => 'Fresh from the farm, straight to your table.';

  @override
  String get quote7 => 'Empowering farmers, feeding the world.';

  @override
  String get quote8 => 'Sustainability is not a goal, it\'s a lifestyle.';

  @override
  String get totalEarningsWallet => 'Total Earnings (Wallet)';

  @override
  String get totalSalesValue => 'Total Sales Value';

  @override
  String itemsSold(int count) {
    return '$count Items Sold';
  }

  @override
  String get advancedAnalytics => 'Advanced Analytics';

  @override
  String get premium => 'PREMIUM';

  @override
  String get unlockDeepInsights => 'Unlock Deep Insights';

  @override
  String get unlockDeepInsightsDescription =>
      'Get AI-powered crop forecasting, detailed soil health history, and advanced ROI projections.';

  @override
  String get productionStrategy => 'Production Strategy';

  @override
  String get productionStrategyDescription =>
      'Get a deep analysis of your current production overhead, potential yield, and profit-maximization strategies powered by AI.';

  @override
  String get consultProductionGuru => 'Consult Production Guru';

  @override
  String upgradeToPlan(String planName) {
    return 'Upgrade to $planName';
  }

  @override
  String get farmyUser => 'Farmy User';

  @override
  String get latestSubmittedProof => 'Latest Submitted Proof';

  @override
  String get free => 'FREE';

  @override
  String get pro => 'PRO';

  @override
  String get enabled => 'ENABLED';

  @override
  String get off => 'OFF';

  @override
  String buyProductConfirmation(String title, double price) {
    return 'Do you want to buy $title for $price credits?';
  }

  @override
  String get buy => 'Buy';

  @override
  String creditsCount(String count) {
    return 'Credits: $count';
  }

  @override
  String priceCountCredits(double price) {
    return '$price Credits';
  }

  @override
  String get buyNow => 'Buy Now';

  @override
  String get pleaseSelectProductType => 'Please select a product type';

  @override
  String get productUpdated => 'Product updated!';

  @override
  String get productListedSuccessfully => 'Product listed successfully!';

  @override
  String get failedToUpdateProduct => 'Failed to update product.';

  @override
  String get failedToListProduct => 'Failed to list product.';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get addProduct => 'Add Product';

  @override
  String get tapToAddImage => 'Tap to add image';

  @override
  String get title => 'Title';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get productType => 'Product Type';

  @override
  String get description => 'Description';

  @override
  String get priceCredits => 'Price (Credits)';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitHint => 'Unit (e.g., kg, liter, piece)';

  @override
  String get pleaseEnterUnit => 'Please enter a unit';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get listProduct => 'List Product';

  @override
  String get noCamerasFound => 'No cameras found on this device.';

  @override
  String get flipIdInstruction => 'Great! Now flip your ID over';

  @override
  String get selfieInstruction => 'Perfect! Now let\'s take a selfie';

  @override
  String get uploadingDocuments => 'Uploading documents...';

  @override
  String kycSuccess(String role) {
    return 'Success! You are now a $role!';
  }

  @override
  String get scanFrontId => 'Scan Front of ID';

  @override
  String get scanBackId => 'Scan Back of ID';

  @override
  String get takeSelfie => 'Take a Selfie';

  @override
  String get positionIdHint => 'Position your ID within the frame';

  @override
  String get flipIdHint => 'Flip your ID and scan the back';

  @override
  String get lookAtCameraHint => 'Look directly at the camera with eyes open';

  @override
  String get verifying => 'Verifying...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get accountBanned => 'Account Banned';

  @override
  String get bannedDescription =>
      'Your account has been suspended due to specific violations. Please contact support if you believe this is a mistake.';

  @override
  String get logout => 'Logout';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get noInternetDescription =>
      'We could not connect to the server. Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get askFarmingQuestion => 'Ask your farming question...';

  @override
  String get sendMessage => 'Send message';

  @override
  String get voiceInput => 'Voice input';

  @override
  String get rename => 'Rename';

  @override
  String get startANewConversation => 'Start a new conversation';

  @override
  String get createChatDescription =>
      'Create a chat to ask for practical farming guidance.';

  @override
  String get askAnythingAboutFarm => 'Ask anything about your farm';

  @override
  String get aiAssistantDescription =>
      'Planting times, crop health, fertilizers, and practical guidance with automatic language detection.';

  @override
  String get noChatStateTitle => 'Welcome to Farmy AI';

  @override
  String get noChatStateDescription =>
      'Start a new conversation to get expert advice on your agriculture.';

  @override
  String get disableVoiceInput => 'Disable voice input';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get muteVoiceOutput => 'Mute voice output';

  @override
  String get enableVoiceOutput => 'Enable voice output';

  @override
  String get moreActions => 'More actions';

  @override
  String get syncBackend => 'Sync backend';

  @override
  String get newChat => 'New chat';

  @override
  String get closeAssistant => 'Close assistant';

  @override
  String get syncingWithBackend => 'Syncing with backend...';

  @override
  String get backendDisconnected =>
      'Backend disconnected. Reconnecting automatically...';

  @override
  String get offlineModeCached =>
      'Offline mode: cached answers will be used when available.';

  @override
  String get noConversationsYet => 'No conversations yet.';

  @override
  String get conversations => 'Conversations';

  @override
  String get renameChat => 'Rename chat';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get chatTitle => 'Chat title';

  @override
  String get updateYourMessage => 'Update your message';

  @override
  String get resend => 'Resend';

  @override
  String get save => 'Save';

  @override
  String deleteChatConfirmation(String title) {
    return 'Delete \"$title\" permanently?';
  }

  @override
  String get responseCopied => 'Response copied to clipboard.';

  @override
  String get voiceInputNotAvailable =>
      'Voice input is not available on this device.';

  @override
  String get unableToStartVoiceInput =>
      'Unable to start voice input. Please check permissions.';

  @override
  String get voiceOutputMuted =>
      'Voice output is muted. Unmute to read this message.';

  @override
  String get messageNoReadableText => 'This message has no readable text.';

  @override
  String get unableToPlayVoiceOutput => 'Unable to play voice output now.';

  @override
  String get couldNotSendMessage =>
      'Could not send your message. Please try again.';

  @override
  String get upgradeRequired => 'Upgrade required to access this feature.';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get editAndResend => 'Edit and resend';

  @override
  String get copy => 'Copy';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get cached => 'Cached';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String verificationCodeSentTo(String email) {
    return 'We sent a 6-digit verification code to\n$email.';
  }

  @override
  String get verifyAccount => 'Verify Account';

  @override
  String get resendNewCode => 'Resend New Code';

  @override
  String get newVerificationCodeSent => 'New verification code sent!';

  @override
  String get failedToSendCode => 'Failed to send code. Try again.';

  @override
  String get yourEmail => 'your email';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String resettingPasswordFor(String email) {
    return 'Resetting password for $email';
  }

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get pleaseEnterAll6Digits => 'Please enter all 6 digits';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully! Please log in.';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we will send you a 6-digit code to reset your password.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get welcomeCustomerTitle => 'Welcome to Farmy!';

  @override
  String get welcomeCustomerSubtitle =>
      'Support local farmers and enjoy fresh, sustainable products directly from the source.';

  @override
  String get welcomeWorkerTitle => 'Join the Workforce';

  @override
  String get welcomeWorkerSubtitle =>
      'Connect with modern farms and start your productive journey in sustainable agriculture.';

  @override
  String get welcomeFarmerTitle => 'Empowering Farmers';

  @override
  String get welcomeFarmerSubtitle =>
      'Your journey to digital farm management starts here. Let\'s grow your business together!';

  @override
  String get welcomeInvestorTitle => 'Invest in the Future';

  @override
  String get welcomeInvestorSubtitle =>
      'Explore sustainable opportunities and grow your green agricultural portfolio with us.';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get continueText => 'Continue';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get spanish => 'Spanish';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get verified => 'Verified';

  @override
  String get unverified => 'Unverified';

  @override
  String get subscription => 'Subscription';

  @override
  String get payments => 'Payments';

  @override
  String get walletCards => 'Wallet & Cards';

  @override
  String get manageCredits => 'Manage credits and payment methods';

  @override
  String get hederaRegistry => 'Hedera Registry';

  @override
  String get viewBlockchainRecords => 'View your on-chain blockchain records';

  @override
  String get general => 'General';

  @override
  String get viewRecentActivity => 'View your recent activity and updates';

  @override
  String get security => 'Security';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get disable2fa => 'Disable 2FA';

  @override
  String get enable2fa => 'Enable 2FA';

  @override
  String get strongSecurityActive => 'Strong security active';

  @override
  String get addExtraSecurity => 'Add an extra layer of security';

  @override
  String get orders => 'Orders';

  @override
  String get trackManagePurchases => 'Track and manage your purchases';

  @override
  String get verification => 'Verification';

  @override
  String get becomeFarmer => 'Become a Farmer';

  @override
  String get startSellingProduce => 'Start selling your produce';

  @override
  String get becomeInvestor => 'Become an Investor';

  @override
  String get investSustainableFarming => 'Invest in sustainable farming';

  @override
  String get worker => 'Worker';

  @override
  String get becomeWorker => 'Become a Worker';

  @override
  String get offerSkillsFarms => 'Offer your skills on farms';

  @override
  String get workerDashboard => 'Worker Dashboard';

  @override
  String get viewAssignmentsTasks => 'View your assignments & tasks';

  @override
  String get gameFeatures => 'Game Features';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get aboutUs => 'About Us - Farmy Team';

  @override
  String get featureUnderDevelopment =>
      'This feature is currently under development.';

  @override
  String get home => 'Home';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get settings => 'Settings';

  @override
  String get analytics => 'Analytics';

  @override
  String get land => 'Land';

  @override
  String get products => 'Products';

  @override
  String get myFarms => 'My Farms';

  @override
  String get explore => 'Explore';

  @override
  String get investments => 'Investments';

  @override
  String get revenue => 'Revenue';

  @override
  String get tasks => 'Tasks';

  @override
  String get openInvestmentAssistant => 'Open investment assistant';

  @override
  String get openAiAssistant => 'Open AI assistant';

  @override
  String get myWorkerTasks => 'My Worker Tasks';

  @override
  String unknownRole(String role) {
    return 'Unknown role: $role';
  }

  @override
  String get appTitle => 'Farmy';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get welcomeToFarmy => 'Welcome to Farmy';

  @override
  String get signInToFarmyAccount => 'Sign in to your Farmy account';

  @override
  String get startJourneyWithFarmy => 'Start your journey with Farmy today';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signingUp => 'Signing up...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get orContinueWith => 'OR CONTINUE WITH';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get signupFailed => 'Signup Failed';

  @override
  String get signIn => 'Sign In';

  @override
  String get ok => 'OK';

  @override
  String get myProducts => 'My Products';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String deleteProductConfirmation(String title) {
    return 'Are you sure you want to delete $title?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get failedToDeleteProduct => 'Failed to delete product';

  @override
  String get analyzeInventory => 'Analyze Inventory';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get addProductFirst => 'Add your first product to see it here!';

  @override
  String get edit => 'Edit';

  @override
  String get credits => 'Credits';

  @override
  String get productLimitReached => 'Product Limit Reached';

  @override
  String get viewPlans => 'VIEW PLANS';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get oopsSomethingWentWrong => 'Oops! Something went wrong';

  @override
  String get productListingsUsed => 'Product Listings Used';

  @override
  String get upgradePlanName => 'Farmer Pro';

  @override
  String get analyzeInventoryPrompt =>
      'Analyse my current product inventory. Are these good products to hold or should I focus on something else based on the market?';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String productLimitMessage(String planName) {
    return 'You\'ve used all product slots on your $planName plan. Upgrade to Farmer Pro or Investor Plus to list more products!';
  }

  @override
  String get workerMarketplace => 'Worker Marketplace';

  @override
  String get searchWorkers => 'Search workers...';

  @override
  String get noVerifiedWorkersFound => 'No verified workers found';

  @override
  String tasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get perHour => '/hour';

  @override
  String workforceLandName(String landName) {
    return 'Workforce — $landName';
  }

  @override
  String get addWorker => 'Add Worker';

  @override
  String get inviteExistingWorker => 'Invite Existing Worker';

  @override
  String get searchWorkerMarketplace => 'Search the worker marketplace';

  @override
  String get openJobRequest => 'Open Job Request';

  @override
  String get soon => 'Soon';

  @override
  String get totalLabel => 'Total';

  @override
  String get activeLabel => 'Active';

  @override
  String get suspendedLabel => 'Suspended';

  @override
  String get monthlyCost => 'Monthly Cost';

  @override
  String get productivity => 'Productivity';

  @override
  String totalSuffix(int count) {
    return '$count total';
  }

  @override
  String get noWorkersYet => 'No workers yet';

  @override
  String get addWorkersMarketplaceHint =>
      'Tap the + button to add workers from the marketplace';

  @override
  String get unknownWorker => 'Unknown Worker';

  @override
  String get tndMo => 'TND/mo';

  @override
  String get workersSyncIssue => 'Workers sync issue';

  @override
  String get invitationsSyncIssue => 'Invitations sync issue';

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get waitingForWorkerResponse => 'Waiting for worker response';

  @override
  String get invitationDecisions => 'Invitation Decisions';

  @override
  String get workersAcceptedDeclinedInvites =>
      'Workers who accepted or declined your invites';

  @override
  String get aiAutoAssignTasks => '🤖 AI Auto-Assign Tasks';

  @override
  String get gpsVerifiedWorkProof => '📍 GPS-verified Work Proof';

  @override
  String get iotSensorDashboard => '🌡️ IoT Sensor Dashboard';

  @override
  String get smartPayrollIntegration => '💰 Smart Payroll Integration';

  @override
  String get freshProductsFarmers => 'Fresh products from local farmers';

  @override
  String get myOrders => 'My Orders';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get all => 'All';

  @override
  String get noProductsFoundMarketplace => 'No products found';

  @override
  String get noProductsAvailableMarketplace => 'No products available';

  @override
  String get adjustSearchFilters => 'Try adjusting your search or filters';

  @override
  String get checkBackLaterFreshProducts =>
      'Check back later for fresh products';

  @override
  String get outOfStock => 'OUT OF STOCK';

  @override
  String get inBasket => 'In basket';

  @override
  String availableCount(int count, String unit) {
    return '$count $unit available';
  }

  @override
  String subtotalLabel(String price) {
    return 'Subtotal: $price TND';
  }

  @override
  String get seller => 'Seller';

  @override
  String get farmer => 'Farmer';

  @override
  String get verifiedSeller => 'Verified Seller';

  @override
  String get updateBasket => 'Update Basket';

  @override
  String get addToBasket => 'Add to Basket';

  @override
  String qtySetTo(String title, int qty) {
    return '$title — qty set to $qty';
  }

  @override
  String addedToBasket(String title) {
    return '$title added to basket';
  }

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get orderHistoryEmptyHint =>
      'Your order history will appear here\nafter your first purchase.';

  @override
  String get order => 'Order';

  @override
  String get farmyPremium => 'Farmy Premium';

  @override
  String currentPlanLabel(String name) {
    return 'Current: $name';
  }

  @override
  String get monthly => 'Monthly';

  @override
  String get yearlySave => 'Yearly (Save 33%)';

  @override
  String get failedToLoadSubscriptions => 'Failed to load subscriptions';

  @override
  String get failedToLoadWorkerProfile => 'Failed to load worker profile';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get upgradeToYearly => 'Upgrade to Yearly';

  @override
  String get switchToMonthly => 'Switch to Monthly';

  @override
  String get downgradeToFree => 'Downgrade to Free';

  @override
  String get getStarted => 'Get Started';

  @override
  String activeOnCycle(String cycle) {
    return 'Active on $cycle';
  }

  @override
  String get confirmDowngrade => 'Confirm Downgrade';

  @override
  String downgradeWarning(String name) {
    return 'Are you sure you want to downgrade to $name? You will lose your premium features and active perks associated with your current plan.';
  }

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String totalWithCycle(String price, String cycle) {
    return 'Total: \$$price · $cycle';
  }

  @override
  String get payWithCredits => 'Pay with Farmy Credits';

  @override
  String get loadingBalance => 'Loading balance...';

  @override
  String balanceValue(String amount) {
    return 'Balance: \$$amount';
  }

  @override
  String get payWithStripe => 'Pay with Card (Stripe)';

  @override
  String get secureCreditCardPayment => 'Secure credit card payment';

  @override
  String get unableToLoadTracking => 'Unable to load tracking';

  @override
  String get noTrackingInformation => 'No tracking information';

  @override
  String get deliveryTrackingEmptyHint =>
      'Delivery tracking will appear\nonce your order is processed.';

  @override
  String get orderDelivered => 'Order Delivered!';

  @override
  String get orderDeliveredSuccess =>
      'Your order has been successfully delivered. Thank you for your purchase!';

  @override
  String get updating => 'Updating';

  @override
  String get profileSyncIssue => 'Profile sync issue';

  @override
  String get assignedLandsUnavailable => 'Assigned lands unavailable';

  @override
  String get tasksUnavailable => 'Tasks unavailable';

  @override
  String get invitationsUnavailable => 'Invitations unavailable';

  @override
  String get contractsUnavailable => 'Contracts unavailable';

  @override
  String get proofsUnavailable => 'Proofs unavailable';

  @override
  String get viewAllHistory => 'View All History';

  @override
  String get noLandAssignmentsYet => 'No land assignments yet';

  @override
  String get landAssignmentsEmptyHint => 'You\'ll see your assigned lands here';

  @override
  String get noTasksAssigned => 'No tasks assigned';

  @override
  String get tasksEmptyHint => 'Tasks will appear here when assigned';

  @override
  String get notifications => 'Notifications';

  @override
  String get realtimeNotificationsSoon =>
      'Real-time task notifications coming soon';

  @override
  String get verifiedWorker => 'Verified Worker';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get invitationAcceptedSuccess => 'Invitation accepted successfully.';

  @override
  String get invitationDeclinedSuccess => 'Invitation declined successfully.';

  @override
  String get unableToProcessInvitation =>
      'Unable to process invitation response.';

  @override
  String get landBoundary => 'Land Boundary';

  @override
  String get landInformation => 'Land Information';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get grid => 'Grid';

  @override
  String get assignmentRole => 'Assignment Role';

  @override
  String get salaryLabel => 'Salary';

  @override
  String salaryValue(String amount) {
    return '\$$amount / month';
  }

  @override
  String get assignmentStatus => 'Assignment Status';

  @override
  String get farmerProfileUnavailable =>
      'Farmer profile is unavailable right now.';

  @override
  String get unableToOpenFarmerProfile =>
      'Unable to open farmer profile. Please retry.';

  @override
  String get invitationApproved => 'Invitation Approved';

  @override
  String get invitationPending => 'Invitation Pending';

  @override
  String get invitationDeclined => 'Invitation Declined';

  @override
  String get invitationExpired => 'Invitation Expired';

  @override
  String get assigned => 'Assigned';
}
