import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'theme/app_theme.dart';
import 'providers/wallet_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/worker_lifecycle_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';

import 'providers/game_provider.dart';
import 'widgets/game_bubble.dart';

import 'utils/global_keys.dart';

// Global RouteObserver for focus management
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LandProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BasketProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => WorkerLifecycleProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialThemeMode: initialTheme),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Farmy',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          navigatorObservers: [routeObserver],
          builder: (context, child) {
            return GameBubbleOverlay(
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

class _AuthWrapperState extends State<AuthWrapper> {
  bool _socketConnected = false;

  WorkerLifecycleProvider? _lifecycle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lifecycle = context.read<WorkerLifecycleProvider>();
  }

  @override
  void dispose() {
    _lifecycle?.disposeSocket();
    super.dispose();
  }

  void _connectSocket(BuildContext context) {
    if (_socketConnected) return;
    _socketConnected = true;
    // Connect socket after frame to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerLifecycleProvider>().initSocket();
    });
  }

  void _disconnectSocket(BuildContext context) {
    if (!_socketConnected) return;
    _socketConnected = false;
    context.read<WorkerLifecycleProvider>().disposeSocket();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.hasConnectionError) {
      return NoInternetScreen(onRetry: authProvider.retryLoadUser);
    }

    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      if (user != null) {
        if (user.isBanned) {
          return const BannedScreen();
        }
        if (!user.isVerified) {
          return const VerifyScreen();
        }
      }
      _connectSocket(context);
      return const MainScreen();
    }

    _disconnectSocket(context);
    return const LoginScreen();
  }
}
