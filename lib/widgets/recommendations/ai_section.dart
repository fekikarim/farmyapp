import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/auth_provider.dart';
import 'ai_product_card.dart';
import 'ai_land_card.dart';

class AIRecommendationsSection extends StatefulWidget {
  final String type; // 'products' or 'lands'
  final VoidCallback? onProductTap;
  final VoidCallback? onLandTap;
  final Function(Map<String, dynamic>)? onItemTap;
  final String? customTitle;
  final String? customSubtitle;

  const AIRecommendationsSection({
    super.key,
    required this.type,
    this.onProductTap,
    this.onLandTap,
    this.onItemTap,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  State<AIRecommendationsSection> createState() => _AIRecommendationsSectionState();
}

class _AIRecommendationsSectionState extends State<AIRecommendationsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadRecommendations() {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final provider = context.read<SmartRecommendationsProvider>();

    if (widget.type == 'products') {
      provider.fetchProductRecommendations(auth.user!.id);
    } else if (widget.type == 'lands') {
      provider.fetchLandRecommendations(auth.user!.id);
    }

    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SmartRecommendationsProvider>(
      builder: (context, provider, _) {
        if (widget.type == 'products') {
          return _buildProductsSection(context, theme, provider);
        } else {
          return _buildLandsSection(context, theme, provider);
        }
      },
    );
  }

  Widget _buildProductsSection(BuildContext context, ThemeData theme, SmartRecommendationsProvider provider) {
    if (provider.isProductsLoading) {
      return _buildSkeletonLoader(theme);
    }

    if (provider.productsError != null) {
      return _buildErrorState(context, theme, provider.productsError!, () {
        _loadRecommendations();
      });
    }

    if (provider.productRecommendations.isEmpty) {
      return _buildEmptyState(theme, 'No recommendations yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customTitle ?? 'AI Recommended for You',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.customSubtitle ?? 'Smart matchings based on your preferences',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Recommendations carousel
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.productRecommendations.length,
            itemBuilder: (context, index) {
              final product = provider.productRecommendations[index];
              final matchScore = (product['matchScore'] as num?)?.toInt() ?? 0;
              final reasoning = product['aiReasoning'] ?? 'Recommended for you';

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 280,
                  child: AIProductRecommendationCard(
                    product: product,
                    matchScore: matchScore,
                    aiReasoning: reasoning,
                    onTap: () {
                      widget.onItemTap?.call(product);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLandsSection(BuildContext context, ThemeData theme, SmartRecommendationsProvider provider) {
    if (provider.isLandsLoading) {
      return _buildSkeletonLoader(theme);
    }

    if (provider.landsError != null) {
      return _buildErrorState(context, theme, provider.landsError!, () {
        _loadRecommendations();
      });
    }

    if (provider.landRecommendations.isEmpty) {
      return _buildEmptyState(theme, 'No lands available for investment');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customTitle ?? 'Best Investment Opportunities',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.customSubtitle ?? 'Lands matched to your investment profile',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Recommendations carousel
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.landRecommendations.length,
            itemBuilder: (context, index) {
              final land = provider.landRecommendations[index];
              final matchScore = (land['matchScore'] as num?)?.toInt() ?? 0;
              final reasoning = land['aiReasoning'] ?? 'Great investment opportunity';

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 280,
                  child: AILandRecommendationCard(
                    land: land,
                    matchScore: matchScore,
                    aiReasoning: reasoning,
                    onTap: () {
                      widget.onItemTap?.call(land);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSkeletonLoader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    String error,
    VoidCallback onRetry,
  ) {
    // Check if error is about location not set
    bool isLocationError = error.contains('location') || error.contains('Location');
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                isLocationError ? Icons.location_off : Icons.error_outline,
                size: 48,
                color: isLocationError ? Colors.orange.shade400 : Colors.red.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                isLocationError ? 'Location Required' : 'Failed to Load Recommendations',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                isLocationError 
                  ? 'Please update your location in settings to get personalized recommendations'
                  : error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              if (isLocationError)
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to settings
                    Navigator.of(context).pushNamed('/settings');
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Go to Settings'),
                )
              else
                ElevatedButton.icon(
                  onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Try updating your profile preferences',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
