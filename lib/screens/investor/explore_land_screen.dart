import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/land_provider.dart';
import '../../models/land_model.dart';
import '../../models/land_rental_model.dart';
import 'land_details_screen.dart';
import 'package:farmyapp/widgets/subscription_limit_bar.dart';
import 'widgets/investor_workforce_screen.dart';

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
      final landProvider = context.read<LandProvider>();
      await Future.wait([
        landProvider.fetchAllLands(),
        landProvider.fetchMyRentals(true), // Fetch as investor
      ]);

      if (mounted && _currentMode == ViewMode.list) {
        // Success feedback if needed
      }
    } catch (e) {
      // Error handled by consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Explore Lands',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
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
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.iconTheme.color,
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

          final availableLands = _currentMode == ViewMode.list
              ? provider.allLands.where((l) => !l.isRented).toList()
              : provider.allLands;

          if (availableLands.isEmpty && _currentMode == ViewMode.list) {
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
                      itemCount: availableLands.length + 1, // +1 for limit bar
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SubscriptionLimitBar(
                              limitKey: 'rental_limit',
                              currentCount: provider.myRentals.length,
                              label: 'Rental Slots Usage',
                              icon: Icons.vpn_key_rounded,
                              accentColor: Colors.blue,
                              upgradePlanName: 'Investor Plus',
                            ),
                          );
                        }
                        return _InvestorLandCard(
                          land: availableLands[index - 1],
                          onTap: (land) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LandDetailsScreen(land: land),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : _buildMapView(provider.allLands),
          );
        },
      ),
    );
  }

  Widget _buildMapView(List<Land> lands) {
    final myRentals = context.read<LandProvider>().myRentals;
    final currentUser = context.read<AuthProvider>().user;

    Land? activeLand;
    if (currentUser?.role == 'investor' && myRentals.isNotEmpty) {
      try {
        final activeRental = myRentals.firstWhere(
          (r) =>
              r.paymentStatus != PaymentStatus.cancelled &&
              (r.rentalEndDate == null ||
                  r.rentalEndDate!.isAfter(DateTime.now())),
        );

        if (activeRental.land != null) {
          activeLand = activeRental.land;
        } else if (lands.isNotEmpty) {
          try {
            activeLand = lands.firstWhere((l) => l.id == activeRental.landId);
          } catch (_) {}
        }
      } catch (_) {}
    }

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
            onTap: (tapPosition, point) {
              for (var land in lands) {
                if (land.boundaries != null &&
                    _isPointInPolygon(point, land.boundaries!)) {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandDetailsScreen(land: land),
                    ),
                  );
                  return;
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.farmy.app',
            ),
            PolygonLayer(
              polygons: lands
                  .where(
                    (l) => l.boundaries != null && l.boundaries!.isNotEmpty,
                  )
                  .map(
                    (land) => Polygon(
                      points: land.boundaries!,
                      color: land.isRented
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                      borderColor: land.isRented ? Colors.orange : Colors.green,
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

        // Game Controls Overlay (Bottom Right)
        Positioned(
          bottom: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Workforce Button (New)
              if (activeLand != null &&
                  activeLand.isRented) // Condition changed
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton.extended(
                    heroTag: 'workforce_fab',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvestorWorkforceScreen(
                            landId: activeLand!.id,
                            landName: activeLand.name,
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.blue.shade600,
                    icon: const Icon(
                      Icons.engineering_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Workforce',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

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

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    var isInside = false;
    var j = polygon.length - 1;
    for (var i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < point.latitude &&
                  polygon[j].latitude >= point.latitude ||
              polygon[j].latitude < point.latitude &&
                  polygon[i].latitude >= point.latitude) &&
          (polygon[i].longitude +
                  (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) *
                      (polygon[j].longitude - polygon[i].longitude) <
              point.longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
  }

  Widget _buildSkeletonLoader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        height: 320,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
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
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 14,
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.08),
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
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.05,
                      ),
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
    bool isNetwork =
        error.contains('SocketException') ||
        error.contains('Failed host lookup');
    String displayError = isNetwork
        ? 'No internet connection. Please check your network and try again.'
        : error.replaceAll('Exception: ', '').replaceAll('HttpException: ', '');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                label: const Text(
                  'TRY AGAIN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white54 : Colors.black45),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green
              : (isDark ? const Color(0xFF1E2125) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
          border: isDark
              ? null
              : Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white : Colors.black87),
          size: 20,
        ),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(land),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.3),
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
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.farmy.app',
                          tileBuilder: (context, tileWidget, tile) {
                            if (!isDark) return tileWidget;
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
                                color: land.isRented
                                    ? Colors.orange.withOpacity(0.4)
                                    : Colors.green.withOpacity(0.4),
                                borderColor: land.isRented
                                    ? Colors.orange
                                    : Colors.green,
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
                        context,
                        'Size',
                        '${land.gridWidth}x${land.gridHeight} Plots',
                        Icons.grid_3x3_rounded,
                      ),
                      _buildPriceInfo(context, land),
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
        color: (land.isRented ? Colors.orange : Colors.green).withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (land.isRented ? Colors.orange : Colors.green).withOpacity(
            0.5,
          ),
          width: 0.5,
        ),
      ),
      child: Text(
        land.isRented ? 'RENTED' : 'AVAILABLE',
        style: TextStyle(
          color: land.isRented ? Colors.orange : Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark ? Colors.white38 : Colors.black38;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: secondaryColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: secondaryColor, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo(BuildContext context, Land land) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Price starting from',
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${NumberFormat('#,###').format(land.price)} TND',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
