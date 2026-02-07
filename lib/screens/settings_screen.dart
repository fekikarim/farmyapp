import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import 'settings/edit_profile_screen.dart';
import 'settings/change_password_screen.dart';
import 'settings/enable_2fa_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/kyc_service.dart';
import '../screens/kyc/kyc_flow_screen.dart';
import '../screens/wallet/payment_methods_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Information Section
              if (user != null) ...[
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        backgroundImage: user.profilePicture != null 
                            ? NetworkImage(user.profilePicture!) 
                            : null,
                        child: user.profilePicture == null
                            ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name ?? 'Farmy User',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isVerified 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: user.isVerified ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.isVerified ? Icons.verified : Icons.gpp_bad,
                              size: 16,
                              color: user.isVerified ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isVerified ? 'Verified' : 'Unverified',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: user.isVerified ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              _buildSectionTitle(theme, 'Payments'),
              _buildSettingsTile(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet & Cards',
                subtitle: 'Manage credits and payment methods',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(theme, 'Security'),
              _buildSettingsTile(
                context,
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: (user?.isTwoFactorEnabled ?? false) ? Icons.security : Icons.security_outlined,
                title: (user?.isTwoFactorEnabled ?? false) ? 'Disable 2FA' : 'Enable 2FA',
                subtitle: (user?.isTwoFactorEnabled ?? false) ? 'Strong security active' : 'Add an extra layer of security',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (user?.isTwoFactorEnabled ?? false) 
                        ? Colors.green.withOpacity(0.1) 
                        : theme.colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (user?.isTwoFactorEnabled ?? false) ? Colors.green : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    (user?.isTwoFactorEnabled ?? false) ? 'ENABLED' : 'OFF',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: (user?.isTwoFactorEnabled ?? false) ? Colors.green : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Enable2FAScreen()),
                ),
              ),

              if (user?.role == 'customer') ...[
                const SizedBox(height: 24),
                _buildSectionTitle(theme, 'Verification'),
                _buildSettingsTile(
                  context,
                  icon: Icons.agriculture_outlined,
                  title: 'Become a Farmer',
                  subtitle: 'Start selling your produce',
                  onTap: () => _handleKyc(context, 'farmer'),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.monetization_on_outlined,
                  title: 'Become an Investor',
                  subtitle: 'Invest in sustainable farming',
                  onTap: () => _handleKyc(context, 'investor'),
                ),
              ],

              if (user?.role == 'investor') ...[
                const SizedBox(height: 24),
                _buildSectionTitle(theme, 'Game Features'),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.videogame_asset, color: Colors.red),
                    ),
                    title: Text(
                      'Show Game Bubble',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Access the 2.5D farm view',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    value: gameProvider.shouldShowBubble,
                    onChanged: (value) {
                      gameProvider.setBubbleVisibility(value);
                    },
                    activeColor: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'Appearance'),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'About'),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About Us - Farmy Team',
                onTap: () => _showComingSoonDialog(context),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  '© ${DateTime.now().year} Farmy Team',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ) : null,
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is currently under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleKyc(BuildContext context, String role) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KycFlowScreen(role: role),
      ),
    );
  }
}
