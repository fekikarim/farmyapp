import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../main.dart'; // Import for routeObserver

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
  String? _errorMessage;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String _formatErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    if (error.contains('AuthorizationError error 1001') || lowerError.contains('canceled')) return 'Sign in was cancelled.';
    if (lowerError.contains('connection refused') || lowerError.contains('failed to connect')) return 'Unable to connect to the server.';
    if (lowerError.contains('timeout')) return 'Connection timed out.';
    if (error.contains('401') || lowerError.contains('unauthorized')) return 'Authentication failed. Check your credentials.';
    return error.length > 100 ? '${error.substring(0, 100)}...' : error;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dismissKeyboard();
    });
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    _dismissKeyboard();
    setState(() => _errorMessage = null);

    final error = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error == 'requires_2fa') {
      Navigator.pushNamed(context, '/verify-2fa');
      return;
    }

    if (error != null) {
      setState(() => _errorMessage = _formatErrorMessage(error));
    }
  }

  Future<void> _handleSocialLogin(AuthProvider authProvider, SocialProvider provider) async {
    if (_loadingProvider != SocialProvider.none) return;
    setState(() {
      _loadingProvider = provider;
      _errorMessage = null;
    });
    _dismissKeyboard();
    
    String? result;
    try {
      if (provider == SocialProvider.google) result = await authProvider.signInWithGoogle();
      if (provider == SocialProvider.github) result = await authProvider.signInWithGithub();
      if (provider == SocialProvider.apple) result = await authProvider.signInWithApple();

      if (!mounted) return;
      if (result == 'requires_2fa') {
        Navigator.pushNamed(context, '/verify-2fa');
      } else if (result != null) {
        _showModernErrorDialog(context, provider, _formatErrorMessage(result));
      }
    } finally {
      if (mounted) setState(() => _loadingProvider = SocialProvider.none);
    }
  }

  void _showModernErrorDialog(BuildContext context, SocialProvider provider, String message) {
    final theme = Theme.of(context);
    final providerName = provider.name[0].toUpperCase() + provider.name.substring(1);
    
    // Brand Colors
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.8), // Keep it dark for both modes
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C19).withValues(alpha: 0.9), // Dark glass for both modes
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          errorColor.withValues(alpha: 0.2),
                          const Color(0xFF1A1C19).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon Section
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: errorColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: errorColor.withValues(alpha: 0.4),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: errorColor.withValues(alpha: 0.4),
                                blurRadius: 25,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.priority_high_rounded,
                            color: errorColor,
                            size: 46,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Title
                        Text(
                          "$providerName Login Failed",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            fontSize: 28,
                            color: Colors.white, // White for both modes
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        
                        // Message
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9), // White for both modes
                            height: 1.5,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 44),
                        
                        // Action Button with Brand Gradient
                        Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.ok.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Stack(
          children: [
            Positioned(top: -100, right: -100, child: _buildBlob(theme.colorScheme.primary, 300, 0.08)),
            Positioned(bottom: -150, left: -100, child: _buildBlob(theme.colorScheme.secondary, 400, 0.05)),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Center(
                    child: AnimationLimiter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 600),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            const SizedBox(height: 20),
                            Hero(tag: 'app_logo', child: Image.asset('assets/logo-no-bg.png', height: 90)),
                            const SizedBox(height: 30),
                            Text(
                              AppLocalizations.of(context)!.welcomeBack,
                              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.signInToFarmyAccount,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 40),

                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildInputField(
                                    context,
                                    controller: _emailController,
                                    label: AppLocalizations.of(context)!.email,
                                    icon: Icons.mail_outline_rounded,
                                    validator: FieldValidators.email,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                    context,
                                    controller: _passwordController,
                                    label: AppLocalizations.of(context)!.password,
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (val) => FieldValidators.required(val, 'Password'),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: theme.colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        minimumSize: const Size(0, 30),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.forgotPassword,
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              _buildErrorContainer(theme, _errorMessage!),
                            ],

                            const SizedBox(height: 24),
                            _buildLoginButton(context, authProvider),

                            const SizedBox(height: 32),
                            _buildSocialDivider(context),
                            const SizedBox(height: 20),
                            _buildSocialButtons(context, authProvider),

                            const SizedBox(height: 40),
                            _buildSignupLink(context, theme),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlob(Color color, double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: alpha), shape: BoxShape.circle),
    );
  }

  Widget _buildInputField(BuildContext context, {required TextEditingController controller, required String label, required IconData icon, bool obscureText = false, Widget? suffixIcon, String? Function(String?)? validator, TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: theme.colorScheme.primary.withValues(alpha: 0.7))),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: theme.colorScheme.primary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () => _handleLogin(authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: authProvider.isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(AppLocalizations.of(context)!.signIn.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSocialDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppLocalizations.of(context)!.orContinueWith.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
        ),
        Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildSocialButtons(BuildContext context, AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          icon: 'assets/google_logo.png',
          isLoading: _loadingProvider == SocialProvider.google,
          onTap: () => _handleSocialLogin(authProvider, SocialProvider.google),
        ),
        const SizedBox(width: 20),
        _SocialButton(
          icon: 'assets/github_logo.png',
          isLoading: _loadingProvider == SocialProvider.github,
          onTap: () => _handleSocialLogin(authProvider, SocialProvider.github),
        ),
        if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) ...[
          const SizedBox(width: 20),
          _SocialButton(
            icon: 'assets/apple-logo/apple-logo.png',
            isLoading: _loadingProvider == SocialProvider.apple,
            onTap: () => _handleSocialLogin(authProvider, SocialProvider.apple),
          ),
        ],
      ],
    );
  }

  Widget _buildSignupLink(BuildContext context, ThemeData theme) {
    return Center(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/signup'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: "${AppLocalizations.of(context)!.dontHaveAccount} ",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
              children: [
                TextSpan(text: AppLocalizations.of(context)!.signup, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(ThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : Image.asset(
                icon,
                color: icon.contains('github') || icon.contains('apple') 
                    ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black) 
                    : null,
              ),
      ),
    );
  }
}
