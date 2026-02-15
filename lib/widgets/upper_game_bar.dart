import 'package:flutter/material.dart';
import '../models/land_model.dart';

class UpperGameBar extends StatelessWidget {
  final Land land;
  final VoidCallback? onSettingsTap;

  const UpperGameBar({
    super.key,
    required this.land,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
            children: [
              // Land name and level
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${land.level}',
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Money counter
              Expanded(
                child: _buildStatContainer(
                  icon: Icons.monetization_on,
                  iconColor: Colors.yellow.shade700,
                  value: _formatNumber(land.money),
                  backgroundColor: Colors.yellow.shade900.withOpacity(0.3),
                ),
              ),

              const SizedBox(width: 8),

              // Food counter
              Expanded(
                child: _buildStatContainer(
                  icon: Icons.grass,
                  iconColor: Colors.green.shade400,
                  value: '${land.foodStorage.toInt()}/${land.maxFoodStorage.toInt()}',
                  backgroundColor: Colors.green.shade900.withOpacity(0.3),
                ),
              ),

              const SizedBox(width: 8),

              // Settings button
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: onSettingsTap,
                iconSize: 24,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStatContainer({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toInt().toString();
  }
}
