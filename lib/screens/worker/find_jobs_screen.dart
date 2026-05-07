import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/job_request_provider.dart';
import '../../providers/job_application_provider.dart';
import '../../models/job_request_model.dart';
import 'components/job_card.dart';
import 'my_applications_screen.dart';
import 'components/job_filter_modal.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobRequestProvider>().fetchRecommendedJobs();
      context.read<JobRequestProvider>().fetchAllJobs();
      context.read<JobApplicationProvider>().fetchMyApplications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobRequestProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAdvancedHeader(context, isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEnhancedJobsList(jobProvider.allJobs, jobProvider.isLoading, jobProvider.error),
                  _buildEnhancedJobsList(jobProvider.recommendedJobs, jobProvider.isLoading, jobProvider.error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.findJobs,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Opportunities tailored for you',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildMyApplicationsButton(context, isDark),
                  const SizedBox(width: 12),
                  _buildModernFilterButton(isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          // Advanced Tab Bar (Glassmorphic)
          Container(
            height: 56,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.white24),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.allJobs),
                Tab(text: AppLocalizations.of(context)!.recommendedJobs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterButton(bool isDark) {
    final hasFilters = _currentFilters.values.any((v) => v != null);

    return Container(
      decoration: BoxDecoration(
        color: hasFilters ? Colors.orange : Colors.green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (hasFilters ? Colors.orange : Colors.green).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showFilterModal,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobFilterModal(initialFilters: _currentFilters),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
      });
      if (mounted) {
        context.read<JobRequestProvider>().fetchAllJobs(filters: _currentFilters);
      }
    }
  }

  Widget _buildMyApplicationsButton(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApplicationsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.description_outlined, color: Colors.green, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedJobsList(List<JobRequest> jobs, bool isLoading, String? error) {
    if (isLoading && jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.green, strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Scanning for opportunities...',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (error != null && jobs.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      );
    }

    if (jobs.isEmpty) {
      final hasFilters = _currentFilters.values.any((v) => v != null);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No jobs match your filters' : AppLocalizations.of(context)!.noJobsFound,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade500),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentFilters = {};
                  });
                  context.read<JobRequestProvider>().fetchAllJobs();
                },
                icon: const Icon(Icons.filter_list_off, color: Colors.green),
                label: const Text('Clear Filters', style: TextStyle(color: Colors.green)),
              ),
            ],
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: RefreshIndicator(
        color: Colors.green,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async {
          await context.read<JobRequestProvider>().fetchRecommendedJobs();
          await context.read<JobRequestProvider>().fetchAllJobs(filters: _currentFilters);
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
          physics: const BouncingScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: JobCard(job: jobs[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
