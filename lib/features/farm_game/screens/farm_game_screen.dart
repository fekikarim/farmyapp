import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmGameProvider>().loadLandGrid(widget.landId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark premium background
      appBar: AppBar(
        title: Text(widget.landName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FarmGameProvider>().loadLandGrid(widget.landId),
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () => context.read<FarmGameProvider>().resetView(),
          ),
        ],
      ),
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

          return GameWidget(
            game: FarmGame(grid: provider.grid!),
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
