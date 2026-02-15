import 'package:flutter/material.dart';

enum GameTab {
  build,
  animals,
  quests,
  resources,
  market,
}

class LowerGameBar extends StatefulWidget {
  final GameTab? selectedTab;
  final Function(GameTab) onTabSelected;

  const LowerGameBar({
    super.key,
    this.selectedTab,
    required this.onTabSelected,
  });

  @override
  State<LowerGameBar> createState() => _LowerGameBarState();
}

class _LowerGameBarState extends State<LowerGameBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabButton(
              icon: Icons.construction,
              label: 'Build',
              tab: GameTab.build,
            ),
            _buildTabButton(
              icon: Icons.pets,
              label: 'Animals',
              tab: GameTab.animals,
            ),
            _buildTabButton(
              icon: Icons.task_alt,
              label: 'Quests',
              tab: GameTab.quests,
            ),
            _buildTabButton(
              icon: Icons.inventory_2,
              label: 'Resources',
              tab: GameTab.resources,
            ),
            _buildTabButton(
              icon: Icons.store,
              label: 'Market',
              tab: GameTab.market,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required GameTab tab,
  }) {
    final isSelected = widget.selectedTab == tab;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTabSelected(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isSelected
                      ? Colors.greenAccent
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.greenAccent : Colors.white70,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.greenAccent : Colors.white70,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
