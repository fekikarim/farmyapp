import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Handle paste - if more than 1 character entered, distribute across fields
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Clear all fields first
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = '';
      }
      
      // Distribute digits across fields starting from first
      int fieldIndex = 0;
      for (int i = 0; i < digits.length && fieldIndex < 6; i++) {
        _controllers[fieldIndex].text = digits[i];
        fieldIndex++;
      }
      
      // Focus the next empty field or the last filled field
      final nextEmptyIndex = fieldIndex < 6 ? fieldIndex : 5;
      _focusNodes[nextEmptyIndex].requestFocus();
      
      setState(() => _errorMessage = '');
      return;
    }
    
    // Normal single character handling
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _errorMessage = '');
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify(AuthProvider authProvider) async {
    final code = _controllers.map((c) => c.text).toList().join();
    final otpError = FieldValidators.otp(code);
    if (otpError != null) {
      setState(() => _errorMessage = otpError);
      return;
    }

    final error = await authProvider.verifyEmail(code);
    if (error != null && mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/logo-no-bg.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Verify Your Email',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We sent a 6-digit verification code to\n${user?.email ?? "your email"}.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // 6-Digit Code Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 50,
                          height: 60,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              counterText: "",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.redAccent, width: 2),
                              ),
                              filled: true,
                              fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) => _onChanged(value, index),
                          ),
                        );
                      }),
                    ),
                    
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ],

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : () => _verify(authProvider),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Verify Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final success = await authProvider.resendVerificationCode();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'New verification code sent!'
                                          : 'Failed to send code. Try again.'),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: const Text('Resend New Code', style: TextStyle(color: AppTheme.primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text('Back to Login', style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.7))),
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
  }
}
