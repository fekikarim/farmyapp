import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../../providers/farmer_dashboard_provider.dart';

class QuickAction {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onAddLand;
  final VoidCallback? onReviewRequests;
  final VoidCallback? onInviteWorker;
  final VoidCallback? onManageProducts;
  final VoidCallback? onAIAssistant;
  final VoidCallback? onCropCalendar;
  final VoidCallback? onManageJobs;

  const QuickActionsGrid({
    super.key,
    this.onAddLand,
    this.onReviewRequests,
    this.onInviteWorker,
    this.onManageProducts,
    this.onAIAssistant,
    this.onCropCalendar,
    this.onManageJobs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<FarmerDashboardProvider>();

    final actions = [
      QuickAction(
        id: 'add_land',
        label: 'Add Land',
        icon: Icons.add_location,
        color: Colors.green,
        onTap: onAddLand ?? () {},
      ),
      QuickAction(
        id: 'review_requests',
        label: 'Review Requests',
        icon: Icons.inbox,
        color: Colors.orange,
        onTap: onReviewRequests ?? () {},
        badgeCount: provider.pendingItemRequests > 0
            ? provider.pendingItemRequests
            : null,
      ),
      QuickAction(
        id: 'invite_worker',
        label: 'Invite Worker',
        icon: Icons.person_add,
        color: Colors.blue,
        onTap: onInviteWorker ?? () {},
      ),
      QuickAction(
        id: 'manage_products',
        label: 'Manage Products',
        icon: Icons.inventory_2,
        color: Colors.brown,
        onTap: onManageProducts ?? () {},
      ),
      QuickAction(
        id: 'ai_assistant',
        label: 'AI Assistant',
        icon: Icons.psychology,
        color: Colors.teal,
        onTap: onAIAssistant ?? () {},
      ),
      QuickAction(
        id: 'crop_calendar',
        label: 'Crop Calendar',
        icon: Icons.calendar_month,
        color: Colors.lightGreen,
        onTap: onCropCalendar ?? () {},
      ),
      QuickAction(
        id: 'manage_jobs',
        label: 'Manage Jobs',
        icon: Icons.assignment_ind,
        color: Colors.indigo,
        onTap: onManageJobs ?? () {},
      ),
    ];

    if (provider.isLoading && provider.lands.isEmpty) {
      return _buildSkeleton(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 1024
                  ? 4
                  : width >= 680
                  ? 3
                  : 2;
              final childAspectRatio = width < 390 ? 1.08 : 1.2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  return _ActionButton(action: actions[index], index: index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120, height: 20, color: Colors.white),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: List.generate(6, (index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final QuickAction action;
  final int index;

  const _ActionButton({required this.action, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + (index * 55)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: action.color.withOpacity(0.34)),
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  action.color.withOpacity(0.14),
                  action.color.withOpacity(0.04),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: action.color.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(action.icon, color: action.color, size: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: onSurface,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (action.badgeCount != null && action.badgeCount! > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        action.badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
