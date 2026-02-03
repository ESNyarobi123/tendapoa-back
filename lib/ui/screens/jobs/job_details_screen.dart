import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';
import '../../widgets/widgets.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job? job;
  final int? jobId;

  const JobDetailsScreen({super.key, this.job, this.jobId})
      : assert(job != null || jobId != null);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  Job? _job;
  bool _isLoading = false;
  bool _isInitialLoading = false;
  final JobService _jobService = JobService();
  final TextEditingController _applicationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _job = widget.job;
      _refreshJobDetails();
    } else if (widget.jobId != null) {
      _loadJobById(widget.jobId!);
    }
  }

  Future<void> _loadJobById(int id) async {
    setState(() => _isInitialLoading = true);
    try {
      final job = await _jobService.getJobDetails(id);
      if (mounted) {
        setState(() {
          _job = job;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imeshindwa kupata maelezo: $e')),
        );
      }
    }
  }

  Future<void> _refreshJobDetails() async {
    if (_job == null) return;
    try {
      final updatedJob = await _jobService.getJobDetails(_job!.id);
      if (mounted) {
        setState(() {
          _job = updatedJob;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing job: $e');
    }
  }

  Future<void> _applyForJob() async {
    if (_applicationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tafadhali andika ujumbe')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _jobService.applyForJob(_job!.id, _applicationController.text);
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maombi yako yametumwa!')));
        _refreshJobDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Imeshindikana: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptWorker(int commentId) async {
    setState(() => _isLoading = true);
    try {
      final updatedJob = await _jobService.selectWorker(_job!.id, commentId);
      if (mounted) {
        setState(() {
          _job = updatedJob;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mfanyakazi ameteuliwa!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Imeshindikana: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showApplicationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            left: 25,
            right: 25,
            top: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35), topRight: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            const Text('Omba Kazi Hii',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            Text(
                'Mteja ataona ujumbe wako na wasifu wako ili kuweza kukuchagua.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: TextField(
                controller: _applicationController,
                decoration: const InputDecoration(
                  hintText: 'Andika maelezo ya kwanini wewe ni bora kwake...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyForJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  _isLoading ? 'INATUMA...' : 'TUMA MAOMBI SASA',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading || _job == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final job = _job!;
    final currentUser = context.watch<AuthProvider>().user;
    final isOwner = currentUser?.id == job.userId;
    final isWorker = currentUser?.role == 'worker';
    final hasWorkerAssigned = job.workerId != null;
    final statusColor = _getStatusColor(job.status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. IMMERSIVE HEADER
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  job.imageUrl != null
                      ? Image.network(job.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.construction_rounded,
                              size: 100, color: Colors.white24),
                        ),
                  // Dark Mesh Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0, 0.4, 1],
                        ),
                      ),
                    ),
                  ),
                  // Title & Status in the header area
                  Positioned(
                    bottom: 60,
                    left: 25,
                    right: 25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            job.status.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(height: 15),
                        Text(
                          job.title,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -0.5),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CONTENT AREA
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
              ),
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DAU LA KAZI',
                              style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            'TZS ${job.price}',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      _buildMetaTag(
                          Icons.category_rounded, job.categoryName ?? 'Huduma'),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // Specific Status Message for Workers
                  if (hasWorkerAssigned) _buildAssignedWorkerCard(job, isOwner),

                  // CLIENT CARD
                  _buildProfileCard(job, isOwner),

                  const SizedBox(height: 40),

                  const Text('Maelezo ya Kazi',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 15),
                  Text(
                    job.description ?? 'Hakuna maelezo ya ziada.',
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF475569), height: 1.7),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 35),

                  // LOCATION
                  const Text('Mahali / Eneo',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15)),
                          child: const Icon(Icons.map_rounded,
                              color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            job.addressText ?? 'Eneo la kazi halikujulikana',
                            style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // APPLICATIONS (For Client View)
                  if (isOwner && !hasWorkerAssigned) _buildAppsSection(job),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _buildBottomBar(isWorker, isOwner, hasWorkerAssigned),
    );
  }

  Widget _buildMetaTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAssignedWorkerCard(Job job, bool isOwner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(bottom: 35),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Color(0xFF22C55E), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              const Text('FUNDI AMESHATEULIWA',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Text(job.workerName?[0] ?? 'W',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.workerName ?? 'Fundi Specialist',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const Text('Mafundi wa Tendapoa',
                        style: TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          if (isOwner && job.completionCode != null) ...[
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: Column(
                children: [
                  const Text('VERIFICATION CODE',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(job.completionCode!,
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileCard(Job job, bool isOwner) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage: job.userPhotoUrl != null
                ? NetworkImage(job.userPhotoUrl!)
                : null,
            child: job.userPhotoUrl == null
                ? Text(
                    job.userName?.isNotEmpty == true ? job.userName![0] : 'U',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22))
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.userName ?? 'Mteja Tendapoa',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1E293B))),
                const Text('Mteja Aliyethibitishwa',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (!isOwner) ...[
            _buildAction(Icons.chat_bubble_rounded, AppColors.primary, () {
              Navigator.pushNamed(context, AppRouter.chatRoom,
                  arguments: ChatConversation(
                      job: job,
                      otherUser: ChatUser(
                          id: job.userId ?? 0,
                          name: job.userName ?? 'Mteja',
                          profilePhotoUrl: job.userPhotoUrl,
                          phone: job.phone)));
            }),
            const SizedBox(width: 10),
            if (job.phone != null)
              _buildAction(Icons.call_rounded, const Color(0xFF22C55E),
                  () => _makePhoneCall(job.phone!)),
          ],
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, Color color, VoidCallback onTap) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildAppsSection(Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Maombi ya Kazi (${job.comments?.length ?? 0})',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 25),
        if (job.comments == null || job.comments!.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.hourglass_empty_rounded,
                    size: 60, color: Colors.blue[50]),
                const SizedBox(height: 15),
                const Text('Bado hakuna mafundi walioomba.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
            ),
          )
        else
          ...job.comments!.map((comment) => _buildAppItem(comment)),
      ],
    );
  }

  Widget _buildAppItem(JobComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(comment.userName?[0] ?? 'W',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.userName ?? 'Fundi',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    Text(
                        timeago.format(comment.createdAt ?? DateTime.now(),
                            locale: 'sw'),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(comment.message,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF475569), height: 1.6)),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _acceptWorker(comment.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('MTEUE FUNDI HUYU',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget? _buildBottomBar(bool isWorker, bool isOwner, bool hasWorkerAssigned) {
    if (isWorker && !hasWorkerAssigned && !isOwner) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, -10))
          ],
        ),
        child: ElevatedButton(
          onPressed: _showApplicationDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded),
              SizedBox(width: 10),
              Text('OMBA KAZI HII SASA',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1)),
            ],
          ),
        ),
      );
    }
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF22C55E);
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF97316);
    }
  }
}
