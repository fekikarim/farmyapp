import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/worker_lifecycle_provider.dart';
import '../../../services/proof_service.dart';
import '../../../services/auth_service.dart';

import '../../../models/worker_contract_model.dart';
import '../../../models/worker_profile_model.dart';
import '../../../models/proof_request_model.dart';
import '../../../models/placed_item_model.dart';
import '../../../services/land_service.dart';
import '../../shared/contract_negotiation_screen.dart';

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
                          'WORKFORCE',
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
                            const Text('APPROVED'),
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
                            const Text('NEGOTIATIONS'),
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
                            const Text('ACTIVE'),
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
                            const Text('PROOFS'),
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
            'HIRE ${(worker.userName ?? "Worker").toUpperCase()}',
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
                const Text(
                  'SALARY AMOUNT (TND)',
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
                  decoration: _inputDecoration('e.g. 1500'),
                ),
                const SizedBox(height: 16),

                // Salary Type
                const Text(
                  'SALARY TYPE',
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
                                  ? 'PER TASK'
                                  : type.toUpperCase(),
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
                          const Text(
                            'START DATE',
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
                                '${startDate.day}/${startDate.month}/${startDate.year}',
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
                          const Text(
                            'END DATE',
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
                                '${endDate.day}/${endDate.month}/${endDate.year}',
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
                const Text(
                  'MESSAGE (OPTIONAL)',
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
                  decoration: _inputDecoration('Optional message...'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCEL',
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
                    const SnackBar(
                      content: Text('Please enter a valid salary'),
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
                        error == null ? 'Hiring proposal sent!' : error,
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
              child: const Text(
                'SEND PROPOSAL',
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
      return _errorView(isDark: true, message: error!, onRetry: onRefresh);
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
            const Text(
              'NO APPROVED WORKERS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Invite workers inside the marketplace',
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
                    Container(
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (w.userName ?? 'Worker').toUpperCase(),
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
                                w.skills.first.toUpperCase(),
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
                            const Text(
                              'NO SPECIAL SKILLS',
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
                      child: const Text(
                        'HIRE',
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
      return _errorView(isDark: true, message: error!, onRetry: onRefresh);
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
            const Text(
              'NO ACTIVE NEGOTIATIONS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hire an approved worker to start\na contract negotiation',
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
        statusText = 'PROPOSED';
        break;
      case 'negotiation_pending':
        statusColor = Colors.orangeAccent;
        statusText = 'NEGOTIATING';
        break;
      case 'negotiation_countered':
        statusColor = Colors.deepOrangeAccent;
        statusText = 'COUNTER-OFFER';
        break;
      case 'payment_pending':
        statusColor = Colors.purpleAccent;
        statusText = 'PAY NOW';
        break;
      default:
        statusColor = Colors.white54;
        statusText = contract.statusLabel.toUpperCase();
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
                    Container(
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
                        child: Icon(Icons.person, color: statusColor, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (contract.workerName ?? 'Worker').toUpperCase(),
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
                              '${contract.salaryAmount.toStringAsFixed(0)} TND / ${contract.salaryTypeLabel.toUpperCase()}',
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
                                ? 'PAYMENT REQUIRED TO ACTIVATE CONTRACT'
                                : 'WORKER RESPONDED — REVIEW COUNTER-OFFER',
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
      return _errorView(isDark: true, message: error!, onRetry: onRefresh);
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
            const Text(
              'NO ACTIVE WORKERS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hire and complete payment to\nactivate workers on this land',
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
          final badgeText = isSuspended ? 'SUSPENDED' : 'ACTIVE';
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
                    Stack(
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (c.workerName ?? 'Worker').toUpperCase(),
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
                              '${c.salaryAmount.toStringAsFixed(0)} TND / ${c.salaryTypeLabel.toUpperCase()}',
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
                          'UNTIL ${DateFormat('MMM d').format(c.contractEndDate).toUpperCase()}',
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
            'Request Proof',
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
                'What do you want proof for?',
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
                  title: const Text(
                    'Entire Land',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'General farming activity',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: 'land',
                  groupValue: targetType,
                  onChanged: (val) => setDialogState(() {
                    targetType = val!;
                    targetId = null;
                    targetLabel = 'Current Land';
                  }),
                ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Or select an item:',
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
                'The worker has 1 hour to submit an AI-verified image of $targetLabel.',
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
                'Cancel',
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
              child: const Text(
                'Request',
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
            content: const Text(
              'Proof requested! The worker has 1 hour to submit.',
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
      tooltip: 'Request AI Proof',
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
            const Text(
              'NO PROOFS REQUESTED',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Request a photo proof from an active\nworker to see it here.',
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
                    Container(
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
                            'REQUESTED • ${_formatDate(p.createdAt).toUpperCase()}',
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
                                'ITEM ID: ${p.targetId?.substring(0, 8)}...',
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
                        p.statusLabel.toUpperCase(),
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
          'Remove Worker',
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently remove ${widget.contract.workerName ?? "this worker"} from this land?\n\nThis action will terminate the contract and cannot be undone.',
          style: TextStyle(
            color: widget.isDark ? Colors.white70 : Colors.black54,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
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
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
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
            success ? 'Worker removed successfully' : 'Failed to remove worker',
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
      tooltip: 'Remove worker',
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
          const Text(
            'SYSTEM ERROR',
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
            label: const Text(
              'RETRY CONNECTION',
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
