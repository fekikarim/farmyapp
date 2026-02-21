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

class InvestorWorkforcePanel extends StatefulWidget {
  final String landId;
  final String landName;

  const InvestorWorkforcePanel({
    super.key,
    required this.landId,
    required this.landName,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  State<InvestorWorkforcePanel> createState() => _InvestorWorkforcePanelState();
}

class _InvestorWorkforcePanelState extends State<InvestorWorkforcePanel>
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lifecycle = context.watch<WorkerLifecycleProvider>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2125) : Colors.white,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16181A) : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workforce',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.landName,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.green.shade600,
                  unselectedLabelColor: isDark
                      ? Colors.white38
                      : Colors.black38,
                  indicatorColor: Colors.green.shade600,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 15),
                          const SizedBox(width: 5),
                          const Text('Approved'),
                          if (lifecycle.approvedWorkers.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            _badge(
                              lifecycle.approvedWorkers.length,
                              Colors.green,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.handshake_outlined, size: 15),
                          const SizedBox(width: 5),
                          const Text('Negotiations'),
                          if (lifecycle.negotiatingContracts.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            _badge(
                              lifecycle.negotiatingContracts.length,
                              Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_edu_outlined, size: 15),
                          const SizedBox(width: 5),
                          const Text('Active'),
                          if (lifecycle.activeContracts.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            _badge(lifecycle.activeContracts.length, Colors.green.shade600),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 15),
                          const SizedBox(width: 5),
                          const Text('Proofs'),
                          if (lifecycle.pendingLandProofs.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            _badge(lifecycle.pendingLandProofs.length, Colors.blue.shade600),
                          ],
                        ],
                      ),
                    ),
                  ],
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
                  isDark: isDark,
                  workers: lifecycle.approvedWorkers,
                  isLoading: lifecycle.approvedWorkersLoading,
                  error: lifecycle.approvedWorkersError,
                  onHire: _showHireDialog,
                  onRefresh: () => lifecycle.loadApprovedWorkers(widget.landId),
                ),
                _NegotiationsTab(
                  landId: widget.landId,
                  isDark: isDark,
                  contracts: lifecycle.negotiatingContracts,
                  isLoading: lifecycle.negotiatingContractsLoading,
                  error: lifecycle.negotiatingContractsError,
                  onRefresh: _loadAllData,
                ),
                _ActiveWorkersTab(
                  landId: widget.landId,
                  isDark: isDark,
                  contracts: lifecycle.activeContracts,
                  isLoading: lifecycle.activeContractsLoading,
                  error: lifecycle.activeContractsError,
                  onRefresh: () => lifecycle.loadActiveContracts(widget.landId),
                ),
                _ProofsTab(
                  landId: widget.landId,
                  isDark: isDark,
                  proofs: lifecycle.landProofs,
                  isLoading: lifecycle.landProofsLoading,
                  onRefresh: () => lifecycle.loadLandProofs(widget.landId),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _badge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showHireDialog(WorkerProfile worker) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salaryController = TextEditingController();
    final messageController = TextEditingController();
    String salaryType = 'monthly';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 90));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2D30) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hire ${worker.userName ?? "Worker"}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salary Amount
                Text(
                  'Salary Amount (TND)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _inputDecoration('e.g. 1500', isDark),
                ),
                const SizedBox(height: 16),

                // Salary Type
                Text(
                  'Salary Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
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
                                ? Colors.green.shade600
                                : (isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Colors.green.shade600
                                  : (isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              type == 'per_task'
                                  ? 'Per Task'
                                  : type[0].toUpperCase() + type.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white60
                                          : Colors.black54),
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
                            'Start Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
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
                              );
                              if (date != null)
                                setDialogState(() => startDate = date);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                '${startDate.day}/${startDate.month}/${startDate.year}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
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
                            'End Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
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
                              );
                              if (date != null)
                                setDialogState(() => endDate = date);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                '${endDate.day}/${endDate.month}/${endDate.year}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
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
                  'Message (optional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: messageController,
                  maxLines: 2,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: _inputDecoration('Optional message...', isDark),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                        error == null
                            ? 'Hiring proposal sent!'
                            : error,
                      ),
                      backgroundColor: error == null
                          ? Colors.green.shade700
                          : Colors.redAccent,
                    ),
                  );
                  if (error == null) {
                    _tabController.animateTo(1); // Switch to Negotiations
                    _loadAllData();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Send Proposal',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
      ),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green.shade500, width: 2),
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
    if (isLoading) return _shimmerList(isDark);

    if (error != null) {
      return _errorView(isDark: isDark, message: error!, onRetry: onRefresh);
    }

    if (workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 56,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
            const SizedBox(height: 14),
            Text(
              'No Approved Workers Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Workers must be invited and approved\nby the farmer first',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: workers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final w = workers[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2F33) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20, // Slightly smaller
                  backgroundColor: isDark
                      ? Colors.green.withOpacity(0.2)
                      : Colors.green.shade100,
                  child: Icon(
                    Icons.person,
                    color: isDark
                        ? Colors.green.shade400
                        : Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        w.userName ?? 'Worker',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13, // Smaller font
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        w.skills.isNotEmpty ? w.skills.first : 'No skills',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onHire(w),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Hire', style: TextStyle(fontSize: 11)),
                ),
              ],
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
    if (isLoading) return _shimmerList(isDark);

    if (error != null) {
      return _errorView(isDark: isDark, message: error!, onRetry: onRefresh);
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 56,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
            const SizedBox(height: 14),
            Text(
              'No Active Negotiations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hire an approved worker to start\na contract negotiation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: contracts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final c = contracts[index];
          return _NegotiationCard(
            contract: c,
            isDark: isDark,
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
        statusColor = Colors.blue;
        statusText = 'Proposed';
        break;
      case 'negotiation_pending':
        statusColor = Colors.orange;
        statusText = 'Negotiating';
        break;
      case 'negotiation_countered':
        statusColor = Colors.deepOrange;
        statusText = 'Counter-offer';
        break;
      case 'payment_pending':
        statusColor = Colors.purple;
        statusText = 'Pay Now';
        break;
      default:
        statusColor = Colors.grey;
        statusText = contract.statusLabel;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Icon(Icons.person, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.workerName ?? 'Worker',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${contract.salaryAmount.toStringAsFixed(0)} TND/${contract.salaryTypeLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (contract.needsInvestorAction) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contract.status == 'payment_pending'
                          ? 'Payment required to activate contract'
                          : 'Worker responded — review their counter-offer',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
    if (isLoading) return _shimmerList(isDark);

    if (error != null) {
      return _errorView(isDark: isDark, message: error!, onRetry: onRefresh);
    }

    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.engineering_outlined,
              size: 56,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
            const SizedBox(height: 14),
            Text(
              'No Active Workers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hire and complete payment to\nactivate workers on this land',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: contracts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final c = contracts[index];
          final isSuspended = c.isSuspended;
          final badgeColor = isSuspended ? Colors.orange : Colors.green;
          final badgeText = isSuspended ? 'SUSPENDED' : 'ACTIVE';
          final dotColor = isSuspended ? Colors.orange : Colors.green;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: badgeColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: badgeColor.withOpacity(0.15),
                      child: Icon(Icons.person, color: badgeColor, size: 22),
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
                            color: isDark
                                ? const Color(0xFF1E2125)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.workerName ?? 'Worker',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${c.salaryAmount.toStringAsFixed(0)} TND${c.salaryTypeLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
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
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Until ${DateFormat('MMM d').format(c.contractEndDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                _RequestProofButton(
                  contract: c,
                  isDark: isDark,
                  landId: landId,
                ),
                const SizedBox(width: 8),
                _RemoveWorkerButton(
                  contract: c,
                  isDark: isDark,
                  landId: landId,
                ),
              ],
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
          backgroundColor: widget.isDark ? const Color(0xFF2A2D30) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: const Text('Entire Land', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('General farming activity', style: TextStyle(fontSize: 11)),
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
                        title: Text(item.displayName, style: const TextStyle(fontSize: 14)),
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
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
              child: const Text('Request', style: TextStyle(color: Colors.white)),
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
            content: const Text('Proof requested! The worker has 1 hour to submit.'),
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
    if (isLoading) return _shimmerList(isDark);

    if (proofs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_enhance_outlined,
              size: 56,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
            const SizedBox(height: 14),
            Text(
              'No Proofs Requested',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Request a photo proof from an active\nworker to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: proofs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final p = proofs[index];
          final color = _getStatusColor(p.status);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(_getStatusIcon(p.status), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.targetName ?? p.landName ?? 'General Land Proof',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Requested • ${_formatDate(p.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                      if (p.targetType == 'item')
                         Padding(
                           padding: const EdgeInsets.only(top: 4),
                           child: Text(
                             'Item ID: ${p.targetId?.substring(0, 8)}...',
                             style: TextStyle(
                               fontSize: 10,
                               color: isDark ? Colors.white24 : Colors.black26,
                             ),
                           ),
                         ),
                       if (p.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                '${AuthService.baseUrl}${p.imageUrl}',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 80,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 24),
                                ),
                              ),
                            ),
                          ),
                      if (p.isPending) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 10, color: Colors.blue.shade300),
                            const SizedBox(width: 4),
                            _ProofCountdown(
                              proof: p,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (p.isRejected && p.aiReasoning != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.aiReasoning!,
                            style: const TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified': return Colors.green;
      case 'rejected': return Colors.red;
      case 'expired': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified': return Icons.check_circle_outline;
      case 'rejected': return Icons.error_outline;
      case 'expired': return Icons.timer_off_outlined;
      default: return Icons.schedule_outlined;
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
    if (oldWidget.proof.id != widget.proof.id || oldWidget.proof.expiresAt != widget.proof.expiresAt) {
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
    return Text(
      widget.proof.timeRemaining,
      style: widget.style,
    );
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
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 14),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
    padding: const EdgeInsets.all(24),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, __) => Container(
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.white10 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.white24 : Colors.grey.shade100,
        child: Row(
          children: [
            const CircleAvatar(radius: 22, backgroundColor: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 80, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
