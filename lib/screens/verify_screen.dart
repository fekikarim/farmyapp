import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import 'welcome_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String _errorMessage = '';
  final int _otpLength = 6;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _onOtpChanged(String value, AuthProvider authProvider) {
    setState(() => _errorMessage = '');
    if (value.length == _otpLength) {
      _verify(authProvider);
    }
  }

  Future<void> _verify(AuthProvider authProvider) async {
    final code = _otpController.text.trim();
    if (code.length < _otpLength) return;

    final otpError = FieldValidators.otp(code);
    if (otpError != null) {
      setState(() => _errorMessage = otpError);
      return;
    }

    final error = await authProvider.verifyEmail(code);
    if (error != null && mounted) {
      setState(() => _errorMessage = error);
    } else if (mounted) {
      final user = authProvider.user;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WelcomeScreen(role: user?.role ?? 'customer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background Decorative Blobs
            Positioned(top: -100, right: -50, child: _buildBlob(theme, 300, 0.05)),
            Positioned(bottom: -80, left: -40, child: _buildBlob(theme, 200, 0.03)),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: AnimationLimiter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 500),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            const SizedBox(height: 40),
                            Hero(tag: 'app_logo', child: Image.asset('assets/logo-no-bg.png', height: 100)),
                            const SizedBox(height: 40),
                            Text(
                              AppLocalizations.of(context)!.verifyEmailTitle,
                              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _buildEmailSubtitle(context, user?.email ?? "your email", theme),
                            const SizedBox(height: 48),

                            // Hidden Input + Visible OTP Display
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextField(
                                    controller: _otpController,
                                    focusNode: _otpFocusNode,
                                    keyboardType: TextInputType.number,
                                    maxLength: _otpLength,
                                    showCursor: false,
                                    cursorColor: Colors.transparent,
                                    autofocus: true,
                                    style: const TextStyle(color: Colors.transparent, fontSize: 1),
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                    onChanged: (val) => _onOtpChanged(val, authProvider),
                                  ),
                                ),
                                IgnorePointer(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(_otpLength, (index) => _buildOTPBox(context, index)),
                                  ),
                                ),
                              ],
                            ),

                            if (_errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildErrorContainer(theme, _errorMessage),
                            ],

                            const SizedBox(height: 48),
                            _buildVerifyButton(context, authProvider),
                            const SizedBox(height: 32),
                            _buildResendButton(context, authProvider),
                            const SizedBox(height: 12),
                            _buildBackToLogin(context, theme),
                            const SizedBox(height: 40),
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

  Widget _buildOTPBox(BuildContext context, int index) {
    final theme = Theme.of(context);
    final text = _otpController.text;
    final isFocused = _otpFocusNode.hasFocus && text.length == index;
    final hasChar = text.length > index;
    final char = hasChar ? text[index] : "";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: hasChar || isFocused ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isFocused ? theme.colorScheme.primary : (hasChar ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent),
          width: 2,
        ),
        boxShadow: isFocused ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Center(
        child: Text(char, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
      ),
    );
  }

  Widget _buildBlob(ThemeData theme, double size, double alpha) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: alpha), shape: BoxShape.circle));
  }

  Widget _buildEmailSubtitle(BuildContext context, String email, ThemeData theme) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "We sent a 6-digit verification code to\n",
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
        children: [TextSpan(text: email, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold))],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () => _verify(authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: authProvider.isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(AppLocalizations.of(context)!.verifyAccount.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildResendButton(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    return Center(
      child: InkWell(
        onTap: authProvider.isLoading ? null : () async {
          final success = await authProvider.resendVerificationCode();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? AppLocalizations.of(context)!.newVerificationCodeSent : AppLocalizations.of(context)!.failedToSendCode),
                backgroundColor: success ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(AppLocalizations.of(context)!.resendNewCode, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context, ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.4), splashFactory: NoSplash.splashFactory),
        child: Text(AppLocalizations.of(context)!.backToLogin.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12)),
      ),
    );
  }

  Widget _buildErrorContainer(ThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2))),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
