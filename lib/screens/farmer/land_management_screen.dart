import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/land_model.dart';
import '../../providers/land_provider.dart';
import 'add_land_screen.dart';
import 'rental_requests_screen.dart';

class FarmerLandManagementScreen extends StatefulWidget {
  const FarmerLandManagementScreen({super.key});

  @override
  State<FarmerLandManagementScreen> createState() =>
      _FarmerLandManagementScreenState();
}

enum ViewMode { list, ar }

class _FarmerLandManagementScreenState extends State<FarmerLandManagementScreen>
    with TickerProviderStateMixin {
  ViewMode _currentMode = ViewMode.list;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await context.read<LandProvider>().fetchMyLands();
    if (_currentMode == ViewMode.ar && mounted) {
      final count = context.read<LandProvider>().myLands.length;
      _fitMapToLands();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ $count Lands Synchronized Successfully!'),
          backgroundColor: Colors.green.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _fitMapToLands() {
    final lands = context.read<LandProvider>().myLands;
    if (lands.isEmpty) return;

    List<LatLng> allPoints = [];
    for (var land in lands) {
      if (land.boundaries != null) allPoints.addAll(land.boundaries!);
    }

    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(allPoints);
    _animatedMapMove(bounds.center, 15.0);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113), // Deep premium background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Lands',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _buildViewToggle(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmerRentalRequestsScreen(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<LandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myLands.isEmpty) {
            return _buildSkeletonLoader();
          }

          if (provider.error != null && provider.myLands.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          if (provider.myLands.isEmpty) {
            return _buildEmptyState();
          }

          return Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _currentMode == ViewMode.list
                    ? _buildListView(provider.myLands)
                    : _buildARMapView(provider.myLands),
              ),
              // Only show general indicator for list view; Map has its own premium overlay
              if (provider.isLoading && _currentMode == ViewMode.list)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FarmerAddLandScreen()),
        ),
        label: const Text(
          'New Listing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_location_alt_outlined),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            icon: Icons.view_list_rounded,
            isSelected: _currentMode == ViewMode.list,
            onTap: () => setState(() => _currentMode = ViewMode.list),
          ),
          _ToggleItem(
            icon: Icons.layers_outlined,
            isSelected: _currentMode == ViewMode.ar,
            onTap: () {
              setState(() => _currentMode = ViewMode.ar);
              _loadData(); // Auto-refresh when switching to AR for fresh data
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Land> lands) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.green,
      child: ListView.builder(
        key: const ValueKey('list_view'),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        itemCount: lands.length,
        itemBuilder: (context, index) => _ModernLandCard(
          land: lands[index],
          onDetailTap: (land) => _showLandDetails(land),
        ),
      ),
    );
  }

  Widget _buildARMapView(List<Land> lands) {
    // Collect all points to calculate center
    List<LatLng> allPoints = [];
    for (var land in lands) {
      if (land.boundaries != null) allPoints.addAll(land.boundaries!);
    }

    final center = allPoints.isNotEmpty
        ? LatLng(
            allPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
                allPoints.length,
            allPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
                allPoints.length,
          )
        : const LatLng(36.8065, 10.1815);

    return Stack(
      children: [
        FlutterMap(
          key: const ValueKey('ar_map_view'),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15.0,
            initialRotation: 15.0, // Slight 3D tilt perspective
            onTap: (tapPosition, latLng) {
              for (var land in lands) {
                if (land.boundaries != null &&
                    _isPointInPolygon(latLng, land.boundaries!)) {
                  _showLandDetails(land);
                  break;
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.farmy.app.v1',
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
                  ]), // Invert colors for dark mode map
                  child: tileWidget,
                );
              },
            ),
            PolygonLayer(
              polygons: lands.where((l) => l.boundaries != null).map((land) {
                return Polygon(
                  points: land.boundaries!,
                  color: Colors.green.withOpacity(0.4),
                  borderColor: Colors.white,
                  borderStrokeWidth: 2,
                  isFilled: true,
                  label: land.name,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Premium Map Loading Overlay
        Consumer<LandProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SYNCHRONIZING BOUNDARIES',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fetching precise spatial data...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (provider.error != null) {
              return _buildMapErrorOverlay(provider.error!);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMapErrorOverlay(String error) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sync Interrupted',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try to Re-sync'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    var isInside = false;
    var j = polygon.length - 1;
    for (var i = 0; i < polygon.length; i++) {
      if ((((polygon[i].latitude <= point.latitude) &&
                  (point.latitude < polygon[j].latitude)) ||
              ((polygon[j].latitude <= point.latitude) &&
                  (point.latitude < polygon[i].latitude))) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
  }

  void _showLandDetails(Land land) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D21),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          land.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${land.id.substring(0, 8)}...',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusTag(land.isActive),
                ],
              ),
              const SizedBox(height: 32),
              _buildDetailGrid(land),
              const SizedBox(height: 40),
              const Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                land.description ?? 'No description provided for this land.',
                style: const TextStyle(color: Colors.white70, height: 1.6),
              ),
              const SizedBox(height: 48),
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailGrid(Land land) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _DetailItem(
          label: 'Area',
          value: '${land.gridWidth}x${land.gridHeight}',
          icon: Icons.grid_4x4,
        ),
        _DetailItem(label: 'Rentals', value: '2 Active', icon: Icons.people),
        _DetailItem(label: 'Earnings', value: '2,400 TND', icon: Icons.wallet),
        _DetailItem(
          label: 'Safety',
          value: 'Verified',
          icon: Icons.verified_user,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Manage Assets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'LIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to sync with backend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
            'Start by listing your first plot of land.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

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
          borderRadius: BorderRadius.circular(12),
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

class _ModernLandCard extends StatelessWidget {
  final Land land;
  final Function(Land) onDetailTap;

  const _ModernLandCard({required this.land, required this.onDetailTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onDetailTap(land),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildThumb(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          land.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${land.gridWidth}x${land.gridHeight} Grid Area',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusTag(land.isActive),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickStat('Rentals', '0 Active', Icons.people_outline),
                  _buildQuickStat(
                    'Revenue',
                    '0.0 TND',
                    Icons.account_balance_wallet_outlined,
                  ),
                  _ActionButton(onTap: () => onDetailTap(land)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.terrain_rounded, color: Colors.white, size: 28),
    );
  }

  Widget _buildStatusTag(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'LIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white38),
            const SizedBox(width: 4),
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
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
