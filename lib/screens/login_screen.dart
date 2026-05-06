import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../main.dart'; // Import for routeObserver

/// Enum to track which social provider is currently loading
enum SocialProvider { none, google, github, apple }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  SocialProvider _loadingProvider = SocialProvider.none;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Format error messages to be more user-friendly
  String _formatErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    
    // Cancellation errors - user cancelled
    if (error.contains('AuthorizationError error 1000') || 
        error.contains('CANCELED') || 
        error.contains('User canceled') ||
        error.contains('canceled') && error.contains('login')) {
      return 'Sign in was cancelled.';
    }
    
    // Apple Sign-In specific errors
    if (error.contains('AuthorizationError error 1001')) {
      return 'Invalid request. Please check your Apple ID settings.';
    }
    if (error.contains('AuthorizationError error 1002')) {
      return 'Invalid credentials. Please try again.';
    }
    if (error.contains('AuthorizationError error 1003') || 
        (lowerError.contains('apple') && lowerError.contains('connection'))) {
      return 'Unable to connect to Apple. Please check your internet connection.';
    }
    if (lowerError.contains('apple') && lowerError.contains('timeout')) {
      return 'Connection to Apple timed out. Please try again.';
    }
    
    // GitHub specific errors
    if (lowerError.contains('github') && lowerError.contains('code')) {
      return 'GitHub authentication failed. Please try again.';
    }
    if (lowerError.contains('github') && lowerError.contains('token')) {
      return 'Unable to verify GitHub account. Please try again.';
    }
    if (lowerError.contains('github') && lowerError.contains('email')) {
      return 'Could not retrieve email from GitHub. Please ensure your GitHub email is verified and public, or try another sign-in method.';
    }
    
    // Google specific errors
    if (lowerError.contains('google') && lowerError.contains('cancel')) {
      return 'Google sign-in was cancelled.';
    }
    if (lowerError.contains('google') && lowerError.contains('token')) {
      return 'Unable to verify Google account. Please try again.';
    }
    
    // Network/Connection errors
    if (lowerError.contains('socketexception') || 
        lowerError.contains('clientexception') ||
        lowerError.contains('connection refused') ||
        error.contains('Server connection failed') ||
        lowerError.contains('failed to connect') ||
        lowerError.contains('network error')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    }
    
    // Timeout errors
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }
    
    // HTTP status code errors
    if (error.contains('401') || lowerError.contains('unauthorized')) {
      return 'Authentication failed. Please check your credentials and try again.';
    }
    if (error.contains('403') || lowerError.contains('forbidden')) {
      return 'Access denied. Your account may be restricted.';
    }
    if (error.contains('500') || 
        error.contains('502') || 
        error.contains('503') || 
        error.contains('504') ||
        lowerError.contains('server error')) {
      return 'Server error occurred. Please try again later.';
    }
    if (error.contains('404') || lowerError.contains('not found')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    
    // Account errors
    if (lowerError.contains('banned') || lowerError.contains('suspended')) {
      return 'Your account has been suspended. Please contact support.';
    }
    if (lowerError.contains('not verified') || lowerError.contains('unverified')) {
      return 'Please verify your email address before signing in.';
    }
    
    // API/Base URL configuration errors
    if (lowerError.contains('api_base_url') || lowerError.contains('not configured')) {
      return 'App configuration error. Please contact support.';
    }
    
    // Database errors
    if (lowerError.contains('unknown column') || lowerError.contains('sql')) {
      return 'Service temporarily unavailable. Please try again in a moment.';
    }
    
    // Return cleaned original if no specific formatting needed
    // Limit length to avoid overwhelming the user
    if (error.length > 150) {
      return '${error.substring(0, 150)}...';
    }
    return error;
  }

  @override
  void initState() {
    super.initState();
    // Prevent auto-focus on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissKeyboard();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another route
    // Reset focus to prevent auto-keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dismissKeyboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Stack(
          children: [
            // Ambient Background Gradients
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(isDark ? 0.15 : 0.1),
                            primaryColor.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150,
                    left: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary.withOpacity(
                              isDark ? 0.1 : 0.05,
                            ),
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Header Section
                            Center(
                              child: Hero(
                                tag: 'logo',
                                child: Image.asset(
                                  'assets/logo-no-bg.png',
                                  height: 60,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.welcomeBack,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.signInToFarmyAccount,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 24),

                            // Glassmorphic Login Card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(isDark ? 0.03 : 0.01),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withOpacity(
                                                isDark ? 0.08 : 0.05,
                                              ),
                                    ),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: _emailController,
                                          autofocus: false,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(context)!.email,
                                            labelStyle: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withOpacity(0.5),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.mail_outline_rounded,
                                              size: 18,
                                              color: primaryColor.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                  horizontal: 16,
                                                ),
                                            filled: true,
                                            fillColor:
                                                (isDark
                                                        ? Colors.black
                                                        : Colors.white)
                                                    .withOpacity(0.3),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color:
                                                    (isDark
                                                            ? Colors.white
                                                            : Colors.black)
                                                        .withOpacity(0.1),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: primaryColor.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.redAccent
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Colors.redAccent,
                                                    width: 2,
                                                  ),
                                                ),
                                          ),
                                          validator: FieldValidators.email,
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(context)!.password,
                                            labelStyle: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withOpacity(0.5),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                              size: 18,
                                              color: primaryColor.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                  horizontal: 16,
                                                ),
                                            filled: true,
                                            fillColor:
                                                (isDark
                                                        ? Colors.black
                                                        : Colors.white)
                                                    .withOpacity(0.3),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color:
                                                    (isDark
                                                            ? Colors.white
                                                            : Colors.black)
                                                        .withOpacity(0.1),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: primaryColor.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.redAccent
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Colors.redAccent,
                                                    width: 2,
                                                  ),
                                                ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withOpacity(0.5),
                                              ),
                                              onPressed: () => setState(
                                                () => _obscurePassword =
                                                    !_obscurePassword,
                                              ),
                                            ),
                                          ),
                                          validator: (value) =>
                                              FieldValidators.required(
                                                value,
                                                'Password',
                                              ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              _dismissKeyboard();
                                              Navigator.pushNamed(
                                                context,
                                                '/forgot-password',
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              minimumSize: const Size(0, 24),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              foregroundColor: primaryColor,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!.forgotPassword,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : () async {
                                                  _dismissKeyboard();
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    final error =
                                                        await authProvider.login(
                                                          _emailController.text,
                                                          _passwordController
                                                              .text,
                                                        );

                                                    if (error ==
                                                        'requires_2fa') {
                                                      if (mounted) {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/verify-2fa',
                                                        );
                                                      }
                                                      return;
                                                    }

                                                    if (error == null) {
                                                      _dismissKeyboard();
                                                    }

                                                    if (error != null &&
                                                        mounted) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => _ErrorDialog(
                                                          title: AppLocalizations.of(context)!.loginFailed,
                                                          message: _formatErrorMessage(error),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: authProvider.isLoading
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : Text(
                                                  AppLocalizations.of(context)!.signIn,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Social Login Section
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(0.05),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.orContinueWith,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(0.05),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(
                                  icon: 'assets/google_logo.png',
                                  size: 54,
                                  providerName: 'Google',
                                  isLoading: _loadingProvider == SocialProvider.google,
                                  onTap: _loadingProvider != SocialProvider.none
                                      ? null
                                      : () async {
                                          setState(() => _loadingProvider = SocialProvider.google);
                                          _dismissKeyboard();
                                          try {
                                            final result = await authProvider.signInWithGoogle();
                                            if (result == 'requires_2fa') {
                                              if (mounted) {
                                                Navigator.pushNamed(context, '/verify-2fa');
                                              }
                                            } else if (result == null) {
                                              _dismissKeyboard();
                                            } else if (mounted) {
                                              showDialog(
                                                context: context,
                                                builder: (context) => _ErrorDialog(
                                                  title: AppLocalizations.of(context)!.loginFailed,
                                                  message: _formatErrorMessage(result),
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() => _loadingProvider = SocialProvider.none);
                                            }
                                          }
                                        },
                                ),
                                const SizedBox(width: 20),
                                _SocialButton(
                                  icon: 'assets/github_logo.png',
                                  size: 54,
                                  providerName: 'GitHub',
                                  iconColor: isDark ? Colors.white : Colors.black,
                                  isLoading: _loadingProvider == SocialProvider.github,
                                  onTap: _loadingProvider != SocialProvider.none
                                      ? null
                                      : () async {
                                          setState(() => _loadingProvider = SocialProvider.github);
                                          _dismissKeyboard();
                                          try {
                                            final result = await authProvider.signInWithGithub();
                                            if (result == 'requires_2fa') {
                                              if (mounted) {
                                                Navigator.pushNamed(context, '/verify-2fa');
                                              }
                                            } else if (result == null) {
                                              _dismissKeyboard();
                                            } else if (mounted) {
                                              showDialog(
                                                context: context,
                                                builder: (context) => _ErrorDialog(
                                                  title: AppLocalizations.of(context)!.loginFailed,
                                                  message: _formatErrorMessage(result),
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() => _loadingProvider = SocialProvider.none);
                                            }
                                          }
                                        },
                                ),
                                // Apple Sign-In - Only on iOS/macOS (Apple requirement)
                                if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
                                  const SizedBox(width: 20),
                                if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
                                  _SocialButton(
                                    icon: 'assets/apple-logo/apple-logo.png',
                                    size: 54,
                                    providerName: 'Apple',
                                    isLoading: _loadingProvider == SocialProvider.apple,
                                    onTap: _loadingProvider != SocialProvider.none
                                        ? null
                                        : () async {
                                            setState(() => _loadingProvider = SocialProvider.apple);
                                            _dismissKeyboard();
                                            try {
                                              final result = await authProvider.signInWithApple();
                                              if (result == 'requires_2fa') {
                                                if (mounted) {
                                                  Navigator.pushNamed(context, '/verify-2fa');
                                                }
                                              } else if (result == null) {
                                                _dismissKeyboard();
                                              } else if (mounted) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => _ErrorDialog(
                                                    title: AppLocalizations.of(context)!.loginFailed,
                                                    message: _formatErrorMessage(result),
                                                  ),
                                                );
                                              }
                                            } finally {
                                              if (mounted) {
                                                setState(() => _loadingProvider = SocialProvider.none);
                                              }
                                            }
                                          },
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  _dismissKeyboard();
                                  Navigator.pushNamed(context, '/signup');
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 30),
                                  padding: EdgeInsets.zero,
                                  splashFactory: NoSplash.splashFactory,
                                  foregroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: "${AppLocalizations.of(context)!.dontHaveAccount} ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                    children: [
                                      TextSpan(
                                        text: AppLocalizations.of(context)!.signup,
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced Social Button with loading state and haptic feedback
class _SocialButton extends StatefulWidget {
  final String icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double size;
  final bool isLoading;
  final String providerName;

  const _SocialButton({
    required this.icon,
    this.onTap,
    this.iconColor,
    this.size = 64,
    this.isLoading = false,
    required this.providerName,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onTap == null) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (widget.isLoading || widget.onTap == null) return;
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.isLoading ? null : widget.onTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: widget.isLoading
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                        primaryColor.withOpacity(isDark ? 0.1 : 0.05),
                      ],
                    )
                  : null,
              color: widget.isLoading
                  ? null
                  : (isDark ? Colors.white : Colors.black).withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isLoading
                    ? primaryColor.withOpacity(isDark ? 0.4 : 0.3)
                    : (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                width: widget.isLoading ? 2 : 1,
              ),
              boxShadow: _isPressed && !widget.isLoading
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(isDark ? 0.3 : 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: widget.size * 0.35,
                      height: widget.size * 0.35,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                      ),
                    )
                  : Image.asset(
                      widget.icon,
                      height: widget.size * 0.4,
                      color: widget.iconColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced Error Dialog with modern UI matching app theme
class _ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final IconData icon;
  final Color? iconColor;

  const _ErrorDialog({
    required this.title,
    required this.message,
    this.buttonText,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = iconColor ?? (isDark ? Colors.redAccent : Colors.red);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Column(
                children: [
                  // Error Icon with gradient background
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          errorColor.withOpacity(isDark ? 0.3 : 0.15),
                          errorColor.withOpacity(isDark ? 0.15 : 0.08),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 32,
                        color: errorColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Message
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Divider
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
            ),
            // Action Button
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                      primaryColor.withOpacity(isDark ? 0.08 : 0.04),
                    ],
                  ),
                ),
                child: Text(
                  buttonText ?? AppLocalizations.of(context)?.ok ?? 'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
