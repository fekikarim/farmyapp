import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

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

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundColor.withBlue(60),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your Farmy account',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final error = await authProvider.login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                      if (!mounted) return;
                                      if (error != null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Login Failed'),
                                            content: Text(error),
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
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Sign In'),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                            Expanded(child: Divider(color: AppTheme.textSecondary.withOpacity(0.3))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: authProvider.isLoading ? null : () => authProvider.signInWithGoogle(),
                          icon: Image.asset(
                            'assets/google_logo.png',
                            height: 24,
                          ),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: authProvider.isLoading ? null : () => authProvider.signInWithGithub(),
                          icon: Image.asset(
                            'assets/github_logo.png',
                            height: 24,
                          ),
                          label: const Text('Continue with GitHub'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            child: RichText(
                              text: const TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: AppTheme.textSecondary),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ),
    );
  }
}
