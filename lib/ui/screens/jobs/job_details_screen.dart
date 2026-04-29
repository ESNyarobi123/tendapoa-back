import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

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
          SnackBar(content: Text('${context.tr('failed_fetch_job_details')}: $e')),
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Jibu la API 422 kwenye apply (Kiswahili / Kiingereza).
  bool _isAlreadyAppliedMessage(String message) {
    final m = message.toLowerCase().trim();
    if (m.contains('tayari') && m.contains('omba')) return true;
    if (m.contains('already') &&
        (m.contains('applied') || m.contains('application'))) {
      return true;
    }
    return false;
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
            SnackBar(content: Text(context.tr('worker_selected_success'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${context.tr('error_prefix')}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectApplication(int applicationId) async {
    setState(() => _isLoading = true);
    try {
      final updatedJob =
          await _jobService.selectApplication(_job!.id, applicationId);
      if (mounted) {
        setState(() => _job = updatedJob);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mfanyakazi amechaguliwa. Fanya malipo.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmClientCompletion() async {
    setState(() => _isLoading = true);
    try {
      await _jobService.clientConfirmJob(_job!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kazi imethibitishwa.')),
        );
        await _refreshJobDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _workerAcceptFunded() async {
    setState(() => _isLoading = true);
    try {
      final updated = await _jobService.workerAcceptFundedJob(_job!.id);
      if (mounted) {
        setState(() => _job = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Umekubali kazi. Anza kufanya kazi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _workerDeclineFunded() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kataa kazi?'),
        content: const Text(
          'Malipo ya escrow yatarudi kwa mteja na kazi itafunguliwa tena kwa maombi mapya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kataa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _isLoading = true);
    try {
      await _jobService.workerDeclineFundedJob(_job!.id);
      if (!mounted) return;
      await _refreshJobDetails();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Umekataa kazi. Malipo yamerudi kwa mteja.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showWorkerSubmitSheet() async {
    final notesCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Wasilisha kazi',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ongeza maelezo (si lazima). Nambari ya uthibitisho ikiwa mteja amekupa.',
              style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Maelezo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nambari ya uthibitisho (si lazima)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final errorPrefix = context.tr('error_prefix');
                      setState(() => _isLoading = true);
                      try {
                        final updated = await _jobService.workerSubmitCompletion(
                          _job!.id,
                          notes: notesCtrl.text,
                          code: codeCtrl.text.trim().isEmpty
                              ? null
                              : codeCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        setState(() => _job = updated);
                        if (ctx.mounted) Navigator.pop(ctx);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Kazi imewasilishwa kwa mteja.'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('$errorPrefix: $e'),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              child: const Text('TUMA'),
            ),
          ],
        ),
      ),
    );
    // Usifute controllers mara moja: route ya sheet bado inaweza kuwa kwenye animation;
    // TextField inaweza kujaribu addListener baada ya dispose → exception.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notesCtrl.dispose();
      codeCtrl.dispose();
    });
  }

  /// Fomu ya mfanyakazi kuomba kazi — inalingana na tovuti (sio chaguo 3: swali / ombi / bei).
  Future<void> _showWorkerApplySheet() async {
    final job = _job;
    if (job == null || !job.acceptsNewApplications) return;

    final loc = AppLocalizations.of(context);
    if (loc == null) return;

    final proposedCtrl = TextEditingController(text: '${job.price}');
    final messageCtrl = TextEditingController();
    final etaCtrl = TextEditingController();
    var sheetSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: bottomInset + 24,
          ),
          child: StatefulBuilder(
            builder: (modalContext, setModalState) {
              Future<void> submit() async {
                final raw = proposedCtrl.text.replaceAll(',', '').trim();
                final proposed = int.tryParse(raw) ?? job.price;
                if (proposed < 1000) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('min_amount_error'))),
                  );
                  return;
                }
                final msg = messageCtrl.text.trim();
                if (msg.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.worker_apply_message_label),
                    ),
                  );
                  return;
                }

                setModalState(() => sheetSubmitting = true);
                try {
                  await _jobService.applyToJobApi(
                    job.id,
                    proposedAmount: proposed,
                    message: msg,
                    etaText: etaCtrl.text.trim().isEmpty ? null : etaCtrl.text.trim(),
                  );
                  if (!mounted) return;
                  if (modalContext.mounted) Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('success_application_sent')),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                  await _refreshJobDetails();
                } catch (e) {
                  if (!mounted) return;
                  final ApiException? api = e is ApiException ? e : null;
                  final msg = api?.message ?? e.toString();
                  final alreadyApplied = api != null &&
                      api.statusCode == 422 &&
                      _isAlreadyAppliedMessage(api.message);
                  if (alreadyApplied && modalContext.mounted) {
                    Navigator.pop(modalContext);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        alreadyApplied
                            ? msg
                            : '${context.tr('error_prefix')}: $msg',
                      ),
                      backgroundColor:
                          alreadyApplied ? const Color(0xFFD97706) : Colors.red,
                    ),
                  );
                  if (alreadyApplied) {
                    await _refreshJobDetails();
                  }
                } finally {
                  if (modalContext.mounted) {
                    setModalState(() => sheetSubmitting = false);
                  }
                }
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.worker_apply_title,
                      style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      loc.worker_apply_lead,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          Navigator.pushNamed(
                            context,
                            AppRouter.workerMyApplications,
                          );
                        },
                        icon: Icon(Icons.list_alt_rounded, color: scheme.primary),
                        label: Text(loc.worker_apply_my_applications),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.worker_apply_budget_label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: proposedCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: scheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        loc.worker_apply_client_budget(_formatNumber(job.price)),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.worker_apply_message_label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: messageCtrl,
                      maxLines: 4,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        hintText: context.tr('why_choose_you_hint'),
                        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.worker_apply_eta_label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: etaCtrl,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        hintText: loc.worker_apply_eta_hint,
                        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: sheetSubmitting ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: sheetSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              loc.worker_apply_submit,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      proposedCtrl.dispose();
      messageCtrl.dispose();
      etaCtrl.dispose();
    });
  }

  Future<void> _promptClientRevision() async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ombi la marekebisho'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Eleza unachohitaji kurekebishwa…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tuma'),
          ),
        ],
      ),
    );
    if (ok != true || reasonCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _jobService.clientRequestRevision(_job!.id, reasonCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ombi limetumwa kwa mfanyakazi.')),
        );
        await _refreshJobDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error_prefix')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _statusDisplay(String status) {
    switch (status) {
      case 'open':
        return 'WAZI';
      case 'posted':
        return 'IMECHAPISHWA';
      case 'awaiting_payment':
        return 'INASUBIRI MALIPO';
      case 'funded':
        return 'IMELIPIWA';
      case 'in_progress':
      case 'assigned':
        return 'INAENDELEA';
      case 'submitted':
      case 'ready_for_confirmation':
        return 'IMEWASILISHWA';
      case 'completed':
        return 'IMEKAMILIKA';
      case 'cancelled':
        return 'IMEGHAIRIWA';
      default:
        return status.toUpperCase().replaceAll('_', ' ');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openFullMap(Job job) {
    if (job.lat == null || job.lng == null) return;
    
    Navigator.pushNamed(
      context,
      AppRouter.map,
      arguments: {
        'jobs': [job],
        'initialLocation': LatLng(job.lat!, job.lng!),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading || _job == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body:
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final job = _job!;
    final cs = Theme.of(context).colorScheme;
    final currentUser = context.watch<AuthProvider>().user;
    final uid = currentUser?.id;
    final isOwner = uid == job.userId;
    final isWorker = currentUser?.isMfanyakazi ?? false;
    final hasWorkerOrSelection = job.hasWorkerOrSelection;
    final statusColor = _getStatusColor(job.status);
    final Widget? nextStepCallout =
        _buildNextStepCallout(context, job, isOwner, isWorker, uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                            _statusDisplay(job.status),
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
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35)),
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bei + kategoria (muktadha kwa muhitaji / mfanyakazi / mgeni)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('job_details').toUpperCase(),
                                style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                            const SizedBox(height: 4),
                            if (job.agreedAmount != null) ...[
                              Text(
                                'TZS ${_formatNumber(job.displayAgreedOrPrice)}',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: cs.onSurface),
                              ),
                              if (job.agreedAmount != job.price)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Bei ya tangazo: TZS ${_formatNumber(job.price)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ] else ...[
                              Text(
                                'TZS ${_formatNumber(job.price)}',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: cs.onSurface),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildMetaTag(
                          context,
                          Icons.category_rounded,
                          job.categoryName ?? context.tr('services_label')),
                    ],
                  ),

                  if (nextStepCallout != null) ...[
                    const SizedBox(height: 20),
                    nextStepCallout,
                  ],

                  const SizedBox(height: 35),

                  // Mfanyakazi aliyechaguliwa / aliyekubaliwa
                  if (hasWorkerOrSelection) _buildAssignedWorkerCard(job, isOwner),

                  // CLIENT CARD
                  _buildProfileCard(job, isOwner),

                  const SizedBox(height: 40),

                  Text(context.tr('job_description_title'),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface)),
                  const SizedBox(height: 15),
                  Text(
                    job.description ?? context.tr('no_desc'),
                    style: TextStyle(
                        fontSize: 16, color: cs.onSurfaceVariant, height: 1.7),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 35),

                  // LOCATION WITH MAP
                  Text(context.tr('location_title'),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface)),
                  const SizedBox(height: 15),
                  
                  // Map Widget showing job location
                  if (job.lat != null && job.lng != null)
                    GestureDetector(
                      onTap: () => _openFullMap(job),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: context.tpShadowSoft,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Stack(
                            children: [
                              // OpenStreetMap
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(job.lat!, job.lng!),
                                  initialZoom: 15,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none, // Disable interaction for preview
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.tendapoa.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(job.lat!, job.lng!),
                                        width: 50,
                                        height: 50,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.surface, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.4),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Gradient overlay at bottom for address text
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          job.addressText ?? context.tr('no_location'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // "Tap to expand" indicator
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHigh
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: cs.outlineVariant
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.open_in_full_rounded,
                                        size: 14,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        context.tr('tap_to_expand'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Fallback to address text only if no coordinates
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.tpMutedFill,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.45)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: cs.primaryContainer
                                    .withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(Icons.map_rounded,
                                color: cs.primary, size: 24),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              job.addressText ?? context.tr('no_location'),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // APPLICATIONS/COMMENTS Section
                  // Show for owner (to select worker) OR for workers (to see all comments including theirs)
                  if (isOwner && !hasWorkerOrSelection)
                    _buildAppsSection(job)
                  else if (isWorker && !isOwner)
                    _buildCommentsSection(job),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _buildBottomBar(isWorker, isOwner, hasWorkerOrSelection),
    );
  }

  Widget _buildMetaTag(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: context.tpMutedFill,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAssignedWorkerCard(Job job, bool isOwner) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final cardBg = isDark
        ? Color.alphaBlend(
            const Color(0xFF22C55E).withValues(alpha: 0.18),
            cs.surfaceContainerHigh,
          )
        : const Color(0xFF0F172A);
    final onCard = isDark ? cs.onSurface : Colors.white;
    final onCardMuted =
        isDark ? cs.onSurfaceVariant : Colors.white.withValues(alpha: 0.65);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(bottom: 35),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.success.withValues(alpha: isDark ? 0.45 : 0.35),
        ),
        boxShadow: [
          BoxShadow(
              color: context.tpShadowSoft,
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
              Text(
                  job.isAwaitingPayment
                      ? 'ALIYECHAGULIWA'
                      : context.tr('assigned_worker').toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: onCard,
                      letterSpacing: 1,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isDark
                    ? cs.primaryContainer.withValues(alpha: 0.5)
                    : Colors.white24,
                backgroundImage: (job.workerPhotoUrl ?? job.selectedWorkerPhotoUrl) !=
                            null &&
                        (job.workerPhotoUrl ?? job.selectedWorkerPhotoUrl)!.isNotEmpty
                    ? NetworkImage(
                        (job.workerPhotoUrl ?? job.selectedWorkerPhotoUrl)!,
                      )
                    : null,
                child: (job.workerPhotoUrl ?? job.selectedWorkerPhotoUrl) == null
                    ? Text(
                        job.effectiveWorkerDisplayName.isNotEmpty
                            ? job.effectiveWorkerDisplayName[0].toUpperCase()
                            : 'W',
                        style: TextStyle(
                            color: isDark ? cs.onPrimaryContainer : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22))
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.effectiveWorkerDisplayName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onCard)),
                    Text(
                      job.isAwaitingPayment
                          ? 'Lipa escrow ili kuanza kazi'
                          : context.tr('appTitle'),
                      style: TextStyle(color: onCardMuted, fontSize: 13),
                    ),
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
                  color: isDark
                      ? cs.surface.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? cs.outlineVariant.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.15))),
              child: Column(
                children: [
                  Text('VERIFICATION CODE',
                      style: TextStyle(
                          color: onCardMuted,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(job.completionCode!,
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          color: onCard)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileCard(Job job, bool isOwner) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.tpCardElevated,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4)),
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
            radius: 30,
            backgroundColor: cs.primaryContainer,
            backgroundImage: job.userPhotoUrl != null
                ? NetworkImage(job.userPhotoUrl!)
                : null,
            child: job.userPhotoUrl == null
                ? Text(
                    job.userName?.isNotEmpty == true ? job.userName![0] : 'U',
                    style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 22))
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.userName ?? context.tr('client_label'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface)),
                Text(context.tr('verified_client'),
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
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
                          name: job.userName ?? context.tr('client_label'),
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
    final cs = Theme.of(context).colorScheme;
    final newApps = job.applications ?? [];
    final legacy = job.comments?.where((c) => c.isApplication).toList() ?? [];
    final count = newApps.isNotEmpty ? newApps.length : legacy.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${context.tr('applications_tab')} ($count)',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 25),
        if (newApps.isNotEmpty)
          ...newApps.map((a) => _buildApplicationItem(job, a))
        else if (legacy.isNotEmpty)
          ...legacy.map((comment) => _buildAppItem(comment))
        else
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.hourglass_empty_rounded,
                    size: 60, color: cs.onSurfaceVariant),
                const SizedBox(height: 15),
                Text(context.tr('no_applications_yet'),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildApplicationItem(Job job, JobApplication app) {
    final cs = Theme.of(context).colorScheme;
    final canSelect = app.canBeSelectedByClient && job.acceptsNewApplications;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: context.tpCardElevated,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
              color: context.tpShadowSoft,
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
                backgroundColor: cs.primaryContainer,
                backgroundImage: app.workerPhotoUrl != null &&
                        app.workerPhotoUrl!.isNotEmpty
                    ? NetworkImage(app.workerPhotoUrl!)
                    : null,
                child: app.workerPhotoUrl == null
                    ? Text(
                        app.workerName?.isNotEmpty == true
                            ? app.workerName![0].toUpperCase()
                            : 'W',
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.workerName ?? context.tr('worker_role'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: cs.onSurface)),
                    Text(
                      'TZS ${_formatNumber(app.proposedAmount)} · ${app.status}',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(app.message,
              style: TextStyle(
                  fontSize: 15, color: cs.onSurfaceVariant, height: 1.6)),
          if (canSelect) ...[
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _selectApplication(app.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('CHAGUA MFANYAKAZI HUYU',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildWorkerSelfApplicationCard(JobApplication app) {
    final cs = Theme.of(context).colorScheme;
    final greenTint = AppColors.success.withValues(
        alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.alphaBlend(greenTint, cs.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.45), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('OMBI LAKO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5)),
              ),
              const Spacer(),
              Text(
                app.status,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(app.message,
              style: TextStyle(
                  fontSize: 14, color: cs.onSurface, height: 1.5)),
          const SizedBox(height: 8),
          Text(
            'TZS ${_formatNumber(app.proposedAmount)}',
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherApplicationBrief(JobApplication app) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.tpMutedFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.surfaceContainerHighest,
            child: Text(
              app.workerName?.isNotEmpty == true
                  ? app.workerName![0].toUpperCase()
                  : 'W',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.workerName ?? context.tr('worker_role'),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: cs.onSurface)),
                Text(
                  'TZS ${_formatNumber(app.proposedAmount)}',
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Comments section for workers to see all comments including their own
  Widget _buildCommentsSection(Job job) {
    final cs = Theme.of(context).colorScheme;
    final currentUser = context.read<AuthProvider>().user;
    final apps = job.applications ?? [];
    if (apps.isNotEmpty) {
      final myApps =
          apps.where((a) => a.workerId == currentUser?.id).toList();
      final otherApps =
          apps.where((a) => a.workerId != currentUser?.id).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (myApps.isNotEmpty) ...[
            Text(context.tr('your_application'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface)),
            const SizedBox(height: 16),
            ...myApps.map((a) => _buildWorkerSelfApplicationCard(a)),
            const SizedBox(height: 24),
          ],
          if (otherApps.isNotEmpty) ...[
            Text('Maombi mengine (${otherApps.length})',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface)),
            const SizedBox(height: 12),
            ...otherApps.map((a) => _buildOtherApplicationBrief(a)),
          ],
          if (myApps.isEmpty && otherApps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.tr('no_applications_yet')),
              ),
            ),
        ],
      );
    }

    final myComments = job.comments?.where((c) => c.userId == currentUser?.id).toList() ?? [];
    final otherComments = job.comments?.where((c) => c.userId != currentUser?.id).toList() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Application/Comment
        if (myComments.isNotEmpty) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(
                      alpha: cs.brightness == Brightness.dark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded, 
                  color: Color(0xFF22C55E), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('your_application'),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface)),
                    Text(context.tr('you_applied'),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF22C55E))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...myComments.map((comment) => _buildMyCommentItem(comment)),
          const SizedBox(height: 30),
        ],
        
        // Other Comments
        if (otherComments.isNotEmpty) ...[
          Text('${context.tr('other_applications')} (${otherComments.length})',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface)),
          const SizedBox(height: 16),
          ...otherComments.map((comment) => _buildOtherCommentItem(comment)),
        ],
        
        // Empty state if no comments at all
        if (job.comments == null || job.comments!.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.tpMutedFill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.chat_bubble_outline_rounded,
                      size: 50, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 15),
                Text(context.tr('no_applications_yet'),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 6),
                Text(context.tr('be_first_to_apply'),
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  /// My comment item (highlighted)
  Widget _buildMyCommentItem(JobComment comment) {
    final cs = Theme.of(context).colorScheme;
    final greenTint = AppColors.success.withValues(
        alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.alphaBlend(greenTint, cs.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.45), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('OMBI LAKO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5)),
              ),
              const Spacer(),
              Text(
                timeago.format(comment.createdAt ?? DateTime.now(), locale: Localizations.localeOf(context).languageCode),
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment.message,
              style: TextStyle(
                  fontSize: 14, color: cs.onSurface, height: 1.5)),
          if (comment.proposedPrice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_rounded, 
                    color: Color(0xFF22C55E), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${context.tr('your_proposed_price')}: TZS ${_formatNumber(comment.proposedPrice!)}',
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Other workers' comment item
  Widget _buildOtherCommentItem(JobComment comment) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tpMutedFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.surfaceContainerHighest,
            backgroundImage: comment.userPhoto != null 
              ? NetworkImage(comment.userPhoto!) 
              : null,
            child: comment.userPhoto == null
              ? Text(
                  comment.userName?.isNotEmpty == true 
                    ? comment.userName![0].toUpperCase() 
                    : 'W',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
              : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName ?? context.tr('worker_role'),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: cs.onSurface)),
                    const Spacer(),
                    Text(
                      timeago.format(comment.createdAt ?? DateTime.now(), locale: Localizations.localeOf(context).languageCode),
                      style: TextStyle(
                          fontSize: 10, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comment.message,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppItem(JobComment comment) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: context.tpCardElevated,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
              color: context.tpShadowSoft,
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
                backgroundColor: cs.primaryContainer,
                child: Text(comment.userName?[0] ?? 'W',
                    style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.userName ?? context.tr('worker_role'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: cs.onSurface)),
                    Text(
                        timeago.format(comment.createdAt ?? DateTime.now(),
                            locale: Localizations.localeOf(context).languageCode),
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(comment.message,
              style: TextStyle(
                  fontSize: 15, color: cs.onSurfaceVariant, height: 1.6)),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _acceptWorker(comment.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('MTEUE Mfanyakazi HUYU',
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

  Widget? _buildBottomBar(
      bool isWorker, bool isOwner, bool hasWorkerOrSelection) {
    final job = _job;
    final uid = context.read<AuthProvider>().user?.id;
    final cs = Theme.of(context).colorScheme;
    final bottomBarDecoration = BoxDecoration(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      boxShadow: [
        BoxShadow(
          color: context.tpShadowSoft,
          blurRadius: 30,
          offset: const Offset(0, -10),
        ),
      ],
    );

    if (isWorker &&
        !isOwner &&
        job != null &&
        job.isAcceptedWorker(uid) &&
        job.status == 'funded') {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: bottomBarDecoration,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _workerDeclineFunded,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('KATAA',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading ? null : _workerAcceptFunded,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('KUBALI KAZI',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    }

    if (isWorker &&
        !isOwner &&
        job != null &&
        job.isAcceptedWorker(uid) &&
        (job.status == 'in_progress' || job.status == 'assigned')) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: bottomBarDecoration,
        child: FilledButton(
          onPressed: _isLoading ? null : _showWorkerSubmitSheet,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt_rounded),
              SizedBox(width: 10),
              Text('WASILISHA KAZI',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      );
    }

    if (isWorker &&
        job != null &&
        job.acceptsNewApplications &&
        !isOwner &&
        !job.workerHasApplication(uid)) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: bottomBarDecoration,
        child: ElevatedButton(
          onPressed: _showWorkerApplySheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.walletAccent,
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

    if (isWorker &&
        job != null &&
        job.acceptsNewApplications &&
        !isOwner &&
        job.workerHasApplication(uid)) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
                color: context.tpShadowSoft,
                blurRadius: 30,
                offset: const Offset(0, -10)),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_top_rounded,
                color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('worker_apply_pending_status'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isOwner && job != null && job.isSubmitted) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: bottomBarDecoration,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _promptClientRevision,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('OMBA MAREKEBISHO',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading ? null : _confirmClientCompletion,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('THIBITISHA KAZI',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    if (isOwner && job != null && job.isAwaitingPayment) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: bottomBarDecoration,
        child: FilledButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final ok = await Navigator.pushNamed(
                    context,
                    AppRouter.fundEscrow,
                    arguments: {'job': job},
                  );
                  if (ok == true && mounted) await _refreshJobDetails();
                },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments_rounded),
              SizedBox(width: 10),
              Text('LIPA ESCROW (MALIPO)',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      );
    }

    if (isOwner &&
        job != null &&
        (job.status == 'posted' ||
            job.status == 'assigned' ||
            job.status == 'open')) {
      return Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
        decoration: bottomBarDecoration,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRouter.editJob,
                    arguments: _job,
                  );
                  if (result == true) {
                    _refreshJobDetails();
                  }
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('HARIRI KAZI',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }

  /// Maelezo mafupi ya hatua inayofuata kwa mhusika (muhitaji / mfanyakazi).
  Widget? _buildNextStepCallout(
    BuildContext context,
    Job job,
    bool isOwner,
    bool isWorker,
    int? uid,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    String? title;
    String? subtitle;
    var bg = const Color(0xFFEFF6FF);
    var border = const Color(0xFFBFDBFE);
    var iconColor = AppColors.primary;

    if (isOwner) {
      if (job.isAwaitingPayment) {
        title = 'Hatua inayofuata: malipo ya escrow';
        subtitle =
            'Lipia kiasi kilichokubaliwa ili mfanyakazi apokee arifa na kuanza kazi.';
        bg = const Color(0xFFFFF7ED);
        border = const Color(0xFFFDBA74);
        iconColor = const Color(0xFFF97316);
      } else if (job.isSubmitted) {
        title = 'Hatua inayofuata: uthibitisho';
        subtitle =
            'Hakiki kazi iliyowasilishwa. Tumia vitufe hapa chini kuthibitisha au kuomba marekebisho.';
        bg = const Color(0xFFF5F3FF);
        border = const Color(0xFFC4B5FD);
        iconColor = const Color(0xFF7C3AED);
      }
    } else if (isWorker && uid != null) {
      if (job.isPendingEscrowAsSelectedWorker(uid)) {
        title = 'Umechaguliwa na mteja';
        subtitle =
            'Subiri mteja alipe escrow. Hutaweza kuanza rasmi kabla ya malipo hayo.';
        bg = const Color(0xFFECFEFF);
        border = const Color(0xFF67E8F9);
        iconColor = const Color(0xFF0891B2);
      } else if (job.isAcceptedWorker(uid) && job.status == 'funded') {
        title = 'Malipo yapo escrow';
        subtitle =
            'Thibitisha ikiwa unaweza kufanya kazi, au kataa ukiwa huru (malipo yatarudi kwa mteja).';
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        iconColor = AppColors.primary;
      } else if (job.isAcceptedWorker(uid) &&
          (job.status == 'in_progress' || job.status == 'assigned')) {
        title = 'Kazi inaendelea';
        subtitle =
            'Ukimaliza, wasilisha kazi kwa mteja kuthibitisha na kufunga malipo.';
        bg = const Color(0xFFF0FDF4);
        border = const Color(0xFF86EFAC);
        iconColor = const Color(0xFF16A34A);
      }
    } else if (!isOwner && !isWorker && job.acceptsNewApplications) {
      title = 'Kazi inapatikana';
      subtitle =
          'Ingia kama mfanyakazi ili uweze kuomba kazi hii na kuwasiliana na mteja.';
      bg = const Color(0xFFF8FAFC);
      border = const Color(0xFFE2E8F0);
      iconColor = cs.onSurfaceVariant;
    }

    if (title == null || subtitle == null) return null;

    final surfaceColor = isDark
        ? Color.alphaBlend(bg.withValues(alpha: 0.22), cs.surfaceContainerHigh)
        : bg;
    final borderColor = isDark
        ? Color.alphaBlend(border.withValues(alpha: 0.55), cs.outlineVariant)
        : border;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
      case 'posted':
        return const Color(0xFF22C55E);
      case 'awaiting_payment':
        return const Color(0xFFF59E0B);
      case 'funded':
      case 'in_progress':
      case 'assigned':
        return const Color(0xFF3B82F6);
      case 'submitted':
      case 'ready_for_confirmation':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppColors.walletAccent;
    }
  }
}
