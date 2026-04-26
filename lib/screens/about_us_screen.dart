import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              title: Text(
                l10n.aboutUs,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo-app-no-bg.png',
                    height: 80,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context, l10n),
                  const SizedBox(height: 40),
                  _buildAboutSection(context, l10n, isDark),
                  const SizedBox(height: 40),
                  _buildTeamSection(context, l10n),
                  const SizedBox(height: 40),
                  _buildFAQSection(context, l10n),
                  const SizedBox(height: 40),
                  _buildFooter(context, l10n, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: Column(
        children: [
          Text(
            'Farmy',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.farmyTagline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n, bool isDark) {
    return _SectionWrapper(
      title: l10n.aboutFarmyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.farmyDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          _buildMissionVisionCard(context, l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildMissionVisionCard(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.missionTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.missionDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.visibility, color: AppTheme.secondaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.visionTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.visionDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, AppLocalizations l10n) {
    final teamMembers = [
      _TeamMemberData(
        name: 'Karim Feki',
        role: l10n.leadDeveloperRole,
        github: 'https://github.com/fekikarim',
        linkedin: 'https://www.linkedin.com/in/karimfeki/',
        portfolio: 'https://karimfeki.is-a.dev',
        color: Colors.blue,
      ),
      _TeamMemberData(
        name: 'Nesrine Derouiche',
        role: l10n.developerRole,
        github: 'https://github.com/nesrine-derouiche',
        linkedin: 'https://www.linkedin.com/in/nesrine-derouiche/',
        portfolio: 'https://nesrine-derouiche.is-a.dev',
        color: Colors.purple,
      ),
      _TeamMemberData(
        name: 'Mohamed Abidi',
        role: l10n.developerRole,
        github: 'https://github.com/HamaBTW',
        linkedin: 'https://www.linkedin.com/in/med-abidi/',
        color: Colors.orange,
      ),
      _TeamMemberData(
        name: 'Oussema Issaoui',
        role: l10n.developerRole,
        github: 'https://github.com/oussemissaoui',
        linkedin: '',
        color: Colors.teal,
      ),
      _TeamMemberData(
        name: 'Fatma Hidoussi',
        role: l10n.developerRole,
        github: 'https://github.com/fatmahidouss',
        linkedin: 'https://www.linkedin.com/in/fatma-hidoussi-497052236/',
        color: Colors.pink,
      ),
    ];

    return _SectionWrapper(
      title: l10n.meetTheTeamTitle,
      subtitle: l10n.meetTheTeamSubtitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: teamMembers.map((member) {
              return SizedBox(
                width: isWide ? (constraints.maxWidth - 32) / 2 : double.infinity,
                child: TeamMemberCard(member: member),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, AppLocalizations l10n) {
    final faqs = [
      FAQItemData(
        question: l10n.faqWhatIsFarmy,
        answer: l10n.faqWhatIsFarmyAnswer,
      ),
      FAQItemData(
        question: l10n.faqWhoIsBehind,
        answer: l10n.faqWhoIsBehindAnswer,
      ),
      FAQItemData(
        question: l10n.faqTechnologies,
        answer: l10n.faqTechnologiesAnswer,
      ),
      FAQItemData(
        question: l10n.faqContribute,
        answer: l10n.faqContributeAnswer,
      ),
    ];

    return _SectionWrapper(
      title: l10n.faqTitle,
      child: Column(
        children: faqs.map((faq) => FAQItem(faq: faq)).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 24),
          Text(
            '© ${DateTime.now().year} Farmy Team',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.madeWithLove,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionWrapper extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionWrapper({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _TeamMemberData {
  final String name;
  final String role;
  final String github;
  final String linkedin;
  final String? portfolio;
  final Color color;

  _TeamMemberData({
    required this.name,
    required this.role,
    required this.github,
    required this.linkedin,
    this.portfolio,
    required this.color,
  });
}

class TeamMemberCard extends StatefulWidget {
  final _TeamMemberData member;

  const TeamMemberCard({super.key, required this.member});

  @override
  State<TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<TeamMemberCard> {
  bool _isHovered = false;

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getInitials(String name) {
    return name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join('').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.member.color.withOpacity(0.5)
                  : AppTheme.primaryColor.withOpacity(0.1),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.member.color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: _isHovered ? 1.05 : 1.0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.member.color,
                        widget.member.color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(widget.member.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.member.role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _SocialIconButton(
                          icon: Icons.code,
                          onTap: () => _launchUrl(widget.member.github),
                          color: widget.member.color,
                          tooltip: 'GitHub',
                        ),
                        if (widget.member.linkedin.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _SocialIconButton(
                            icon: Icons.business,
                            onTap: () => _launchUrl(widget.member.linkedin),
                            color: widget.member.color,
                            tooltip: 'LinkedIn',
                          ),
                        ],
                        if (widget.member.portfolio != null && widget.member.portfolio!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _SocialIconButton(
                            icon: Icons.language,
                            onTap: () => _launchUrl(widget.member.portfolio!),
                            color: widget.member.color,
                            tooltip: 'Portfolio',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tooltip;

  const _SocialIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class FAQItemData {
  final String question;
  final String answer;

  FAQItemData({required this.question, required this.answer});
}

class FAQItem extends StatefulWidget {
  final FAQItemData faq;

  const FAQItem({super.key, required this.faq});

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.expand_more,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.faq.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
