import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_contract_model.dart';
import '../../models/contract_negotiation_model.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../services/auth_service.dart';
import '../../services/worker_lifecycle_service.dart';

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
  String? _currentUserId;

  // Live contract state — refreshed after every action
  late WorkerContract _liveContract;

  // Per-action loading flag
  bool _actionLoading = false;

  // Investor counter-offer panel
  bool _showCounterPanel = false;
  String _counterSalaryType = 'monthly';

  @override
  void initState() {
    super.initState();
    _liveContract = widget.contract;
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
      setState(() => _currentUserId = user.id);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _salaryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  bool get _isInvestor => _currentUserId == _liveContract.investorId;
  bool get _isWorker => _currentUserId == _liveContract.workerId;

  bool get _isTerminalState => const [
    'hiring_declined',
    'terminated',
    'expired',
  ].contains(_liveContract.status);

  /// Whether the worker can see accept/decline buttons
  bool get _workerCanRespond =>
      _isWorker &&
      (_liveContract.status == 'hiring_pending' ||
          _liveContract.status == 'negotiation_countered');

  /// Whether the worker can type in the chat input
  bool get _workerCanNegotiate => _isWorker && _liveContract.isInNegotiation;

  /// Whether the investor sees the 3-button action bar
  bool get _investorCanRespond =>
      _isInvestor &&
      (_liveContract.status == 'negotiation_pending' ||
          _liveContract.status == 'negotiation_countered' ||
          _liveContract.status == 'hiring_pending');

  /// Whether the investor sees the payment bar
  bool get _investorPaymentPending =>
      _isInvestor && _liveContract.status == 'payment_pending';

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Refresh the contract from the server after every mutation
  Future<void> _refreshContract() async {
    final updated = await WorkerLifecycleService.getContract(_liveContract.id);
    if (updated != null && mounted) {
      setState(() => _liveContract = updated);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ─── Worker actions ─────────────────────────────────────────────────

  Future<void> _workerRespond(String response) async {
    setState(() => _actionLoading = true);
    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.respondToContract(
      contractId: _liveContract.id,
      response: response,
    );
    if (mounted) {
      if (success) {
        await _refreshContract();
        _showSnack(
          response == 'approve' ? 'Contract approved!' : 'Contract declined',
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnack(provider.lastError ?? 'Failed to respond', isError: true);
      }
      setState(() => _actionLoading = false);
    }
  }

  /// Worker sends a negotiation message (simple chat input)
  Future<void> _workerSendNegotiation() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _actionLoading = true);

    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.negotiateContract(
      contractId: _liveContract.id,
      comment: comment,
    );

    if (mounted) {
      if (success) {
        _commentController.clear();
        await _refreshContract();
        _scrollToBottom();
      } else {
        _showSnack(provider.lastError ?? 'Failed to send', isError: true);
      }
      setState(() => _actionLoading = false);
    }
  }

  // ─── Investor actions ───────────────────────────────────────────────

  /// Investor accepts the current terms
  Future<void> _investorAccept() async {
    setState(() => _actionLoading = true);
    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.investorRespondToContract(
      contractId: _liveContract.id,
      response: 'accept',
    );
    if (mounted) {
      if (success) {
        await _refreshContract();
        await provider.loadNegotiationHistory(_liveContract.id);
        _scrollToBottom();
        _showSnack('Offer accepted — proceed to payment');
      } else {
        _showSnack(provider.lastError ?? 'Failed to accept', isError: true);
      }
      setState(() => _actionLoading = false);
    }
  }

  /// Investor declines with confirmation
  Future<void> _investorDecline() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2D30) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Decline Negotiation?',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Text(
            'This will permanently cancel the contract negotiation with ${_liveContract.workerName ?? "this worker"}.',
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Decline',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _actionLoading = true);
    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.investorRespondToContract(
      contractId: _liveContract.id,
      response: 'decline',
    );
    if (mounted) {
      if (success) {
        await _refreshContract();
        await provider.loadNegotiationHistory(_liveContract.id);
        _scrollToBottom();
        _showSnack('Negotiation declined');
      } else {
        _showSnack(provider.lastError ?? 'Failed to decline', isError: true);
      }
      setState(() => _actionLoading = false);
    }
  }

  /// Investor sends a counter-offer (salary + type + message)
  Future<void> _investorSendCounter() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      _showSnack('Please enter a message', isError: true);
      return;
    }

    double? proposedSalary;
    if (_salaryController.text.isNotEmpty) {
      proposedSalary = double.tryParse(_salaryController.text);
      if (proposedSalary == null || proposedSalary <= 0) {
        _showSnack('Please enter a valid salary amount', isError: true);
        return;
      }
    }

    setState(() => _actionLoading = true);

    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.negotiateContract(
      contractId: _liveContract.id,
      comment: comment,
      proposedSalaryAmount: proposedSalary,
      proposedSalaryType: _counterSalaryType,
    );

    if (mounted) {
      if (success) {
        _commentController.clear();
        _salaryController.clear();
        setState(() {
          _showCounterPanel = false;
          _counterSalaryType = 'monthly';
        });
        await _refreshContract();
        _scrollToBottom();
        _showSnack('Counter-offer sent');
      } else {
        _showSnack(
          provider.lastError ?? 'Failed to send counter-offer',
          isError: true,
        );
      }
      setState(() => _actionLoading = false);
    }
  }

  /// Investor creates a payment intent
  Future<void> _processPayment() async {
    setState(() => _actionLoading = true);

    final provider = context.read<WorkerLifecycleProvider>();
    final paymentData = await provider.createContractPayment(_liveContract.id);

    if (mounted) {
      setState(() => _actionLoading = false);
      if (paymentData.isEmpty) {
        _showSnack('Failed to create payment', isError: true);
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF2A2D30) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.payment, color: Colors.purple.shade400, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Payment Ready',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: ${_liveContract.salaryAmount.toStringAsFixed(2)} TND',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete the Stripe payment to activate the contract.',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
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
          );
        },
      );
    }
  }

  // ─── Pull-to-refresh ────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    final provider = context.read<WorkerLifecycleProvider>();
    await Future.wait([
      provider.loadNegotiationHistory(_liveContract.id),
      _refreshContract(),
    ]);
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WorkerLifecycleProvider>();
    final negotiations = provider.negotiations;
    final isLoading = provider.negotiationsLoading;

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
              _liveContract.workerName ?? 'Contract',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${_liveContract.salaryAmount.toStringAsFixed(0)} TND${_liveContract.salaryTypeLabel} \u2022 ${_liveContract.statusLabel}',
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
          onPressed: () => Navigator.pop(
            context,
            _liveContract.status != widget.contract.status,
          ),
        ),
      ),
      body: Column(
        children: [
          // Contract summary card
          _buildContractSummary(isDark),

          // Terminal state banner
          if (_isTerminalState) _buildTerminalBanner(isDark),

          // Chat messages with pull-to-refresh
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : negotiations.isEmpty
                ? _buildEmptyChat(isDark)
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: negotiations.length,
                      itemBuilder: (context, index) =>
                          _buildMessageBubble(negotiations[index], isDark),
                    ),
                  ),
          ),

          // ── Action Bars (mutually exclusive) ──

          // Loading spinner replaces action bars during API calls
          if (_actionLoading)
            _buildLoadingBar(isDark)
          // Worker: accept / decline buttons
          else if (_workerCanRespond)
            _buildWorkerActionBar(isDark)
          // Worker: chat input for negotiation
          else if (_workerCanNegotiate)
            _buildWorkerInputArea(isDark)
          // Investor: decline / counter / accept bar
          else if (_investorCanRespond && !_showCounterPanel)
            _buildInvestorActionBar(isDark)
          // Investor: counter-offer panel (expanded)
          else if (_investorCanRespond && _showCounterPanel)
            _buildInvestorCounterPanel(isDark)
          // Investor: payment bar
          else if (_investorPaymentPending)
            _buildPaymentBar(isDark),
        ],
      ),
    );
  }

  // ─── Contract Summary Card ──────────────────────────────────────────

  Widget _buildContractSummary(bool isDark) {
    final sc = _statusColor(_liveContract.status);
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
                  'Contract for ${_liveContract.workerName ?? "Worker"}',
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
                      '${_liveContract.salaryAmount.toStringAsFixed(0)} TND',
                      isDark,
                    ),
                    _infoChip(
                      Icons.schedule,
                      _liveContract.salaryTypeLabel,
                      isDark,
                    ),
                    _infoChip(
                      Icons.calendar_today,
                      '${_liveContract.contractStartDate.day}/${_liveContract.contractStartDate.month}',
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
              color: sc.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _liveContract.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: sc,
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
      case 'hiring_pending':
        return Colors.blue;
      case 'negotiation_pending':
      case 'negotiation_countered':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'payment_pending':
        return Colors.purple;
      case 'hiring_declined':
      case 'terminated':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      case 'suspended':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // ─── Terminal State Banner ──────────────────────────────────────────

  Widget _buildTerminalBanner(bool isDark) {
    IconData icon;
    String label;
    Color color;
    switch (_liveContract.status) {
      case 'hiring_declined':
        icon = Icons.cancel_outlined;
        label = 'This negotiation has been declined';
        color = Colors.red;
        break;
      case 'terminated':
        icon = Icons.remove_circle_outline;
        label = 'This contract has been terminated';
        color = Colors.red;
        break;
      case 'expired':
        icon = Icons.timer_off_outlined;
        label = 'This contract has expired';
        color = Colors.grey;
        break;
      default:
        icon = Icons.info_outline;
        label = 'Contract is ${_liveContract.statusLabel}';
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty Chat ─────────────────────────────────────────────────────

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

  // ─── Message Bubble ─────────────────────────────────────────────────

  /// System messages (accept / decline records) are rendered as centered pills
  bool _isSystemMessage(ContractNegotiation n) {
    const systemPhrases = [
      'Offer accepted. Proceeding to payment.',
      'Offer declined. This negotiation has been cancelled.',
    ];
    return systemPhrases.contains(n.comment);
  }

  Widget _buildMessageBubble(ContractNegotiation negotiation, bool isDark) {
    // ── System message pill ──
    if (_isSystemMessage(negotiation)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              negotiation.comment,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    // ── Normal chat bubble ──
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
                color: Colors.grey.shade500,
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

  // ─── Loading Bar ────────────────────────────────────────────────────

  Widget _buildLoadingBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  // ─── Worker Action Bar (Accept / Decline) ───────────────────────────

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
              onPressed: () => _workerRespond('decline'),
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
              onPressed: () => _workerRespond('approve'),
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

  // ─── Worker Input Area (simple chat) ────────────────────────────────

  Widget _buildWorkerInputArea(bool isDark) {
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
      child: Row(
        children: [
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
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _workerSendNegotiation,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Investor Action Bar (Decline / Counter / Accept) ───────────────

  Widget _buildInvestorActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          // Decline
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _investorDecline,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Decline', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Counter
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showCounterPanel = true),
              icon: Icon(
                Icons.edit_note,
                size: 18,
                color: Colors.orange.shade700,
              ),
              label: Text(
                'Counter',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Accept
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _investorAccept,
              icon: const Icon(Icons.check, size: 16, color: Colors.white),
              label: const Text(
                'Accept',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Investor Counter-offer Panel ───────────────────────────────────

  Widget _buildInvestorCounterPanel(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).padding.bottom,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close
          Row(
            children: [
              Icon(Icons.edit_note, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                'Counter-offer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showCounterPanel = false),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Salary amount + type row
          Row(
            children: [
              // Amount
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Salary amount',
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
                    prefixIcon: Icon(
                      Icons.attach_money,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 36),
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
              const SizedBox(width: 8),
              // Salary type dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _counterSalaryType,
                      isExpanded: true,
                      dropdownColor: isDark
                          ? const Color(0xFF2A2D30)
                          : Colors.white,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: 'hourly',
                          child: Text('Hourly'),
                        ),
                        DropdownMenuItem(
                          value: 'per_task',
                          child: Text('Per Task'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _counterSalaryType = v);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Message + send
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: null,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a message...',
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _investorSendCounter,
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

  // ─── Payment Bar ────────────────────────────────────────────────────

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
            'Pay ${_liveContract.salaryAmount.toStringAsFixed(0)} TND to Activate',
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
}
