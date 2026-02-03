import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../widgets/widgets.dart';

class WorkerJobsScreen extends StatefulWidget {
  const WorkerJobsScreen({super.key});

  @override
  State<WorkerJobsScreen> createState() => _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends State<WorkerJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JobService _jobService = JobService();
  bool _isLoading = true;
  List<Job> _allJobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await _jobService.getAssignedJobs();
      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('myJobs')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.tr('applications_tab')),
            Tab(text: context.tr('active_tab')),
            Tab(text: context.tr('completed_tab')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJobList(_getJobsByStatus([AppConstants.statusPending])),
                _buildJobList(_getJobsByStatus([AppConstants.statusAccepted])),
                _buildJobList(_getJobsByStatus([
                  AppConstants.statusCompleted,
                  AppConstants.statusCancelled
                ])),
              ],
            ),
    );
  }

  List<Job> _getJobsByStatus(List<String> statuses) {
    return _allJobs.where((j) => statuses.contains(j.status)).toList();
  }

  Widget _buildJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off_outlined, size: 60, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(context.tr('no_jobs_here'),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => JobCard(
        job: jobs[i],
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.jobDetails,
          arguments: {'job': jobs[i]},
        ),
      ),
    );
  }
}
