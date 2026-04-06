import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/about_us_models.dart';
import '../widgets/about_section_title.dart';
import '../widgets/about_surface_card.dart';

class AboutLicenseScreen extends StatelessWidget {
  const AboutLicenseScreen({super.key, required this.license});

  final LicenseInfo license;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('License & Legal'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AboutSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      license.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        license.type,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      license.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.74,
                        ),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const AboutSectionTitle(title: 'License Highlights'),
              AboutSurfaceCard(
                child: Column(
                  children: license.highlights
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
              const AboutSectionTitle(title: 'Full License Text'),
              AboutSurfaceCard(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 220),
                  child: SelectableText(
                    license.fullText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.78,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AboutSurfaceCard(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showLicensePage(
                          context: context,
                          applicationName: 'Farmy',
                        );
                      },
                      icon: const Icon(Icons.article_outlined),
                      label: const Text('Dependency Licenses'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copyLicense(context),
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('Copy Text'),
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

  Future<void> _copyLicense(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: license.fullText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('License text copied.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to copy license text.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
