import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';

class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({Key? key}) : super(key: key);

  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen> {
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
            _tasks = body['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(AppLocalizations.of(context)!.failedLoadTasks);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.errorFetchingTasks;
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
          SnackBar(content: Text(AppLocalizations.of(context)!.taskCompletedSuccess), backgroundColor: Colors.green),
        );
        _fetchMyTasks(); // Refresh list
      } else {
        throw Exception(AppLocalizations.of(context)!.failedCompleteTask);
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithPrefix(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myTasksTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMyTasks,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade200),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.noPendingTasks, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(AppLocalizations.of(context)!.availableForAssignments, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMyTasks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          final bool isCompleted = task['status'] == 'completed' || task['status'] == 'verified';
                          
                          return Card(
                            elevation: 2,
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
                                        task['title'] ?? AppLocalizations.of(context)!.taskLabel,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Chip(
                                        label: Text(
                                          task['status']?.toUpperCase() ?? AppLocalizations.of(context)!.unknownCaps,
                                          style: TextStyle(color: isCompleted ? Colors.green.shade700 : Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        backgroundColor: isCompleted ? Colors.green.shade50 : Colors.amber.shade50,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (task['description'] != null)
                                    Text(task['description'], style: TextStyle(color: Colors.grey.shade700)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.monetization_on, size: 16, color: Colors.green.shade600),
                                      const SizedBox(width: 4),
                                      Text('${task['reward'] ?? 0} HBAR', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 16),
                                      Icon(Icons.schedule, size: 16, color: Colors.blue.shade600),
                                      const SizedBox(width: 4),
                                      Text('${task['time_required_minutes'] ?? 0} ${AppLocalizations.of(context)!.minsSuffix}'),
                                    ],
                                  ),
                                  if (!isCompleted) ...[
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _completeTask(task['id']),
                                        icon: const Icon(Icons.done_all),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        label: Text(AppLocalizations.of(context)!.markAsComplete),
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
    );
  }
}
