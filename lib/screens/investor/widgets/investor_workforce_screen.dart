import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/worker_lifecycle_provider.dart';
import '../../../services/proof_service.dart';
import '../../../services/auth_service.dart';
import '../../../../widgets/profile_preview_sheet.dart';

import '../../../models/worker_contract_model.dart';
import '../../../models/worker_profile_model.dart';
import '../../../models/proof_request_model.dart';
import '../../../models/placed_item_model.dart';
import '../../../services/land_service.dart';
import '../../shared/contract_negotiation_screen.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class InvestorWorkforceScreen extends StatefulWidget {
  final String landId;
  final String landName;

  const InvestorWorkforceScreen({
    super.key,
    required this.landId,
    required this.landName,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  State<InvestorWorkforceScreen> createState() =>
      _InvestorWorkforceScreenState();
}

class _InvestorWorkforceScreenState extends State<InvestorWorkforceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _loadAllData() {
    final lifecycle = context.read<WorkerLifecycleProvider>();
    lifecycle.loadApprovedWorkers(widget.landId);
    lifecycle.loadNegotiatingContracts(widget.landId);
    lifecycle.loadActiveContracts(widget.landId);
    lifecycle.loadLandProofs(widget.landId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifecycle = context.watch<WorkerLifecycleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.workforceUpper,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: Colors.greenAccent,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.landName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TabBar
                Container(
                  height: 45,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 3.0,
                        color: Colors.greenAccent.withOpacity(0.8),
                      ),
                      insets: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    labelColor: Colors.greenAccent,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.approvedUpper),
                            if (lifecycle.approvedWorkers.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _buildTabBadge(lifecycle.approvedWorkers.length),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.negotiationsUpper),
                            if (lifecycle.negotiatingContracts.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _buildTabBadge(
                                lifecycle.negotiatingContracts.length,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.activeUpper),
                            if (lifecycle.activeContracts.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _buildTabBadge(lifecycle.activeContracts.length),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.proofsUpper),
                            if (lifecycle.pendingLandProofs.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _buildTabBadge(
                                lifecycle.pendingLandProofs.length,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ApprovedWorkersTab(
                        landId: widget.landId,
                        isDark: true, // Always dark theme
                        workers: lifecycle.approvedWorkers,
                        isLoading: lifecycle.approvedWorkersLoading,
                        error: lifecycle.approvedWorkersError,
                        onHire: _showHireDialog,
                        onRefresh: () =>
                            lifecycle.loadApprovedWorkers(widget.landId),
                      ),
                      _NegotiationsTab(
                        landId: widget.landId,
                        isDark: true, // Always dark theme
                        contracts: lifecycle.negotiatingContracts,
                        isLoading: lifecycle.negotiatingContractsLoading,
                        error: lifecycle.negotiatingContractsError,
                        onRefresh: _loadAllData,
                      ),
                      _ActiveWorkersTab(
                        landId: widget.landId,
                        isDark: true, // Always dark theme
                        contracts: lifecycle.activeContracts,
                        isLoading: lifecycle.activeContractsLoading,
                        error: lifecycle.activeContractsError,
                        onRefresh: () =>
                            lifecycle.loadActiveContracts(widget.landId),
                      ),
                      _ProofsTab(
                        landId: widget.landId,
                        isDark: true, // Always dark theme
                        proofs: lifecycle.landProofs,
                        isLoading: lifecycle.landProofsLoading,
                        onRefresh: () =>
                            lifecycle.loadLandProofs(widget.landId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  void _showHireDialog(WorkerProfile worker) {
    final salaryController = TextEditingController();
    final messageController = TextEditingController();
    String salaryType = 'monthly';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 90));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B), // Slate-800
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: Text(
            AppLocalizations.of(context)!.hireWorkerUpper((worker.userName ?? AppLocalizations.of(context)!.worker).toUpperCase()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salary Amount
                Text(
                  AppLocalizations.of(context)!.salaryAmountTNDUpper,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(AppLocalizations.of(context)!.egSalaryHint),
                ),
                const SizedBox(height: 16),

                // Salary Type
                Text(
                  AppLocalizations.of(context)!.salaryTypeUpper,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['monthly', 'hourly', 'per_task'].map((type) {
                    final selected = salaryType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => salaryType = type),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.greenAccent.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                                type == 'per_task'
                                  ? AppLocalizations.of(context)!.perTaskUpper
                                  : (type == 'monthly' ? AppLocalizations.of(context)!.monthlyUpper : AppLocalizations.of(context)!.hourlyUpper),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: selected
                                    ? Colors.greenAccent
                                    : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.startDateUpper,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: ctx,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.greenAccent,
                                        onPrimary: Colors.black,
                                        surface: Color(0xFF1E293B),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setDialogState(() => startDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                DateFormat.yMd(Localizations.localeOf(context).toString()).format(startDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.endDateUpper,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: ctx,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 730),
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.greenAccent,
                                        onPrimary: Colors.black,
                                        surface: Color(0xFF1E293B),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setDialogState(() => endDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                DateFormat.yMd(Localizations.localeOf(context).toString()).format(endDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  AppLocalizations.of(context)!.messageOptionalUpper,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: messageController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(AppLocalizations.of(context)!.optionalMessageHint),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.of(context)!.cancelUpper,
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final salary = double.tryParse(salaryController.text);
                if (salary == null || salary <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.pleaseEnterValidSalary),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final lifecycle = context.read<WorkerLifecycleProvider>();
                final error = await lifecycle.hireWorker(
                  landId: widget.landId,
                  workerId: worker.userId,
                  salaryAmount: salary,
                  salaryType: salaryType,
                  contractStartDate: startDate
                      .toIso8601String()
                      .split('T')
                      .first,
                  contractEndDate: endDate.toIso8601String().split('T').first,
                  message: messageController.text.isNotEmpty
                      ? messageController.text
                      : null,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error == null ? AppLocalizations.of(context)!.hiringProposalSent : error,
                      ),
                      backgroundColor: error == null
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  if (error == null) {
                    _tabController.animateTo(1); // Switch to Negotiations
                    _loadAllData();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.sendProposalUpper,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// ── Approved Workers Tab ──
class _ApprovedWorkersTab extends StatelessWidget {
  final String landId;
  final bool isDark;
  final List<WorkerProfile> workers;
  final bool isLoading;
  final String? error;
  final void Function(WorkerProfile) onHire;
  final VoidCallback onRefresh;

  const _ApprovedWorkersTab({
    required this.landId,
    required this.isDark,
    required this.workers,
    required this.isLoading,
    this.error,
    required this.onHire,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmerList(true); // Always dark

    if (error != null) {
      return _errorView(context: context, isDark: true, message: error!, onRetry: onRefresh);
    }

    if (workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noApprovedWorkersUpper,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.inviteWorkersMarketplaceHint,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.greenAccent,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: workers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final w = workers[index];
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E293B), // Slate-800
                  Color(0xFF0F172A), // Slate-900
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => ProfilePreviewSheet.show(context, w.userId),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          backgroundImage: w.userProfilePicture != null
                              ? NetworkImage(w.userProfilePicture!)
                              : null,
                          child: w.userProfilePicture == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white54,
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (w.userName ?? AppLocalizations.of(context)!.worker).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (w.skills.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                w.skills.isEmpty 
                                  ? AppLocalizations.of(context)!.noSpecialSkillsUpper
                                  : _translateSkill(context, w.skills.first).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            Text(
                              AppLocalizations.of(context)!.noSpecialSkillsUpper,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white38,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => onHire(w),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(70, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.hireUpper,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Negotiations Tab ──
class _NegotiationsTab extends StatelessWidget {
  final String landId;
  final bool isDark;
  final List<WorkerContract> contracts;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const _NegotiationsTab({
    required this.landId,
    required this.isDark,
    required this.contracts,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmerList(true); // Always dark

    if (error != null) {
      return _errorView(context: context, isDark: true, message: error!, onRetry: onRefresh);
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.handshake_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noActiveNegotiationsUpper,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.hireApprovedWorkerNegotiationHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.greenAccent,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: contracts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final c = contracts[index];
          return _NegotiationCard(
            contract: c,
            isDark: true,
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ContractNegotiationScreen(contract: c),
                ),
              );
              if (result == true) {
                onRefresh();
              }
            },
          );
        },
      ),
    );
  }
}

class _NegotiationCard extends StatelessWidget {
  final WorkerContract contract;
  final bool isDark;
  final VoidCallback onTap;

  const _NegotiationCard({
    required this.contract,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    switch (contract.status) {
      case 'hiring_pending':
        statusColor = Colors.blueAccent;
        statusText = AppLocalizations.of(context)!.proposedUpper;
        break;
      case 'negotiation_pending':
        statusColor = Colors.orangeAccent;
        statusText = AppLocalizations.of(context)!.negotiatingUpper;
        break;
      case 'negotiation_countered':
        statusColor = Colors.deepOrangeAccent;
        statusText = AppLocalizations.of(context)!.counterOfferUpper;
        break;
      case 'payment_pending':
        statusColor = Colors.purpleAccent;
        statusText = AppLocalizations.of(context)!.payNowUpper;
        break;
      default:
        statusColor = Colors.white54;
        statusText = _translateContractStatus(context, contract.status).toUpperCase();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Slate-800
            Color(0xFF0F172A), // Slate-900
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          ProfilePreviewSheet.show(context, contract.workerId),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: statusColor.withOpacity(0.15),
                          child: Icon(
                            Icons.person,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (contract.workerName ?? AppLocalizations.of(context)!.worker).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.salaryAmountType(contract.salaryAmount.toInt(), _translateSalaryTypeLabel(context, contract.salaryTypeLabel)),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                                letterSpacing: 0.5,
                              ),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (contract.needsInvestorAction) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amberAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.amberAccent.shade100,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            contract.status == 'payment_pending'
                                ? AppLocalizations.of(context)!.paymentRequiredToActivate
                                : AppLocalizations.of(context)!.workerRespondedReviewCounterOffer,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.amberAccent.shade100,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Active Workers Tab ──
class _ActiveWorkersTab extends StatelessWidget {
  final String landId;
  final bool isDark;
  final List<WorkerContract> contracts;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const _ActiveWorkersTab({
    required this.landId,
    required this.isDark,
    required this.contracts,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmerList(true); // Always dark

    if (error != null) {
      return _errorView(context: context, isDark: true, message: error!, onRetry: onRefresh);
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.engineering_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noActiveWorkersUpper,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.hireActivateWorkersHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.greenAccent,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: contracts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final c = contracts[index];
          final isSuspended = c.isSuspended;
          final badgeColor = isSuspended
              ? Colors.orangeAccent
              : Colors.greenAccent;
          final badgeText = isSuspended ? AppLocalizations.of(context)!.suspendedUpper : AppLocalizations.of(context)!.activeUpper;
          final dotColor = isSuspended
              ? Colors.orangeAccent
              : Colors.greenAccent;

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E293B), // Slate-800
                  Color(0xFF0F172A), // Slate-900
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badgeColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          ProfilePreviewSheet.show(context, c.workerId),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: badgeColor.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: badgeColor.withOpacity(0.15),
                              child: Icon(
                                Icons.person,
                                color: badgeColor,
                                size: 20,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1E293B),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (c.workerName ?? AppLocalizations.of(context)!.worker).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.salaryAmountType(c.salaryAmount.toInt(), _translateSalaryTypeLabel(context, c.salaryTypeLabel)),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                                letterSpacing: 0.5,
                              ),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: badgeColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context)!.untilDateUpper(DateFormat.MMMd(Localizations.localeOf(context).toString()).format(c.contractEndDate).toUpperCase()),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    _RequestProofButton(
                      contract: c,
                      isDark: true,
                      landId: landId,
                    ),
                    const SizedBox(width: 8),
                    _RemoveWorkerButton(
                      contract: c,
                      isDark: true,
                      landId: landId,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Request Proof Button ──
class _RequestProofButton extends StatefulWidget {
  final WorkerContract contract;
  final bool isDark;
  final String landId;

  const _RequestProofButton({
    required this.contract,
    required this.isDark,
    required this.landId,
  });

  @override
  State<_RequestProofButton> createState() => _RequestProofButtonState();
}

class _RequestProofButtonState extends State<_RequestProofButton> {
  bool _requesting = false;

  Future<void> _handleRequest() async {
    setState(() => _requesting = true);
    final items = await LandService.getPlacedItems(widget.landId);
    if (!mounted) return;
    setState(() => _requesting = false);

    String targetType = 'land';
    String? targetId;
    String targetLabel = 'Current Land';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: widget.isDark
              ? const Color(0xFF2A2D30)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context)!.requestProof,
            style: TextStyle(
              color: widget.isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.proofRequestQuestion,
                style: TextStyle(
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    AppLocalizations.of(context)!.entireLand,
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.generalFarmingActivity,
                    style: TextStyle(fontSize: 11),
                  ),
                  value: 'land',
                  groupValue: targetType,
                  onChanged: (val) => setDialogState(() {
                    targetType = val!;
                    targetId = null;
                    targetLabel = AppLocalizations.of(context)!.currentLand;
                  }),
                ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.orSelectAnItem,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return RadioListTile<String>(
                        title: Text(
                          item.displayName,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: item.id,
                        groupValue: targetId,
                        onChanged: (val) => setDialogState(() {
                          targetType = 'item';
                          targetId = val;
                          targetLabel = item.displayName;
                        }),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.proofSubmissionHint(targetLabel),
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: widget.isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'targetType': targetType,
                'targetId': targetId,
                'targetLabel': targetLabel,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.request,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _requesting = true);
    final errorMsg = await ProofService.requestProof(
      widget.contract.workerId,
      widget.landId,
      targetType: result['targetType'],
      targetId: result['targetId'],
    );

    if (mounted) {
      setState(() => _requesting = false);
      if (errorMsg == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.proofRequestedHint,
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_requesting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      onPressed: _handleRequest,
      icon: Icon(
        Icons.camera_alt_outlined,
        size: 20,
        color: Colors.blue.shade400,
      ),
      tooltip: AppLocalizations.of(context)!.requestAIProof,
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

// ── Proofs Tab ──
class _ProofsTab extends StatelessWidget {
  final String landId;
  final bool isDark;
  final List<ProofRequest> proofs;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _ProofsTab({
    required this.landId,
    required this.isDark,
    required this.proofs,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmerList(true); // Always dark

    if (proofs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_enhance_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noProofsRequestedUpper,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.requestProofHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.greenAccent,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: proofs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final p = proofs[index];
          final color = _getStatusColor(p.status);

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E293B), // Slate-800
                  Color(0xFF0F172A), // Slate-900
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          ProfilePreviewSheet.show(context, p.farmerId),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(
                            _getStatusIcon(p.status),
                            color: color,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (p.targetName ?? p.landName ?? 'General Land Proof')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.requestedDateUpper(DateFormat.MMMd(Localizations.localeOf(context).toString()).add_Hm().format(p.createdAt ?? DateTime.now()).toUpperCase()),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.white54,
                            ),
                          ),
                          if (p.targetType == 'item')
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                AppLocalizations.of(context)!.itemIdUpper(p.targetId?.substring(0, 8) ?? ''),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          if (p.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    '${AuthService.baseUrl}${p.imageUrl}',
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 100,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.broken_image_outlined,
                                                color: Colors.white38,
                                                size: 32,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          if (p.isPending) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 12,
                                    color: Colors.blueAccent.shade100,
                                  ),
                                  const SizedBox(width: 6),
                                  _ProofCountdown(
                                    proof: p,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.blueAccent.shade100,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (p.isRejected && p.aiReasoning != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.redAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: Colors.redAccent.shade100,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p.aiReasoning!.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent.shade100,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        _translateProofStatus(context, p.status).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.error_outline;
      case 'expired':
        return Icons.timer_off_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'unknown';
    return DateFormat('MMM d, HH:mm').format(date);
  }
}

class _ProofCountdown extends StatefulWidget {
  final ProofRequest proof;
  final TextStyle? style;
  const _ProofCountdown({required this.proof, this.style});

  @override
  State<_ProofCountdown> createState() => _ProofCountdownState();
}

class _ProofCountdownState extends State<_ProofCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
        if (widget.proof.isExpired) {
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void didUpdateWidget(_ProofCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proof.id != widget.proof.id ||
        oldWidget.proof.expiresAt != widget.proof.expiresAt) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.proof.timeRemaining, style: widget.style);
  }
}

// ── Remove Worker Button ──
class _RemoveWorkerButton extends StatefulWidget {
  final WorkerContract contract;
  final bool isDark;
  final String landId;

  const _RemoveWorkerButton({
    required this.contract,
    required this.isDark,
    required this.landId,
  });

  @override
  State<_RemoveWorkerButton> createState() => _RemoveWorkerButtonState();
}

class _RemoveWorkerButtonState extends State<_RemoveWorkerButton> {
  bool _removing = false;

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF2A2D30) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.removeWorker,
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.removeWorkerConfirmation(widget.contract.workerName ?? AppLocalizations.of(context)!.worker),
          style: TextStyle(
            color: widget.isDark ? Colors.white70 : Colors.black54,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: widget.isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.remove, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _removing = true);
    final lifecycle = context.read<WorkerLifecycleProvider>();
    final success = await lifecycle.terminateContract(widget.contract.id);
    if (mounted) {
      setState(() => _removing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? AppLocalizations.of(context)!.workerRemovedSuccessfully : AppLocalizations.of(context)!.failedToRemoveWorker,
          ),
          backgroundColor: success ? Colors.green.shade700 : Colors.redAccent,
        ),
      );
      if (success) {
        // Also refresh approved workers so the worker reappears as available
        lifecycle.loadApprovedWorkers(widget.landId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_removing) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      onPressed: _confirmRemove,
      icon: Icon(
        Icons.person_remove_outlined,
        size: 20,
        color: Colors.red.shade400,
      ),
      tooltip: AppLocalizations.of(context)!.removeWorker,
      style: IconButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

// ── Error view helper ──
Widget _errorView({
  required BuildContext context,
  required bool isDark,
  required String message,
  required VoidCallback onRetry,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.redAccent.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.systemErrorUpper,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18, color: Colors.black),
            label: Text(
              AppLocalizations.of(context)!.retryConnectionUpper,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Shared shimmer loader ──
Widget _shimmerList(bool isDark) {
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: 16),
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFF1E293B), // Slate-800
      highlightColor: const Color(0xFF334155), // Slate-700
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Slate-900
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 36,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _translateSalaryTypeLabel(BuildContext context, String label) {
  final l10n = AppLocalizations.of(context)!;
  switch (label.toLowerCase()) {
    case 'monthly': return l10n.monthly;
    case 'hourly': return l10n.hourly;
    case 'per task':
    case 'per_task': return l10n.perTask;
    default:
      return label;
    }
  }

  String _translateSkill(BuildContext context, String skill) {
    final l10n = AppLocalizations.of(context)!;
    switch (skill.toLowerCase()) {
      case 'watering':
        return l10n.watering;
      case 'harvesting':
        return l10n.harvesting;
      case 'planting':
        return l10n.planting;
      case 'animal care':
      case 'animalcare':
        return l10n.animalCare;
      case 'machine operation':
      case 'machineoperation':
        return l10n.machineOperation;
      case 'soil management':
      case 'soilmanagement':
        return l10n.soilManagement;
      case 'structure installation':
      case 'structureinstallation':
        return l10n.structureInstallation;
      case 'quality inspection':
      case 'qualityinspection':
        return l10n.qualityInspection;
      case 'crop monitoring':
      case 'cropmonitoring':
        return l10n.cropMonitoring;
      case 'pest control':
      case 'pestcontrol':
        return l10n.pestControl;
      default:
        return skill;
    }
  }

  String _translateContractStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.activeUpper;
      case 'pending':
      case 'hiring_pending':
        return l10n.pendingUpper;
      case 'negotiating':
      case 'negotiation_pending':
        return l10n.negotiatingUpper;
      case 'counter-offer':
      case 'negotiation_countered':
        return l10n.counterOfferUpper;
      case 'declined':
      case 'hiring_declined':
        return l10n.declinedUpper;
      case 'awaiting payment':
      case 'payment_pending':
        return l10n.pendingUpper;
      case 'suspended':
        return l10n.suspendedUpper;
      case 'expired':
        return l10n.expiredUpper;
      default:
        return status;
    }
  }

  String _translateProofStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pendingUpper;
      case 'verified':
      case 'approved':
        return l10n.verifiedUpper;
      case 'rejected':
        return l10n.rejectedUpper;
      case 'expired':
        return l10n.expiredUpper;
      default:
        return status;
    }
  }

