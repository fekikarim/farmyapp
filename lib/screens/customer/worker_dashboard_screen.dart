import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../models/task_model.dart';
import '../../models/land_worker_model.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkerProvider>();
      provider.loadMyProfile();
      provider.loadAssignedLands();
      provider.loadMyTasks();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = workerProvider.myProfile;
    final lands = workerProvider.assignedLands;
    final tasks = workerProvider.myTasks;

    final isLoading =
        workerProvider.profileLoading ||
        workerProvider.assignedLandsLoading ||
        workerProvider.myTasksLoading;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: () async {
                  await workerProvider.loadMyProfile();
                  await workerProvider.loadAssignedLands();
                  await workerProvider.loadMyTasks();
                },
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Profile Status Card
                    if (profile != null) _buildProfileCard(profile, isDark),
                    const SizedBox(height: 20),

                    // Quick Stats
                    Row(
                      children: [
                        _statWidget(
                          'Assigned Lands',
                          '${lands.length}',
                          Icons.landscape,
                          Colors.green,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _statWidget(
                          'Active Tasks',
                          '${tasks.where((t) => t.isAssigned || t.isInProgress).length}',
                          Icons.task,
                          Colors.blue,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _statWidget(
                          'Earnings',
                          '${lands.fold<double>(0, (sum, l) => sum + l.salary).toStringAsFixed(0)} TND',
                          Icons.payments,
                          Colors.purple,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _statWidget(
                          'Performance',
                          '${profile?.rating.toStringAsFixed(1) ?? '0.0'}',
                          Icons.star,
                          Colors.amber,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _statWidget(
                          'Completed',
                          '${profile?.completedTasks ?? 0}',
                          Icons.check_circle,
                          Colors.teal,
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        _statWidget(
                          'On-time',
                          '${profile?.onTimeRate.toStringAsFixed(0) ?? '0'}%',
                          Icons.timer,
                          Colors.orange,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Assigned Lands
                    _sectionHeader('Assigned Lands', Icons.landscape, isDark),
                    const SizedBox(height: 12),
                    if (lands.isEmpty)
                      _emptyState(
                        'No land assignments yet',
                        'You\'ll see your assigned lands here',
                        Icons.landscape_outlined,
                      )
                    else
                      ...lands.map((land) => _buildLandCard(land, isDark)),
                    const SizedBox(height: 24),

                    // Active Tasks
                    _sectionHeader('Active Tasks', Icons.task, isDark),
                    const SizedBox(height: 12),
                    if (tasks.isEmpty)
                      _emptyState(
                        'No tasks assigned',
                        'Tasks will appear here when assigned',
                        Icons.task_outlined,
                      )
                    else
                      ...tasks
                          .take(5)
                          .map((task) => _buildTaskCard(task, isDark)),
                    const SizedBox(height: 24),

                    // Notifications Placeholder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.blue.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: isDark
                                ? Colors.blue.shade400
                                : Colors.blue.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.blue.shade200
                                        : Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  'Real-time task notifications coming soon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.blue.shade100
                                        : Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.amber.withOpacity(0.15)
                                  : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.amber.shade300
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(dynamic profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981), // Emerald 500
            const Color(0xFF059669), // Emerald 600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: profile.userProfilePicture != null
                  ? NetworkImage(profile.userProfilePicture!)
                  : null,
              child: profile.userProfilePicture == null
                  ? const Icon(Icons.person, color: Colors.white, size: 32)
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.userName ?? 'Worker',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (profile.isVerified)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF059669),
                          size: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: profile.isVerified
                        ? Colors.white.withOpacity(0.2)
                        : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profile.isVerified
                            ? Icons.verified_user_outlined
                            : Icons.pending_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile.isVerified
                            ? 'Verified Worker'
                            : 'Pending Verification',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statWidget(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLandCard(LandWorker land, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.landscape, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  land.landName ?? 'Land',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      land.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.blue.shade300
                            : Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${land.salary.toStringAsFixed(0)} TND/mo',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: land.isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(FarmTask task, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(task.typeIcon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      task.typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '⏱ ${task.timeRequiredMinutes}min',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '💰 ${task.reward.toStringAsFixed(0)} TND',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.green.shade400
                            : Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? (isDark
                        ? Colors.green.withOpacity(0.15)
                        : Colors.green.shade50)
                  : (task.isAssigned
                        ? (isDark
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.blue.shade50)
                        : (isDark
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.grey.shade100)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: task.isCompleted
                    ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                    : (task.isAssigned
                          ? (isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700)
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
