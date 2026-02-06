import 'package:flutter/material.dart';
import '../../models/land_model.dart';
import 'isometric_map.dart';
import 'land_grid_service.dart';

class GameScreen extends StatefulWidget {
  final Land land;

  const GameScreen({super.key, required this.land});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Map<String, dynamic>? _gridData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGrid();
  }

  Future<void> _fetchGrid() async {
    try {
      final data = await LandGridService.fetchLandGrid(widget.land.id);
      if (mounted) {
        setState(() {
          _gridData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching grid: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Space/Void background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gridData == null
              ? const Center(child: Text('Failed to load map', style: TextStyle(color: Colors.white)))
              : IsometricMap(
                  gridWidth: _gridData!['grid_width'],
                  gridHeight: _gridData!['grid_height'],
                  matrix: _gridData!['matrix'],
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
