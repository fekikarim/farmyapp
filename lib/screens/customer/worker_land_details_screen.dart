import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
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
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.landDetails),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
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
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(land?.name ?? widget.assignment.landName ?? AppLocalizations.of(context)!.landDetails),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            const SizedBox(height: 14),

            _buildStatusStatsCard(isDark, relationStatus),
            const SizedBox(height: 14),

            _buildMapSection(
              isDark: isDark,
              center: center,
              boundaries: boundaries,
            ),
            const SizedBox(height: 14),

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openFarmerProfile(farmerUserId),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.green.withOpacity(0.14),
                backgroundImage: farmerPicture != null
                    ? NetworkImage(farmerPicture)
                    : null,
                child: farmerPicture == null
                    ? Icon(Icons.person, color: Colors.green.shade700)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                          AppLocalizations.of(context)!.farmerInfoSyncedFromAssignment,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.tapToViewProfile,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.green.shade300
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _translateContractStatus(context, relationStatus),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.blue.shade300
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStatsCard(bool isDark, String relationStatus) {
    final role = widget.assignment.role;
    final salary = widget.assignment.salary;
    final status = widget.assignment.status;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _chip(Icons.work_outline, _translateRole(context, role).toUpperCase(), isDark),
          _chip(
            Icons.payments_outlined,
            AppLocalizations.of(context)!.amountPerMonth(salary.toStringAsFixed(0)),
            isDark,
          ),
          _chip(Icons.bolt_outlined, _translateAssignmentStatus(context, status).toUpperCase(), isDark),
          _chip(Icons.link, _translateContractStatus(context, relationStatus).toUpperCase(), isDark),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
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
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.farmy.app',
              ),
              if (boundaries != null && boundaries.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: boundaries,
                      color: Colors.green.withOpacity(0.2),
                      borderColor: Colors.green.shade700,
                      borderStrokeWidth: 3,
                      isFilled: true,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.landBoundary,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.landInformation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow(AppLocalizations.of(context)!.name, land?.name ?? assignment.landName ?? '-'),
          _detailRow(
            AppLocalizations.of(context)!.description,
            land?.description ?? AppLocalizations.of(context)!.noDescriptionAvailable,
          ),
          _detailRow(
            AppLocalizations.of(context)!.grid,
            land != null ? '${land.gridWidth} x ${land.gridHeight}' : '-',
          ),
          _detailRow(
            AppLocalizations.of(context)!.area,
            land != null
                ? AppLocalizations.of(context)!.squareMeters((land.gridWidth * land.gridHeight).toInt())
                : '-',
          ),
          _detailRow(AppLocalizations.of(context)!.assignmentRole, _translateRole(context, assignment.role)),
          _detailRow(
            AppLocalizations.of(context)!.salary,
            AppLocalizations.of(context)!.salaryPerMonth(assignment.salary.toStringAsFixed(0)),
          ),
          _detailRow(AppLocalizations.of(context)!.assignmentStatus, _translateAssignmentStatus(context, assignment.status)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
