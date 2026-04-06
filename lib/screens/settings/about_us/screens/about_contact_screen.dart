import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/about_us_models.dart';
import '../widgets/about_section_title.dart';
import '../widgets/about_surface_card.dart';

class AboutContactScreen extends StatelessWidget {
  const AboutContactScreen({
    super.key,
    required this.contactDirectory,
    required this.team,
  });

  final ContactDirectory contactDirectory;
  final List<TeamMember> team;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Farmy Team'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AboutSectionTitle(title: 'GitHub'),
              _ContactGroup(
                items: contactDirectory.github,
                icon: Icons.code,
                onOpen: (item) => _openContact(context, item),
                onCopy: (item) => _copyValue(context, item.value),
              ),
              const SizedBox(height: 10),
              const AboutSectionTitle(title: 'LinkedIn'),
              _ContactGroup(
                items: contactDirectory.linkedIn,
                icon: Icons.business_center_outlined,
                onOpen: (item) => _openContact(context, item),
                onCopy: (item) => _copyValue(context, item.url),
              ),
              const SizedBox(height: 10),
              const AboutSectionTitle(title: 'Email'),
              _ContactGroup(
                items: contactDirectory.email,
                icon: Icons.email_outlined,
                onOpen: (item) => _openContact(context, item),
                onCopy: (item) => _copyValue(context, item.value),
              ),
              const SizedBox(height: 18),
              const AboutSectionTitle(title: 'Response Commitment'),
              AboutSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The Farmy team actively monitors collaboration and support channels. For the fastest response, include context about your feature, bug, or partnership request.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: team
                          .map((member) => _chip(context, member.name))
                          .toList(),
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

  Future<void> _openContact(BuildContext context, ContactLink item) async {
    final uri = Uri.tryParse(item.url);
    if (uri == null) {
      _showError(context, 'Invalid link format for ${item.label}.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showError(context, 'Unable to open ${item.label}.');
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Unable to open ${item.label}.');
      }
    }
  }

  Future<void> _copyValue(BuildContext context, String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context, 'Copy failed. Please try again.');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _chip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactGroup extends StatelessWidget {
  const _ContactGroup({
    required this.items,
    required this.icon,
    required this.onOpen,
    required this.onCopy,
  });

  final List<ContactLink> items;
  final IconData icon;
  final Future<void> Function(ContactLink item) onOpen;
  final Future<void> Function(ContactLink item) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AboutSurfaceCard(
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    item.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    item.value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      IconButton(
                        tooltip: 'Open',
                        onPressed: () => onOpen(item),
                        icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Copy',
                        onPressed: () => onCopy(item),
                        icon: const Icon(Icons.copy_rounded, size: 19),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
