import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/about_us_repository.dart';
import '../models/about_us_models.dart';
import '../providers/about_us_provider.dart';
import '../widgets/about_error_state.dart';
import '../widgets/about_hub_skeleton.dart';
import '../widgets/about_section_title.dart';
import '../widgets/about_surface_card.dart';
import 'about_contact_screen.dart';
import 'about_license_screen.dart';
import 'about_project_screen.dart';
import 'about_team_screen.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late final AboutUsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AboutUsProvider(repository: AboutUsRepository());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.initialize();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('About Farmy'), centerTitle: true),
        body: Consumer<AboutUsProvider>(
          builder: (context, provider, _) {
            final content = provider.content;

            Widget child;
            if (provider.isLoading && content == null) {
              child = const AboutHubSkeleton();
            } else if (provider.errorMessage != null && content == null) {
              child = AboutErrorState(
                message: provider.errorMessage!,
                onRetry: provider.retry,
              );
            } else if (content != null) {
              child = _AboutHubContent(
                content: content,
                onRefresh: provider.refresh,
                onOpenProject: () => _openProject(context, content),
                onOpenTeam: () => _openTeam(context, content),
                onOpenContacts: () => _openContacts(context, content),
                onOpenLicense: () => _openLicense(context, content),
              );
            } else {
              child = AboutErrorState(
                message:
                    'Something unexpected happened while loading Farmy info.',
                onRetry: provider.retry,
              );
            }

            return Column(
              children: [
                if (provider.isRefreshing)
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: theme.colorScheme.primary,
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openProject(BuildContext context, AboutUsContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AboutProjectScreen(
          project: content.project,
          capabilities: content.capabilities,
          milestones: content.milestones,
        ),
      ),
    );
  }

  void _openTeam(BuildContext context, AboutUsContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AboutTeamScreen(team: content.team)),
    );
  }

  void _openContacts(BuildContext context, AboutUsContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AboutContactScreen(
          contactDirectory: content.contactDirectory,
          team: content.team,
        ),
      ),
    );
  }

  void _openLicense(BuildContext context, AboutUsContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AboutLicenseScreen(license: content.license),
      ),
    );
  }
}

class _AboutHubContent extends StatelessWidget {
  const _AboutHubContent({
    required this.content,
    required this.onRefresh,
    required this.onOpenProject,
    required this.onOpenTeam,
    required this.onOpenContacts,
    required this.onOpenLicense,
  });

  final AboutUsContent content;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenProject;
  final VoidCallback onOpenTeam;
  final VoidCallback onOpenContacts;
  final VoidCallback onOpenLicense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int columns = width >= 980
              ? 3
              : width >= 640
              ? 2
              : 1;

          final cards = [
            _HubAction(
              title: 'Project Story',
              subtitle: 'Vision, architecture, and key capabilities',
              icon: Icons.auto_stories_outlined,
              color: theme.colorScheme.primary,
              onTap: onOpenProject,
            ),
            _HubAction(
              title: 'Team',
              subtitle: 'Meet Farmy builders and focus areas',
              icon: Icons.groups_2_outlined,
              color: Colors.blue.shade500,
              onTap: onOpenTeam,
            ),
            _HubAction(
              title: 'Contact',
              subtitle: 'GitHub, LinkedIn, and direct email channels',
              icon: Icons.contact_mail_outlined,
              color: Colors.teal.shade500,
              onTap: onOpenContacts,
            ),
            _HubAction(
              title: 'License',
              subtitle: 'Legal terms, usage rights, and notices',
              icon: Icons.gavel_outlined,
              color: Colors.orange.shade600,
              onTap: onOpenLicense,
            ),
          ];

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _HeroCard(content: content),
              const SizedBox(height: 18),
              const AboutSectionTitle(title: 'Explore Farmy'),
              GridView.builder(
                itemCount: cards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 132,
                ),
                itemBuilder: (context, index) {
                  final action = cards[index];
                  return _HubActionCard(action: action);
                },
              ),
              const SizedBox(height: 18),
              const AboutSectionTitle(title: 'Quick Snapshot'),
              AboutSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPill(
                          theme,
                          '${content.team.length} Team Members',
                        ),
                        _buildPill(
                          theme,
                          '${content.capabilities.length} Core Capabilities',
                        ),
                        _buildPill(theme, content.license.type),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      content.project.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPill(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.content});

  final AboutUsContent content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  content.project.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content.project.tagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.project.mission,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HubAction {
  const _HubAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _HubActionCard extends StatelessWidget {
  const _HubActionCard({required this.action});

  final _HubAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                action.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
