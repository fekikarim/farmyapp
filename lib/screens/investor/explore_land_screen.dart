import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/land_provider.dart';
import '../../models/land_model.dart';
import 'land_details_screen.dart';

class InvestorExploreLandScreen extends StatefulWidget {
  const InvestorExploreLandScreen({super.key});

  @override
  State<InvestorExploreLandScreen> createState() =>
      _InvestorExploreLandScreenState();
}

class _InvestorExploreLandScreenState extends State<InvestorExploreLandScreen> {
  ViewMode _currentMode = ViewMode.list;
  bool _isSatellite = true;
  bool _is3D = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      await context.read<LandProvider>().fetchAllLands();
      if (mounted && _currentMode == ViewMode.list) {
        // Success feedback if needed
      }
    } catch (e) {
      // Error handled by consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131518),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Explore Lands',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _ToggleItem(
                  icon: Icons.list_rounded,
                  isSelected: _currentMode == ViewMode.list,
                  onTap: () => setState(() => _currentMode = ViewMode.list),
                ),
                _ToggleItem(
                  icon: Icons.layers_rounded,
                  isSelected: _currentMode == ViewMode.ar,
                  onTap: () => setState(() => _currentMode = ViewMode.ar),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<LandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allLands.isEmpty) {
            return _buildSkeletonLoader();
          }

          if (provider.error != null && provider.allLands.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          if (provider.allLands.isEmpty) {
            return _buildEmptyState();
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _currentMode == ViewMode.list
                ? RefreshIndicator(
                    onRefresh: _loadData,
                    backgroundColor: Colors.green,
                    color: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.allLands.length,
                      itemBuilder: (context, index) => _InvestorLandCard(
                        land: provider.allLands[index],
                        onTap: (land) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandDetailsScreen(land: land),
                          ),
                        ),
                      ),
                    ),
                  )
                : _buildMapView(provider.allLands),
          );
        },
      ),
    );
  }

  Widget _buildMapView(List<Land> lands) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter:
                lands.isNotEmpty &&
                    lands[0].boundaries != null &&
                    lands[0].boundaries!.isNotEmpty
                ? lands[0].boundaries![0]
                : const LatLng(36.8065, 10.1815),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.farmy.app',
              subdomains: const ['a', 'b', 'c'],
            ),
            PolygonLayer(
              polygons: lands
                  .where(
                    (l) => l.boundaries != null && l.boundaries!.isNotEmpty,
                  )
                  .map(
                    (land) => Polygon(
                      points: land.boundaries!,
                      color: Colors.green.withOpacity(0.3),
                      borderColor: Colors.green,
                      borderStrokeWidth: 2,
                      isFilled: true,
                      label: land.name,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: Column(
            children: [
              _MapActionBtn(
                icon: _isSatellite
                    ? Icons.map_outlined
                    : Icons.satellite_alt_rounded,
                onTap: () => setState(() => _isSatellite = !_isSatellite),
              ),
              const SizedBox(height: 12),
              _MapActionBtn(
                icon: Icons.view_in_ar_rounded,
                isSelected: _is3D,
                onTap: () {
                  setState(() {
                    _is3D = !_is3D;
                    _mapController.rotate(_is3D ? 45.0 : 0.0);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        height: 280,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D21),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (i) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadData,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape_rounded, size: 100, color: Colors.white12),
          const SizedBox(height: 16),
          const Text(
            'No lands found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new opportunities.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

enum ViewMode { list, ar }

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.white54,
        ),
      ),
    );
  }
}

class _MapActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const _MapActionBtn({
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : const Color(0xFF1E2125),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _InvestorLandCard extends StatelessWidget {
  final Land land;
  final Function(Land) onTap;

  const _InvestorLandCard({required this.land, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final center = land.boundaries != null && land.boundaries!.isNotEmpty
        ? LatLng(
            land.boundaries!.map((p) => p.latitude).reduce((a, b) => a + b) /
                land.boundaries!.length,
            land.boundaries!.map((p) => p.longitude).reduce((a, b) => a + b) /
                land.boundaries!.length,
          )
        : const LatLng(36.8065, 10.1815);

    return GestureDetector(
      onTap: () => onTap(land),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D21),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 16.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.farmy.app',
                          tileBuilder: (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -1,
                                0,
                                0,
                                0,
                                255,
                                0,
                                -1,
                                0,
                                0,
                                255,
                                0,
                                0,
                                -1,
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
                        if (land.boundaries != null)
                          PolygonLayer(
                            polygons: [
                              Polygon(
                                points: land.boundaries!,
                                color: Colors.green.withOpacity(0.4),
                                borderColor: Colors.green,
                                borderStrokeWidth: 2,
                                isFilled: true,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              land.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 8, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        'Size',
                        '${land.gridWidth}x${land.gridHeight} Plots',
                        Icons.grid_3x3_rounded,
                      ),
                      _buildPriceInfo(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onTap(land),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.green.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 0.5),
      ),
      child: const Text(
        'AVAILABLE',
        style: TextStyle(
          color: Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white38),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Price starting from',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 4),
        const Text(
          '1,200 TND',
          style: TextStyle(
            color: Colors.green,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
