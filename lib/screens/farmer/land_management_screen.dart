import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/land_model.dart';
import '../../providers/land_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/subscription_limit_bar.dart';
import 'add_land_screen.dart';
import 'rental_requests_screen.dart';
import 'edit_land_sheet.dart';
import 'workforce_screen.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/land_rental_model.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = context.read<LandProvider>();
    await Future.wait([provider.fetchMyLands(), provider.fetchAllLands()]);

    if (_currentMode == ViewMode.ar && mounted) {
      // Small delay to ensure map is built if we just switched
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _fitMapToLands();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.landDataSyncSuccess),
          backgroundColor: Colors.green.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _fitMapToLands() {
    final provider = context.read<LandProvider>();
    final myLands = provider.myLands;
    final allLands = provider.allLands;

    // Prioritize fitting to My Lands, fall back to All Lands if no personal lands
    final targetLands = myLands.isNotEmpty ? myLands : allLands;
    if (targetLands.isEmpty) return;

    List<LatLng> allPoints = [];
    for (var land in targetLands) {
      if (land.boundaries != null) allPoints.addAll(land.boundaries!);
    }

    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(allPoints);
    _animatedMapMove(bounds.center, 15.0);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    try {
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
        try {
          _mapController.move(
            LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
            zoomTween.evaluate(animation),
          );
        } catch (_) {
          // Surpress map move errors if controller is detached
        }
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.dispose();
        } else if (status == AnimationStatus.dismissed) {
          controller.dispose();
        }
      });

      controller.forward();
    } catch (_) {
      // Map controller not ready
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.myLands,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          _buildViewToggle(),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.iconTheme.color,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmerRentalRequestsScreen(),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<LandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.myLands.isEmpty &&
              provider.allLands.isEmpty) {
            return _buildSkeletonLoader();
          }

          if (provider.error != null &&
              provider.myLands.isEmpty &&
              provider.allLands.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          if (provider.myLands.isEmpty && _currentMode == ViewMode.list) {
            return _buildEmptyState();
          }

          return Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _currentMode == ViewMode.list
                    ? _buildListView(provider.myLands)
                    : _buildARMapView(provider.myLands, provider.allLands),
              ),
              // Only show general indicator for list view; Map has its own premium overlay
              if (provider.isLoading && _currentMode == ViewMode.list)
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(child: _SyncingIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<SubscriptionProvider>(
        builder: (context, subProvider, _) {
          final landCount = context.watch<LandProvider>().myLands.length;
          final isAtLimit = !subProvider.isWithinLimit('land_limit', landCount);

          return FloatingActionButton(
            heroTag: 'land_management_fab',
            onPressed: isAtLimit
                ? () => _showLandLimitDialog(subProvider.planName)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FarmerAddLandScreen(),
                    ),
                  ),
            backgroundColor: isAtLimit
                ? Colors.amber.shade700
                : Colors.green[600],
            foregroundColor: Colors.white,
            elevation: 4,
            child: Icon(
              isAtLimit
                  ? Icons.lock_outline_rounded
                  : Icons.add_location_alt_outlined,
            ),
          );
        },
      ),
    );
  }

  void _showLandLimitDialog(String planName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.amber,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.landLimitReachedTitle,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.landLimitReachedDescription(planName),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/subscriptions');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewPlans,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.of(context)!.maybeLater,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
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
        itemCount: lands.length + 1, // +1 for limit bar header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SubscriptionLimitBar(
                limitKey: 'land_limit',
                currentCount: lands.length,
                label: AppLocalizations.of(context)!.landSlotsUsed,
                icon: Icons.terrain_rounded,
                accentColor: Colors.green,
                upgradePlanName: 'Farmer Pro',
              ),
            );
          }
          return _ModernLandCard(
            land: lands[index - 1],
            onDetailTap: (land) => _showLandDetails(land),
          );
        },
      ),
    );
  }

  Widget _buildARMapView(List<Land> myLands, List<Land> allLands) {
    // Separate other farmers' lands
    final myLandIds = myLands.map((l) => l.id).toSet();
    final otherLands = allLands
        .where((l) => !myLandIds.contains(l.id))
        .toList();

    // Collect all points for centering (prioritize my lands)
    List<LatLng> centerPoints = [];
    for (var land in (myLands.isNotEmpty ? myLands : allLands)) {
      if (land.boundaries != null) centerPoints.addAll(land.boundaries!);
    }

    final center = centerPoints.isNotEmpty
        ? LatLng(
            centerPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
                centerPoints.length,
            centerPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
                centerPoints.length,
          )
        : const LatLng(36.8065, 10.1815);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              // Priority 1: Check my lands
              for (var land in myLands) {
                if (land.boundaries != null &&
                    _isPointInPolygon(latLng, land.boundaries!)) {
                  _showLandDetails(land);
                  return;
                }
              }
              // Priority 2: Check other lands
              for (var land in otherLands) {
                if (land.boundaries != null &&
                    _isPointInPolygon(latLng, land.boundaries!)) {
                  _showOtherLandDetails(land);
                  return;
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            PolygonLayer(
              polygons: [
                // Render Other Lands First (so they stay in background)
                ...otherLands.where((l) => l.boundaries != null).map((land) {
                  return Polygon(
                    points: land.boundaries!,
                    color: Colors.orange.withOpacity(0.3),
                    borderColor: Colors.orange.withOpacity(0.6),
                    borderStrokeWidth: 2,
                    isFilled: true,
                    label: AppLocalizations.of(context)!.owner(land.ownerId.substring(0, 8)),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                // Render My Lands (Green)
                ...myLands.where((l) => l.boundaries != null).map((land) {
                  final isRented = land.isRented;
                  return Polygon(
                    points: land.boundaries!,
                    color: isRented
                        ? Colors.orangeAccent.withOpacity(0.4)
                        : Colors.green.withOpacity(0.4),
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
                }),
              ],
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
                      Text(
                        AppLocalizations.of(context)!.synchronizingBoundaries,
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
                      Text(
                        AppLocalizations.of(context)!.fetchingSpatialData,
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
            Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 60),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.syncInterrupted,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.tryToResync),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
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
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.1,
                    ),
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
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${land.id.substring(0, 8)}...',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusTag(land.isActive, isRented: land.isRented),
                ],
              ),
              const SizedBox(height: 32),
              _buildDetailGrid(land),
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)!.description,
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                land.description ?? AppLocalizations.of(context)!.noDescriptionProvided,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              _buildActionButtons(land),
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
          label: AppLocalizations.of(context)!.area,
          value: '${land.gridWidth}x${land.gridHeight}',
          icon: Icons.grid_4x4,
        ),
        _DetailItem(
          label: AppLocalizations.of(context)!.rentals,
          value: '2 Active',
          icon: Icons.people,
        ),
        _DetailItem(
          label: AppLocalizations.of(context)!.earnings,
          value: '2,400 TND',
          icon: Icons.wallet,
        ),
        _DetailItem(
          label: AppLocalizations.of(context)!.safety,
          value: 'Verified',
          icon: Icons.verified_user,
        ),
      ],
    );
  }

  Widget _buildActionButtons(Land land) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkforceScreen(
                    landId: land.id,
                    landName: land.name,
                    canHire: !land.isRented,
                  ),
                ),
              );
            },
            icon: Icon(Icons.people_alt_outlined),
            label: Text(
              AppLocalizations.of(context)!.workforce,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => EditLandSheet(land: land),
                  );
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                padding: const EdgeInsets.all(16),
                tooltip: AppLocalizations.of(context)!.editLandDetails,
              ),
              Container(
                height: 24,
                width: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(land),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                padding: const EdgeInsets.all(16),
                tooltip: AppLocalizations.of(context)!.deleteLand,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Land land) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2125),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.deleteLandTitle,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.deleteLandConfirmation(land.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.deleteLandActionWarning,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<LandProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.deleteLand(land.id);
                        if (success && mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close details sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.landDeletedSuccess),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.redAccent,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.delete,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2125),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
            SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.comingSoon,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.featureOptimizedDescription(feature),
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Stay tuned for advanced spatial asset tracking!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.gotIt,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(bool isActive, {bool isRented = false}) {
    final status = !isActive
        ? AppLocalizations.of(context)!.inactive
        : isRented
            ? AppLocalizations.of(context)!.rented
            : AppLocalizations.of(context)!.live;

    Color color;
    if (!isActive) {
      color = Colors.red;
    } else if (isRented) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        height: 280,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
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
                          SizedBox(height: 8),
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
                  SizedBox(height: 24),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.03,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.05),
                      ),
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.failedToSyncBackend,
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape_rounded,
            size: 100,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noLandsFound,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.startByListingPlot,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showOtherLandDetails(Land land) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: FutureBuilder<User?>(
          future: AuthService.getUserById(land.ownerId),
          builder: (context, snapshot) {
            String ownerName = 'Loading...';
            bool isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              if (user.name != null && user.name!.isNotEmpty) {
                ownerName = user.name!;
              } else {
                ownerName = user.email.split('@')[0];
                // Capitalize first letter
                if (ownerName.isNotEmpty) {
                  ownerName =
                      ownerName[0].toUpperCase() + ownerName.substring(1);
                }
              }
            } else if (snapshot.hasError ||
                (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == null)) {
              ownerName = 'Unknown Farmer';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.externalProperty,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            land.name,
                            style: TextStyle(
                              color: theme.textTheme.titleLarge?.color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.notYours,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.05,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange,
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.ownerLabel,
                              style: TextStyle(
                                color: (isDark
                                    ? Colors.white54
                                    : Colors.black54),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              ownerName,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.dismiss,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white54 : Colors.black54),
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
    // Calculate center for mini-map
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

    final isRented = land.isRented;
    final rentalCount = land.rentals
        .where(
          (r) =>
              r.paymentStatus != PaymentStatus.cancelled &&
              (r.rentalEndDate == null ||
                  r.rentalEndDate!.isAfter(DateTime.now())),
        )
        .length;

    return GestureDetector(
      onTap: () => onDetailTap(land),
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
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Map Preview Section
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  // Background placeholder for loading/error resilience
                  Container(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.05,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map_rounded,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.1),
                        size: 40,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 16.5,
                        // Fix for "Access blocked" error by compliant User-Agent
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.farmy.app',
                          subdomains: const ['a', 'b', 'c'],
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
                                color: isRented
                                    ? Colors.orangeAccent.withOpacity(0.5)
                                    : Colors.green.withOpacity(0.4),
                                borderColor: isRented
                                    ? Colors.orangeAccent
                                    : Colors.green,
                                borderStrokeWidth: 2,
                                isFilled: true,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Glass Overlay for Name & Status
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 8, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          _buildStatusBadge(land.isActive, isRented: isRented),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
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
                        '${land.gridWidth}x${land.gridHeight}',
                        Icons.grid_3x3_rounded,
                      ),
                      _buildInfoItem(
                        context,
                        'Rentals',
                        '$rentalCount Active',
                        Icons.people_alt_rounded,
                        isHighlight: rentalCount > 0,
                      ),
                      _buildInfoItem(
                        context,
                        'Earnings',
                        '0 TND',
                        Icons.monetization_on_rounded,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onDetailTap(land),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isRented
                                  ? Colors.orangeAccent.withOpacity(0.5)
                                  : Colors.green.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              color: isRented
                                  ? Colors.orangeAccent
                                  : Colors.green,
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

  Widget _buildStatusBadge(bool isActive, {bool isRented = false}) {
    Color color;
    String text;

    if (!isActive) {
      color = Colors.red;
      text = 'INACTIVE';
    } else if (isRented) {
      color = Colors.orangeAccent;
      text = 'RENTED';
    } else {
      color = Colors.green;
      text = 'LIVE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
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
    IconData icon, {
    bool isHighlight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isHighlight
        ? Colors.orangeAccent
        : Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isHighlight
                  ? Colors.orangeAccent
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncingIndicator extends StatelessWidget {
  const _SyncingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Syncing Data...',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
