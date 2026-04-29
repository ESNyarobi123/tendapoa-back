import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

class WorkerActiveJobScreen extends StatefulWidget {
  const WorkerActiveJobScreen({super.key, this.initialJob});

  final Job? initialJob;

  @override
  State<WorkerActiveJobScreen> createState() => _WorkerActiveJobScreenState();
}

class _WorkerActiveJobScreenState extends State<WorkerActiveJobScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final JobService _jobService = JobService();
  bool _isLoading = false;
  Job? _job;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncJob());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncJob() {
    final w = context.read<WorkerProvider>();
    final id = widget.initialJob?.id ?? _job?.id;
    Job? resolved = widget.initialJob ?? _job;
    if (id != null) {
      resolved = w.findWorkerJobById(id) ?? resolved;
    }
    resolved ??= w.activeJobsFromAssigned.isNotEmpty
        ? w.activeJobsFromAssigned.first
        : w.currentActiveJob;
    if (mounted) setState(() => _job = resolved);
  }

  Future<void> _acceptFunded() async {
    final job = _job;
    if (job == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _jobService.workerAcceptFundedJob(job.id);
      if (!mounted) return;
      await context.read<WorkerProvider>().loadAssignedJobs();
      if (!mounted) return;
      await context.read<WorkerProvider>().loadDashboard();
      if (!mounted) return;
      setState(() => _job = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('job_accepted_success'))),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _declineFunded() async {
    final job = _job;
    if (job == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('decline_btn')),
        content: const Text(
          'Malipo ya escrow yatarudi kwa mteja na kazi itafunguliwa tena.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('no').toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('decline_btn').toUpperCase()),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await _jobService.workerDeclineFundedJob(job.id);
      if (!mounted) return;
      await context.read<WorkerProvider>().loadAssignedJobs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Umekataa kazi.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitCompletion() async {
    final job = _job;
    if (job == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _jobService.workerSubmitCompletion(
        job.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim(),
      );
      if (!mounted) return;
      await context.read<WorkerProvider>().loadAssignedJobs();
      if (!mounted) return;
      await context.read<WorkerProvider>().loadDashboard();
      if (!mounted) return;
      setState(() => _job = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kazi imewasilishwa. Subiri mteja athibitishe.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _legacyCompleteWithCode() async {
    final job = _job;
    if (job == null) return;
    if (_codeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('enter_code_error'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _jobService.completeJob(job.id, _codeController.text.trim());
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
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
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
    context.watch<WorkerProvider>();
    final job = _job;

    if (job == null) {
      final cs = Theme.of(context).colorScheme;
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(
            context.tr('active_job_title'),
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: cs.surface,
          foregroundColor: cs.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: cs.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.walletAccent.withValues(
                      alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_history_rounded,
                  size: 50,
                  color: AppColors.walletAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('no_active_job_msg'),
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final status = job.status;
    final isFunded = job.isFunded;
    final isInProgress = status == 'in_progress';
    final isSubmitted = status == 'submitted';
    final isLegacyConfirm = status == 'ready_for_confirmation';

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFF97316),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
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
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          job.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TZS ${NumberFormat('#,###').format(job.price)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('client_label'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.tpCardElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: context.tpShadowSoft,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: cs.primaryContainer,
                            child: Text(
                              job.userName?.isNotEmpty == true
                                  ? job.userName![0]
                                  : 'M',
                              style: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.userName ?? context.tr('client_label'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: cs.onSurface,
                                  ),
                                ),
                                Text(
                                  job.addressText ?? context.tr('no_location'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _iconAction(Icons.message_rounded, AppColors.primary,
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.chatRoom,
                              arguments: {
                                'conversation': ChatConversation(
                                  job: job,
                                  otherUser: ChatUser(
                                    id: job.userId ?? 0,
                                    name: job.userName ?? 'Mteja',
                                    phone: job.phone,
                                  ),
                                ),
                              },
                            );
                          }),
                          if (job.phone != null) ...[
                            const SizedBox(width: 8),
                            _iconAction(
                              Icons.phone_rounded,
                              const Color(0xFF22C55E),
                              () => _makePhoneCall(job.phone!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (isFunded) ...[
                      Text(
                        'Mteja amelipa escrow. Kubali kuanza kazi, au kataa kurudisha malipo.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _declineFunded,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(context.tr('decline_btn')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _acceptFunded,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Kubali kazi'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (isInProgress) ...[
                      Text(
                        'Wasilisha kazi ukiisha. Unaweza kuongeza maelezo; code ni hiari ikiwa ipo.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Maelezo (hiari)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Code ya ukamilishaji (hiari)',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submitCompletion,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Wasilisha kazi imekamilika',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ] else if (isSubmitted) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top_rounded,
                                color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Umewasilisha kazi. Subiri mteja athibitishe malipo ya escrow.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isLegacyConfirm) ...[
                      Text(
                        context.tr('give_code_instruction'),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _legacyCompleteWithCode,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(context.tr('complete_job_title')),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Hali: $status. Fungua maelezo ya kazi au wasiliana na mteja.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
