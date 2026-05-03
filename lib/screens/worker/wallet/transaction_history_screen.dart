import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/worker_wallet_provider.dart';
import '../../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    await context.read<WorkerWalletProvider>().fetchTransactions(
      type: _selectedFilter == 'all' ? null : _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Earnings', 'earnings'),
                const SizedBox(width: 8),
                _buildFilterChip('Withdrawals', 'withdrawals'),
              ],
            ),
          ),

          Expanded(
            child: Consumer<WorkerWalletProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingTransactions) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.transactionsError != null) {
                  return _buildFeedbackState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Unable to sync transactions',
                    message: provider.transactionsError!,
                    onRetry: _fetchData,
                  );
                }

                if (provider.transactions.isEmpty) {
                  return _buildFeedbackState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    message:
                        'Completed rewards and withdrawals will appear here automatically.',
                    onRetry: _fetchData,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.transactions.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.withValues(alpha: 0.2)),
                    itemBuilder: (context, index) {
                      final tx = provider.transactions[index];
                      return _buildTransactionItem(tx as Map<String, dynamic>);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
          _fetchData();
        }
      },
    );
  }

  Widget _buildFeedbackState({
    required IconData icon,
    required String title,
    required String message,
    required Future<void> Function() onRetry,
  }) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: onRetry,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 56, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          onRetry();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
    final type = tx['type']?.toString() ?? 'transaction';
    final status = tx['status']?.toString() ?? 'pending';
    final date = DateTime.tryParse(tx['createdAt'] ?? '') ?? DateTime.now();

    final isPositive = type == 'task_earning' || type.startsWith('salary');
    final icon = isPositive ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isPositive ? Colors.green : Colors.red;

    String title = 'Transaction';
    if (type == 'task_earning')
      title = 'Task Reward';
    else if (type == 'withdrawal')
      title = 'Withdrawal';
    else if (type.startsWith('salary'))
      title = 'Salary Payment';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${DateFormat.yMMMd().format(date)} • ${status.toUpperCase()}',
        style: TextStyle(
          color: status == 'pending' ? Colors.orange : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${isPositive ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isPositive
              ? Colors.green
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
