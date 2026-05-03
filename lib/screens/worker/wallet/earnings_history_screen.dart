import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/worker_wallet_provider.dart';
import 'package:intl/intl.dart';

class EarningsHistoryScreen extends StatefulWidget {
  const EarningsHistoryScreen({Key? key}) : super(key: key);

  @override
  _EarningsHistoryScreenState createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends State<EarningsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    await context.read<WorkerWalletProvider>().fetchTaskEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Task Earnings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<WorkerWalletProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingTransactions) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.earningsError != null) {
            return _buildFeedbackState(
              icon: Icons.cloud_off_rounded,
              title: 'Unable to sync earnings',
              message: provider.earningsError!,
              onRetry: _fetchData,
            );
          }

          if (provider.taskEarnings.isEmpty) {
            return _buildFeedbackState(
              icon: Icons.insights_outlined,
              title: 'No task earnings yet',
              message: 'Verified task rewards will appear here automatically.',
              onRetry: _fetchData,
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchData,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.taskEarnings.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey.withValues(alpha: 0.2)),
              itemBuilder: (context, index) {
                final tx = provider.taskEarnings[index] as Map<String, dynamic>;
                final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
                final date =
                    DateTime.tryParse(tx['createdAt'] ?? '') ?? DateTime.now();
                final metadata = tx['metadata'] is Map
                    ? tx['metadata'] as Map
                    : const {};
                final taskId =
                    metadata['task_id']?.toString() ?? 'Unknown Task';
                final shortTaskId = taskId.length > 8
                    ? '${taskId.substring(0, 8)}...'
                    : taskId;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  title: Text(
                    'Verified Task',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Task ID: $shortTaskId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().add_jm().format(date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '+\$${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
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
}
