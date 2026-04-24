import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class Enable2FAScreen extends StatefulWidget {
  const Enable2FAScreen({super.key});

  @override
  State<Enable2FAScreen> createState() => _Enable2FAScreenState();
}

class _Enable2FAScreenState extends State<Enable2FAScreen> {
  int _step = 1;
  String? _secret;
  String? _otpUri;
  final _codeController = TextEditingController();
  bool _isDisabling = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.isTwoFactorEnabled ?? false) {
      _isDisabling = true;
    }
  }

  Future<void> _startSetup() async {
    final result = await Provider.of<AuthProvider>(context, listen: false).setup2fa();
    if (result != null) {
      setState(() {
        _secret = result['secret'];
        _otpUri = result['otpUri'];
        _step = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedInitiate2FA)),
      );
    }
  }

  Future<void> _confirmSetup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.confirm2fa(_codeController.text);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.twoFAEnabledSuccess)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _disable2FA() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.disable2fa(_codeController.text);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.twoFADisabledSuccess)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.codeCopied),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDisabling ? AppLocalizations.of(context)!.disable2FA : AppLocalizations.of(context)!.enable2FA),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            if (_isDisabling) _buildDisableUI(theme, isLoading)
            else if (_step == 1) _buildStep1(theme, isLoading)
            else _buildStep2(theme, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, bool isLoading) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.security_outlined, size: 80, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.secureYourAccount,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.twoFADesc,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _startSetup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: isLoading 
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ) 
              : Text(AppLocalizations.of(context)!.startSetup, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.linkYourAppStep,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.scanQRCodeDesc,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: _otpUri != null
                ? QrImageView(
                    data: _otpUri!,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox(height: 200, width: 200, child: Center(child: CircularProgressIndicator())),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          AppLocalizations.of(context)!.enterCodeManually,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _secret ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(_secret ?? ''),
                icon: const Icon(Icons.copy_rounded, size: 20),
                color: theme.colorScheme.primary,
                tooltip: AppLocalizations.of(context)!.copyToClipboardTooltip,
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Text(
          AppLocalizations.of(context)!.confirmEnablementStep,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.enter6DigitCodeConfirm,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 24),
        Theme(
          data: theme.copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: theme.colorScheme.primary,
              selectionHandleColor: theme.colorScheme.primary,
              selectionColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            cursorColor: theme.colorScheme.primary,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                letterSpacing: 8,
              ),
              counterText: '',
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _confirmSetup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: isLoading 
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ) 
              : Text(AppLocalizations.of(context)!.enable2FA, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = 1),
            child: Text(AppLocalizations.of(context)!.backButton, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDisableUI(ThemeData theme, bool isLoading) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.gpp_maybe_outlined, size: 80, color: theme.colorScheme.error),
        ),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.disable2FA,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.enter6DigitCodeDisable,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 48),
        Theme(
          data: theme.copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: theme.colorScheme.primary,
              selectionHandleColor: theme.colorScheme.primary,
              selectionColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            cursorColor: theme.colorScheme.primary,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                letterSpacing: 8,
              ),
              counterText: '',
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _disable2FA,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: isLoading 
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ) 
              : Text(AppLocalizations.of(context)!.disable2FA, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
