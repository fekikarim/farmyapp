import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/land_model.dart';
import '../../models/land_worker_model.dart';
import '../../models/worker_contract_model.dart';
import '../../models/worker_invitation_model.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../providers/worker_provider.dart';
import '../../services/land_service.dart';
import '../../widgets/profile_preview_sheet.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class WorkerLandDetailsScreen extends StatefulWidget {
  final LandWorker assignment;

  const WorkerLandDetailsScreen({super.key, required this.assignment});

  @override
  State<WorkerLandDetailsScreen> createState() =>
      _WorkerLandDetailsScreenState();
}

class _WorkerLandDetailsScreenState extends State<WorkerLandDetailsScreen> {
  Land? _land;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updated = await LandService.getLandById(widget.assignment.landId);
      if (!mounted) return;
      setState(() {
        _land = updated;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final errorText = e.toString();
        if (errorText.contains('SocketException') ||
            errorText.contains('Failed host lookup')) {
          _error = AppLocalizations.of(context)!.noInternetConnection;
        } else {
          _error = errorText
              .replaceAll('Exception: ', '')
              .replaceAll('HttpException: ', '');
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    final workerProvider = context.read<WorkerProvider>();
    final lifecycle = context.read<WorkerLifecycleProvider>();

    await Future.wait([
      _fetchDetails(),
      workerProvider.loadAssignedLands(),
      lifecycle.loadMyInvitations(),
      lifecycle.loadMyContracts(),
    ]);
  }

  Future<void> _openFarmerProfile(String? farmerUserId) async {
    if (farmerUserId == null || farmerUserId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.farmerProfileUnavailable),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    try {
      await ProfilePreviewSheet.show(context, farmerUserId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unableToOpenFarmerProfile),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading && _land == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.landDetails, style: const TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.green.shade600,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loading,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null && _land == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.landDetails),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 44, color: Colors.red.shade400),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.red.shade200 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _refreshAll,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final land = _land;
    final lifecycle = context.watch<WorkerLifecycleProvider>();
    final contract = _findContractForLand(
      lifecycle.myContracts,
      widget.assignment.landId,
    );
    final invitation = _findInvitationForLand(
      lifecycle.myInvitations,
      widget.assignment.landId,
    );

    final farmerName =
        land?.ownerName ??
        contract?.investorName ??
        invitation?.farmerName ??
        widget.assignment.assignerName ??
        AppLocalizations.of(context)!.farmer;
    final farmerEmail =
        land?.ownerEmail ?? contract?.investorEmail ?? invitation?.farmerEmail;
    final farmerPicture = land?.ownerProfilePicture;
    final farmerUserId = land?.ownerId.isNotEmpty == true
        ? land!.ownerId
        : (contract?.investorId.isNotEmpty == true
              ? contract!.investorId
              : (invitation?.farmerId.isNotEmpty == true
                    ? invitation!.farmerId
                    : (widget.assignment.landOwnerId?.isNotEmpty == true
                          ? widget.assignment.landOwnerId!
                          : (widget.assignment.assignedBy.isNotEmpty
                                ? widget.assignment.assignedBy
                                : null))));
    final relationStatus =
        contract?.statusLabel ??
        (invitation != null
            ? (invitation.isApproved
                  ? AppLocalizations.of(context)!.invitationApproved
                  : invitation.isPending
                  ? AppLocalizations.of(context)!.invitationPending
                  : invitation.isDeclined
                  ? AppLocalizations.of(context)!.invitationDeclined
                  : AppLocalizations.of(context)!.invitationExpired)
            : AppLocalizations.of(context)!.assigned);

    final boundaries = land?.boundaries;
    final center = _resolveCenter(boundaries);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          land?.name ?? widget.assignment.landName ?? AppLocalizations.of(context)!.landDetails,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green.shade600,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.orange.withOpacity(0.12)
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.orange.shade200
                              : Colors.orange.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: _refreshAll,
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              ),

            _buildFarmerCard(
              isDark: isDark,
              farmerName: farmerName,
              farmerEmail: farmerEmail,
              farmerPicture: farmerPicture,
              farmerUserId: farmerUserId,
              relationStatus: relationStatus,
            ),
            const SizedBox(height: 16),

            _buildStatusStatsCard(isDark, relationStatus),
            const SizedBox(height: 16),

            _buildMapSection(
              isDark: isDark,
              center: center,
              boundaries: boundaries,
            ),
            const SizedBox(height: 16),

            _buildDetailsSection(
              isDark: isDark,
              land: land,
              assignment: widget.assignment,
            ),
          ],
        ),
      ),
    );
  }

  WorkerContract? _findContractForLand(
    List<WorkerContract> contracts,
    String landId,
  ) {
    for (final contract in contracts) {
      if (contract.landId == landId) return contract;
    }
    return null;
  }

  WorkerInvitation? _findInvitationForLand(
    List<WorkerInvitation> invitations,
    String landId,
  ) {
    for (final invitation in invitations) {
      if (invitation.landId == landId) return invitation;
    }
    return null;
  }

  LatLng _resolveCenter(List<LatLng>? boundaries) {
    if (boundaries == null || boundaries.isEmpty) {
      return const LatLng(36.8065, 10.1815);
    }

    double totalLat = 0;
    double totalLng = 0;
    for (final point in boundaries) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }
    return LatLng(totalLat / boundaries.length, totalLng / boundaries.length);
  }

  Widget _buildFarmerCard({
    required bool isDark,
    required String farmerName,
    required String? farmerEmail,
    required String? farmerPicture,
    required String? farmerUserId,
    required String relationStatus,
  }) {
    final theme = Theme.of(context);
    final statusColor = Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openFarmerProfile(farmerUserId),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            backgroundImage: farmerPicture != null
                                ? NetworkImage(farmerPicture)
                                : null,
                            child: farmerPicture == null
                                ? Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 28)
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.farmerInfoSyncedFromAssignment,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.tapToViewProfile,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _translateContractStatus(context, relationStatus).toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStatsCard(bool isDark, String relationStatus) {
    final theme = Theme.of(context);
    final role = widget.assignment.role;
    final salary = widget.assignment.salary;
    final status = widget.assignment.status;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _chip(Icons.work_rounded, _translateRole(context, role).toUpperCase(), isDark, theme.colorScheme.primary),
                _chip(
                  Icons.payments_rounded,
                  AppLocalizations.of(context)!.amountPerMonth(salary.toStringAsFixed(0)),
                  isDark,
                  Colors.green,
                ),
                _chip(Icons.bolt_rounded, _translateAssignmentStatus(context, status).toUpperCase(), isDark, Colors.orange),
                _chip(Icons.link_rounded, _translateContractStatus(context, relationStatus).toUpperCase(), isDark, Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, bool isDark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDark ? accentColor.withValues(alpha: 0.9) : accentColor.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection({
    required bool isDark,
    required LatLng center,
    required List<LatLng>? boundaries,
  }) {
    final theme = Theme.of(context);
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: boundaries == null || boundaries.isEmpty ? 12 : 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.farmy.app',
                tileBuilder: isDark ? (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1.0, 0.0, 0.0, 0.0, 255.0,
                      0.0, -1.0, 0.0, 0.0, 255.0,
                      0.0, 0.0, -1.0, 0.0, 255.0,
                      0.0, 0.0, 0.0, 1.0, 0.0,
                    ]),
                    child: tileWidget,
                  );
                } : null,
              ),
              if (boundaries != null && boundaries.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: boundaries,
                      color: Colors.green.withValues(alpha: 0.3),
                      borderColor: Colors.green.shade600,
                      borderStrokeWidth: 4,
                      isFilled: true,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded, color: Colors.green.shade400, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.landBoundary.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection({
    required bool isDark,
    required Land? land,
    required LandWorker assignment,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.landInformation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailRow(AppLocalizations.of(context)!.name, land?.name ?? assignment.landName ?? '-', theme),
                _detailRow(
                  AppLocalizations.of(context)!.description,
                  land?.description ?? AppLocalizations.of(context)!.noDescriptionAvailable,
                  theme,
                ),
                _detailRow(
                  AppLocalizations.of(context)!.grid,
                  land != null ? '${land.gridWidth} x ${land.gridHeight}' : '-',
                  theme,
                ),
                _detailRow(
                  AppLocalizations.of(context)!.area,
                  land != null
                      ? AppLocalizations.of(context)!.squareMeters((land.gridWidth * land.gridHeight).toInt())
                      : '-',
                  theme,
                ),
                _detailRow(AppLocalizations.of(context)!.assignmentRole, _translateRole(context, assignment.role), theme),
                _detailRow(
                  AppLocalizations.of(context)!.salary,
                  AppLocalizations.of(context)!.salaryPerMonth(assignment.salary.toStringAsFixed(0)),
                  theme,
                ),
                _detailRow(AppLocalizations.of(context)!.assignmentStatus, _translateAssignmentStatus(context, assignment.status), theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _translateRole(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role.toLowerCase()) {
      case 'worker': return l10n.worker;
      case 'supervisor': return l10n.supervisor;
      case 'manager': return l10n.manager;
      default: return role;
    }
  }

  String _translateAssignmentStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'active': return l10n.activeLabel;
      case 'pending': return l10n.pendingLabel;
      case 'inactive': return l10n.inactiveLabel;
      default: return status;
    }
  }

  String _translateContractStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'active': return l10n.activeLabel;
      case 'suspended': return l10n.suspendedLabel;
      case 'terminated': return l10n.terminatedLabel;
      case 'hiring_pending': return l10n.hiringPending;
      case 'negotiation_pending': return l10n.negotiating;
      case 'payment_pending': return l10n.awaitingPayment;
      case 'invitation approved': return l10n.invitationApproved;
      case 'invitation pending': return l10n.invitationPending;
      case 'invitation declined': return l10n.invitationDeclined;
      case 'invitation expired': return l10n.invitationExpired;
      default: return status;
    }
  }
}
