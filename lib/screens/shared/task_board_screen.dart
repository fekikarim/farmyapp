import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/subscription_limit_bar.dart';
import '../../models/task_model.dart';

class TaskBoardScreen extends StatefulWidget {
  final String landId;
  final String landName;

  const TaskBoardScreen({
    super.key,
    required this.landId,
    required this.landName,
  });

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedType = 'maintenance';
  double _reward = 0;
  int _timeMinutes = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadLandTasks(widget.landId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showCreateTaskSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setSheetState) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create New Task',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'e.g. Water the tomato field',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1C2333)
                          : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1C2333)
                          : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Task Type
                  const Text(
                    'Task Type',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _typeChip('💧', 'water', setSheetState),
                      _typeChip('🌾', 'harvest', setSheetState),
                      _typeChip('🐄', 'feed', setSheetState),
                      _typeChip('🏗️', 'install', setSheetState),
                      _typeChip('✅', 'verify', setSheetState),
                      _typeChip('🔧', 'maintenance', setSheetState),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Reward
                  Row(
                    children: [
                      const Text(
                        'Reward:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Slider(
                          value: _reward,
                          min: 0,
                          max: 200,
                          divisions: 20,
                          label: '${_reward.toInt()} TND',
                          activeColor: Colors.green.shade600,
                          onChanged: (val) =>
                              setSheetState(() => _reward = val),
                        ),
                      ),
                      Text(
                        '${_reward.toInt()} TND',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  // Time
                  Row(
                    children: [
                      const Text(
                        'Time:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Slider(
                          value: _timeMinutes.toDouble(),
                          min: 5,
                          max: 180,
                          divisions: 35,
                          label: '$_timeMinutes min',
                          activeColor: Colors.blue.shade600,
                          onChanged: (val) =>
                              setSheetState(() => _timeMinutes = val.toInt()),
                        ),
                      ),
                      Text(
                        '$_timeMinutes min',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _createTask(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Create Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _typeChip(String emoji, String type, StateSetter setSheetState) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () => setSheetState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.green.shade400 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$emoji ${type[0].toUpperCase()}${type.substring(1)}',
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.green.shade800 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Future<void> _createTask(BuildContext sheetContext) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = context.read<WorkerProvider>();
    final success = await provider.createTask(
      landId: widget.landId,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      type: _selectedType,
      reward: _reward,
      timeRequiredMinutes: _timeMinutes,
    );

    if (mounted) {
      Navigator.pop(sheetContext);
      if (success) {
        _titleController.clear();
        _descController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task created! 🎯'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    }
  }

  List<FarmTask> _filteredTasks(List<FarmTask> all, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return all;
      case 1:
        return all.where((t) => t.isOpen).toList();
      case 2:
        return all.where((t) => t.isAssigned || t.isInProgress).toList();
      case 3:
        return all.where((t) => t.isCompleted || t.isVerified).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Tasks — ${widget.landName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade600,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: Colors.green.shade600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Open'),
            Tab(text: 'Active'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      floatingActionButton: Consumer<SubscriptionProvider>(
        builder: (context, subProvider, _) {
          final taskCount = workerProvider.tasks
              .where((t) => !t.isCompleted && !t.isVerified)
              .length;
          final isAtLimit = !subProvider.isWithinLimit(
            'task_limit_per_land',
            taskCount,
          );

          return FloatingActionButton(
            heroTag: 'add_task_fab',
            onPressed: isAtLimit
                ? () => _showTaskLimitDialog(subProvider.planName)
                : _showCreateTaskSheet,
            backgroundColor: isAtLimit
                ? Colors.amber.shade700
                : Colors.green.shade600,
            child: Icon(
              isAtLimit ? Icons.lock_outline : Icons.add,
              color: Colors.white,
            ),
          );
        },
      ),
      body: workerProvider.tasksLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(4, (tabIndex) {
                final filtered = _filteredTasks(workerProvider.tasks, tabIndex);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks here',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => workerProvider.loadLandTasks(widget.landId),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length + 1, // +1 for limit bar
                    itemBuilder: (ctx, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SubscriptionLimitBar(
                            limitKey: 'task_limit_per_land',
                            currentCount: workerProvider.tasks
                                .where((t) => !t.isCompleted && !t.isVerified)
                                .length,
                            label: 'Active Tasks Count',
                            icon: Icons.task_alt_rounded,
                            accentColor: Colors.green,
                            upgradePlanName: 'Farmer Pro',
                          ),
                        );
                      }
                      return _buildTaskCard(filtered[i - 1], isDark);
                    },
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildTaskCard(FarmTask task, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2333) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(task.typeIcon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (task.description != null)
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              _statusBadge(task),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _taskInfo(Icons.category, task.typeLabel),
              _taskInfo(Icons.timer, '${task.timeRequiredMinutes} min'),
              _taskInfo(
                Icons.monetization_on,
                '${task.reward.toStringAsFixed(0)} TND',
              ),
            ],
          ),
          if (task.assigneeName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Assigned to: ${task.assigneeName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(FarmTask task) {
    Color bgColor;
    Color textColor;
    if (task.isCompleted || task.isVerified) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (task.isAssigned || task.isInProgress) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        task.statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _taskInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  void _showTaskLimitDialog(String planName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.amber,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Task Limit Reached',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You've reached the active task limit for this land on your $planName plan. Upgrade to Farmer Pro for unlimited tasks!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/subscriptions');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'VIEW PLANS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
