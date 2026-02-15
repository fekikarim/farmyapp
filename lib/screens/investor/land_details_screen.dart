import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/land_model.dart';
import '../../services/land_service.dart';
import 'rental_checkout_screen.dart';
import '../farmer/workforce_screen.dart';
import 'dart:ui';

class LandDetailsScreen extends StatefulWidget {
  final Land land;

  const LandDetailsScreen({super.key, required this.land});

  @override
  State<LandDetailsScreen> createState() => _LandDetailsScreenState();
}

class _LandDetailsScreenState extends State<LandDetailsScreen> {
  late Land _land;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _land = widget.land;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final updatedLand = await LandService.getLandById(widget.land.id);
      if (updatedLand != null && mounted) {
        setState(() {
          _land = updatedLand;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading && _land.boundaries == null
          ? _buildSkeletonLoader()
          : _error != null
          ? _buildErrorState()
          : _buildMainContent(),
      bottomSheet: _isLoading || _error != null ? null : _buildBottomSheet(),
    );
  }

  Widget _buildMainContent() {
    final center = _land.boundaries != null && _land.boundaries!.isNotEmpty
        ? LatLng(
            _land.boundaries!.map((p) => p.latitude).reduce((a, b) => a + b) /
                _land.boundaries!.length,
            _land.boundaries!.map((p) => p.longitude).reduce((a, b) => a + b) /
                _land.boundaries!.length,
          )
        : const LatLng(36.8065, 10.1815);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.iconTheme.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 16.5),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.farmy.app',
                      tileBuilder: (context, tileWidget, tile) {
                        if (!isDark) return tileWidget;
                        return ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            -0.9,
                            0,
                            0,
                            0,
                            255,
                            0,
                            -0.9,
                            0,
                            0,
                            255,
                            0,
                            0,
                            -0.9,
                            0,
                            255,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: tileWidget,
                        );
                      },
                    ),
                    if (_land.boundaries != null)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _land.boundaries!,
                            color: _land.isRented
                                ? Colors.orange.withOpacity(0.4)
                                : Colors.green.withOpacity(0.4),
                            borderColor: _land.isRented
                                ? Colors.orange
                                : Colors.green,
                            borderStrokeWidth: 3,
                            isFilled: true,
                          ),
                        ],
                      ),
                  ],
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withOpacity(0.0),
                          theme.scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (_land.isRented ? Colors.orange : Colors.green)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (_land.isRented ? Colors.orange : Colors.green)
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _land.isRented ? 'ALREADY RENTED' : 'PREMIUM FARMLAND',
                        style: TextStyle(
                          color: _land.isRented ? Colors.orange : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      'ID: ${_land.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _land.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoChip(
                        Icons.zoom_out_map_rounded,
                        '${(_land.gridWidth * _land.gridHeight * 1).toInt()} m²',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.grid_on_rounded,
                        '${_land.gridWidth}x${_land.gridHeight} Grid',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.water_drop_rounded, 'Irrigated'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader('Description', theme),
                const SizedBox(height: 12),
                Text(
                  _land.description ?? 'No description available',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader('Location Highlights', theme),
                const SizedBox(height: 24),
                _buildLocationItem(
                  Icons.wb_sunny_rounded,
                  'Optimal solar exposure for high-yield crops',
                  theme,
                ),
                _buildLocationItem(
                  Icons.local_shipping_rounded,
                  'Direct access to regional distribution roads',
                  theme,
                ),
                _buildLocationItem(
                  Icons.opacity_rounded,
                  'Secured year-round water access rights',
                  theme,
                ),
                const SizedBox(height: 40),
                // Workforce Management (only for rented lands where investor has authority)
                if (_land.isRented) ...[
                  _buildSectionHeader('Workforce', theme),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkforceScreen(
                              landId: _land.id,
                              landName: _land.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.people_alt_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Manage Workers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 100), // Spacer for bottom sheet
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.textTheme.titleLarge?.color,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price per month',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1,200 TND',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              decoration: _land.isRented
                  ? null
                  : BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
              child: ElevatedButton(
                onPressed: _land.isRented
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RentalCheckoutScreen(land: _land),
                          ),
                        );
                        if (result == true) {
                          _fetchDetails();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _land.isRented
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green,
                  foregroundColor: _land.isRented
                      ? Colors.orange
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  side: _land.isRented
                      ? const BorderSide(color: Colors.orange, width: 1.5)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.orange.withOpacity(0.1),
                  disabledForegroundColor: Colors.orange,
                ),
                child: Text(
                  _land.isRented ? 'OCCUPIED' : 'RENT NOW',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 300, color: Colors.white.withOpacity(0.03)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: 200,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sync Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Unable to retrieve land details',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String text, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
