import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import '../providers/game_provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

// Static helper to show the sheet properly
void showTaskAssignmentSheet(
  BuildContext context, {
  required dynamic itemData,
  required String category,
  required String variantId,
  required int gridWidth,
  required int gridHeight,
  required String landId,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (ctx) => _TaskAssignmentSheetContent(
      itemData: itemData,
      category: category,
      variantId: variantId,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      landId: landId,
    ),
  );
}

class TaskAssignmentSheet extends StatelessWidget {
  final dynamic itemData;
  final String category;
  final String variantId;
  final int gridWidth;
  final int gridHeight;
  final String landId;

  const TaskAssignmentSheet({
    Key? key,
    required this.itemData,
    required this.category,
    required this.variantId,
    required this.gridWidth,
    required this.gridHeight,
    required this.landId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _TaskAssignmentSheetContent(
      itemData: itemData,
      category: category,
      variantId: variantId,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      landId: landId,
    );
  }
}

class _TaskAssignmentSheetContent extends StatefulWidget {
  final dynamic itemData;
  final String category;
  final String variantId;
  final int gridWidth;
  final int gridHeight;
  final String landId;

  const _TaskAssignmentSheetContent({
    required this.itemData,
    required this.category,
    required this.variantId,
    required this.gridWidth,
    required this.gridHeight,
    required this.landId,
  });

  @override
  State<_TaskAssignmentSheetContent> createState() => _TaskAssignmentSheetContentState();
}

class _TaskAssignmentSheetContentState extends State<_TaskAssignmentSheetContent> {
  bool _isLoading = true;
  List<dynamic> _tasks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/asset-tasks/variant/${widget.variantId}'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _tasks = body['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching tasks: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _assignTask(dynamic taskDef, GameProvider gameProvider) async {
    int fw = widget.itemData['footprint_width'] ?? 1;
    int fh = widget.itemData['footprint_height'] ?? 1;
    int ox = widget.itemData['origin_x'] ?? 0;
    int oy = widget.itemData['origin_y'] ?? 0;
    double targetX = ox + (fw - 1) / 2.0;
    double targetY = oy + (fh - 1) / 2.0;

    final String? workerId = gameProvider.getClosestAvailableWorkerId(targetX, targetY);

    if (workerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noAvailableWorkers), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final landId = widget.landId;  // Use the explicitly passed landId
      final placedItemId = widget.itemData['id'] ?? '';

      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/tasks/lands/$landId/tasks'),
        body: {
          'title': taskDef['description'] ?? 'Task',
          'description': taskDef['description'],
          'type': taskDef['action'],
          'reward': taskDef['reward'],
          'time_required_minutes': taskDef['time_required_minutes'],
          'placed_item_id': placedItemId,
          'asset_task_id': taskDef['id'],
          'assigned_to': workerId,
        },
      );

      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark the specific assigned worker as busy immediately
        gameProvider.setWorkerBusy(workerId);

        // Walk THAT specific worker to the task location (not the closest arbitrary one)
        gameProvider.moveWorkerById(
          workerId,
          targetX,
          targetY,
          gridWidth: widget.gridWidth,
          gridHeight: widget.gridHeight,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.taskAssigned), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to assign task');
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTaskRow(dynamic task, int availableCount, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _translateAction(context, task['action'] as String? ?? 'task').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  task['description'] as String? ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: ElevatedButton(
              onPressed: availableCount > 0
                  ? () => _assignTask(task, gameProvider)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(AppLocalizations.of(context)!.assignButton, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final availableCount = gameProvider.workers.where((w) => w.availability == 'available').length;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.assignTaskTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: availableCount > 0
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.workersAvailable(availableCount.toString()),
                        style: TextStyle(
                          color: availableCount > 0 ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Content
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  )
                else if (_tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(AppLocalizations.of(context)!.noTasksDefined)),
                  )
                else
                  // Use a simple Column for the tasks list, no ListView scrolling issues
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final task in _tasks)
                        _buildTaskRow(task, availableCount, gameProvider),
                    ],
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _translateAction(BuildContext context, String action) {
    final l10n = AppLocalizations.of(context)!;
    switch (action.toLowerCase()) {
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
        return action;
    }
  }
}
