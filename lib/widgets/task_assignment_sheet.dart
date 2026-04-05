import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import '../providers/game_provider.dart';

class TaskAssignmentSheet extends StatefulWidget {
  final dynamic itemData;
  final String category;
  final String variantId;
  final int gridWidth;
  final int gridHeight;

  const TaskAssignmentSheet({
    Key? key,
    required this.itemData,
    required this.category,
    required this.variantId,
    required this.gridWidth,
    required this.gridHeight,
  }) : super(key: key);

  @override
  State<TaskAssignmentSheet> createState() => _TaskAssignmentSheetState();
}

class _TaskAssignmentSheetState extends State<TaskAssignmentSheet> {
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
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching tasks';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _assignTask(dynamic taskDef, GameProvider gameProvider) async {
    // Determine closest worker
    int fw = widget.itemData['footprint_width'] ?? 1;
    int fh = widget.itemData['footprint_height'] ?? 1;
    int ox = widget.itemData['origin_x'] ?? 0;
    int oy = widget.itemData['origin_y'] ?? 0;
    double targetX = ox + (fw - 1) / 2.0;
    double targetY = oy + (fh - 1) / 2.0;

    String? workerId = gameProvider.getClosestAvailableWorkerId(targetX, targetY);
    
    if (workerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available workers found!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final landId = widget.itemData['land_id'] ?? '';
      final placedItemId = widget.itemData['id'] ?? '';

      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/tasks/lands/$landId/tasks'), // Check task route later
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

      Navigator.pop(context); // Close dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Move worker visually
        gameProvider.moveClosestWorkerTo(
          targetX,
          targetY,
          gridWidth: widget.gridWidth,
          gridHeight: widget.gridHeight,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task assigned to closest worker!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close sheet
      } else {
        final body = jsonDecode(response.body);
        print('Backend error: $body');
        throw Exception(body['message'] ?? 'Failed to assign');
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final availableCount = gameProvider.workers.where((w) => w.availability == 'available').length;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assign Task',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: availableCount > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$availableCount Available Workers',
                  style: TextStyle(
                    color: availableCount > 0 ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ))
          else if (_error != null)
            Center(child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ))
          else if (_tasks.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No tasks available for this item.'),
            ))
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _tasks.length,
                separatorBuilder: (ctx, idx) => const Divider(),
                itemBuilder: (ctx, idx) {
                  final task = _tasks[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task['action']?.toUpperCase() ?? 'TASK', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(task['description'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: availableCount > 0 ? () => _assignTask(task, gameProvider) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Assign'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
