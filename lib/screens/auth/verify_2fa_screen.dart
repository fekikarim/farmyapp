import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class Verify2FAScreen extends StatefulWidget {
  const Verify2FAScreen({super.key});

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final _codeController = TextEditingController();

  Future<void> _verify() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.verify2faLogin(_codeController.text);
    
    if (error == null) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Verification Required',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter the 6-digit code from your authenticator app to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '000 000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Verify'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
