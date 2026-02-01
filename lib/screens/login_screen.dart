import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
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
                          Theme.of(context).colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
                          Theme.of(context).colorScheme.secondary.withOpacity(0),
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
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  fontSize: 22,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sign in to your Farmy account',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 24),

                          // Glassmorphic Login Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.03 : 0.01),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.08 : 0.05),
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        style: const TextStyle(fontSize: 14),
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
                                          prefixIcon: Icon(Icons.mail_outline_rounded, size: 18, color: primaryColor.withOpacity(0.7)),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                          filled: true,
                                          fillColor: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.redAccent, width: 2),
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
                                          labelText: 'Password',
                                          labelStyle: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
                                          prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: primaryColor.withOpacity(0.7)),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                          filled: true,
                                          fillColor: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.redAccent, width: 2),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                              size: 16,
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                            ),
                                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          ),
                                        ),
                                        validator: (value) => FieldValidators.required(value, 'Password'),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            minimumSize: const Size(0, 24),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            splashFactory: NoSplash.splashFactory,
                                            foregroundColor: primaryColor,
                                          ),
                                          child: Text(
                                            'Forgot Password?',
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
                                                if (_formKey.currentState!.validate()) {
                                                  final error = await authProvider.login(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                  );
                                                  if (error != null && mounted) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                        title: const Text('Login Failed', style: TextStyle(fontSize: 18)),
                                                        content: Text(error, style: const TextStyle(fontSize: 14)),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            child: const Text('OK'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: authProvider.isLoading
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 15),
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
                              Expanded(child: Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                icon: 'assets/google_logo.png',
                                size: 54,
                                onTap: authProvider.isLoading ? null : () => authProvider.signInWithGoogle(),
                              ),
                              const SizedBox(width: 20),
                              _SocialButton(
                                icon: 'assets/github_logo.png',
                                size: 54,
                                iconColor: isDark ? Colors.white : Colors.black,
                                onTap: authProvider.isLoading ? null : () => authProvider.signInWithGithub(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/signup'),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                padding: EdgeInsets.zero,
                                splashFactory: NoSplash.splashFactory,
                                foregroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',
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
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double size;

  const _SocialButton({
    required this.icon,
    this.onTap,
    this.iconColor,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          ),
        ),
        child: Center(
          child: Image.asset(
            icon,
            height: size * 0.4,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
