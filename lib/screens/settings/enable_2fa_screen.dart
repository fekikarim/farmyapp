import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';

class Enable2FAScreen extends StatefulWidget {
  const Enable2FAScreen({super.key});

  @override
  State<Enable2FAScreen> createState() => _Enable2FAScreenState();
}

class _Enable2FAScreenState extends State<Enable2FAScreen> {
  int _step = 1;
  String? _secret;
  String? _qrCode;
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
        _qrCode = result['qrCode'];
        _step = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initiate 2FA setup')),
      );
    }
  }

  Future<void> _confirmSetup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.confirm2fa(_codeController.text);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('2FA enabled successfully')),
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
        const SnackBar(content: Text('2FA disabled successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDisabling ? 'Disable 2FA' : 'Enable 2FA'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
        Icon(Icons.security_outlined, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'Secure Your Account',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Two-factor authentication adds an extra layer of security to your account. '
          'To log in, you will need to provide a 6-digit code from your authenticator app.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _startSetup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading 
              ? const CircularProgressIndicator() 
              : const Text('Start Setup'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme, bool isLoading) {
    return Column(
      children: [
        const Text(
          '1. Scan this QR code with your Authenticator App (Google Authenticator, Authy, etc.)',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (_qrCode != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: QrImageView(
              data: _qrCode!,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        const SizedBox(height: 24),
        const Text('Or enter this code manually:'),
        SelectableText(
          _secret ?? '',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          '2. Enter the 6-digit code from your app to confirm:',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: '000 000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _confirmSetup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading 
              ? const CircularProgressIndicator() 
              : const Text('Enable 2FA'),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _step = 1),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildDisableUI(ThemeData theme, bool isLoading) {
    return Column(
      children: [
        Icon(Icons.gpp_maybe_outlined, size: 80, color: theme.colorScheme.error),
        const SizedBox(height: 24),
        Text(
          'Disable 2FA',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter the 6-digit code from your authenticator app to disable two-factor authentication.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: '000 000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _disable2FA,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text('Disable 2FA'),
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
