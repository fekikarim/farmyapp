import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import '../providers/farm_game_provider.dart';
import '../flame/farm_game.dart';

class FarmGameScreen extends StatefulWidget {
  final String landId;
  final String landName;

  const FarmGameScreen({
    super.key,
    required this.landId,
    required this.landName,
  });

  @override
  State<FarmGameScreen> createState() => _FarmGameScreenState();
}

class _FarmGameScreenState extends State<FarmGameScreen> {

  @override
  void initState() {
    super.initState();
    // Force Landscape and Fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmGameProvider>().loadLandGrid(widget.landId);
    });
  }

  @override
  void dispose() {
    // Reset to Portrait and show UI on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark premium background
      body: Consumer<FarmGameProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadLandGrid(widget.landId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.grid == null) {
            return const Center(child: Text('No grid data found', style: TextStyle(color: Colors.white)));
          }

          return Stack(
            children: [
              GameWidget(
                game: FarmGame(grid: provider.grid!),
                loadingBuilder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              // Floating Tools Bar
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToolButton(
                          icon: Icons.refresh,
                          onPressed: () => context.read<FarmGameProvider>().loadLandGrid(widget.landId),
                        ),
                        const SizedBox(width: 20),
                        _ToolButton(
                          icon: Icons.center_focus_strong,
                          onPressed: () => context.read<FarmGameProvider>().resetView(),
                        ),
                        const SizedBox(width: 20),
                        _ToolButton(
                          icon: Icons.shopping_cart,
                          onPressed: () {}, // Shop placeholder
                        ),
                        const SizedBox(width: 20),
                        _ToolButton(
                          icon: Icons.grid_on,
                          onPressed: () {}, // Grid toggle placeholder
                        ),
                        const SizedBox(width: 20),
                        _ToolButton(
                          icon: Icons.close,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ToolButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
