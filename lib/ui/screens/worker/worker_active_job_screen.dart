import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

class WorkerActiveJobScreen extends StatefulWidget {
  const WorkerActiveJobScreen({super.key});

  @override
  State<WorkerActiveJobScreen> createState() => _WorkerActiveJobScreenState();
}

class _WorkerActiveJobScreenState extends State<WorkerActiveJobScreen> {
  final TextEditingController _codeController = TextEditingController();
  final JobService _jobService = JobService();
  bool _isLoading = false;

  Future<void> _completeJob(int jobId) async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('enter_code_error'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _jobService.completeJob(jobId, _codeController.text);
      if (!mounted) return;

      await context.read<WorkerProvider>().refreshAll();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('job_completed_success'))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Hitilafu: $e'), backgroundColor: AppColors.error),
        );
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

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final job = workerProvider.currentActiveJob;

    if (job == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.tr('active_job_title'),
              style:
                  const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                child: const Icon(Icons.work_history_rounded,
                    size: 50, color: Color(0xFFF97316)),
              ),
              const SizedBox(height: 20),
              Text(context.tr('no_active_job_msg'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // PREMIUM ORANGE HEADER
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFF97316),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black12,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('KAZI INAYOENDELEA',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(job.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 10),
                    Text('TZS ${job.price}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
              ),
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CLIENT CARD
                  const Text('Mteja Wako',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: Text(
                              job.userName?.isNotEmpty == true
                                  ? job.userName![0]
                                  : 'U',
                              style: const TextStyle(
                                  color: Color(0xFFEA580C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.userName ?? context.tr('client_label'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: AppColors.textPrimary)),
                              Text(job.addressText ?? context.tr('no_location'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        _buildAction(Icons.message_rounded, AppColors.primary,
                            () {
                          Navigator.pushNamed(context, AppRouter.chatRoom,
                              arguments: ChatConversation(
                                  job: job,
                                  otherUser: ChatUser(
                                      id: job.userId ?? 0,
                                      name: job.userName ?? 'Mteja',
                                      phone: job.phone)));
                        }),
                        const SizedBox(width: 10),
                        if (job.phone != null)
                          _buildAction(
                              Icons.phone_rounded,
                              const Color(0xFF22C55E),
                              () => _makePhoneCall(job.phone!)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // PROGRESS SECTION
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFFF97316), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('give_code_instruction'),
                          style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // COMPLETION FORM
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(context.tr('complete_job_title'),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        Text(context.tr('enter_completion_code_title'),
                            style: const TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 14)),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              counterText: "",
                              hintText: '0000',
                              hintStyle: TextStyle(
                                  color: Color(0xFFE2E8F0), letterSpacing: 10),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _completeJob(job.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('THIBITISHA UKAMILISHAJI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
