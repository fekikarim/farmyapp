import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_contract_model.dart';
import '../../models/contract_negotiation_model.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../services/auth_service.dart';

class ContractNegotiationScreen extends StatefulWidget {
  final WorkerContract contract;

  const ContractNegotiationScreen({super.key, required this.contract});

  @override
  State<ContractNegotiationScreen> createState() =>
      _ContractNegotiationScreenState();
}

class _ContractNegotiationScreenState extends State<ContractNegotiationScreen> {
  final _commentController = TextEditingController();
  final _salaryController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSalaryField = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerLifecycleProvider>().loadNegotiationHistory(
        widget.contract.id,
      );
      _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getUser();
    if (user != null && mounted) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _salaryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendNegotiation() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    double? proposedSalary;
    if (_showSalaryField && _salaryController.text.isNotEmpty) {
      proposedSalary = double.tryParse(_salaryController.text);
    }

    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.negotiateContract(
      contractId: widget.contract.id,
      comment: comment,
      proposedSalaryAmount: proposedSalary,
    );

    if (success && mounted) {
      _commentController.clear();
      _salaryController.clear();
      setState(() => _showSalaryField = false);
      _scrollToBottom();
    }
  }

  Future<void> _respondToContract(String response) async {
    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.respondToContract(
      contractId: widget.contract.id,
      response: response,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (response == 'approve'
                      ? 'Contract approved!'
                      : 'Contract declined')
                : 'Failed to respond',
          ),
          backgroundColor: success ? Colors.green.shade700 : Colors.redAccent,
        ),
      );
      if (success) Navigator.pop(context, true);
    }
  }

  Future<void> _processPayment() async {
    final provider = context.read<WorkerLifecycleProvider>();
    final paymentData = await provider.createContractPayment(
      widget.contract.id,
    );

    if (paymentData.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create payment'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // In a real app, use stripe_sdk to present the payment sheet
    // For now, show payment info
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Payment Ready'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount: ${widget.contract.salaryAmount.toStringAsFixed(2)} TND',
              ),
              const SizedBox(height: 8),
              const Text(
                'Stripe PaymentIntent created. Complete the payment to activate the contract.',
              ),
              const SizedBox(height: 8),
              Text(
                'Client Secret: ${paymentData['clientSecret']?.toString().substring(0, 20) ?? '...'}...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WorkerLifecycleProvider>();
    final negotiations = provider.negotiations;
    final isLoading = provider.negotiationsLoading;

    // Scroll to bottom when new messages load
    if (!isLoading && negotiations.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF252525) : Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contract.workerName ?? 'Contract',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${widget.contract.salaryAmount.toStringAsFixed(0)} TND/${widget.contract.salaryTypeLabel} • ${widget.contract.statusLabel}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Contract Summary Card
          _buildContractSummary(isDark),

          // Chat Messages
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : negotiations.isEmpty
                ? _buildEmptyChat(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: negotiations.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(negotiations[index], isDark);
                    },
                  ),
          ),

          // Action Buttons for Worker
          if (widget.contract.status == 'hiring_proposed' &&
              _currentUserId == widget.contract.workerId)
            _buildWorkerActionBar(isDark),

          // Payment Button for Investor
          if (widget.contract.status == 'payment_pending' &&
              _currentUserId == widget.contract.investorId)
            _buildPaymentBar(isDark),

          // Input Area (for negotiation)
          if (widget.contract.status == 'hiring_proposed' ||
              widget.contract.status == 'negotiating')
            _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildContractSummary(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2D30) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.green.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contract for ${widget.contract.workerName ?? "Worker"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    _infoChip(
                      Icons.payments_outlined,
                      '${widget.contract.salaryAmount.toStringAsFixed(0)} TND',
                      isDark,
                    ),
                    _infoChip(
                      Icons.schedule,
                      widget.contract.salaryTypeLabel,
                      isDark,
                    ),
                    _infoChip(
                      Icons.calendar_today,
                      '${widget.contract.contractStartDate.day}/${widget.contract.contractStartDate.month}',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(widget.contract.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.contract.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _statusColor(widget.contract.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'hiring_proposed':
        return Colors.blue;
      case 'negotiating':
        return Colors.orange;
      case 'worker_approved':
      case 'active':
        return Colors.green;
      case 'payment_pending':
        return Colors.purple;
      case 'hiring_declined':
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyChat(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 56,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          ),
          const SizedBox(height: 14),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start the negotiation by sending a message',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ContractNegotiation negotiation, bool isDark) {
    final isMe = negotiation.senderId == _currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              isMe ? 'You' : (negotiation.senderName ?? 'Other party'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ),

          // Proposed salary indicator
          if (negotiation.proposedSalaryAmount != null)
            Container(
              margin: EdgeInsets.only(
                left: isMe ? 60 : 0,
                right: isMe ? 0 : 60,
                bottom: 4,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Proposed: ${negotiation.proposedSalaryAmount!.toStringAsFixed(0)} TND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),

          // Message bubble
          Container(
            margin: EdgeInsets.only(left: isMe ? 60 : 0, right: isMe ? 0 : 60),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.green.shade600
                  : (isDark ? const Color(0xFF2F3336) : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  negotiation.comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(negotiation.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withOpacity(0.6)
                        : (isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildWorkerActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _respondToContract('decline'),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Decline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _respondToContract('approve'),
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: const Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _processPayment,
          icon: const Icon(Icons.payment, color: Colors.white),
          label: Text(
            'Pay ${widget.contract.salaryAmount.toStringAsFixed(0)} TND to Activate',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Salary proposal toggle
          if (_showSalaryField)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Propose new salary...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.amber.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.amber.shade600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showSalaryField = false),
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

          // Message input row
          Row(
            children: [
              // Salary toggle button
              IconButton(
                onPressed: () =>
                    setState(() => _showSalaryField = !_showSalaryField),
                icon: Icon(
                  Icons.attach_money,
                  color: _showSalaryField
                      ? Colors.amber.shade700
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _showSalaryField
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.transparent,
                ),
              ),
              const SizedBox(width: 4),
              // Comment field
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: null,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendNegotiation,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
