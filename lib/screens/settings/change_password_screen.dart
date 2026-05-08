import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = '');

    final error = await authProvider.changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordChangedSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changePasswordTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createNewPassword,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.passwordPolicyHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Inputs Section
                    _buildPasswordField(
                      context,
                      controller: _oldPasswordController,
                      label: AppLocalizations.of(context)!.currentPassword,
                      obscureText: _obscureOld,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                      validator: (val) => (val == null || val.isEmpty) ? AppLocalizations.of(context)!.enterCurrentPasswordError : null,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      context,
                      controller: _newPasswordController,
                      label: AppLocalizations.of(context)!.newPassword,
                      obscureText: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: FieldValidators.password,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      context,
                      controller: _confirmPasswordController,
                      label: AppLocalizations.of(context)!.confirmNewPassword,
                      obscureText: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (val) => FieldValidators.confirmPassword(val, _newPasswordController.text),
                    ),

                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildErrorWidget(theme, _errorMessage),
                    ],

                    const SizedBox(height: 48),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : () => _submit(authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                AppLocalizations.of(context)!.updatePassword.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_person_outlined, size: 20, color: theme.colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
