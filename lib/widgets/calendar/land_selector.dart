import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_calendar_provider.dart';
import '../../theme/app_theme.dart';

/// Dropdown selector for choosing which land to view
class LandSelector extends StatelessWidget {
  final bool showAllOption;
  final VoidCallback? onChanged;

  const LandSelector({super.key, this.showAllOption = true, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropCalendarProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lands = provider.lands;
    final selectedLandId = provider.selectedLandId;

    if (lands.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No lands available. Add a land first.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    // Build dropdown items
    final List<DropdownMenuItem<String>> items = [];

    if (showAllOption) {
      items.add(
        DropdownMenuItem(
          value: null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.landscape,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'All Lands',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    items.addAll(
      lands.map((land) {
        return DropdownMenuItem(
          value: land.id,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      land.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${land.gridWidth}x${land.gridHeight} tiles',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLandId,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: items,
          onChanged: (value) {
            provider.selectLand(value);
            onChanged?.call();
          },
          hint: const Row(
            children: [
              Icon(Icons.landscape, size: 20),
              SizedBox(width: 12),
              Text('Select Land'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact chip version of land selector for tight spaces
class LandSelectorChips extends StatelessWidget {
  final VoidCallback? onChanged;

  const LandSelectorChips({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropCalendarProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lands = provider.lands;
    final selectedLandId = provider.selectedLandId;

    if (lands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lands.length + 1,
        itemBuilder: (context, index) {
          // "All Lands" chip at the beginning
          if (index == 0) {
            final isSelected = selectedLandId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All Lands'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    provider.selectLand(null);
                    onChanged?.call();
                  }
                },
                selectedColor: AppTheme.primaryColor,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            );
          }

          final land = lands[index - 1];
          final isSelected = selectedLandId == land.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(land.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.selectLand(land.id);
                  onChanged?.call();
                }
              },
              selectedColor: AppTheme.secondaryColor,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              avatar: isSelected
                  ? const Icon(Icons.check, size: 16)
                  : const Icon(Icons.location_on, size: 16),
            ),
          );
        },
      ),
    );
  }
}
