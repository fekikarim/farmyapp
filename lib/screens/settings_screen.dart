import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/worker_provider.dart';
import '../providers/locale_provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'settings/edit_profile_screen.dart';
import 'settings/change_password_screen.dart';
import 'settings/enable_2fa_screen.dart';
import 'about_us_screen.dart';
import '../screens/kyc/kyc_flow_screen.dart';
import '../screens/wallet/payment_methods_screen.dart';
import 'customer/become_worker_screen.dart';
import 'customer/worker_dashboard_screen.dart';
import 'investor/hedera_registry_screen.dart';
import 'investor/invoice_generator_screen.dart';
import 'shared/proof_requests_screen.dart';
import '../services/auth_service.dart';
import '../providers/worker_lifecycle_provider.dart';
import '../providers/subscription_provider.dart';
import 'customer/subscriptions_screen.dart';
import 'settings/notifications_screen.dart';
import 'investor/my_investments_screen.dart';
import 'customer/my_orders_screen.dart';
import 'farmer/manage_jobs_screen.dart';
import 'settings/feedback_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final workerProvider = Provider.of<WorkerProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              if (user != null) _buildProfileHeader(context, user, workerProvider),
              
              const SizedBox(height: 32),

              // 1. Account & Security
              _buildSectionTitle(theme, AppLocalizations.of(context)!.security),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: AppLocalizations.of(context)!.editProfile,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock_outline_rounded,
                    title: AppLocalizations.of(context)!.changePassword,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: (user?.isTwoFactorEnabled ?? false) ? Icons.verified_user_rounded : Icons.verified_user_outlined,
                    title: (user?.isTwoFactorEnabled ?? false) ? AppLocalizations.of(context)!.disable2fa : AppLocalizations.of(context)!.enable2fa,
                    trailing: _buildBadge(
                      context,
                      label: (user?.isTwoFactorEnabled ?? false) ? AppLocalizations.of(context)!.enabled : AppLocalizations.of(context)!.off,
                      isActive: user?.isTwoFactorEnabled ?? false,
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Enable2FAScreen())),
                  ),
                ],
              ),

              // 2. Commercial & Finances
              const SizedBox(height: 24),
              _buildSectionTitle(theme, AppLocalizations.of(context)!.commercialFinances),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSubscriptionTile(context, subProvider),
                  _buildSettingsTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: AppLocalizations.of(context)!.walletCards,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                  ),
                  if (user?.role == 'customer')
                    _buildSettingsTile(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      title: AppLocalizations.of(context)!.myOrders,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                    ),
                  if (user?.role == 'investor')
                    _buildSettingsTile(
                      context,
                      icon: Icons.trending_up_rounded,
                      title: AppLocalizations.of(context)!.myInvestments,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestorMyInvestmentsScreen())),
                    ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: AppLocalizations.of(context)!.invoiceGenerator,
                    trailing: _buildFormatBadge('PDF', Colors.red),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceGeneratorScreen())),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.hub_outlined,
                    title: AppLocalizations.of(context)!.hederaRegistry,
                    trailing: _buildFormatBadge('HCS', Colors.deepPurple),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HederaRegistryScreen())),
                  ),
                ],
              ),

              // 3. Role Management
              const SizedBox(height: 24),
              _buildSectionTitle(theme, AppLocalizations.of(context)!.professionalTools),
              _buildSettingsGroup(
                context,
                children: [
                  if (user?.role == 'customer') ...[
                    if (workerProvider.myProfile == null)
                      _buildSettingsTile(
                        context,
                        icon: Icons.engineering_outlined,
                        title: AppLocalizations.of(context)!.becomeWorker,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BecomeWorkerScreen())).then((_) => workerProvider.loadMyProfile()),
                      )
                    else
                      _buildSettingsTile(
                        context,
                        icon: Icons.dashboard_customize_outlined,
                        title: AppLocalizations.of(context)!.workerDashboard,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerDashboardScreen())),
                      ),
                    _buildSettingsTile(
                      context,
                      icon: Icons.agriculture_outlined,
                      title: AppLocalizations.of(context)!.becomeFarmer,
                      onTap: () => _handleKyc(context, 'farmer'),
                    ),
                    _buildSettingsTile(
                      context,
                      icon: Icons.monetization_on_outlined,
                      title: AppLocalizations.of(context)!.becomeInvestor,
                      onTap: () => _handleKyc(context, 'investor'),
                    ),
                  ],
                  if (user?.role.toLowerCase() == 'farmer')
                    _buildSettingsTile(
                      context,
                      icon: Icons.work_outline_rounded,
                      title: AppLocalizations.of(context)!.manageJobs,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageJobsScreen())),
                    ),
                  if (['farmer', 'investor', 'admin'].contains(user?.role.toLowerCase()))
                    _buildSettingsTile(
                      context,
                      icon: Icons.verified_user_outlined,
                      title: AppLocalizations.of(context)!.aiProofRequests,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProofRequestsScreen())),
                    ),
                ],
              ),

              // 4. Preferences
              const SizedBox(height: 24),
              _buildSectionTitle(theme, AppLocalizations.of(context)!.appearance),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSwitchTile(
                    context,
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    title: AppLocalizations.of(context)!.darkMode,
                    value: isDark,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.translate_rounded,
                    title: AppLocalizations.of(context)!.language,
                    trailing: Text(
                      _getLanguageName(localeProvider.locale?.languageCode ?? 'en'),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: AppLocalizations.of(context)!.notifications,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  if (user?.role == 'investor')
                    _buildSwitchTile(
                      context,
                      icon: Icons.videogame_asset_outlined,
                      title: AppLocalizations.of(context)!.enableGameEdgePanel,
                      value: gameProvider.showEdgePanel,
                      onChanged: (val) => gameProvider.setEdgePanelVisibility(val),
                    ),
                ],
              ),

              // 5. Support
              const SizedBox(height: 24),
              _buildSectionTitle(theme, AppLocalizations.of(context)!.helpSupport),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.support_agent_rounded,
                    title: AppLocalizations.of(context)!.helpCenterReports,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackListScreen())),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: AppLocalizations.of(context)!.aboutUs,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(AppLocalizations.of(context)!.logout.toUpperCase()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.error,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      '© ${DateTime.now().year} Farmy Team',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0 Stable',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user, WorkerProvider workerProvider) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!.startsWith('http') ? user.profilePicture! : '${AuthService.baseUrl}${user.profilePicture!}')
                  : null,
              child: user.profilePicture == null ? Icon(Icons.person_rounded, size: 50, color: theme.colorScheme.primary) : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name ?? 'Farmy User', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 16),
          _buildRoleBadges(context, user, workerProvider),
        ],
      ),
    );
  }

  Widget _buildRoleBadges(BuildContext context, dynamic user, WorkerProvider workerProvider) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildRoleChip(context, label: _getRoleLabel(context, user.role).toUpperCase(), color: theme.colorScheme.primary),
        if (workerProvider.myProfile != null && user.role == 'customer')
          _buildRoleChip(context, label: AppLocalizations.of(context)!.worker.toUpperCase(), color: Colors.blue),
        _buildRoleChip(
          context,
          label: user.isVerified ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.unverified,
          color: user.isVerified ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRoleChip(BuildContext context, {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, Widget? trailing, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
    );
  }

  Widget _buildSubscriptionTile(BuildContext context, SubscriptionProvider subProvider) {
    final sub = subProvider.currentSubscription;
    final isFree = sub?.plan.planKey.contains('free') ?? true;
    return _buildSettingsTile(
      context,
      icon: Icons.auto_awesome_rounded,
      title: sub?.plan.name ?? 'Free Tier',
      trailing: _buildBadge(context, label: isFree ? 'FREE' : 'PRO', isActive: !isFree, activeColor: Colors.amber),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen())),
    );
  }

  Widget _buildBadge(BuildContext context, {required String label, required bool isActive, Color activeColor = Colors.green}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? activeColor : Colors.transparent),
      ),
      child: Text(label, style: TextStyle(color: isActive ? activeColor : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFormatBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'fr': return 'Français';
      case 'es': return 'Español';
      default: return code.toUpperCase();
    }
  }
  String _getRoleLabel(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'farmer': return AppLocalizations.of(context)!.farmer;
      case 'investor': return AppLocalizations.of(context)!.investor;
      case 'customer': return AppLocalizations.of(context)!.customerLabel;
      default: return role;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
          surfaceTintColor: theme.colorScheme.primary,
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'en', 'English', '🇺🇸', currentLocale == 'en'),
              const SizedBox(height: 8),
              _buildLanguageOption(context, 'fr', 'Français', '🇫🇷', currentLocale == 'fr'),
              const SizedBox(height: 8),
              _buildLanguageOption(context, 'es', 'Español', '🇪🇸', currentLocale == 'es'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name, String flag, bool isSelected) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
        onTap: () {
          context.read<LocaleProvider>().setLocale(Locale(code));
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _handleKyc(BuildContext context, String targetRole) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => KycFlowScreen(role: targetRole)));
  }
}
