import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @becomeAWorker.
  ///
  /// In en, this message translates to:
  /// **'Become a Worker'**
  String get becomeAWorker;

  /// No description provided for @joinTheWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Join the Workforce'**
  String get joinTheWorkforce;

  /// No description provided for @joinWorkforceDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your professional profile and\nstart earning on nearby farms today.'**
  String get joinWorkforceDescription;

  /// No description provided for @selectYourSkills.
  ///
  /// In en, this message translates to:
  /// **'Select Your Skills'**
  String get selectYourSkills;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @aboutYouHint.
  ///
  /// In en, this message translates to:
  /// **'Tell farmers about your experience...'**
  String get aboutYouHint;

  /// No description provided for @hourlyRateTnd.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate (TND)'**
  String get hourlyRateTnd;

  /// No description provided for @hourlyRateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15.00'**
  String get hourlyRateHint;

  /// No description provided for @aiVerificationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'AI Verification Coming Soon'**
  String get aiVerificationComingSoon;

  /// No description provided for @aiVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Automated identity & skill verification will speed up your approval.'**
  String get aiVerificationDescription;

  /// No description provided for @createWorkerProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Worker Profile'**
  String get createWorkerProfile;

  /// No description provided for @selectAtLeastOneSkill.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one skill'**
  String get selectAtLeastOneSkill;

  /// No description provided for @workerProfileCreated.
  ///
  /// In en, this message translates to:
  /// **'🎉 Worker profile created! Pending verification.'**
  String get workerProfileCreated;

  /// No description provided for @failedToCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to create profile'**
  String get failedToCreateProfile;

  /// No description provided for @enterValidRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid rate'**
  String get enterValidRate;

  /// No description provided for @watering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get watering;

  /// No description provided for @harvesting.
  ///
  /// In en, this message translates to:
  /// **'Harvesting'**
  String get harvesting;

  /// No description provided for @planting.
  ///
  /// In en, this message translates to:
  /// **'Planting'**
  String get planting;

  /// No description provided for @animalCare.
  ///
  /// In en, this message translates to:
  /// **'Animal Care'**
  String get animalCare;

  /// No description provided for @machineOperation.
  ///
  /// In en, this message translates to:
  /// **'Machine Operation'**
  String get machineOperation;

  /// No description provided for @soilManagement.
  ///
  /// In en, this message translates to:
  /// **'Soil Management'**
  String get soilManagement;

  /// No description provided for @structureInstallation.
  ///
  /// In en, this message translates to:
  /// **'Structure Installation'**
  String get structureInstallation;

  /// No description provided for @qualityInspection.
  ///
  /// In en, this message translates to:
  /// **'Quality Inspection'**
  String get qualityInspection;

  /// No description provided for @cropMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Crop Monitoring'**
  String get cropMonitoring;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pestControl;

  /// No description provided for @viewManageLandInvestments.
  ///
  /// In en, this message translates to:
  /// **'View and manage your land investments'**
  String get viewManageLandInvestments;

  /// No description provided for @enableGameEdgePanel.
  ///
  /// In en, this message translates to:
  /// **'Enable Game Edge Panel'**
  String get enableGameEdgePanel;

  /// No description provided for @accessFarmView.
  ///
  /// In en, this message translates to:
  /// **'Access the 2.5D farm view'**
  String get accessFarmView;

  /// No description provided for @tasksProofs.
  ///
  /// In en, this message translates to:
  /// **'Tasks & Proofs'**
  String get tasksProofs;

  /// No description provided for @aiProofRequests.
  ///
  /// In en, this message translates to:
  /// **'AI Proof Requests'**
  String get aiProofRequests;

  /// No description provided for @viewManageProofRequests.
  ///
  /// In en, this message translates to:
  /// **'View and manage proof requests'**
  String get viewManageProofRequests;

  /// No description provided for @freeTier.
  ///
  /// In en, this message translates to:
  /// **'Free Tier'**
  String get freeTier;

  /// No description provided for @upgradePremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for premium features'**
  String get upgradePremium;

  /// No description provided for @freeForever.
  ///
  /// In en, this message translates to:
  /// **'No expiration · Free forever'**
  String get freeForever;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String validUntil(String date);

  /// No description provided for @editLandDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Land Details'**
  String get editLandDetails;

  /// No description provided for @deleteLand.
  ///
  /// In en, this message translates to:
  /// **'Delete Land'**
  String get deleteLand;

  /// No description provided for @deleteLandTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Land?'**
  String get deleteLandTitle;

  /// No description provided for @deleteLandConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteLandConfirmation(String name);

  /// No description provided for @deleteLandActionWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All associated data will be permanently removed.'**
  String get deleteLandActionWarning;

  /// No description provided for @landDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Land deleted successfully'**
  String get landDeletedSuccess;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureOptimizedDescription.
  ///
  /// In en, this message translates to:
  /// **'The \"{feature}\" module is currently being optimized for personal farming management.'**
  String featureOptimizedDescription(String feature);

  /// No description provided for @stayTunedSpatialTracking.
  ///
  /// In en, this message translates to:
  /// **'Stay tuned for advanced spatial asset tracking!'**
  String get stayTunedSpatialTracking;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @failedToSyncBackend.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync with backend'**
  String get failedToSyncBackend;

  /// No description provided for @externalProperty.
  ///
  /// In en, this message translates to:
  /// **'EXTERNAL PROPERTY'**
  String get externalProperty;

  /// No description provided for @notYours.
  ///
  /// In en, this message translates to:
  /// **'NOT YOURS'**
  String get notYours;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get dismiss;

  /// No description provided for @myLands.
  ///
  /// In en, this message translates to:
  /// **'My Lands'**
  String get myLands;

  /// No description provided for @landDataSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'✨ Land Data Synchronized Successfully!'**
  String get landDataSyncSuccess;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New Listing'**
  String get newListing;

  /// No description provided for @landLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Land Limit Reached'**
  String get landLimitReachedTitle;

  /// No description provided for @landLimitReachedDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all land slots on your {planName} plan. Upgrade to Farmer Pro to unlock unlimited lands!'**
  String landLimitReachedDescription(String planName);

  /// No description provided for @landSlotsUsed.
  ///
  /// In en, this message translates to:
  /// **'Land Slots Used'**
  String get landSlotsUsed;

  /// No description provided for @synchronizingBoundaries.
  ///
  /// In en, this message translates to:
  /// **'SYNCHRONIZING BOUNDARIES'**
  String get synchronizingBoundaries;

  /// No description provided for @fetchingSpatialData.
  ///
  /// In en, this message translates to:
  /// **'Fetching precise spatial data...'**
  String get fetchingSpatialData;

  /// No description provided for @syncInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Sync Interrupted'**
  String get syncInterrupted;

  /// No description provided for @tryToResync.
  ///
  /// In en, this message translates to:
  /// **'Try to Re-sync'**
  String get tryToResync;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No description provided for this land.'**
  String get noDescriptionProvided;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @rentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get rentals;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @workforce.
  ///
  /// In en, this message translates to:
  /// **'Workforce'**
  String get workforce;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @rented.
  ///
  /// In en, this message translates to:
  /// **'RENTED'**
  String get rented;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get available;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner: {id}'**
  String owner(String id);

  /// No description provided for @myBasket.
  ///
  /// In en, this message translates to:
  /// **'My Basket'**
  String get myBasket;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @yourBasketIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your basket is empty'**
  String get yourBasketIsEmpty;

  /// No description provided for @browseMarketplaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse the marketplace and add\nsome fresh products!'**
  String get browseMarketplaceDescription;

  /// No description provided for @browseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get browseProducts;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tva.
  ///
  /// In en, this message translates to:
  /// **'TVA (19%)'**
  String get tva;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @balanceWithCredits.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance} Credits'**
  String balanceWithCredits(String balance);

  /// No description provided for @checkoutWithItems.
  ///
  /// In en, this message translates to:
  /// **'Checkout ({count} items)'**
  String checkoutWithItems(int count);

  /// No description provided for @insufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Funds'**
  String get insufficientFunds;

  /// No description provided for @insufficientFundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your balance is {balance} Credits, but the total is {total} TND.\n\nPlease top up your wallet.'**
  String insufficientFundsDescription(String balance, String total);

  /// No description provided for @confirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String itemsCount(int count);

  /// No description provided for @includingTva.
  ///
  /// In en, this message translates to:
  /// **'(including 19% TVA: {tax} TND)'**
  String includingTva(String tax);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @itemsPurchasedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) purchased successfully.'**
  String itemsPurchasedSuccess(int count);

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @viewMyOrders.
  ///
  /// In en, this message translates to:
  /// **'View My Orders'**
  String get viewMyOrders;

  /// No description provided for @backToMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Back to Marketplace'**
  String get backToMarketplace;

  /// No description provided for @checkoutResultFeedback.
  ///
  /// In en, this message translates to:
  /// **'{successCount} purchased, {failCount} failed. Failed items remain in basket.'**
  String checkoutResultFeedback(int successCount, int failCount);

  /// No description provided for @clearBasketTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Basket?'**
  String get clearBasketTitle;

  /// No description provided for @clearBasketDescription.
  ///
  /// In en, this message translates to:
  /// **'This will remove all items from your basket.'**
  String get clearBasketDescription;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @enter2faCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app to continue.'**
  String get enter2faCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @customerAccount.
  ///
  /// In en, this message translates to:
  /// **'Customer Account'**
  String get customerAccount;

  /// No description provided for @dailyInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily Inspiration'**
  String get dailyInspiration;

  /// No description provided for @workerPlus.
  ///
  /// In en, this message translates to:
  /// **'Worker Plus'**
  String get workerPlus;

  /// No description provided for @workerPlusDescription.
  ///
  /// In en, this message translates to:
  /// **'Boost your profile, get priority matching, and instant withdrawals.'**
  String get workerPlusDescription;

  /// No description provided for @farmboxSubscription.
  ///
  /// In en, this message translates to:
  /// **'FarmBox Subscription'**
  String get farmboxSubscription;

  /// No description provided for @farmboxDescription.
  ///
  /// In en, this message translates to:
  /// **'Get fresh, locally grown vegetables delivered to your doorstep weekly!'**
  String get farmboxDescription;

  /// No description provided for @upgradeWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Upgrade {price}'**
  String upgradeWithPrice(String price);

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'The future of agriculture is in your hands.'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'Support local, eat fresh, live healthy.'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'Connecting you to the roots of your food.'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In en, this message translates to:
  /// **'Every investment in nature yields the best interest.'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In en, this message translates to:
  /// **'Small choices make a big impact on our planet.'**
  String get quote5;

  /// No description provided for @quote6.
  ///
  /// In en, this message translates to:
  /// **'Fresh from the farm, straight to your table.'**
  String get quote6;

  /// No description provided for @quote7.
  ///
  /// In en, this message translates to:
  /// **'Empowering farmers, feeding the world.'**
  String get quote7;

  /// No description provided for @quote8.
  ///
  /// In en, this message translates to:
  /// **'Sustainability is not a goal, it\'s a lifestyle.'**
  String get quote8;

  /// No description provided for @totalEarningsWallet.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings (Wallet)'**
  String get totalEarningsWallet;

  /// No description provided for @totalSalesValue.
  ///
  /// In en, this message translates to:
  /// **'Total Sales Value'**
  String get totalSalesValue;

  /// No description provided for @itemsSold.
  ///
  /// In en, this message translates to:
  /// **'Items Sold'**
  String itemsSold(int count);

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @unlockDeepInsights.
  ///
  /// In en, this message translates to:
  /// **'Unlock Deep Insights'**
  String get unlockDeepInsights;

  /// No description provided for @unlockDeepInsightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered crop forecasting, detailed soil health history, and advanced ROI projections.'**
  String get unlockDeepInsightsDescription;

  /// No description provided for @productionStrategy.
  ///
  /// In en, this message translates to:
  /// **'Production Strategy'**
  String get productionStrategy;

  /// No description provided for @productionStrategyDescription.
  ///
  /// In en, this message translates to:
  /// **'Get a deep analysis of your current production overhead, potential yield, and profit-maximization strategies powered by AI.'**
  String get productionStrategyDescription;

  /// No description provided for @consultProductionGuru.
  ///
  /// In en, this message translates to:
  /// **'Consult Production Guru'**
  String get consultProductionGuru;

  /// No description provided for @upgradeToPlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to {planName}'**
  String upgradeToPlan(String planName);

  /// No description provided for @farmyUser.
  ///
  /// In en, this message translates to:
  /// **'Farmy User'**
  String get farmyUser;

  /// No description provided for @latestSubmittedProof.
  ///
  /// In en, this message translates to:
  /// **'Latest Submitted Proof'**
  String get latestSubmittedProof;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'ENABLED'**
  String get enabled;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @buyProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to buy {title} for {price} credits?'**
  String buyProductConfirmation(String title, double price);

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @creditsCount.
  ///
  /// In en, this message translates to:
  /// **'Credits: {count}'**
  String creditsCount(String count);

  /// No description provided for @priceCountCredits.
  ///
  /// In en, this message translates to:
  /// **'{price} Credits'**
  String priceCountCredits(double price);

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @pleaseSelectProductType.
  ///
  /// In en, this message translates to:
  /// **'Please select a product type'**
  String get pleaseSelectProductType;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated!'**
  String get productUpdated;

  /// No description provided for @productListedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product listed successfully!'**
  String get productListedSuccessfully;

  /// No description provided for @failedToUpdateProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to update product.'**
  String get failedToUpdateProduct;

  /// No description provided for @failedToListProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to list product.'**
  String get failedToListProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @tapToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get tapToAddImage;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @productType.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @priceCredits.
  ///
  /// In en, this message translates to:
  /// **'Price (Credits)'**
  String get priceCredits;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g., kg, liter, piece)'**
  String get unitHint;

  /// No description provided for @pleaseEnterUnit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a unit'**
  String get pleaseEnterUnit;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @listProduct.
  ///
  /// In en, this message translates to:
  /// **'List Product'**
  String get listProduct;

  /// No description provided for @noCamerasFound.
  ///
  /// In en, this message translates to:
  /// **'No cameras found on this device.'**
  String get noCamerasFound;

  /// No description provided for @flipIdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Great! Now flip your ID over'**
  String get flipIdInstruction;

  /// No description provided for @selfieInstruction.
  ///
  /// In en, this message translates to:
  /// **'Perfect! Now let\'s take a selfie'**
  String get selfieInstruction;

  /// No description provided for @uploadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Uploading documents...'**
  String get uploadingDocuments;

  /// No description provided for @kycSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success! You are now a {role}!'**
  String kycSuccess(String role);

  /// No description provided for @scanFrontId.
  ///
  /// In en, this message translates to:
  /// **'Scan Front of ID'**
  String get scanFrontId;

  /// No description provided for @scanBackId.
  ///
  /// In en, this message translates to:
  /// **'Scan Back of ID'**
  String get scanBackId;

  /// No description provided for @takeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take a Selfie'**
  String get takeSelfie;

  /// No description provided for @positionIdHint.
  ///
  /// In en, this message translates to:
  /// **'Position your ID within the frame'**
  String get positionIdHint;

  /// No description provided for @flipIdHint.
  ///
  /// In en, this message translates to:
  /// **'Flip your ID and scan the back'**
  String get flipIdHint;

  /// No description provided for @lookAtCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Look directly at the camera with eyes open'**
  String get lookAtCameraHint;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @accountBanned.
  ///
  /// In en, this message translates to:
  /// **'Account Banned'**
  String get accountBanned;

  /// No description provided for @bannedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended due to specific violations. Please contact support if you believe this is a mistake.'**
  String get bannedDescription;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @noInternetDescription.
  ///
  /// In en, this message translates to:
  /// **'We could not connect to the server. Please check your internet connection and try again.'**
  String get noInternetDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @askFarmingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask your farming question...'**
  String get askFarmingQuestion;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @startANewConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation'**
  String get startANewConversation;

  /// No description provided for @createChatDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a chat to ask for practical farming guidance.'**
  String get createChatDescription;

  /// No description provided for @askAnythingAboutFarm.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your farm'**
  String get askAnythingAboutFarm;

  /// No description provided for @aiAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'Planting times, crop health, fertilizers, and practical guidance with automatic language detection.'**
  String get aiAssistantDescription;

  /// No description provided for @noChatStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Farmy AI'**
  String get noChatStateTitle;

  /// No description provided for @noChatStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation to get expert advice on your agriculture.'**
  String get noChatStateDescription;

  /// No description provided for @disableVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Disable voice input'**
  String get disableVoiceInput;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @muteVoiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Mute voice output'**
  String get muteVoiceOutput;

  /// No description provided for @enableVoiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Enable voice output'**
  String get enableVoiceOutput;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @syncBackend.
  ///
  /// In en, this message translates to:
  /// **'Sync backend'**
  String get syncBackend;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @closeAssistant.
  ///
  /// In en, this message translates to:
  /// **'Close assistant'**
  String get closeAssistant;

  /// No description provided for @syncingWithBackend.
  ///
  /// In en, this message translates to:
  /// **'Syncing with backend...'**
  String get syncingWithBackend;

  /// No description provided for @backendDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Backend disconnected. Reconnecting automatically...'**
  String get backendDisconnected;

  /// No description provided for @offlineModeCached.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: cached answers will be used when available.'**
  String get offlineModeCached;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get noConversationsYet;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @renameChat.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get renameChat;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChat;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat title'**
  String get chatTitle;

  /// No description provided for @updateYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Update your message'**
  String get updateYourMessage;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteChatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" permanently?'**
  String deleteChatConfirmation(String title);

  /// No description provided for @responseCopied.
  ///
  /// In en, this message translates to:
  /// **'Response copied to clipboard.'**
  String get responseCopied;

  /// No description provided for @voiceInputNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not available on this device.'**
  String get voiceInputNotAvailable;

  /// No description provided for @unableToStartVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Unable to start voice input. Please check permissions.'**
  String get unableToStartVoiceInput;

  /// No description provided for @voiceOutputMuted.
  ///
  /// In en, this message translates to:
  /// **'Voice output is muted. Unmute to read this message.'**
  String get voiceOutputMuted;

  /// No description provided for @messageNoReadableText.
  ///
  /// In en, this message translates to:
  /// **'This message has no readable text.'**
  String get messageNoReadableText;

  /// No description provided for @unableToPlayVoiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Unable to play voice output now.'**
  String get unableToPlayVoiceOutput;

  /// No description provided for @couldNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not send your message. Please try again.'**
  String get couldNotSendMessage;

  /// No description provided for @upgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Required'**
  String get upgradeRequired;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @editAndResend.
  ///
  /// In en, this message translates to:
  /// **'Edit and resend'**
  String get editAndResend;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @cached.
  ///
  /// In en, this message translates to:
  /// **'Cached'**
  String get cached;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit verification code to\n{email}.'**
  String verificationCodeSentTo(String email);

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccount;

  /// No description provided for @resendNewCode.
  ///
  /// In en, this message translates to:
  /// **'Resend New Code'**
  String get resendNewCode;

  /// No description provided for @newVerificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'New verification code sent!'**
  String get newVerificationCodeSent;

  /// No description provided for @failedToSendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code. Try again.'**
  String get failedToSendCode;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmail;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resettingPasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Resetting password for {email}'**
  String resettingPasswordFor(String email);

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterAll6Digits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits'**
  String get pleaseEnterAll6Digits;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please log in.'**
  String get passwordResetSuccess;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a 6-digit code to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @welcomeCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Farmy!'**
  String get welcomeCustomerTitle;

  /// No description provided for @welcomeCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support local farmers and enjoy fresh, sustainable products directly from the source.'**
  String get welcomeCustomerSubtitle;

  /// No description provided for @welcomeWorkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the Workforce'**
  String get welcomeWorkerTitle;

  /// No description provided for @welcomeWorkerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with modern farms and start your productive journey in sustainable agriculture.'**
  String get welcomeWorkerSubtitle;

  /// No description provided for @welcomeFarmerTitle.
  ///
  /// In en, this message translates to:
  /// **'Empowering Farmers'**
  String get welcomeFarmerTitle;

  /// No description provided for @welcomeFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey to digital farm management starts here. Let\'s grow your business together!'**
  String get welcomeFarmerSubtitle;

  /// No description provided for @welcomeInvestorTitle.
  ///
  /// In en, this message translates to:
  /// **'Invest in the Future'**
  String get welcomeInvestorTitle;

  /// No description provided for @welcomeInvestorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore sustainable opportunities and grow your green agricultural portfolio with us.'**
  String get welcomeInvestorSubtitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @walletCards.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Cards'**
  String get walletCards;

  /// No description provided for @manageCredits.
  ///
  /// In en, this message translates to:
  /// **'Manage credits and payment methods'**
  String get manageCredits;

  /// No description provided for @hederaRegistry.
  ///
  /// In en, this message translates to:
  /// **'Hedera Registry'**
  String get hederaRegistry;

  /// No description provided for @viewBlockchainRecords.
  ///
  /// In en, this message translates to:
  /// **'View your on-chain blockchain records'**
  String get viewBlockchainRecords;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @viewRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'View your recent activity and updates'**
  String get viewRecentActivity;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @disable2fa.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get disable2fa;

  /// No description provided for @enable2fa.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get enable2fa;

  /// No description provided for @strongSecurityActive.
  ///
  /// In en, this message translates to:
  /// **'Strong security active'**
  String get strongSecurityActive;

  /// No description provided for @addExtraSecurity.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security'**
  String get addExtraSecurity;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @trackManagePurchases.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your purchases'**
  String get trackManagePurchases;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @becomeFarmer.
  ///
  /// In en, this message translates to:
  /// **'Become a Farmer'**
  String get becomeFarmer;

  /// No description provided for @startSellingProduce.
  ///
  /// In en, this message translates to:
  /// **'Start selling your produce'**
  String get startSellingProduce;

  /// No description provided for @becomeInvestor.
  ///
  /// In en, this message translates to:
  /// **'Become an Investor'**
  String get becomeInvestor;

  /// No description provided for @investSustainableFarming.
  ///
  /// In en, this message translates to:
  /// **'Invest in sustainable farming'**
  String get investSustainableFarming;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @becomeWorker.
  ///
  /// In en, this message translates to:
  /// **'Become a Worker'**
  String get becomeWorker;

  /// No description provided for @offerSkillsFarms.
  ///
  /// In en, this message translates to:
  /// **'Offer your skills on farms'**
  String get offerSkillsFarms;

  /// No description provided for @workerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Worker Dashboard'**
  String get workerDashboard;

  /// No description provided for @viewAssignmentsTasks.
  ///
  /// In en, this message translates to:
  /// **'View your assignments & tasks'**
  String get viewAssignmentsTasks;

  /// No description provided for @gameFeatures.
  ///
  /// In en, this message translates to:
  /// **'Game Features'**
  String get gameFeatures;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us - Farmy Team'**
  String get aboutUs;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'This feature is currently under development.'**
  String get featureUnderDevelopment;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get land;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @myFarms.
  ///
  /// In en, this message translates to:
  /// **'My Farms'**
  String get myFarms;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @openInvestmentAssistant.
  ///
  /// In en, this message translates to:
  /// **'Open investment assistant'**
  String get openInvestmentAssistant;

  /// No description provided for @openAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Open AI assistant'**
  String get openAiAssistant;

  /// No description provided for @myWorkerTasks.
  ///
  /// In en, this message translates to:
  /// **'My Worker Tasks'**
  String get myWorkerTasks;

  /// No description provided for @unknownRole.
  ///
  /// In en, this message translates to:
  /// **'Unknown role: {role}'**
  String unknownRole(String role);

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Farmy'**
  String get appName;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @revenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenueTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeToFarmy.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Farmy'**
  String get welcomeToFarmy;

  /// No description provided for @signInToFarmyAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Farmy account'**
  String get signInToFarmyAccount;

  /// No description provided for @startJourneyWithFarmy.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with Farmy today'**
  String get startJourneyWithFarmy;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing up...'**
  String get signingUp;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get orContinueWith;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup Failed'**
  String get signupFailed;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {title}?'**
  String deleteProductConfirmation(String title);

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @failedToDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get failedToDeleteProduct;

  /// No description provided for @analyzeInventory.
  ///
  /// In en, this message translates to:
  /// **'Analyze Inventory'**
  String get analyzeInventory;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @addProductFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to see it here!'**
  String get addProductFirst;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @productLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Product Limit Reached'**
  String get productLimitReached;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @oopsSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// No description provided for @productListingsUsed.
  ///
  /// In en, this message translates to:
  /// **'Product Listings Used'**
  String get productListingsUsed;

  /// No description provided for @upgradePlanName.
  ///
  /// In en, this message translates to:
  /// **'Farmer Pro'**
  String get upgradePlanName;

  /// No description provided for @analyzeInventoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Analyse my current product inventory. Are these good products to hold or should I focus on something else based on the market?'**
  String get analyzeInventoryPrompt;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @productLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all product slots on your {planName} plan. Upgrade to Farmer Pro or Investor Plus to list more products!'**
  String productLimitMessage(String planName);

  /// No description provided for @workerMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Worker Marketplace'**
  String get workerMarketplace;

  /// No description provided for @searchWorkers.
  ///
  /// In en, this message translates to:
  /// **'Search workers...'**
  String get searchWorkers;

  /// No description provided for @noVerifiedWorkersFound.
  ///
  /// In en, this message translates to:
  /// **'No verified workers found'**
  String get noVerifiedWorkersFound;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String tasksCount(int count);

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'/hour'**
  String get perHour;

  /// No description provided for @workforceLandName.
  ///
  /// In en, this message translates to:
  /// **'Workforce — {landName}'**
  String workforceLandName(String landName);

  /// No description provided for @addWorker.
  ///
  /// In en, this message translates to:
  /// **'Add Worker'**
  String get addWorker;

  /// No description provided for @inviteExistingWorker.
  ///
  /// In en, this message translates to:
  /// **'Invite Existing Worker'**
  String get inviteExistingWorker;

  /// No description provided for @searchWorkerMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Search the worker marketplace'**
  String get searchWorkerMarketplace;

  /// No description provided for @openJobRequest.
  ///
  /// In en, this message translates to:
  /// **'Open Job Request'**
  String get openJobRequest;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @suspendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspendedLabel;

  /// No description provided for @monthlyCost.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cost'**
  String get monthlyCost;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @totalSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalSuffix(int count);

  /// No description provided for @noWorkersYet.
  ///
  /// In en, this message translates to:
  /// **'No workers yet'**
  String get noWorkersYet;

  /// No description provided for @addWorkersMarketplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add workers from the marketplace'**
  String get addWorkersMarketplaceHint;

  /// No description provided for @unknownWorker.
  ///
  /// In en, this message translates to:
  /// **'Unknown Worker'**
  String get unknownWorker;

  /// No description provided for @tndMo.
  ///
  /// In en, this message translates to:
  /// **'TND/mo'**
  String get tndMo;

  /// No description provided for @workersSyncIssue.
  ///
  /// In en, this message translates to:
  /// **'Workers sync issue'**
  String get workersSyncIssue;

  /// No description provided for @invitationsSyncIssue.
  ///
  /// In en, this message translates to:
  /// **'Invitations sync issue'**
  String get invitationsSyncIssue;

  /// No description provided for @pendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// No description provided for @waitingForWorkerResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for worker response'**
  String get waitingForWorkerResponse;

  /// No description provided for @invitationDecisions.
  ///
  /// In en, this message translates to:
  /// **'Invitation Decisions'**
  String get invitationDecisions;

  /// No description provided for @workersAcceptedDeclinedInvites.
  ///
  /// In en, this message translates to:
  /// **'Workers who accepted or declined your invites'**
  String get workersAcceptedDeclinedInvites;

  /// No description provided for @aiAutoAssignTasks.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI Auto-Assign Tasks'**
  String get aiAutoAssignTasks;

  /// No description provided for @gpsVerifiedWorkProof.
  ///
  /// In en, this message translates to:
  /// **'📍 GPS-verified Work Proof'**
  String get gpsVerifiedWorkProof;

  /// No description provided for @iotSensorDashboard.
  ///
  /// In en, this message translates to:
  /// **'🌡️ IoT Sensor Dashboard'**
  String get iotSensorDashboard;

  /// No description provided for @smartPayrollIntegration.
  ///
  /// In en, this message translates to:
  /// **'💰 Smart Payroll Integration'**
  String get smartPayrollIntegration;

  /// No description provided for @freshProductsFarmers.
  ///
  /// In en, this message translates to:
  /// **'Fresh products from local farmers'**
  String get freshProductsFarmers;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noProductsFoundMarketplace.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFoundMarketplace;

  /// No description provided for @noProductsAvailableMarketplace.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailableMarketplace;

  /// No description provided for @adjustSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustSearchFilters;

  /// No description provided for @checkBackLaterFreshProducts.
  ///
  /// In en, this message translates to:
  /// **'Check back later for fresh products'**
  String get checkBackLaterFreshProducts;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK'**
  String get outOfStock;

  /// No description provided for @inBasket.
  ///
  /// In en, this message translates to:
  /// **'In basket'**
  String get inBasket;

  /// No description provided for @availableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit} available'**
  String availableCount(int count, String unit);

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: {price} TND'**
  String subtotalLabel(String price);

  /// No description provided for @seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get seller;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @verifiedSeller.
  ///
  /// In en, this message translates to:
  /// **'Verified Seller'**
  String get verifiedSeller;

  /// No description provided for @updateBasket.
  ///
  /// In en, this message translates to:
  /// **'Update Basket'**
  String get updateBasket;

  /// No description provided for @addToBasket.
  ///
  /// In en, this message translates to:
  /// **'Add to Basket'**
  String get addToBasket;

  /// No description provided for @qtySetTo.
  ///
  /// In en, this message translates to:
  /// **'{title} — qty set to {qty}'**
  String qtySetTo(String title, int qty);

  /// No description provided for @addedToBasket.
  ///
  /// In en, this message translates to:
  /// **'{title} added to basket'**
  String addedToBasket(String title);

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @orderHistoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here\nafter your first purchase.'**
  String get orderHistoryEmptyHint;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @farmyPremium.
  ///
  /// In en, this message translates to:
  /// **'Farmy Premium'**
  String get farmyPremium;

  /// No description provided for @currentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current: {name}'**
  String currentPlanLabel(String name);

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearlySave.
  ///
  /// In en, this message translates to:
  /// **'Yearly (Save 33%)'**
  String get yearlySave;

  /// No description provided for @failedToLoadSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscriptions'**
  String get failedToLoadSubscriptions;

  /// No description provided for @failedToLoadWorkerProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load worker profile'**
  String get failedToLoadWorkerProfile;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @upgradeToYearly.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Yearly'**
  String get upgradeToYearly;

  /// No description provided for @switchToMonthly.
  ///
  /// In en, this message translates to:
  /// **'Switch to Monthly'**
  String get switchToMonthly;

  /// No description provided for @downgradeToFree.
  ///
  /// In en, this message translates to:
  /// **'Downgrade to Free'**
  String get downgradeToFree;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @activeOnCycle.
  ///
  /// In en, this message translates to:
  /// **'Active on {cycle}'**
  String activeOnCycle(String cycle);

  /// No description provided for @confirmDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Confirm Downgrade'**
  String get confirmDowngrade;

  /// No description provided for @downgradeWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to downgrade to {name}? You will lose your premium features and active perks associated with your current plan.'**
  String downgradeWarning(String name);

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @totalWithCycle.
  ///
  /// In en, this message translates to:
  /// **'Total: \${price} · {cycle}'**
  String totalWithCycle(String price, String cycle);

  /// No description provided for @payWithCredits.
  ///
  /// In en, this message translates to:
  /// **'Pay with Farmy Credits'**
  String get payWithCredits;

  /// No description provided for @loadingBalance.
  ///
  /// In en, this message translates to:
  /// **'Loading balance...'**
  String get loadingBalance;

  /// No description provided for @balanceValue.
  ///
  /// In en, this message translates to:
  /// **'Balance: \${amount}'**
  String balanceValue(String amount);

  /// No description provided for @payWithStripe.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card (Stripe)'**
  String get payWithStripe;

  /// No description provided for @secureCreditCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Secure credit card payment'**
  String get secureCreditCardPayment;

  /// No description provided for @unableToLoadTracking.
  ///
  /// In en, this message translates to:
  /// **'Unable to load tracking'**
  String get unableToLoadTracking;

  /// No description provided for @noTrackingInformation.
  ///
  /// In en, this message translates to:
  /// **'No tracking information'**
  String get noTrackingInformation;

  /// No description provided for @deliveryTrackingEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Delivery tracking will appear\nonce your order is processed.'**
  String get deliveryTrackingEmptyHint;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order Delivered!'**
  String get orderDelivered;

  /// No description provided for @orderDeliveredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your order has been successfully delivered. Thank you for your purchase!'**
  String get orderDeliveredSuccess;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updating;

  /// No description provided for @profileSyncIssue.
  ///
  /// In en, this message translates to:
  /// **'Profile sync issue'**
  String get profileSyncIssue;

  /// No description provided for @assignedLandsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Assigned lands unavailable'**
  String get assignedLandsUnavailable;

  /// No description provided for @tasksUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tasks unavailable'**
  String get tasksUnavailable;

  /// No description provided for @invitationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Invitations unavailable'**
  String get invitationsUnavailable;

  /// No description provided for @contractsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contracts unavailable'**
  String get contractsUnavailable;

  /// No description provided for @proofsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Proofs unavailable'**
  String get proofsUnavailable;

  /// No description provided for @viewAllHistory.
  ///
  /// In en, this message translates to:
  /// **'View All History'**
  String get viewAllHistory;

  /// No description provided for @noLandAssignmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No land assignments yet'**
  String get noLandAssignmentsYet;

  /// No description provided for @landAssignmentsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see your assigned lands here'**
  String get landAssignmentsEmptyHint;

  /// No description provided for @noTasksAssigned.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned'**
  String get noTasksAssigned;

  /// No description provided for @tasksEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tasks will appear here when assigned'**
  String get tasksEmptyHint;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @realtimeNotificationsSoon.
  ///
  /// In en, this message translates to:
  /// **'Real-time task notifications coming soon'**
  String get realtimeNotificationsSoon;

  /// No description provided for @verifiedWorker.
  ///
  /// In en, this message translates to:
  /// **'Verified Worker'**
  String get verifiedWorker;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// No description provided for @invitationAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted successfully.'**
  String get invitationAcceptedSuccess;

  /// No description provided for @invitationDeclinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined successfully.'**
  String get invitationDeclinedSuccess;

  /// No description provided for @unableToProcessInvitation.
  ///
  /// In en, this message translates to:
  /// **'Unable to process invitation response.'**
  String get unableToProcessInvitation;

  /// No description provided for @landBoundary.
  ///
  /// In en, this message translates to:
  /// **'Land Boundary'**
  String get landBoundary;

  /// No description provided for @landInformation.
  ///
  /// In en, this message translates to:
  /// **'Land Information'**
  String get landInformation;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @assignmentRole.
  ///
  /// In en, this message translates to:
  /// **'Assignment Role'**
  String get assignmentRole;

  /// No description provided for @salaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salaryLabel;

  /// No description provided for @salaryValue.
  ///
  /// In en, this message translates to:
  /// **'\${amount} / month'**
  String salaryValue(String amount);

  /// No description provided for @assignmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Assignment Status'**
  String get assignmentStatus;

  /// No description provided for @farmerProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Farmer profile is unavailable right now.'**
  String get farmerProfileUnavailable;

  /// No description provided for @unableToOpenFarmerProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to open farmer profile. Please retry.'**
  String get unableToOpenFarmerProfile;

  /// No description provided for @invitationApproved.
  ///
  /// In en, this message translates to:
  /// **'Invitation Approved'**
  String get invitationApproved;

  /// No description provided for @invitationPending.
  ///
  /// In en, this message translates to:
  /// **'Invitation Pending'**
  String get invitationPending;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation Declined'**
  String get invitationDeclined;

  /// No description provided for @invitationExpired.
  ///
  /// In en, this message translates to:
  /// **'Invitation Expired'**
  String get invitationExpired;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @acceptThisOfferQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept this offer?'**
  String get acceptThisOfferQuestion;

  /// No description provided for @acceptOfferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You are about to accept the offer of \${amount} {type}. This will establish a legal contract.'**
  String acceptOfferConfirmation(String amount, String type);

  /// No description provided for @contractApproved.
  ///
  /// In en, this message translates to:
  /// **'Contract approved! Waiting for investor payment.'**
  String get contractApproved;

  /// No description provided for @failedToAccept.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept offer.'**
  String get failedToAccept;

  /// No description provided for @declineThisOfferQuestion.
  ///
  /// In en, this message translates to:
  /// **'Decline this offer?'**
  String get declineThisOfferQuestion;

  /// No description provided for @declineOfferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to decline the offer from {name}?'**
  String declineOfferConfirmation(String name);

  /// No description provided for @theInvestor.
  ///
  /// In en, this message translates to:
  /// **'the investor'**
  String get theInvestor;

  /// No description provided for @contractDeclined.
  ///
  /// In en, this message translates to:
  /// **'Contract offer declined.'**
  String get contractDeclined;

  /// No description provided for @failedToDecline.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline offer.'**
  String get failedToDecline;

  /// No description provided for @pleaseEnterAMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get pleaseEnterAMessage;

  /// No description provided for @pleaseEnterValidSalary.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid salary amount'**
  String get pleaseEnterValidSalary;

  /// No description provided for @counterOfferSent.
  ///
  /// In en, this message translates to:
  /// **'Counter-offer sent successfully!'**
  String get counterOfferSent;

  /// No description provided for @failedToSendCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Failed to send counter-offer.'**
  String get failedToSendCounterOffer;

  /// No description provided for @messageCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get messageCannotBeEmpty;

  /// No description provided for @messageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Message updated successfully'**
  String get messageUpdated;

  /// No description provided for @failedToEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update message'**
  String get failedToEditMessage;

  /// No description provided for @withdrawMessageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this message?'**
  String get withdrawMessageQuestion;

  /// No description provided for @withdrawMessageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove your last negotiation message.'**
  String get withdrawMessageConfirmation;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @messageWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Message withdrawn'**
  String get messageWithdrawn;

  /// No description provided for @failedToWithdrawMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to withdraw message'**
  String get failedToWithdrawMessage;

  /// No description provided for @investorAcceptOfferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You are about to accept {name}\'s counter-offer of \${amount} {type}. Once accepted, you must pay the first month\'s salary to activate the contract.'**
  String investorAcceptOfferConfirmation(
    String name,
    String amount,
    String type,
  );

  /// No description provided for @theWorker.
  ///
  /// In en, this message translates to:
  /// **'the worker'**
  String get theWorker;

  /// No description provided for @offerAcceptedProceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted! Please proceed to payment to activate the contract.'**
  String get offerAcceptedProceedToPayment;

  /// No description provided for @declineNegotiationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Decline negotiation?'**
  String get declineNegotiationQuestion;

  /// No description provided for @declineNegotiationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to decline further negotiations with {name}?'**
  String declineNegotiationConfirmation(String name);

  /// No description provided for @thisWorker.
  ///
  /// In en, this message translates to:
  /// **'this worker'**
  String get thisWorker;

  /// No description provided for @negotiationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Negotiation declined and closed.'**
  String get negotiationDeclined;

  /// No description provided for @failedToCreatePayment.
  ///
  /// In en, this message translates to:
  /// **'Failed to create payment intent.'**
  String get failedToCreatePayment;

  /// No description provided for @contractActivated.
  ///
  /// In en, this message translates to:
  /// **'Contract activated successfully!'**
  String get contractActivated;

  /// No description provided for @invalidPaymentData.
  ///
  /// In en, this message translates to:
  /// **'Invalid payment data received from server. Please try again.'**
  String get invalidPaymentData;

  /// No description provided for @paymentSubmittedHint.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted. The contract will be activated once confirmed.'**
  String get paymentSubmittedHint;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled.'**
  String get paymentCancelled;

  /// No description provided for @contractForWorker.
  ///
  /// In en, this message translates to:
  /// **'Contract for {name}'**
  String contractForWorker(String name);

  /// No description provided for @negotiationDeclinedBanner.
  ///
  /// In en, this message translates to:
  /// **'Negotiation Declined'**
  String get negotiationDeclinedBanner;

  /// No description provided for @contractTerminatedBanner.
  ///
  /// In en, this message translates to:
  /// **'Contract Terminated'**
  String get contractTerminatedBanner;

  /// No description provided for @contractExpiredBanner.
  ///
  /// In en, this message translates to:
  /// **'Contract Expired'**
  String get contractExpiredBanner;

  /// No description provided for @contractIsStatus.
  ///
  /// In en, this message translates to:
  /// **'This contract is {status}'**
  String contractIsStatus(String status);

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startNegotiationHint.
  ///
  /// In en, this message translates to:
  /// **'Start the negotiation by sending a message.'**
  String get startNegotiationHint;

  /// No description provided for @systemOfferAccepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted. Proceeding to payment.'**
  String get systemOfferAccepted;

  /// No description provided for @systemOfferDeclined.
  ///
  /// In en, this message translates to:
  /// **'Offer declined. This negotiation has been cancelled.'**
  String get systemOfferDeclined;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @otherParty.
  ///
  /// In en, this message translates to:
  /// **'Other party'**
  String get otherParty;

  /// No description provided for @proposedSalaryAmount.
  ///
  /// In en, this message translates to:
  /// **'Proposed Salary: \${amount}'**
  String proposedSalaryAmount(String amount);

  /// No description provided for @editingYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Editing your message'**
  String get editingYourMessage;

  /// No description provided for @editYourMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Edit your message...'**
  String get editYourMessageHint;

  /// No description provided for @salaryOptional.
  ///
  /// In en, this message translates to:
  /// **'Salary (optional)'**
  String get salaryOptional;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{mins} min ago'**
  String minutesAgo(String mins);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(String hours);

  /// No description provided for @negotiateTerms.
  ///
  /// In en, this message translates to:
  /// **'Negotiate Terms'**
  String get negotiateTerms;

  /// No description provided for @salaryAmount.
  ///
  /// In en, this message translates to:
  /// **'Salary Amount'**
  String get salaryAmount;

  /// No description provided for @addAMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Add a message...'**
  String get addAMessageHint;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @counterOffer.
  ///
  /// In en, this message translates to:
  /// **'Counter-offer'**
  String get counterOffer;

  /// No description provided for @payAmountToActivate.
  ///
  /// In en, this message translates to:
  /// **'Pay \${amount} to Activate'**
  String payAmountToActivate(String amount);

  /// No description provided for @hiringPending.
  ///
  /// In en, this message translates to:
  /// **'Hiring Pending'**
  String get hiringPending;

  /// No description provided for @negotiating.
  ///
  /// In en, this message translates to:
  /// **'Negotiating'**
  String get negotiating;

  /// No description provided for @awaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get awaitingPayment;

  /// No description provided for @negotiate.
  ///
  /// In en, this message translates to:
  /// **'Negotiate'**
  String get negotiate;

  /// No description provided for @perTask.
  ///
  /// In en, this message translates to:
  /// **'per task'**
  String get perTask;

  /// No description provided for @squareMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m²'**
  String squareMeters(String value);

  /// No description provided for @amountPrefix.
  ///
  /// In en, this message translates to:
  /// **'\${amount}'**
  String amountPrefix(String amount);

  /// No description provided for @terminatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Terminated'**
  String get terminatedLabel;

  /// No description provided for @hourlyLabel.
  ///
  /// In en, this message translates to:
  /// **'per hour'**
  String get hourlyLabel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or cancelled.'**
  String paymentFailed(String error);

  /// No description provided for @farmerInfoSyncedFromAssignment.
  ///
  /// In en, this message translates to:
  /// **'Information synced from assignment'**
  String get farmerInfoSyncedFromAssignment;

  /// No description provided for @tapToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Tap to view profile'**
  String get tapToViewProfile;

  /// No description provided for @salaryPerMonth.
  ///
  /// In en, this message translates to:
  /// **'\${amount} / month'**
  String salaryPerMonth(String amount);

  /// No description provided for @revenueAnalysisPrompt.
  ///
  /// In en, this message translates to:
  /// **'Analyze my revenue sources and suggest ways to maximize my profits based on current market trends.'**
  String get revenueAnalysisPrompt;

  /// No description provided for @analyzeRevenueTooltip.
  ///
  /// In en, this message translates to:
  /// **'Analyze Revenue'**
  String get analyzeRevenueTooltip;

  /// No description provided for @totalDetailsRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Details Revenue'**
  String get totalDetailsRevenue;

  /// No description provided for @creditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsLabel;

  /// No description provided for @productSales.
  ///
  /// In en, this message translates to:
  /// **'Product Sales'**
  String get productSales;

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsLabel;

  /// No description provided for @investmentRevenue.
  ///
  /// In en, this message translates to:
  /// **'Investment Revenue'**
  String get investmentRevenue;

  /// No description provided for @viewInvestmentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'View detailed breakdown in Investments'**
  String get viewInvestmentBreakdown;

  /// No description provided for @portfolioInsights.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Insights'**
  String get portfolioInsights;

  /// No description provided for @premiumLabel.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premiumLabel;

  /// No description provided for @unlockPortfolioMaster.
  ///
  /// In en, this message translates to:
  /// **'Unlock Portfolio Master'**
  String get unlockPortfolioMaster;

  /// No description provided for @premiumPortfolioDesc.
  ///
  /// In en, this message translates to:
  /// **'Get real-time ROI tracking, automated dividend reports, and AI-powered investment advice.'**
  String get premiumPortfolioDesc;

  /// No description provided for @investorPlus.
  ///
  /// In en, this message translates to:
  /// **'Investor Plus'**
  String get investorPlus;

  /// No description provided for @portfolioAnalyticsLoading.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Analytics Loading...'**
  String get portfolioAnalyticsLoading;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get createNewPassword;

  /// No description provided for @passwordPolicyHint.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previous used passwords.'**
  String get passwordPolicyHint;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get enterCurrentPasswordError;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @profileSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync profile: {error}'**
  String profileSyncFailed(String error);

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get unsavedChangesDesc;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @waitUsernameCheck.
  ///
  /// In en, this message translates to:
  /// **'Please wait for username availability check'**
  String get waitUsernameCheck;

  /// No description provided for @correctErrorsInForm.
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form'**
  String get correctErrorsInForm;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get usernameTaken;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @identityTab.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identityTab;

  /// No description provided for @trustTab.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get trustTab;

  /// No description provided for @rolePrivacyTab.
  ///
  /// In en, this message translates to:
  /// **'Role & Privacy'**
  String get rolePrivacyTab;

  /// No description provided for @saveChangesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesTooltip;

  /// No description provided for @profileCompleteness.
  ///
  /// In en, this message translates to:
  /// **'Profile Completeness'**
  String get profileCompleteness;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get nameTooShort;

  /// No description provided for @onlyLettersAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only letters and spaces allowed'**
  String get onlyLettersAllowed;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @publicUniqueHandle.
  ///
  /// In en, this message translates to:
  /// **'Public unique handle'**
  String get publicUniqueHandle;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @tooShortMin3.
  ///
  /// In en, this message translates to:
  /// **'Too short (min 3)'**
  String get tooShortMin3;

  /// No description provided for @usernameFormatError.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase, numbers, dots, underscores'**
  String get usernameFormatError;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @invalidPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone format'**
  String get invalidPhoneFormat;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @headlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get headlineLabel;

  /// No description provided for @headlineHint.
  ///
  /// In en, this message translates to:
  /// **'A short description of what you do'**
  String get headlineHint;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @portfolioLinks.
  ///
  /// In en, this message translates to:
  /// **'Portfolio & Links'**
  String get portfolioLinks;

  /// No description provided for @linkedinProfile.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn Profile'**
  String get linkedinProfile;

  /// No description provided for @linkedinUrlError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid LinkedIn URL or handle'**
  String get linkedinUrlError;

  /// No description provided for @personalWebsite.
  ///
  /// In en, this message translates to:
  /// **'Personal Website'**
  String get personalWebsite;

  /// No description provided for @websiteUrlError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid website URL'**
  String get websiteUrlError;

  /// No description provided for @farmerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer Details'**
  String get farmerDetailsTitle;

  /// No description provided for @businessFarmName.
  ///
  /// In en, this message translates to:
  /// **'Business/Farm Name'**
  String get businessFarmName;

  /// No description provided for @investorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Investor Details'**
  String get investorDetailsTitle;

  /// No description provided for @expectedBudgetRange.
  ///
  /// In en, this message translates to:
  /// **'Expected Budget Range'**
  String get expectedBudgetRange;

  /// No description provided for @budgetRangeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \$10,000 - \$50,000'**
  String get budgetRangeHint;

  /// No description provided for @privacyControls.
  ///
  /// In en, this message translates to:
  /// **'Privacy Controls'**
  String get privacyControls;

  /// No description provided for @discoverableMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Discoverable in Marketplace'**
  String get discoverableMarketplace;

  /// No description provided for @discoverableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let others find and view your profile'**
  String get discoverableSubtitle;

  /// No description provided for @showContactInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Show Contact Info'**
  String get showContactInfoLabel;

  /// No description provided for @showContactInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make phone and email visible to connections'**
  String get showContactInfoSubtitle;

  /// No description provided for @failedInitiate2FA.
  ///
  /// In en, this message translates to:
  /// **'Failed to initiate 2FA setup'**
  String get failedInitiate2FA;

  /// No description provided for @twoFAEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'2FA enabled successfully'**
  String get twoFAEnabledSuccess;

  /// No description provided for @twoFADisabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'2FA disabled successfully'**
  String get twoFADisabledSuccess;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @disable2FA.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get disable2FA;

  /// No description provided for @enable2FA.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get enable2FA;

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure Your Account'**
  String get secureYourAccount;

  /// No description provided for @twoFADesc.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication adds an extra layer of security to your account. To log in, you will need to provide a 6-digit code from your authenticator app.'**
  String get twoFADesc;

  /// No description provided for @startSetup.
  ///
  /// In en, this message translates to:
  /// **'Start Setup'**
  String get startSetup;

  /// No description provided for @linkYourAppStep.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Link your app'**
  String get linkYourAppStep;

  /// No description provided for @scanQRCodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your Authenticator App (Google Authenticator, Authy, etc.)'**
  String get scanQRCodeDesc;

  /// No description provided for @enterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Or enter this code manually:'**
  String get enterCodeManually;

  /// No description provided for @copyToClipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboardTooltip;

  /// No description provided for @confirmEnablementStep.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Confirm Enablement'**
  String get confirmEnablementStep;

  /// No description provided for @enter6DigitCodeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your app to confirm:'**
  String get enter6DigitCodeConfirm;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @enter6DigitCodeDisable.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app to disable two-factor authentication.'**
  String get enter6DigitCodeDisable;

  /// No description provided for @allNotificationsMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedRead;

  /// No description provided for @failedToDeleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete notification'**
  String get failedToDeleteNotification;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllAsReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsReadTooltip;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @premiumAccess.
  ///
  /// In en, this message translates to:
  /// **'Premium Access'**
  String get premiumAccess;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @subscriptionHeadline.
  ///
  /// In en, this message translates to:
  /// **'Select a plan to unlock the full Farmy experience.\nOne subscription opens every door.'**
  String get subscriptionHeadline;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @alwaysFree.
  ///
  /// In en, this message translates to:
  /// **'Always Free'**
  String get alwaysFree;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeLabel;

  /// No description provided for @monthlySuffix.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get monthlySuffix;

  /// No description provided for @yearlySuffix.
  ///
  /// In en, this message translates to:
  /// **'/yr'**
  String get yearlySuffix;

  /// No description provided for @savingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Was {oldPrice}/yr — save {savings}'**
  String savingsLabel(String oldPrice, String savings);

  /// No description provided for @continueWithFree.
  ///
  /// In en, this message translates to:
  /// **'Continue with Free'**
  String get continueWithFree;

  /// No description provided for @getPlan.
  ///
  /// In en, this message translates to:
  /// **'Get {planName}'**
  String getPlan(String planName);

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'{price} · {cycle} · {planName}'**
  String paymentSummary(String price, String cycle, String planName);

  /// No description provided for @balanceStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount} ✓'**
  String balanceStatusSuccess(String amount);

  /// No description provided for @balanceStatusInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount} — Insufficient'**
  String balanceStatusInsufficient(String amount);

  /// No description provided for @payWithCardStripe.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card (Stripe)'**
  String get payWithCardStripe;

  /// No description provided for @secureCardPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Secure credit / debit card payment'**
  String get secureCardPaymentDesc;

  /// No description provided for @failedLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans'**
  String get failedLoadPlans;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailable;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Please contact support.'**
  String get contactSupport;

  /// No description provided for @paymentPendingVerifying.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted. We are verifying it in the background.'**
  String get paymentPendingVerifying;

  /// No description provided for @paymentProcessingSync.
  ///
  /// In en, this message translates to:
  /// **'Payment is still processing. Your subscription will sync automatically.'**
  String get paymentProcessingSync;

  /// No description provided for @paymentStatusDelay.
  ///
  /// In en, this message translates to:
  /// **'Payment status check is delayed. We will keep syncing in the background.'**
  String get paymentStatusDelay;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment Error: {error}'**
  String paymentError(String error);

  /// No description provided for @deliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveriesTitle;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{total} total'**
  String totalCount(String total);

  /// No description provided for @totalOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrdersLabel;

  /// No description provided for @deliveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredLabel;

  /// No description provided for @noDeliveriesYet.
  ///
  /// In en, this message translates to:
  /// **'No deliveries yet'**
  String get noDeliveriesYet;

  /// No description provided for @noDeliveriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Deliveries for your products will\nappear here when customers order.'**
  String get noDeliveriesDesc;

  /// No description provided for @manageDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Delivery'**
  String get manageDeliveryTitle;

  /// No description provided for @deliveryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Delivery not found'**
  String get deliveryNotFound;

  /// No description provided for @deliveryTimeline.
  ///
  /// In en, this message translates to:
  /// **'Delivery Timeline'**
  String get deliveryTimeline;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @etaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA: {time}'**
  String etaLabel(String time);

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @orderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderIdLabel;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @deliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery Info'**
  String get deliveryInfo;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get startedLabel;

  /// No description provided for @cancelDeliveryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel Delivery?'**
  String get cancelDeliveryQuestion;

  /// No description provided for @updateToStatusQuestion.
  ///
  /// In en, this message translates to:
  /// **'Update to {status}?'**
  String updateToStatusQuestion(String status);

  /// No description provided for @cancelNotifyCustomer.
  ///
  /// In en, this message translates to:
  /// **'This will cancel the delivery and notify the customer.'**
  String get cancelNotifyCustomer;

  /// No description provided for @advanceNotifyCustomer.
  ///
  /// In en, this message translates to:
  /// **'This will advance the delivery to \"{status}\" and notify the customer.'**
  String advanceNotifyCustomer(String status);

  /// No description provided for @cancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for cancellation...'**
  String get cancellationReasonHint;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)...'**
  String get addNoteHint;

  /// No description provided for @confirmUpdate.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmUpdate;

  /// No description provided for @cancelDeliveryAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Delivery'**
  String get cancelDeliveryAction;

  /// No description provided for @statusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @failedUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status'**
  String get failedUpdateStatus;

  /// No description provided for @moveToStatus.
  ///
  /// In en, this message translates to:
  /// **'Move to {status}'**
  String moveToStatus(String status);

  /// No description provided for @successfullyDelivered.
  ///
  /// In en, this message translates to:
  /// **'Successfully Delivered'**
  String get successfullyDelivered;

  /// No description provided for @deliveryCancelled.
  ///
  /// In en, this message translates to:
  /// **'Delivery Cancelled'**
  String get deliveryCancelled;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String completedOn(String date);

  /// No description provided for @dateTimeAt.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateTimeAt(String date, String time);

  /// No description provided for @cardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAddedSuccess;

  /// No description provided for @failedAddCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to add card'**
  String get failedAddCard;

  /// No description provided for @addCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Credits'**
  String get addCreditsTitle;

  /// No description provided for @selectAmount.
  ///
  /// In en, this message translates to:
  /// **'Select Amount'**
  String get selectAmount;

  /// No description provided for @customAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmountLabel;

  /// No description provided for @maxAmountError.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount is \$999,999.99'**
  String get maxAmountError;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'PAY \${amount}'**
  String payAmount(String amount);

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'ENTER AMOUNT'**
  String get enterAmount;

  /// No description provided for @successfullyAddedCredits.
  ///
  /// In en, this message translates to:
  /// **'Successfully added \${amount}'**
  String successfullyAddedCredits(String amount);

  /// No description provided for @priceTnd.
  ///
  /// In en, this message translates to:
  /// **'{price} TND'**
  String priceTnd(String price);

  /// No description provided for @failedAddCredits.
  ///
  /// In en, this message translates to:
  /// **'Failed to add credits'**
  String get failedAddCredits;

  /// No description provided for @walletPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Payments'**
  String get walletPaymentsTitle;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @expiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires {expiry}'**
  String expiresLabel(String expiry);

  /// No description provided for @failedLoadTasks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tasks'**
  String get failedLoadTasks;

  /// No description provided for @errorFetchingTasks.
  ///
  /// In en, this message translates to:
  /// **'Error fetching your tasks'**
  String get errorFetchingTasks;

  /// No description provided for @taskCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task completed! You are now available.'**
  String get taskCompletedSuccess;

  /// No description provided for @failedCompleteTask.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete task'**
  String get failedCompleteTask;

  /// No description provided for @errorWithPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithPrefix(String error);

  /// No description provided for @myTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasksTitle;

  /// No description provided for @noPendingTasks.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks!'**
  String get noPendingTasks;

  /// No description provided for @availableForAssignments.
  ///
  /// In en, this message translates to:
  /// **'You are available for new assignments.'**
  String get availableForAssignments;

  /// No description provided for @taskLabel.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskLabel;

  /// No description provided for @unknownCaps.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get unknownCaps;

  /// No description provided for @minsSuffix.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get minsSuffix;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @productionGuruTitle.
  ///
  /// In en, this message translates to:
  /// **'Production Guru'**
  String get productionGuruTitle;

  /// No description provided for @sessionHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistoryTooltip;

  /// No description provided for @newSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSessionTooltip;

  /// No description provided for @askGuruHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your guru...'**
  String get askGuruHint;

  /// No description provided for @harvestChroniclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Harvest Chronicles'**
  String get harvestChroniclesTitle;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @farmAnalysisDefault.
  ///
  /// In en, this message translates to:
  /// **'Farm Analysis'**
  String get farmAnalysisDefault;

  /// No description provided for @assetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assetsLabel;

  /// No description provided for @failedReachAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Failed to reach AI Strategy Analyst.'**
  String get failedReachAnalyst;

  /// No description provided for @strategicPortfolioAnalystTitle.
  ///
  /// In en, this message translates to:
  /// **'Strategic Portfolio Analyst'**
  String get strategicPortfolioAnalystTitle;

  /// No description provided for @investmentStrategyChroniclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Investment Strategy Chronicles'**
  String get investmentStrategyChroniclesTitle;

  /// No description provided for @strategySessionDefault.
  ///
  /// In en, this message translates to:
  /// **'Strategy Session'**
  String get strategySessionDefault;

  /// No description provided for @welcomeStrategicAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Strategic Analysis'**
  String get welcomeStrategicAnalysis;

  /// No description provided for @investmentAgentWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell me your budget and risk preference, or ask about current market and weather trends.'**
  String get investmentAgentWelcomeDesc;

  /// No description provided for @consultedLiveData.
  ///
  /// In en, this message translates to:
  /// **'Consulted Live Data:'**
  String get consultedLiveData;

  /// No description provided for @marketLabel.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketLabel;

  /// No description provided for @weatherLabel.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherLabel;

  /// No description provided for @suggestedRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Suggested Real Estate:'**
  String get suggestedRealEstate;

  /// No description provided for @unknownFarm.
  ///
  /// In en, this message translates to:
  /// **'Unknown Farm'**
  String get unknownFarm;

  /// No description provided for @tndPerMeter.
  ///
  /// In en, this message translates to:
  /// **'TND/m'**
  String get tndPerMeter;

  /// No description provided for @enterPreferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter preferences or ask analysis...'**
  String get enterPreferencesHint;

  /// No description provided for @laborMarketLabel.
  ///
  /// In en, this message translates to:
  /// **'LABOR MARKET'**
  String get laborMarketLabel;

  /// No description provided for @specificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Specifications:'**
  String get specificationsLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @sellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerLabel;

  /// No description provided for @cancellationReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancellationReasonLabel;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @arrivingSoon.
  ///
  /// In en, this message translates to:
  /// **'Arriving soon'**
  String get arrivingSoon;

  /// No description provided for @etaMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{mins} min'**
  String etaMinutes(String mins);

  /// No description provided for @etaHours.
  ///
  /// In en, this message translates to:
  /// **'~{hours}h {mins}min'**
  String etaHours(String hours, String mins);

  /// No description provided for @driverNearby.
  ///
  /// In en, this message translates to:
  /// **'Driver Nearby!'**
  String get driverNearby;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onTheWay;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get filterNew;

  /// No description provided for @filterConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get filterConfirmed;

  /// No description provided for @filterPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get filterPreparing;

  /// No description provided for @filterInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get filterInTransit;

  /// No description provided for @filterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get filterDelivered;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @unknownCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Customer'**
  String get unknownCustomer;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @manageButton.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageButton;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @qtyUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'{title} — qty updated to {qty}'**
  String qtyUpdatedTo(String title, String qty);

  /// No description provided for @maximumStockReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum stock reached'**
  String get maximumStockReached;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'{price} TND / {unit}'**
  String pricePerUnit(String price, String unit);

  /// No description provided for @premiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeatureTitle;

  /// No description provided for @premiumFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your subscription to unlock this feature.'**
  String get premiumFeatureDesc;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @upgradeRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'This feature ({featureKey}) is available on a premium plan. Upgrade your subscription to unlock it.'**
  String upgradeRequiredDesc(String featureKey);

  /// No description provided for @laterButton.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterButton;

  /// No description provided for @myLandsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Lands'**
  String get myLandsTitle;

  /// No description provided for @noLandsFound.
  ///
  /// In en, this message translates to:
  /// **'No lands found'**
  String get noLandsFound;

  /// No description provided for @noLandsRented.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t rented any lands yet.'**
  String get noLandsRented;

  /// No description provided for @landActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get landActive;

  /// No description provided for @landInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get landInactive;

  /// No description provided for @landsRented.
  ///
  /// In en, this message translates to:
  /// **'Lands Rented'**
  String get landsRented;

  /// No description provided for @completenessLabel.
  ///
  /// In en, this message translates to:
  /// **'Completeness'**
  String get completenessLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @directLinksLabel.
  ///
  /// In en, this message translates to:
  /// **'Direct Links'**
  String get directLinksLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @farmyMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Farmy Community Member since {date}'**
  String farmyMemberSince(String date);

  /// No description provided for @privacyRestricted.
  ///
  /// In en, this message translates to:
  /// **'Privacy Restricted'**
  String get privacyRestricted;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found or private'**
  String get profileNotFound;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile. Please check your connection.'**
  String get profileLoadError;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @upgradeForUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Upgrade{plan} for unlimited access'**
  String upgradeForUnlimited(String plan);

  /// No description provided for @tapToViewPlans.
  ///
  /// In en, this message translates to:
  /// **'Tap to view plans →'**
  String get tapToViewPlans;

  /// No description provided for @assignTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Task'**
  String get assignTaskTitle;

  /// No description provided for @workersAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} Available'**
  String workersAvailable(String count);

  /// No description provided for @noTasksDefined.
  ///
  /// In en, this message translates to:
  /// **'No tasks defined for this item.'**
  String get noTasksDefined;

  /// No description provided for @noAvailableWorkers.
  ///
  /// In en, this message translates to:
  /// **'No available workers!'**
  String get noAvailableWorkers;

  /// No description provided for @taskAssigned.
  ///
  /// In en, this message translates to:
  /// **'Task assigned!'**
  String get taskAssigned;

  /// No description provided for @assignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assignButton;

  /// No description provided for @myTasksOnLand.
  ///
  /// In en, this message translates to:
  /// **'My Tasks on this Land'**
  String get myTasksOnLand;

  /// No description provided for @noPendingTasksHere.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks here!'**
  String get noPendingTasksHere;

  /// No description provided for @availableForAssignment.
  ///
  /// In en, this message translates to:
  /// **'You are available for assignments.'**
  String get availableForAssignment;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed! You are now available.'**
  String get taskCompleted;

  /// No description provided for @markCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markCompleteButton;

  /// No description provided for @errorFetchingYourTasks.
  ///
  /// In en, this message translates to:
  /// **'Error fetching your tasks'**
  String get errorFetchingYourTasks;

  /// No description provided for @closeTip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTip;

  /// No description provided for @farmyStore.
  ///
  /// In en, this message translates to:
  /// **'FARMY STORE'**
  String get farmyStore;

  /// No description provided for @nothingFoundHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing found here'**
  String get nothingFoundHere;

  /// No description provided for @shopBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get shopBack;

  /// No description provided for @shopVariants.
  ///
  /// In en, this message translates to:
  /// **'VARIANTS'**
  String get shopVariants;

  /// No description provided for @shopBuy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get shopBuy;

  /// No description provided for @mustRentLand.
  ///
  /// In en, this message translates to:
  /// **'You must rent a land to buy items.'**
  String get mustRentLand;

  /// No description provided for @selectLand.
  ///
  /// In en, this message translates to:
  /// **'Select Land'**
  String get selectLand;

  /// No description provided for @unknownLand.
  ///
  /// In en, this message translates to:
  /// **'Unknown Land'**
  String get unknownLand;

  /// No description provided for @purchaseRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent! Transaction recorded on Hedera.'**
  String get purchaseRequestSent;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Insufficient credits?'**
  String get purchaseFailed;

  /// No description provided for @topUpCredits.
  ///
  /// In en, this message translates to:
  /// **'TOP UP CREDITS'**
  String get topUpCredits;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmount;

  /// No description provided for @maximumAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount is \${max}'**
  String maximumAmount(String max);

  /// No description provided for @creditsAdded.
  ///
  /// In en, this message translates to:
  /// **'Successfully added \${amount}!'**
  String creditsAdded(String amount);

  /// No description provided for @myInventory.
  ///
  /// In en, this message translates to:
  /// **'MY INVENTORY'**
  String get myInventory;

  /// No description provided for @allLands.
  ///
  /// In en, this message translates to:
  /// **'All Lands'**
  String get allLands;

  /// No description provided for @unknownLandFallback.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLandFallback;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get tabAll;

  /// No description provided for @tabPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get tabPending;

  /// No description provided for @tabApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get tabApproved;

  /// No description provided for @tabRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get tabRejected;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No {status} items found'**
  String noItemsFound(String status);

  /// No description provided for @placedBadge.
  ///
  /// In en, this message translates to:
  /// **'PLACED'**
  String get placedBadge;

  /// No description provided for @itemActions.
  ///
  /// In en, this message translates to:
  /// **'Item Actions'**
  String get itemActions;

  /// No description provided for @alreadyPlaced.
  ///
  /// In en, this message translates to:
  /// **'Already Placed'**
  String get alreadyPlaced;

  /// No description provided for @addToLand.
  ///
  /// In en, this message translates to:
  /// **'Add to Land'**
  String get addToLand;

  /// No description provided for @wrongLand.
  ///
  /// In en, this message translates to:
  /// **'Wrong Land'**
  String get wrongLand;

  /// No description provided for @alreadyPlacedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This item is already on the map.'**
  String get alreadyPlacedSubtitle;

  /// No description provided for @wrongLandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This item belongs to another land.'**
  String get wrongLandSubtitle;

  /// No description provided for @buyMore.
  ///
  /// In en, this message translates to:
  /// **'Buy More'**
  String get buyMore;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Please try again.'**
  String get failedToLoadData;

  /// No description provided for @failedToLoadInventory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load inventory. Please try again.'**
  String get failedToLoadInventory;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development. You will be able to place items on your land soon!'**
  String get comingSoonDesc;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @gotItButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItButton;

  /// No description provided for @placingItem.
  ///
  /// In en, this message translates to:
  /// **'Placing item...'**
  String get placingItem;

  /// No description provided for @itemPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item placed successfully!'**
  String get itemPlacedSuccess;

  /// No description provided for @placingLabel.
  ///
  /// In en, this message translates to:
  /// **'Placing: {name}'**
  String placingLabel(String name);

  /// No description provided for @loadingFootprint.
  ///
  /// In en, this message translates to:
  /// **'Loading footprint...'**
  String get loadingFootprint;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {w}x{h}'**
  String sizeLabel(String w, String h);

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @failedToLoadFarm.
  ///
  /// In en, this message translates to:
  /// **'Failed to load farm'**
  String get failedToLoadFarm;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// No description provided for @menuWorkforce.
  ///
  /// In en, this message translates to:
  /// **'Workforce'**
  String get menuWorkforce;

  /// No description provided for @menuMyTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get menuMyTasks;

  /// No description provided for @menuAiAdvisor.
  ///
  /// In en, this message translates to:
  /// **'AI Advisor'**
  String get menuAiAdvisor;

  /// No description provided for @menuInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get menuInventory;

  /// No description provided for @menuShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get menuShop;

  /// No description provided for @menuExitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get menuExitGame;

  /// No description provided for @mapTooltipInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get mapTooltipInfo;

  /// No description provided for @mapTooltipMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get mapTooltipMove;

  /// No description provided for @mapTooltipTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get mapTooltipTasks;

  /// No description provided for @placementFailed.
  ///
  /// In en, this message translates to:
  /// **'Placement failed: {error}'**
  String placementFailed(String error);

  /// No description provided for @placementFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to place item. Try elsewhere.'**
  String get placementFailedGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
