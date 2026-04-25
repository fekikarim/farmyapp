import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/land_model.dart';
import '../../models/land_rental_model.dart';
import '../../services/land_service.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/land_provider.dart';
import '../../widgets/subscription_limit_bar.dart';
import '../farmer/workforce_screen.dart';
import '../investment_agent_screen.dart';
import 'rental_checkout_screen.dart';
import 'dart:ui';
import 'package:farmyapp/l10n/app_localizations.dart';

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
  int _activeRentalCount = 0;

  @override
  void initState() {
    super.initState();
    _land = widget.land;
    _fetchDetails();
    _loadRentalCount();
  }

  void _loadRentalCount() {
    final landProvider = context.read<LandProvider>();
    final activeRentals = landProvider.myRentals.where(
      (r) =>
          r.paymentStatus != PaymentStatus.cancelled &&
          (r.rentalEndDate == null || r.rentalEndDate!.isAfter(DateTime.now())),
    );
    _activeRentalCount = activeRentals.length;
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
          if (e.toString().contains('SocketException') ||
              e.toString().contains('Failed host lookup')) {
            _error = AppLocalizations.of(context)!.noInternetConnection;
          } else {
            _error = e
                .toString()
                .replaceAll('Exception: ', '')
                .replaceAll('HttpException: ', '');
          }
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.auto_awesome, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvestmentAgentScreen(
                        initialMessage: AppLocalizations.of(context)!.aiLandInvestmentHint(_land.name),
                        initialContext: {
                          'targetLand': _land.toJson(),
                        },
                      ),
                    ),
                  );
                },
                tooltip: AppLocalizations.of(context)!.askAiAnalyst,
              ),
            ),
          ],
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
                        _land.isRented ? AppLocalizations.of(context)!.alreadyRentedUpper : AppLocalizations.of(context)!.premiumFarmlandUpper,
                        style: TextStyle(
                          color: _land.isRented ? Colors.orange : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.idLabel(_land.id.substring(0, 8).toUpperCase()),
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
                        AppLocalizations.of(context)!.squareMeters((_land.gridWidth * _land.gridHeight * 1).toInt()),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.grid_on_rounded,
                        AppLocalizations.of(context)!.gridPlots(_land.gridWidth, _land.gridHeight),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.water_drop_rounded, AppLocalizations.of(context)!.irrigated),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(AppLocalizations.of(context)!.description, theme),
                const SizedBox(height: 12),
                Text(
                  _land.description ?? AppLocalizations.of(context)!.noDescriptionAvailable,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(AppLocalizations.of(context)!.locationHighlights, theme),
                const SizedBox(height: 24),
                _buildLocationItem(
                  Icons.wb_sunny_rounded,
                  AppLocalizations.of(context)!.optimalSolarExposure,
                  theme,
                ),
                _buildLocationItem(
                  Icons.local_shipping_rounded,
                  AppLocalizations.of(context)!.directRoadAccess,
                  theme,
                ),
                _buildLocationItem(
                  Icons.opacity_rounded,
                  AppLocalizations.of(context)!.securedWaterAccess,
                  theme,
                ),
                const SizedBox(height: 40),
                // Workforce Management (only for rented lands where investor has authority)
                if (_land.isRented) ...[
                  _buildSectionHeader(AppLocalizations.of(context)!.workforce, theme),
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
                              canHire: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.people_alt_outlined,
                        color: Colors.white,
                      ),
                      label: Text(AppLocalizations.of(context)!.manageWorkers),
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
                // Subscription Limit Bar for Investor
                if (!_land.isRented)
                  SubscriptionLimitBar(
                    limitKey: 'rental_limit',
                    currentCount: _activeRentalCount,
                    label: AppLocalizations.of(context)!.rentalSlotsUsed,
                    icon: Icons.real_estate_agent_rounded,
                    accentColor: Colors.blue,
                    upgradePlanName: AppLocalizations.of(context)!.investorPlus,
                  ),
                const SizedBox(height: 240), // Spacer for bottom sheet
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
    final subProvider = context.watch<SubscriptionProvider>();
    final isAtRentalLimit = !subProvider.isWithinLimit(
      'rental_limit',
      _activeRentalCount,
    );
    final isDisabled = _land.isRented || isAtRentalLimit;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upgrade banner when at rental limit
          if (isAtRentalLimit && !_land.isRented) ...[
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/subscriptions'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.15),
                      Colors.orange.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 20,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.rentalLimitReached,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.unlockUnlimitedSlotsInvestorPlus,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark ? Colors.amber : Colors.amber.shade900,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pricePerMonth,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.amountTND(NumberFormat('#,###').format(_land.price)),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: isDisabled
                      ? null
                      : BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                  child: ElevatedButton(
                    onPressed: isDisabled
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
                          : (isAtRentalLimit
                                ? theme.disabledColor.withOpacity(0.1)
                                : theme.primaryColor),
                      foregroundColor: _land.isRented
                          ? Colors.orange
                          : (isAtRentalLimit
                                ? theme.disabledColor
                                : Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      side: _land.isRented
                          ? const BorderSide(color: Colors.orange, width: 2)
                          : (isAtRentalLimit
                                ? BorderSide(
                                    color: theme.disabledColor.withOpacity(0.2),
                                  )
                                : null),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _land.isRented
                          ? AppLocalizations.of(context)!.occupiedUpper
                          : (isAtRentalLimit ? AppLocalizations.of(context)!.limitReachedUpper : AppLocalizations.of(context)!.rentNowUpper),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons
                    .wifi_off_rounded, // Better visual representation of sync failures
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.connectionError,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ??
                  AppLocalizations.of(context)!.unableToRetrieveLandDetails,
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
                onPressed: _fetchDetails,
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
                label: Text(
                  AppLocalizations.of(context)!.tryAgainUpper,
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
