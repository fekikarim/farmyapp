import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/stripe_runtime_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/land_provider.dart';
import 'providers/product_provider.dart';
import 'providers/basket_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/banned_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/main_screen.dart';
import 'screens/auth/verify_2fa_screen.dart';
import 'screens/no_internet_screen.dart';
import 'screens/customer/subscriptions_screen.dart';
import 'screens/subscription/mandatory_pricing_screen.dart';
import 'theme/app_theme.dart';
import 'providers/wallet_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/worker_lifecycle_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/vendor_delivery_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

import 'providers/game_provider.dart';
import 'widgets/edge_panel.dart';

import 'utils/global_keys.dart';

// Global RouteObserver for focus management
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Unhandled Flutter error: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled async error: $error');
    return true;
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.initialize();
  await dotenv.load(fileName: ".env");
  await StripeRuntimeService.bootstrap();

  // Load saved theme
  final prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme_mode');
  ThemeMode initialTheme = ThemeMode.light; // Default to light
  if (savedTheme == 'dark') {
    initialTheme = ThemeMode.dark;
  } else if (savedTheme == 'system') {
    initialTheme = ThemeMode.system;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LandProvider()),
          ChangeNotifierProvider(create: (_) => GameProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => BasketProvider()),
          ChangeNotifierProvider(create: (_) => WorkerProvider()),
          ChangeNotifierProvider(create: (_) => WorkerLifecycleProvider()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => DeliveryProvider()),
          ChangeNotifierProvider(create: (_) => VendorDeliveryProvider()),
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(initialThemeMode: initialTheme),
          ),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'Farmy',
          locale: localeProvider.locale,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
            Locale('es'), // Spanish
          ],
          navigatorObservers: [routeObserver],
          builder: (context, child) {
            return GameEdgePanelOverlay(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: child,
              ),
            );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/verify-2fa': (context) => const Verify2FAScreen(),
            '/main': (context) => const MainScreen(),
            '/subscriptions': (context) => const SubscriptionsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/reset-password') {
              final email = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(email: email),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _socketConnected = false;
  bool _isReconcilingPendingStripePayment = false;

  // Guards — prevent repeat initialisation across rebuilds
  bool _initDone = false;
  bool _subscriptionCheckStarted = false;

  WorkerLifecycleProvider? _lifecycle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lifecycle = context.read<WorkerLifecycleProvider>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycle?.disposeSocket();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    _reconcilePendingStripePayment();
  }

  void _connectSocket() {
    if (_socketConnected) return;
    _socketConnected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WorkerLifecycleProvider>().initSocket();
    });
  }

  Future<void> _reconcilePendingStripePayment() async {
    if (_isReconcilingPendingStripePayment || !mounted) return;
    _isReconcilingPendingStripePayment = true;

    try {
      final status = await context
          .read<SubscriptionProvider>()
          .reconcilePendingStripePayment();

      if (!mounted) return;

      if (status == 'succeeded') {
        context.read<SubscriptionProvider>().markSubscribed();
        await context.read<AuthProvider>().refreshUser();
      }
    } finally {
      _isReconcilingPendingStripePayment = false;
    }
  }

  Future<void> _runSubscriptionCheck() async {
    await _reconcilePendingStripePayment();
    if (!mounted) return;
    await context.read<SubscriptionProvider>().checkSubscriptionExistence();
  }

  void _disconnectSocket() {
    if (!_socketConnected) return;
    _socketConnected = false;
    context.read<WorkerLifecycleProvider>().disposeSocket();
  }

  /// Called from build() — starts the async check ONCE via post-frame callback.
  /// Never calls setState() directly; the provider's notifyListeners() drives rebuilds.
  void _maybeStartSubscriptionCheck() {
    if (_subscriptionCheckStarted) return;
    final subProvider = context.read<SubscriptionProvider>();
    // Already determined — no need to query API
    if (subProvider.hasSubscription != null) {
      _subscriptionCheckStarted = true;
      return;
    }
    _subscriptionCheckStarted = true;
    // Defer to avoid triggering side effects during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runSubscriptionCheck();
    });
  }

  /// Called from build() when user logs out — resets ALL flags for next login.
  void _handleLogout() {
    if (_subscriptionCheckStarted || _initDone) {
      _subscriptionCheckStarted = false;
      _initDone = false;
      _isReconcilingPendingStripePayment = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SubscriptionProvider>().resetSubscriptionCheck();
        }
      });
    }
  }

  /// Ensures subscription data is loaded for the current user.
  /// Covers the case where didChangeDependencies already fired but
  /// _initDone was still true from the previous session.
  void _maybeInitSubscription() {
    if (_initDone) return;
    _initDone = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        context.read<SubscriptionProvider>().init(
          role: authProvider.user?.role,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pure reads — no side effects, no setState, no async calls here
    final authProvider = Provider.of<AuthProvider>(context);
    final subProvider = Provider.of<SubscriptionProvider>(context);

    // ── Initialising ─────────────────────────────────────────────────────────
    if (authProvider.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ── Network error ─────────────────────────────────────────────────────────
    if (authProvider.hasConnectionError) {
      return NoInternetScreen(onRetry: authProvider.retryLoadUser);
    }

    // ── Authenticated ─────────────────────────────────────────────────────────
    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      if (user != null) {
        if (user.isBanned) return const BannedScreen();
        if (!user.isVerified) return const VerifyScreen();
      }

      // Ensure subscription data is initialized for the current user
      _maybeInitSubscription();

      // Kick off subscription existence check (safe — runs in post-frame)
      _maybeStartSubscriptionCheck();

      // Waiting for the check to complete
      if (subProvider.isCheckingSubscription ||
          subProvider.hasSubscription == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // No subscription history → mandatory pricing gate
      if (subProvider.hasSubscription == false) {
        return const MandatoryPricingScreen();
      }

      // All good → main app
      _connectSocket();
      return const MainScreen();
    }

    // ── Logged out ────────────────────────────────────────────────────────────
    _handleLogout();
    _disconnectSocket();
    return const LoginScreen();
  }
}
