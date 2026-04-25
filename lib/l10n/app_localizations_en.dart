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
  String get itemsSold => 'Items Sold';

  @override
  String nTasksUpper(int count) {
    return '$count TASKS';
  }

  @override
  String minutesCount(int count) {
    return '${count}m';
  }

  @override
  String hoursCount(int count) {
    return '${count}h';
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
  String get upgradeRequired => 'Upgrade Required';

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
  String get appName => 'Farmy';

  @override
  String get unknown => 'Unknown';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get revenueTitle => 'Revenue';

  @override
  String get cancel => 'Cancel';

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
  String get viewPlans => 'View Plans';

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

  @override
  String get acceptThisOfferQuestion => 'Accept this offer?';

  @override
  String acceptOfferConfirmation(String amount, String type) {
    return 'You are about to accept the offer of \$$amount $type. This will establish a legal contract.';
  }

  @override
  String get contractApproved =>
      'Contract approved! Waiting for investor payment.';

  @override
  String get failedToAccept => 'Failed to accept offer.';

  @override
  String get declineThisOfferQuestion => 'Decline this offer?';

  @override
  String declineOfferConfirmation(String name) {
    return 'Are you sure you want to decline the offer from $name?';
  }

  @override
  String get theInvestor => 'the investor';

  @override
  String get contractDeclined => 'Contract offer declined.';

  @override
  String get failedToDecline => 'Failed to decline offer.';

  @override
  String get pleaseEnterAMessage => 'Please enter a message';

  @override
  String get pleaseEnterValidSalary => 'Please enter a valid salary amount';

  @override
  String get counterOfferSent => 'Counter-offer sent successfully!';

  @override
  String get failedToSendCounterOffer => 'Failed to send counter-offer.';

  @override
  String get messageCannotBeEmpty => 'Message cannot be empty';

  @override
  String get messageUpdated => 'Message updated successfully';

  @override
  String get failedToEditMessage => 'Failed to update message';

  @override
  String get withdrawMessageQuestion => 'Withdraw this message?';

  @override
  String get withdrawMessageConfirmation =>
      'This will permanently remove your last negotiation message.';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get messageWithdrawn => 'Message withdrawn';

  @override
  String get failedToWithdrawMessage => 'Failed to withdraw message';

  @override
  String investorAcceptOfferConfirmation(
    String name,
    String amount,
    String type,
  ) {
    return 'You are about to accept $name\'s counter-offer of \$$amount $type. Once accepted, you must pay the first month\'s salary to activate the contract.';
  }

  @override
  String get theWorker => 'the worker';

  @override
  String get offerAcceptedProceedToPayment =>
      'Offer accepted! Please proceed to payment to activate the contract.';

  @override
  String get declineNegotiationQuestion => 'Decline negotiation?';

  @override
  String declineNegotiationConfirmation(String name) {
    return 'Are you sure you want to decline further negotiations with $name?';
  }

  @override
  String get thisWorker => 'this worker';

  @override
  String get negotiationDeclined => 'Negotiation declined and closed.';

  @override
  String get failedToCreatePayment => 'Failed to create payment intent.';

  @override
  String get contractActivated => 'Contract activated successfully!';

  @override
  String get invalidPaymentData =>
      'Invalid payment data received from server. Please try again.';

  @override
  String get paymentSubmittedHint =>
      'Payment submitted. The contract will be activated once confirmed.';

  @override
  String get paymentCancelled => 'Payment was cancelled.';

  @override
  String contractForWorker(String name) {
    return 'Contract for $name';
  }

  @override
  String get negotiationDeclinedBanner => 'Negotiation Declined';

  @override
  String get contractTerminatedBanner => 'Contract Terminated';

  @override
  String get contractExpiredBanner => 'Contract Expired';

  @override
  String contractIsStatus(String status) {
    return 'This contract is $status';
  }

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startNegotiationHint =>
      'Start the negotiation by sending a message.';

  @override
  String get systemOfferAccepted => 'Offer accepted. Proceeding to payment.';

  @override
  String get systemOfferDeclined =>
      'Offer declined. This negotiation has been cancelled.';

  @override
  String get you => 'You';

  @override
  String get otherParty => 'Other party';

  @override
  String proposedSalaryAmount(String amount) {
    return 'Proposed Salary: \$$amount';
  }

  @override
  String get editingYourMessage => 'Editing your message';

  @override
  String get editYourMessageHint => 'Edit your message...';

  @override
  String get salaryOptional => 'Salary (optional)';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(String mins) {
    return '$mins min ago';
  }

  @override
  String hoursAgo(String hours) {
    return '${hours}h ago';
  }

  @override
  String get negotiateTerms => 'Negotiate Terms';

  @override
  String get salaryAmount => 'Salary Amount';

  @override
  String get addAMessageHint => 'Add a message...';

  @override
  String get counter => 'Counter';

  @override
  String get counterOffer => 'Counter-offer';

  @override
  String payAmountToActivate(String amount) {
    return 'Pay \$$amount to Activate';
  }

  @override
  String get hiringPending => 'Hiring Pending';

  @override
  String get negotiating => 'Negotiating';

  @override
  String get awaitingPayment => 'Awaiting Payment';

  @override
  String get negotiate => 'Negotiate';

  @override
  String get perTask => 'per task';

  @override
  String squareMeters(int count) {
    return '$count m²';
  }

  @override
  String amountPrefix(String amount) {
    return '\$$amount';
  }

  @override
  String get terminatedLabel => 'Terminated';

  @override
  String get hourlyLabel => 'per hour';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get contract => 'Contract';

  @override
  String get paymentFailedCancelled => 'Payment failed or cancelled.';

  @override
  String get farmerInfoSyncedFromAssignment =>
      'Information synced from assignment';

  @override
  String get tapToViewProfile => 'Tap to view profile';

  @override
  String salaryPerMonth(String amount) {
    return '\$$amount / month';
  }

  @override
  String get revenueAnalysisPrompt =>
      'Analyze my revenue sources and suggest ways to maximize my profits based on current market trends.';

  @override
  String get analyzeRevenueTooltip => 'Analyze Revenue';

  @override
  String get totalDetailsRevenue => 'Total Details Revenue';

  @override
  String get creditsLabel => 'Credits';

  @override
  String get productSales => 'Product Sales';

  @override
  String get unitsLabel => 'Units';

  @override
  String get investmentRevenue => 'Investment Revenue';

  @override
  String get viewInvestmentBreakdown =>
      'View detailed breakdown in Investments';

  @override
  String get portfolioInsights => 'Portfolio Insights';

  @override
  String get premiumLabel => 'PREMIUM';

  @override
  String get unlockPortfolioMaster => 'Unlock Portfolio Master';

  @override
  String get premiumPortfolioDesc =>
      'Get real-time ROI tracking, automated dividend reports, and AI-powered investment advice.';

  @override
  String get investorPlus => 'Investor Plus';

  @override
  String get portfolioAnalyticsLoading => 'Portfolio Analytics Loading...';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get createNewPassword => 'Create a new password';

  @override
  String get passwordPolicyHint =>
      'Your new password must be different from previous used passwords.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPasswordError => 'Please enter your current password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String profileSyncFailed(String error) {
    return 'Failed to sync profile: $error';
  }

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesDesc =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get discard => 'Discard';

  @override
  String get waitUsernameCheck => 'Please wait for username availability check';

  @override
  String get correctErrorsInForm => 'Please correct the errors in the form';

  @override
  String get usernameTaken => 'This username is already taken';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get changeProfilePicture => 'Change Profile Picture';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get identityTab => 'Identity';

  @override
  String get trustTab => 'Trust';

  @override
  String get rolePrivacyTab => 'Role & Privacy';

  @override
  String get saveChangesTooltip => 'Save Changes';

  @override
  String get profileCompleteness => 'Profile Completeness';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameTooShort => 'Name is too short';

  @override
  String get onlyLettersAllowed => 'Only letters and spaces allowed';

  @override
  String get usernameLabel => 'Username';

  @override
  String get publicUniqueHandle => 'Public unique handle';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get tooShortMin3 => 'Too short (min 3)';

  @override
  String get usernameFormatError => 'Use lowercase, numbers, dots, underscores';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get invalidPhoneFormat => 'Invalid phone format';

  @override
  String get countryLabel => 'Country';

  @override
  String get cityLabel => 'City';

  @override
  String get headlineLabel => 'Headline';

  @override
  String get headlineHint => 'A short description of what you do';

  @override
  String get aboutMe => 'About Me';

  @override
  String get portfolioLinks => 'Portfolio & Links';

  @override
  String get linkedinProfile => 'LinkedIn Profile';

  @override
  String get linkedinUrlError => 'Enter a valid LinkedIn URL or handle';

  @override
  String get personalWebsite => 'Personal Website';

  @override
  String get websiteUrlError => 'Enter a valid website URL';

  @override
  String get farmerDetailsTitle => 'Farmer Details';

  @override
  String get businessFarmName => 'Business/Farm Name';

  @override
  String get investorDetailsTitle => 'Investor Details';

  @override
  String get expectedBudgetRange => 'Expected Budget Range';

  @override
  String get budgetRangeHint => 'e.g. \$10,000 - \$50,000';

  @override
  String get privacyControls => 'Privacy Controls';

  @override
  String get discoverableMarketplace => 'Discoverable in Marketplace';

  @override
  String get discoverableSubtitle => 'Let others find and view your profile';

  @override
  String get showContactInfoLabel => 'Show Contact Info';

  @override
  String get showContactInfoSubtitle =>
      'Make phone and email visible to connections';

  @override
  String get failedInitiate2FA => 'Failed to initiate 2FA setup';

  @override
  String get twoFAEnabledSuccess => '2FA enabled successfully';

  @override
  String get twoFADisabledSuccess => '2FA disabled successfully';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get disable2FA => 'Disable 2FA';

  @override
  String get enable2FA => 'Enable 2FA';

  @override
  String get secureYourAccount => 'Secure Your Account';

  @override
  String get twoFADesc =>
      'Two-factor authentication adds an extra layer of security to your account. To log in, you will need to provide a 6-digit code from your authenticator app.';

  @override
  String get startSetup => 'Start Setup';

  @override
  String get linkYourAppStep => 'Step 1: Link your app';

  @override
  String get scanQRCodeDesc =>
      'Scan this QR code with your Authenticator App (Google Authenticator, Authy, etc.)';

  @override
  String get enterCodeManually => 'Or enter this code manually:';

  @override
  String get copyToClipboardTooltip => 'Copy to clipboard';

  @override
  String get confirmEnablementStep => 'Step 2: Confirm Enablement';

  @override
  String get enter6DigitCodeConfirm =>
      'Enter the 6-digit code from your app to confirm:';

  @override
  String get backButton => 'Back';

  @override
  String get enter6DigitCodeDisable =>
      'Enter the 6-digit code from your authenticator app to disable two-factor authentication.';

  @override
  String get allNotificationsMarkedRead => 'All notifications marked as read';

  @override
  String get failedToDeleteNotification => 'Failed to delete notification';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsReadTooltip => 'Mark all as read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get premiumAccess => 'Premium Access';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get subscriptionHeadline =>
      'Select a plan to unlock the full Farmy experience.\nOne subscription opens every door.';

  @override
  String get yearly => 'Yearly';

  @override
  String get alwaysFree => 'Always Free';

  @override
  String get freeLabel => 'Free';

  @override
  String get monthlySuffix => '/mo';

  @override
  String get yearlySuffix => '/yr';

  @override
  String savingsLabel(String oldPrice, String savings) {
    return 'Was $oldPrice/yr — save $savings';
  }

  @override
  String get continueWithFree => 'Continue with Free';

  @override
  String getPlan(String planName) {
    return 'Get $planName';
  }

  @override
  String paymentSummary(String price, String cycle, String planName) {
    return '$price · $cycle · $planName';
  }

  @override
  String balanceStatusSuccess(String amount) {
    return 'Balance: $amount ✓';
  }

  @override
  String balanceStatusInsufficient(String amount) {
    return 'Balance: $amount — Insufficient';
  }

  @override
  String get payWithCardStripe => 'Pay with Card (Stripe)';

  @override
  String get secureCardPaymentDesc => 'Secure credit / debit card payment';

  @override
  String get failedLoadPlans => 'Failed to load plans';

  @override
  String get noPlansAvailable => 'No plans available';

  @override
  String get contactSupport => 'Please contact support.';

  @override
  String get paymentPendingVerifying =>
      'Payment submitted. We are verifying it in the background.';

  @override
  String get paymentProcessingSync =>
      'Payment is still processing. Your subscription will sync automatically.';

  @override
  String get paymentStatusDelay =>
      'Payment status check is delayed. We will keep syncing in the background.';

  @override
  String paymentError(String error) {
    return 'Payment Error: $error';
  }

  @override
  String get deliveriesTitle => 'Deliveries';

  @override
  String get ordersTitle => 'Orders';

  @override
  String totalCount(String total) {
    return '$total total';
  }

  @override
  String get totalOrdersLabel => 'Total Orders';

  @override
  String get deliveredLabel => 'Delivered';

  @override
  String get noDeliveriesYet => 'No deliveries yet';

  @override
  String get noDeliveriesDesc =>
      'Deliveries for your products will\nappear here when customers order.';

  @override
  String get manageDeliveryTitle => 'Manage Delivery';

  @override
  String get deliveryNotFound => 'Delivery not found';

  @override
  String get deliveryTimeline => 'Delivery Timeline';

  @override
  String get updateStatus => 'Update Status';

  @override
  String etaLabel(String time) {
    return 'ETA: $time';
  }

  @override
  String get orderDetails => 'Order Details';

  @override
  String get productLabel => 'Product';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get orderIdLabel => 'Order ID';

  @override
  String get customerLabel => 'Customer';

  @override
  String get deliveryInfo => 'Delivery Info';

  @override
  String get addressLabel => 'Address';

  @override
  String get createdLabel => 'Created';

  @override
  String get startedLabel => 'Started';

  @override
  String get cancelDeliveryQuestion => 'Cancel Delivery?';

  @override
  String updateToStatusQuestion(String status) {
    return 'Update to $status?';
  }

  @override
  String get cancelNotifyCustomer =>
      'This will cancel the delivery and notify the customer.';

  @override
  String advanceNotifyCustomer(String status) {
    return 'This will advance the delivery to \"$status\" and notify the customer.';
  }

  @override
  String get cancellationReasonHint => 'Reason for cancellation...';

  @override
  String get addNoteHint => 'Add a note (optional)...';

  @override
  String get confirmUpdate => 'Confirm';

  @override
  String get cancelDeliveryAction => 'Cancel Delivery';

  @override
  String statusUpdatedTo(String status) {
    return 'Status updated to $status';
  }

  @override
  String get failedUpdateStatus => 'Failed to update status';

  @override
  String moveToStatus(String status) {
    return 'Move to $status';
  }

  @override
  String get successfullyDelivered => 'Successfully Delivered';

  @override
  String get deliveryCancelled => 'Delivery Cancelled';

  @override
  String completedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String dateTimeAt(String date, String time) {
    return '$date at $time';
  }

  @override
  String get cardAddedSuccess => 'Card added successfully';

  @override
  String get failedAddCard => 'Failed to add card';

  @override
  String get addCreditsTitle => 'Add Credits';

  @override
  String get selectAmount => 'Select Amount';

  @override
  String get customAmountLabel => 'Custom Amount';

  @override
  String get maxAmountError => 'Maximum amount is \$999,999.99';

  @override
  String payAmount(String amount) {
    return 'PAY \$$amount';
  }

  @override
  String get enterAmount => 'ENTER AMOUNT';

  @override
  String successfullyAddedCredits(String amount) {
    return 'Successfully added \$$amount';
  }

  @override
  String priceTnd(String price) {
    return '$price TND';
  }

  @override
  String get failedAddCredits => 'Failed to add credits';

  @override
  String get walletPaymentsTitle => 'Wallet & Payments';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String expiresLabel(String expiry) {
    return 'Expires $expiry';
  }

  @override
  String get failedLoadTasks => 'Failed to load tasks';

  @override
  String get errorFetchingTasks => 'Error fetching your tasks';

  @override
  String get taskCompletedSuccess => 'Task completed! You are now available.';

  @override
  String get failedCompleteTask => 'Failed to complete task';

  @override
  String errorWithPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get myTasksTitle => 'My Tasks';

  @override
  String get noPendingTasks => 'No pending tasks!';

  @override
  String get availableForAssignments =>
      'You are available for new assignments.';

  @override
  String get taskLabel => 'Task';

  @override
  String get unknownCaps => 'UNKNOWN';

  @override
  String get minsSuffix => 'mins';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get productionGuruTitle => 'Production Guru';

  @override
  String get sessionHistoryTooltip => 'Session History';

  @override
  String get newSessionTooltip => 'New Session';

  @override
  String get askGuruHint => 'Ask your guru...';

  @override
  String get harvestChroniclesTitle => 'Harvest Chronicles';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get farmAnalysisDefault => 'Farm Analysis';

  @override
  String get assetsLabel => 'Assets';

  @override
  String get failedReachAnalyst => 'Failed to reach AI Strategy Analyst.';

  @override
  String get strategicPortfolioAnalystTitle => 'Strategic Portfolio Analyst';

  @override
  String get investmentStrategyChroniclesTitle =>
      'Investment Strategy Chronicles';

  @override
  String get strategySessionDefault => 'Strategy Session';

  @override
  String get welcomeStrategicAnalysis => 'Welcome to Strategic Analysis';

  @override
  String get investmentAgentWelcomeDesc =>
      'Tell me your budget and risk preference, or ask about current market and weather trends.';

  @override
  String get consultedLiveData => 'Consulted Live Data:';

  @override
  String get marketLabel => 'Market';

  @override
  String get weatherLabel => 'Weather';

  @override
  String get suggestedRealEstate => 'Suggested Real Estate:';

  @override
  String get unknownFarm => 'Unknown Farm';

  @override
  String get tndPerMeter => 'TND/m';

  @override
  String get enterPreferencesHint => 'Enter preferences or ask analysis...';

  @override
  String get laborMarketLabel => 'LABOR MARKET';

  @override
  String get specificationsLabel => 'Specifications:';

  @override
  String get priceLabel => 'Price';

  @override
  String get rateLabel => 'Rate';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get closeButton => 'Close';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get sellerLabel => 'Seller';

  @override
  String get cancellationReasonLabel => 'Cancellation Reason';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get arrivingSoon => 'Arriving soon';

  @override
  String etaMinutes(String mins) {
    return '~$mins min';
  }

  @override
  String etaHours(String hours, String mins) {
    return '~${hours}h ${mins}min';
  }

  @override
  String get driverNearby => 'Driver Nearby!';

  @override
  String get onTheWay => 'On the way';

  @override
  String get youLabel => 'You';

  @override
  String get filterAll => 'All';

  @override
  String get filterNew => 'New';

  @override
  String get filterConfirmed => 'Confirmed';

  @override
  String get filterPreparing => 'Preparing';

  @override
  String get filterInTransit => 'In Transit';

  @override
  String get filterDelivered => 'Delivered';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get unknownCustomer => 'Unknown Customer';

  @override
  String get orderLabel => 'Order';

  @override
  String get manageButton => 'Manage';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get addMore => 'Add More';

  @override
  String qtyUpdatedTo(String title, String qty) {
    return '$title — qty updated to $qty';
  }

  @override
  String get maximumStockReached => 'Maximum stock reached';

  @override
  String pricePerUnit(String price, String unit) {
    return '$price TND / $unit';
  }

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc =>
      'Upgrade your subscription to unlock this feature.';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String upgradeRequiredDesc(String featureKey) {
    return 'This feature ($featureKey) is available on a premium plan. Upgrade your subscription to unlock it.';
  }

  @override
  String get laterButton => 'Later';

  @override
  String get myLandsTitle => 'My Lands';

  @override
  String get noLandsFound => 'No lands found';

  @override
  String get noLandsRented => 'You haven\'t rented any lands yet.';

  @override
  String get landActive => 'Active';

  @override
  String get landInactive => 'Inactive';

  @override
  String get landsRented => 'Lands Rented';

  @override
  String get completenessLabel => 'Completeness';

  @override
  String get roleLabel => 'Role';

  @override
  String get aboutLabel => 'About';

  @override
  String get directLinksLabel => 'Direct Links';

  @override
  String get websiteLabel => 'Website';

  @override
  String farmyMemberSince(String date) {
    return 'Farmy Community Member since $date';
  }

  @override
  String get privacyRestricted => 'Privacy Restricted';

  @override
  String get profileNotFound => 'Profile not found or private';

  @override
  String get profileLoadError =>
      'Failed to load profile. Please check your connection.';

  @override
  String get retryButton => 'Retry';

  @override
  String upgradeForUnlimited(String plan) {
    return 'Upgrade$plan for unlimited access';
  }

  @override
  String get tapToViewPlans => 'Tap to view plans →';

  @override
  String get assignTaskTitle => 'Assign Task';

  @override
  String workersAvailable(String count) {
    return '$count Available';
  }

  @override
  String get noTasksDefined => 'No tasks defined for this item.';

  @override
  String get noAvailableWorkers => 'No available workers!';

  @override
  String get taskAssigned => 'Task assigned!';

  @override
  String get assignButton => 'Assign';

  @override
  String get myTasksOnLand => 'My Tasks on this Land';

  @override
  String get noPendingTasksHere => 'No pending tasks here!';

  @override
  String get availableForAssignment => 'You are available for assignments.';

  @override
  String get taskCompleted => 'Task completed! You are now available.';

  @override
  String get markCompleteButton => 'Mark as Complete';

  @override
  String get errorFetchingYourTasks => 'Error fetching your tasks';

  @override
  String get closeTip => 'Close';

  @override
  String get farmyStore => 'FARMY STORE';

  @override
  String get nothingFoundHere => 'Nothing found here';

  @override
  String get shopBack => 'BACK';

  @override
  String get shopVariants => 'VARIANTS';

  @override
  String get shopBuy => 'BUY';

  @override
  String get mustRentLand => 'You must rent a land to buy items.';

  @override
  String get selectLand => 'Select Land';

  @override
  String get unknownLand => 'Unknown Land';

  @override
  String get purchaseRequestSent =>
      'Request sent! Transaction recorded on Hedera.';

  @override
  String get purchaseFailed => 'Purchase failed. Insufficient credits?';

  @override
  String get topUpCredits => 'TOP UP CREDITS';

  @override
  String get customAmount => 'Custom Amount';

  @override
  String maximumAmount(String max) {
    return 'Maximum amount is \$$max';
  }

  @override
  String creditsAdded(String amount) {
    return 'Successfully added \$$amount!';
  }

  @override
  String get myInventory => 'MY INVENTORY';

  @override
  String get allLands => 'All Lands';

  @override
  String get unknownLandFallback => 'Unknown';

  @override
  String get tabAll => 'ALL';

  @override
  String get tabPending => 'PENDING';

  @override
  String get tabApproved => 'APPROVED';

  @override
  String get tabRejected => 'REJECTED';

  @override
  String get noItemsFound => 'No items found';

  @override
  String noItemsFoundStatus(String status) {
    return 'No $status items found';
  }

  @override
  String get placedBadge => 'PLACED';

  @override
  String get itemActions => 'Item Actions';

  @override
  String get alreadyPlaced => 'Already Placed';

  @override
  String get addToLand => 'Add to Land';

  @override
  String get wrongLand => 'Wrong Land';

  @override
  String get alreadyPlacedSubtitle => 'This item is already on the map.';

  @override
  String get wrongLandSubtitle => 'This item belongs to another land.';

  @override
  String get buyMore => 'Buy More';

  @override
  String get failedToLoadData => 'Failed to load data. Please try again.';

  @override
  String get failedToLoadInventory =>
      'Failed to load inventory. Please try again.';

  @override
  String get comingSoonTitle => 'Coming Soon';

  @override
  String get comingSoonDesc =>
      'This feature is under development. You will be able to place items on your land soon!';

  @override
  String get okButton => 'OK';

  @override
  String get gotItButton => 'Got it';

  @override
  String get placingItem => 'Placing item...';

  @override
  String get itemPlacedSuccess => 'Item placed successfully!';

  @override
  String placingLabel(String name) {
    return 'Placing: $name';
  }

  @override
  String get loadingFootprint => 'Loading footprint...';

  @override
  String sizeLabel(String w, String h) {
    return 'Size: ${w}x$h';
  }

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get failedToLoadFarm => 'Failed to load farm';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get menuWorkforce => 'Workforce';

  @override
  String get menuMyTasks => 'My Tasks';

  @override
  String get menuAiAdvisor => 'AI Advisor';

  @override
  String get menuInventory => 'Inventory';

  @override
  String get menuShop => 'Shop';

  @override
  String get menuExitGame => 'Exit Game';

  @override
  String get mapTooltipInfo => 'Info';

  @override
  String get mapTooltipMove => 'Move';

  @override
  String get mapTooltipTasks => 'Tasks';

  @override
  String placementFailed(String error) {
    return 'Placement failed: $error';
  }

  @override
  String get placementFailedGeneric => 'Failed to place item. Try elsewhere.';

  @override
  String daysAgo(String count) {
    return '${count}d ago';
  }

  @override
  String get couldNotOpenHashScan => 'Could not open HashScan';

  @override
  String get setMonthlySalary => 'Set Monthly Salary';

  @override
  String get assign => 'Assign';

  @override
  String get tasksLabelShort => 'Tasks';

  @override
  String get assignToLand => 'Assign to Land';

  @override
  String invitationSentTo(String worker) {
    return 'Invitation sent to $worker';
  }

  @override
  String get failedToSendInvitation => 'Failed to send invitation';

  @override
  String get inviteWorker => 'Invite Worker';

  @override
  String inviteWorkerMessage(String worker, String landName) {
    return 'Invite $worker to $landName';
  }

  @override
  String get optionalMessageHint => 'Optional message...';

  @override
  String get sendInvite => 'Send Invite';

  @override
  String workerAssignedToLand(String worker, String landName) {
    return '$worker assigned to $landName';
  }

  @override
  String get failedToAssignWorker => 'Failed to assign worker';

  @override
  String get directMessagingDescription => 'Direct messaging description';

  @override
  String get readReviewsDescription => 'Read reviews description';

  @override
  String get messageWorker => 'Message Worker';

  @override
  String get viewReviews => 'View Reviews';

  @override
  String get inviteToLand => 'Invite to Land';

  @override
  String amountPerHour(String amount) {
    return '\$$amount/h';
  }

  @override
  String get onTimeLabel => 'On-Time';

  @override
  String get disputesLabel => 'Disputes';

  @override
  String get skills => 'Skills';

  @override
  String get about => 'About';

  @override
  String get performance => 'Performance';

  @override
  String get performanceGraphComingSoon => 'Performance Graph Coming Soon';

  @override
  String get manager => 'Manager';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get name => 'Name';

  @override
  String get salary => 'Salary';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get landDetails => 'Land Details';

  @override
  String amountPerMonth(String amount) {
    return '\$$amount/mo';
  }

  @override
  String get hourly => 'Hourly';

  @override
  String get listingPublished => 'Listing Published';

  @override
  String get listingPublishedHint =>
      'Your listing is now visible to the public.';

  @override
  String get continueLabelUpper => 'CONTINUE';

  @override
  String get failedToLoadProofs => 'Failed to load proofs';

  @override
  String get aiVerifyingProof => 'AI is verifying your proof...';

  @override
  String get proofVerifiedSuccessfully => 'Proof verified successfully!';

  @override
  String get noProofRequestsFound => 'No proof requests found';

  @override
  String fromLabel(String name) {
    return 'From: $name';
  }

  @override
  String get investor => 'Investor';

  @override
  String toLabel(String name) {
    return 'To: $name';
  }

  @override
  String mustSubmitBefore(String date) {
    return 'Must submit before $date';
  }

  @override
  String aiNotes(String notes) {
    return 'AI Notes: $notes';
  }

  @override
  String get submitPhotoProof => 'Submit Photo Proof';

  @override
  String get createNewTask => 'Create New Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskTitleHint => 'e.g., Water the tomatoes';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get taskType => 'Task Type';

  @override
  String get rewardLabel => 'Reward';

  @override
  String rewardAmountTnd(String amount) {
    return '$amount TND';
  }

  @override
  String get timeLabel => 'Time';

  @override
  String get createTask => 'Create Task';

  @override
  String get pleaseEnterTaskTitle => 'Please enter a task title';

  @override
  String get taskCreated => 'Task created successfully!';

  @override
  String tasksForLand(String landName) {
    return 'Tasks for $landName';
  }

  @override
  String get open => 'Open';

  @override
  String get done => 'Done';

  @override
  String get noTasksHere => 'No tasks here';

  @override
  String activeTasksCount(int count) {
    return '$count Active Tasks';
  }

  @override
  String get activeTasksLabel => 'Active Tasks';

  @override
  String get farmerPro => 'Farmer Pro';

  @override
  String assignedTo(String name) {
    return 'Assigned to $name';
  }

  @override
  String get taskLimitReached => 'Task Limit Reached';

  @override
  String taskLimitReachedMessage(String count) {
    return 'You can only have $count active tasks on the free plan.';
  }

  @override
  String get water => 'Water';

  @override
  String get harvest => 'Harvest';

  @override
  String get feed => 'Feed';

  @override
  String get install => 'Install';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get paymentFailedGeneric => 'Payment could not be completed.';

  @override
  String paymentFailedWithError(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get proofRequestedHint =>
      'A proof request has been sent to the worker.';

  @override
  String get requestAIProof => 'Request AI Proof';

  @override
  String get noProofsRequestedUpper => 'NO PROOFS REQUESTED';

  @override
  String get requestProofHint =>
      'Ask the worker to submit photo evidence of their work.';

  @override
  String get removeWorker => 'Remove Worker';

  @override
  String get remove => 'Remove';

  @override
  String get workerRemovedSuccessfully => 'Worker removed successfully';

  @override
  String get failedToRemoveWorker => 'Failed to remove worker';

  @override
  String get systemErrorUpper => 'SYSTEM ERROR';

  @override
  String get retryConnectionUpper => 'RETRY CONNECTION';

  @override
  String get myInvestments => 'My Investments';

  @override
  String get rentalConfirmed => 'Rental Confirmed';

  @override
  String get rentalConfirmedDescription =>
      'Your rental has been confirmed and the equipment will be delivered soon.';

  @override
  String get goToDashboardUpper => 'GO TO DASHBOARD';

  @override
  String get manageCards => 'Manage Cards';

  @override
  String get cardAddedSuccessfully => 'Card added successfully';

  @override
  String get cancelledOrFailedToAddCard => 'Cancelled or failed to add card.';

  @override
  String get allocatingSpatialResources => 'Allocating spatial resources...';

  @override
  String get paymentFailedTryAgain => 'Payment failed. Please try again.';

  @override
  String get paymentIssueHint => 'There was an issue processing your payment.';

  @override
  String get payNowUpper => 'PAY NOW';

  @override
  String get pleaseSelectPaymentMethod => 'Please select a payment method';

  @override
  String get securingRental => 'Securing rental...';

  @override
  String get agreeToTermsAndPrivacy =>
      'I agree to the Terms and Privacy Policy';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String amountTND(String amount) {
    return '$amount TND';
  }

  @override
  String get duration => 'Duration';

  @override
  String nMonths(String count) {
    return '$count months';
  }

  @override
  String get totalProject => 'Total Project';

  @override
  String get walletCredits => 'Wallet Credits';

  @override
  String get availableInstantPayment => 'Available for instant payment';

  @override
  String get monthlyRent => 'Monthly Rent';

  @override
  String get defaultMethod => 'Default';

  @override
  String get savedCard => 'Saved Card';

  @override
  String get changeAction => 'Change';

  @override
  String insufficientCredits(String amount) {
    return 'Insufficient Credits: $amount available';
  }

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String balanceAmount(String amount) {
    return 'Balance: $amount TND';
  }

  @override
  String get startingFrom => 'Starting from';

  @override
  String get monthAbbreviation => 'mo';

  @override
  String monthsAbbreviation(String count) {
    return '$count mos';
  }

  @override
  String get paymentSecurity => 'Secure payment processed by Stripe.';

  @override
  String get availableUpper => 'AVAILABLE';

  @override
  String organicPlotGrid(int w, int h) {
    return 'Organic plot (${w}x$h grid)';
  }

  @override
  String get checkout => 'Checkout';

  @override
  String get leaseStartDate => 'Lease Start Date';

  @override
  String get rentalDuration => 'Rental Duration';

  @override
  String get failedToLoadRecords => 'Failed to load records.';

  @override
  String get noBlockchainRecordsYet => 'No Blockchain Records Yet';

  @override
  String get makePurchaseImmutableRecordsHint =>
      'Make a purchase to see immutable records here.';

  @override
  String get pendingUpper => 'PENDING';

  @override
  String get rejectedUpper => 'REJECTED';

  @override
  String get fetchingBlockchainRecords => 'Fetching blockchain records...';

  @override
  String get transactionIdCopied => 'Transaction ID copied to clipboard';

  @override
  String get paidUpper => 'PAID';

  @override
  String get approvedUpper => 'APPROVED';

  @override
  String get rentalsLabel => 'Rentals';

  @override
  String get purchasesLabel => 'Purchases';

  @override
  String get hederaConsensusServiceUpper => 'HEDERA CONSENSUS SERVICE';

  @override
  String get proofSubmittedVerified =>
      'Proof submitted and verified successfully.';

  @override
  String get hederaRegistryUpper => 'HEDERA REGISTRY';

  @override
  String get immutableOnChainRecords => 'Immutable On-Chain Records';

  @override
  String get captureSubmit => 'Capture & Submit';

  @override
  String get uploadingImage => 'Uploading image...';

  @override
  String get pleaseWaitAFewMoments => 'Please wait a few moments...';

  @override
  String get orSelectAnItem => 'Or select an item';

  @override
  String itemIdUpper(String param) {
    return 'ITEM ID';
  }

  @override
  String gridPlots(int w, int h) {
    return '${w}x$h plots';
  }

  @override
  String get hireUpper => 'HIRE';

  @override
  String get size => 'Size';

  @override
  String get ownerLabel => 'Owner';

  @override
  String get draw => 'Draw';

  @override
  String get unknownItem => 'Unknown Item';

  @override
  String get moveAll => 'Move All';

  @override
  String plotNumber(String param) {
    return 'Plot #';
  }

  @override
  String get optimalSolarExposure => 'Optimal Solar Exposure';

  @override
  String get cancelUpper => 'CANCEL';

  @override
  String get failedToRejectRequest => 'Failed to reject request';

  @override
  String get hireWorkersUpper => 'HIRE WORKERS';

  @override
  String get invalidGeometryAlert => 'Invalid Geometry Alert';

  @override
  String get activeTasks => 'Active Tasks';

  @override
  String get perTaskUpper => 'PER TASK';

  @override
  String get analyzePortfolio => 'Analyze Portfolio';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get heightAuto => 'Auto Height';

  @override
  String rentAmountMonthly(String param) {
    return 'Monthly Rent: $param';
  }

  @override
  String get totalCapitalInvested => 'Total Capital Invested';

  @override
  String get currentLand => 'Current Land';

  @override
  String get descriptionTooShort => 'Description too short';

  @override
  String get landName => 'Land Name';

  @override
  String get alreadyRentedUpper => 'ALREADY RENTED';

  @override
  String get requestRejectedRefunded => 'Request rejected & refunded';

  @override
  String get rejectionReasonPrompt => 'Please provide a rejection reason';

  @override
  String get negotiationsUpper => 'NEGOTIATIONS';

  @override
  String get noWorkersFoundUpper => 'NO WORKERS FOUND';

  @override
  String get unknownInvestor => 'Unknown Investor';

  @override
  String hoursLeft(int count) {
    return '$count hours left';
  }

  @override
  String get rentalSlotsUsage => 'Rental Slots Usage';

  @override
  String get selectAtLeast3Points => 'Select at least 3 points';

  @override
  String get activeLabelUpper => 'ACTIVE';

  @override
  String salaryAmountType(int amount, String type) {
    return '$amount / $type';
  }

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get checkBackLaterOpportunities =>
      'Check back later for new opportunities';

  @override
  String get inactive => 'Inactive';

  @override
  String get endDateUpper => 'END DATE';

  @override
  String farmerWithColon(String param) {
    return 'Farmer: $param';
  }

  @override
  String get farmingActivity => 'Farming Activity';

  @override
  String get noActiveFarmingActivities => 'No active farming activities';

  @override
  String get boundaries => 'Boundaries';

  @override
  String get noInvestmentsYet => 'No investments yet';

  @override
  String get activeStatusUpper => 'ACTIVE STATUS';

  @override
  String plotsCount(int w, int h) {
    return '${w}x$h plots';
  }

  @override
  String get noPendingRequestsHint =>
      'You have no pending requests at the moment.';

  @override
  String requestedDateUpper(String param) {
    return 'REQUESTED DATE: $param';
  }

  @override
  String get priceCannotBeEmpty => 'Price cannot be empty';

  @override
  String get rentedUpper => 'RENTED';

  @override
  String get rentalLimitReached => 'Rental limit reached';

  @override
  String get invitationUpdates => 'Invitation Updates';

  @override
  String get priceStartingFrom => 'Price starting from';

  @override
  String get locationHighlights => 'Location Highlights';

  @override
  String get amount => 'Amount';

  @override
  String get publishingFailed => 'Publishing failed';

  @override
  String get securedWaterAccess => 'Secured Water Access';

  @override
  String get monthlyRentPriceTND => 'Monthly Rent Price (TND)';

  @override
  String get geometryVerified => 'Geometry Verified';

  @override
  String landWithColon(String param) {
    return 'Land: $param';
  }

  @override
  String get cannotPublishInvalidGeometry =>
      'Cannot publish with invalid geometry';

  @override
  String get retryUpper => 'RETRY';

  @override
  String get imageProofRequiredToApprove => 'Image proof required to approve';

  @override
  String get sendProposalUpper => 'SEND PROPOSAL';

  @override
  String get min => 'min';

  @override
  String get pricePerMonth => 'Price per month';

  @override
  String get noActiveWorkersUpper => 'NO ACTIVE WORKERS';

  @override
  String get reasonTooShort => 'Reason is too short';

  @override
  String get viewDetails => 'View Details';

  @override
  String get proofsUpper => 'PROOFS';

  @override
  String get noActiveNegotiationsUpper => 'NO ACTIVE NEGOTIATIONS';

  @override
  String get plantCrops => 'Plant Crops';

  @override
  String get readyForActivityHint => 'Ready for activity';

  @override
  String get irrigated => 'Irrigated';

  @override
  String get tryAdjustingFilters => 'Try adjusting filters';

  @override
  String get occupiedUpper => 'OCCUPIED';

  @override
  String get generalFarmingActivity => 'General Farming Activity';

  @override
  String endsDate(String param) {
    return 'Ends on: $param';
  }

  @override
  String daysLeft(int count) {
    return '$count days left';
  }

  @override
  String get hireActivateWorkersHint => 'Hire and activate workers';

  @override
  String get manageWorkers => 'Manage Workers';

  @override
  String get onTime => 'On Time';

  @override
  String removeWorkerConfirmation(String param) {
    return 'Remove worker $param?';
  }

  @override
  String get assignedLands => 'Assigned Lands';

  @override
  String get limitReachedUpper => 'LIMIT REACHED';

  @override
  String get proofHistory => 'Proof History';

  @override
  String get farmerInvitations => 'Farmer Invitations';

  @override
  String get workforceUpper => 'WORKFORCE';

  @override
  String get descriptionRequired => 'Description required';

  @override
  String get priceGreaterThanZero => 'Price must be greater than zero';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get proofRequestQuestion => 'Proof Request Question';

  @override
  String get rentalSlotsUsed => 'Rental Slots Used';

  @override
  String get activeLands => 'Active Lands';

  @override
  String get widthAuto => 'Auto Width';

  @override
  String get spatialDimensions => 'Spatial Dimensions';

  @override
  String idLabel(String param) {
    return 'ID: $param';
  }

  @override
  String rentalExpires(String param) {
    return 'Rental expires: $param';
  }

  @override
  String proofSubmissionHint(String param) {
    return 'Proof submission: $param';
  }

  @override
  String landPlotNumber(String param) {
    return 'Land Plot #: $param';
  }

  @override
  String get messageOptionalUpper => 'MESSAGE (OPTIONAL)';

  @override
  String get roiEst => 'Estimated ROI';

  @override
  String get paymentRequiredToActivate => 'Payment required to activate';

  @override
  String get invalidNumericAmount => 'Invalid numeric amount';

  @override
  String pointsDefined(int count) {
    return '$count points defined';
  }

  @override
  String nItemsSold(int count) {
    return '$count items sold';
  }

  @override
  String get itemVerification => 'Item Verification';

  @override
  String get invalidGeometryHint => 'Invalid geometry detected';

  @override
  String get declinedUpper => 'DECLINED';

  @override
  String get connectionError => 'Connection error';

  @override
  String get startByListingPlot => 'Start by listing a plot';

  @override
  String get propertyDetails => 'Property Details';

  @override
  String get invalidGeometry => 'Invalid Geometry';

  @override
  String get failedToLoadRequests => 'Failed to load requests';

  @override
  String untilDate(String param) {
    return 'until $param';
  }

  @override
  String get drawInstructions => 'Tap on map to draw boundaries';

  @override
  String get na => 'N/A';

  @override
  String get noTasksAssignedHint => 'No tasks assigned yet';

  @override
  String get cannotPublishBoundaryConflicts =>
      'Cannot publish: boundary conflicts detected';

  @override
  String get farmingActivities => 'Farming Activities';

  @override
  String get listNewLand => 'List New Land';

  @override
  String get noApprovedWorkersUpper => 'NO APPROVED WORKERS';

  @override
  String get expiredUpper => 'EXPIRED';

  @override
  String get conflictDetected => 'Conflict detected';

  @override
  String get rejectRequest => 'Reject Request';

  @override
  String get boundaryConflictAlert => 'Boundary Conflict Alert';

  @override
  String get requestProof => 'Request Proof';

  @override
  String get perHourUpper => 'PER HOUR';

  @override
  String get exploreLands => 'Explore Lands';

  @override
  String get premiumFarmlandUpper => 'PREMIUM FARMLAND';

  @override
  String get newProposal => 'New Proposal';

  @override
  String get suspendedUpper => 'SUSPENDED';

  @override
  String get aiPortfolioAnalysisHint => 'AI Portfolio Analysis';

  @override
  String get defineOnMap => 'Define on Map';

  @override
  String get itemUpper => 'ITEM';

  @override
  String amountPerType(String amount, String type) {
    return '$amount / $type';
  }

  @override
  String get landDescriptionHint => 'Describe your land...';

  @override
  String get autoFromBoundary => 'Auto from boundary';

  @override
  String get tryAgainUpper => 'TRY AGAIN';

  @override
  String get landNameRequired => 'Land name is required';

  @override
  String get activeUpper => 'ACTIVE';

  @override
  String get hiringProposals => 'Hiring Proposals';

  @override
  String get confirmReject => 'Confirm Reject';

  @override
  String get movePoint => 'Move Point';

  @override
  String get priceExceedsLimit => 'Price exceeds limit';

  @override
  String get egSalaryHint => 'e.g. 15.00';

  @override
  String hireWorkerUpper(String param) {
    return 'HIRE $param';
  }

  @override
  String get hiringProposalSent => 'Hiring proposal sent';

  @override
  String get entireLand => 'Entire Land';

  @override
  String get acceptedUpper => 'ACCEPTED';

  @override
  String get fundsReleasedAfterVerification =>
      'Funds released after verification';

  @override
  String get enterRejectionReason => 'Enter rejection reason';

  @override
  String get proofRequests => 'Proof Requests';

  @override
  String get enableVoiceInput => 'Enable Voice Input';

  @override
  String get salaryAmountTNDUpper => 'SALARY AMOUNT (TND)';

  @override
  String get unableToRetrieveLandDetails => 'Unable to retrieve land details';

  @override
  String get hourlyUpper => 'HOURLY';

  @override
  String aiLandInvestmentHint(String param) {
    return 'AI Investment Hint: $param';
  }

  @override
  String get askAiAnalyst => 'Ask AI Analyst';

  @override
  String get monthlyUpper => 'MONTHLY';

  @override
  String get activeContracts => 'Active Contracts';

  @override
  String get workerRespondedReviewCounterOffer =>
      'Worker responded, review counter-offer';

  @override
  String get unlockUnlimitedSlotsInvestorPlus =>
      'Unlock unlimited slots with Investor+';

  @override
  String get escrowBalance => 'Escrow Balance';

  @override
  String get pleaseEnterAName => 'Please enter a name';

  @override
  String get raiseLivestock => 'Raise Livestock';

  @override
  String get noLandAssignments => 'No land assignments';

  @override
  String get aiVerifyUpper => 'AI VERIFY';

  @override
  String get requestExpired => 'Request expired';

  @override
  String get rejectUpper => 'REJECT';

  @override
  String get landUpdatedSuccess => 'Land updated successfully';

  @override
  String get realTimeTaskNotificationsSoon =>
      'Real-time task notifications soon';

  @override
  String get approveUpper => 'APPROVE';

  @override
  String untilDateUpper(String param) {
    return 'UNTIL $param';
  }

  @override
  String get overlapsExistingLand => 'Overlaps with existing land';

  @override
  String get itemRequests => 'Item Requests';

  @override
  String get startDateUpper => 'START DATE';

  @override
  String get generalLandProof => 'General Land Proof';

  @override
  String get landNameTooShort => 'Land name too short';

  @override
  String get verifiedUpper => 'VERIFIED';

  @override
  String minutesLeft(int count) {
    return '$count minutes left';
  }

  @override
  String get tapToDrawBoundaries => 'Tap to draw boundaries';

  @override
  String get directRoadAccess => 'Direct road access';

  @override
  String invitationFrom(String param) {
    return 'Invitation from $param';
  }

  @override
  String get failedToLoadContracts => 'Failed to load contracts';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get perimeterNotSet => 'Perimeter not set';

  @override
  String get requestApprovedItemPlaced => 'Request approved, item placed';

  @override
  String get inviteWorkersMarketplaceHint => 'Invite workers from marketplace';

  @override
  String get landNameHint => 'e.g. Sunny Valley Farm';

  @override
  String get publishListing => 'Publish Listing';

  @override
  String get hireApprovedWorkerNegotiationHint =>
      'Hire approved worker to start negotiation';

  @override
  String get request => 'Request';

  @override
  String get counterOfferUpper => 'COUNTER-OFFER';

  @override
  String get proposedUpper => 'PROPOSED';

  @override
  String get verificationSuccessful => 'Verification successful';

  @override
  String get rentLandToStartUpper => 'RENT LAND TO START';

  @override
  String get expiredLabel => 'Expired';

  @override
  String get salaryTypeUpper => 'SALARY TYPE';

  @override
  String get pleaseEnterRejectionReason => 'Please enter rejection reason';

  @override
  String get negotiatingUpper => 'NEGOTIATING';

  @override
  String get rentNowUpper => 'RENT NOW';

  @override
  String get noSpecialSkillsUpper => 'NO SPECIAL SKILLS';

  @override
  String get noLandAssignmentsHint => 'No land assignments yet';
}
