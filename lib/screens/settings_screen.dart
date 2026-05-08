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
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings), centerTitle: true),
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
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(
                                user.profilePicture!.startsWith('http')
                                    ? user.profilePicture!
                                    : '${AuthService.baseUrl}${user.profilePicture!}',
                              )
                            : null,
                        child: user.profilePicture == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name ?? AppLocalizations.of(context)!.farmyUser,
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          // Primary Role Badge
                          _buildRoleChip(
                            context,
                            label: _getRoleLabel(context, user.role).toUpperCase(),
                            icon: _getRoleIcon(user.role),
                            gradientColors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primaryContainer,
                            ],
                            textColor: Colors.white,
                          ),
                          // Worker Badge (if applicable)
                          if (workerProvider.myProfile != null &&
                              user.role == 'customer')
                            _buildRoleChip(
                              context,
                              label: AppLocalizations.of(context)!.worker,
                              icon: Icons.engineering_outlined,
                              gradientColors: [
                                Colors.blue.shade400,
                                Colors.blue.shade700,
                              ],
                              textColor: Colors.white,
                            ),
                          // Verification Badge
                          _buildRoleChip(
                            context,
                            label: user.isVerified
                                ? AppLocalizations.of(context)!.verified
                                : AppLocalizations.of(context)!.unverified,
                            icon: user.isVerified
                                ? Icons.verified_rounded
                                : Icons.gpp_bad_outlined,
                            gradientColors: user.isVerified
                                ? [
                                    Colors.green.shade400,
                                    Colors.green.shade700,
                                  ]
                                : [
                                    Colors.orange.shade400,
                                    Colors.orange.shade700,
                                  ],
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Latest Proof Preview for Workers
                if (workerProvider.myProfile != null)
                  Consumer<WorkerLifecycleProvider>(
                    builder: (context, lifecycle, _) {
                      if (lifecycle.myProofs.isEmpty) return const SizedBox();
                      final latest = lifecycle.myProofs.first;
                      if (latest.imageUrl == null) return const SizedBox();

                      return Center(
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.latestSubmittedProof,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '${AuthService.baseUrl}${latest.imageUrl}',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),

                // Subscription Section
                _buildSectionTitle(theme, AppLocalizations.of(context)!.subscription),
                Consumer<SubscriptionProvider>(
                  builder: (context, subProvider, _) {
                    final sub = subProvider.currentSubscription;
                    final isActive = sub?.isActive ?? false;
                    final planName = sub?.plan.name ?? AppLocalizations.of(context)!.freeTier;
                    final isFree = sub?.plan.planKey.contains('free') ?? true;

                    String subtitle;
                    if (!isActive) {
                      subtitle = AppLocalizations.of(context)!.upgradePremium;
                    } else if (isFree) {
                      subtitle = AppLocalizations.of(context)!.freeForever;
                    } else {
                      subtitle = AppLocalizations.of(context)!.validUntil(_formatDate(sub!.endDate));
                    }

                    return _buildSettingsTile(
                      context,
                      icon: Icons.auto_awesome_outlined,
                      title: planName,
                      subtitle: subtitle,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isFree ? Colors.green : Colors.amber,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isFree ? AppLocalizations.of(context)!.free : AppLocalizations.of(context)!.pro,
                              style: TextStyle(
                                color: isFree ? Colors.green : Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              _buildSectionTitle(theme, AppLocalizations.of(context)!.payments),
              _buildSettingsTile(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: AppLocalizations.of(context)!.walletCards,
                subtitle: AppLocalizations.of(context)!.manageCredits,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.hub_outlined,
                title: AppLocalizations.of(context)!.hederaRegistry,
                subtitle: AppLocalizations.of(context)!.viewBlockchainRecords,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8259EF), Color(0xFF5B2BE8)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'HCS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HederaRegistryScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.receipt_long_rounded,
                title: 'Invoice Generator',
                subtitle: 'Generate PDF invoices from your activity',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceGeneratorScreen(),
                  ),
                ),
              ),

              _buildSectionTitle(theme, AppLocalizations.of(context)!.general),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none,
                title: AppLocalizations.of(context)!.notifications,
                subtitle: AppLocalizations.of(context)!.viewRecentActivity,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(theme, AppLocalizations.of(context)!.security),
              _buildSettingsTile(
                context,
                icon: Icons.edit_outlined,
                title: AppLocalizations.of(context)!.editProfile,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: AppLocalizations.of(context)!.changePassword,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                context,
                icon: (user?.isTwoFactorEnabled ?? false)
                    ? Icons.security
                    : Icons.security_outlined,
                title: (user?.isTwoFactorEnabled ?? false)
                    ? AppLocalizations.of(context)!.disable2fa
                    : AppLocalizations.of(context)!.enable2fa,
                subtitle: (user?.isTwoFactorEnabled ?? false)
                    ? AppLocalizations.of(context)!.strongSecurityActive
                    : AppLocalizations.of(context)!.addExtraSecurity,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (user?.isTwoFactorEnabled ?? false)
                        ? Colors.green.withOpacity(0.1)
                        : theme.colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (user?.isTwoFactorEnabled ?? false)
                          ? Colors.green
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    (user?.isTwoFactorEnabled ?? false) ? AppLocalizations.of(context)!.enabled : AppLocalizations.of(context)!.off,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: (user?.isTwoFactorEnabled ?? false)
                          ? Colors.green
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Enable2FAScreen(),
                  ),
                ),
              ),

              if (user?.role == 'customer') ...[
                const SizedBox(height: 24),
                _buildSectionTitle(theme, AppLocalizations.of(context)!.orders),
                _buildSettingsTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: AppLocalizations.of(context)!.myOrders,
                  subtitle: AppLocalizations.of(context)!.trackManagePurchases,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(theme, AppLocalizations.of(context)!.verification),
                _buildSettingsTile(
                  context,
                  icon: Icons.agriculture_outlined,
                  title: AppLocalizations.of(context)!.becomeFarmer,
                  subtitle: AppLocalizations.of(context)!.startSellingProduce,
                  onTap: () => _handleKyc(context, 'farmer'),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.monetization_on_outlined,
                  title: AppLocalizations.of(context)!.becomeInvestor,
                  subtitle: AppLocalizations.of(context)!.investSustainableFarming,
                  onTap: () => _handleKyc(context, 'investor'),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(theme, AppLocalizations.of(context)!.worker),
                Consumer<WorkerProvider>(
                  builder: (context, provider, _) {
                    if (provider.profileLoading && provider.myProfile == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final hasProfile = provider.myProfile != null;
                    return Column(
                      children: [
                        if (!hasProfile)
                          _buildSettingsTile(
                            context,
                            icon: Icons.construction_outlined,
                            title: AppLocalizations.of(context)!.becomeWorker,
                            subtitle: AppLocalizations.of(context)!.offerSkillsFarms,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BecomeWorkerScreen(),
                              ),
                            ).then((_) => provider.loadMyProfile()),
                          ),
                        if (hasProfile)
                          _buildSettingsTile(
                            context,
                            icon: Icons.dashboard_outlined,
                            title: AppLocalizations.of(context)!.workerDashboard,
                            subtitle: AppLocalizations.of(context)!.viewAssignmentsTasks,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkerDashboardScreen(),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],

              if (user?.role == 'investor') ...[
                const SizedBox(height: 24),
                _buildSectionTitle(theme, AppLocalizations.of(context)!.investments),
                _buildSettingsTile(
                  context,
                  icon: Icons.monetization_on_outlined,
                  title: AppLocalizations.of(context)!.myInvestments,
                  subtitle: AppLocalizations.of(context)!.viewManageLandInvestments, // Need to ensure this exists or use generic
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InvestorMyInvestmentsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(theme, AppLocalizations.of(context)!.gameFeatures),
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
                      child: const Icon(
                        Icons.videogame_asset,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.enableGameEdgePanel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.accessFarmView,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    value: gameProvider.showEdgePanel,
                    onChanged: (value) {
                      gameProvider.setEdgePanelVisibility(value);
                    },
                    activeColor: Colors.red,
                  ),
                ),
              ],

              if (user?.role.toLowerCase() == 'farmer') ...[
                const SizedBox(height: 24),
                _buildSectionTitle(theme, 'Farmer Management'),
                _buildSettingsTile(
                  context,
                  icon: Icons.assignment_ind_outlined,
                  title: 'Manage Jobs',
                  subtitle: 'Post new jobs and manage worker applications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageJobsScreen(),
                    ),
                  ),
                ),
              ],
              if (user?.role.toLowerCase() == 'farmer' ||
                  user?.role.toLowerCase() == 'investor' ||
                  user?.role.toLowerCase() == 'admin') ...[
                const SizedBox(height: 24),
                _buildSectionTitle(theme, AppLocalizations.of(context)!.tasksProofs),
                _buildSettingsTile(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: AppLocalizations.of(context)!.aiProofRequests,
                  subtitle: AppLocalizations.of(context)!.viewManageProofRequests,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProofRequestsScreen(),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              _buildSectionTitle(theme, AppLocalizations.of(context)!.appearance),
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
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.darkMode,
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
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildSettingsTile(
                      context,
                      icon: Icons.language_outlined,
                      title: AppLocalizations.of(context)!.language,
                      subtitle: _getLanguageName(
                        localeProvider.locale?.languageCode ?? 'en',
                      ),
                      onTap: () => _showLanguageDialog(context),
                      useContainer: false, // I'll add this parameter to avoid nested containers
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: AppLocalizations.of(context)!.aboutUs,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                ),
              ),

              _buildSectionTitle(theme, 'Support & Feedback'),
              _buildSettingsTile(
                context,
                icon: Icons.support_agent_outlined,
                title: 'Help Center & Reports',
                subtitle: 'Report issues or suggest improvements',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackListScreen()),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.logout),
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
    bool useContainer = true,
  }) {
    final theme = Theme.of(context);
    final content = ListTile(
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );

    if (!useContainer) return content;

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
      child: content,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return AppLocalizations.of(context)!.english;
      case 'fr':
        return AppLocalizations.of(context)!.french;
      case 'es':
        return AppLocalizations.of(context)!.spanish;
      default:
        return code;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.english),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.french),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.spanish),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('es'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleKyc(BuildContext context, String role) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KycFlowScreen(role: role)),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getRoleLabel(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role.toLowerCase()) {
      case 'customer':
        return l10n.customerLabel;
      case 'farmer':
        return l10n.farmer;
      case 'investor':
        return l10n.investor;
      case 'worker':
        return l10n.worker;
      case 'admin':
        return 'Admin'; // Usually not translated or add to ARB
      default:
        return role;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return Icons.person_outline;
      case 'farmer':
        return Icons.agriculture_outlined;
      case 'investor':
        return Icons.trending_up_outlined;
      case 'worker':
        return Icons.engineering_outlined;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Widget _buildRoleChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
