import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

void showWorkerTasksSheet(BuildContext context, {required String landId}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2D231E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _WorkerTasksSheetContent(
            landId: landId,
            scrollController: controller,
          ),
        );
      },
    ),
  );
}

class _WorkerTasksSheetContent extends StatefulWidget {
  final String landId;
  final ScrollController scrollController;

  const _WorkerTasksSheetContent({
    Key? key,
    required this.landId,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<_WorkerTasksSheetContent> createState() => _WorkerTasksSheetContentState();
}

class _WorkerTasksSheetContentState extends State<_WorkerTasksSheetContent> {
  bool _isLoading = true;
  List<dynamic> _tasks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyTasks();
  }

  Future<void> _fetchMyTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/tasks/me'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final allTasks = body['data'] ?? [];
            // Filter tasks to only include the ones on this specific land!
            _tasks = allTasks.where((t) => t['land_id'] == widget.landId).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching your tasks';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeTask(String taskId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/tasks/$taskId/complete'),
        body: {
          'proof_image_url': 'https://example.com/proof.jpg', // Dummy for now
        },
      );

      Navigator.pop(context); // Close dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed! You are now available.'), backgroundColor: Colors.green),
        );
        _fetchMyTasks(); // Refresh list
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to complete task');
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Tasks on this Land',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.amber))
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                  : _tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade200),
                              const SizedBox(height: 16),
                              const Text('No pending tasks here!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Text('You are available for assignments.', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: widget.scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            final bool isCompleted = task['status'] == 'completed' || task['status'] == 'verified';
                            
                            return Card(
                              color: Colors.white.withOpacity(0.05),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          task['title'] ?? 'Task',
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: isCompleted ? Colors.greenAccent : Colors.amberAccent),
                                          ),
                                          child: Text(
                                            task['status']?.toUpperCase() ?? 'UNKNOWN',
                                            style: TextStyle(color: isCompleted ? Colors.greenAccent : Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (task['description'] != null)
                                      Text(task['description'], style: const TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.monetization_on, size: 16, color: Colors.green.shade400),
                                            const SizedBox(width: 4),
                                            Text('${task['reward'] ?? 0} HBAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.schedule, size: 16, color: Colors.blue.shade400),
                                            const SizedBox(width: 4),
                                            Text('${task['time_required_minutes'] ?? 0} mins', style: const TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (!isCompleted) ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _completeTask(task['id']),
                                          icon: const Icon(Icons.done_all, color: Colors.black),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                          label: const Text('Mark as Complete', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
