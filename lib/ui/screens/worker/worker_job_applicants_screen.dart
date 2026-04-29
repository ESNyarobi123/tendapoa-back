import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';

/// Orodha ya waombaji kwa kazi moja iliyochapishwa.
/// Backend: `GET /api/jobs/{job}/applications`.
class WorkerJobApplicantsScreen extends StatefulWidget {
  final int jobId;
  final String? jobTitle;

  const WorkerJobApplicantsScreen({
    super.key,
    required this.jobId,
    this.jobTitle,
  });

  @override
  State<WorkerJobApplicantsScreen> createState() =>
      _WorkerJobApplicantsScreenState();
}

class _WorkerJobApplicantsScreenState extends State<WorkerJobApplicantsScreen> {
  final _service = JobService();
  bool _loading = true;
  String? _error;
  List<JobApplication> _applicants = [];
  int? _selectingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _applicants = await _service.getJobApplicants(widget.jobId);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectApplicant(JobApplication app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mchaguo wa mwombaji'),
        content: Text(
          'Una uhakika unataka kumchagua ${app.workerName ?? 'mwombaji huyu'}? '
          'Hatua hii itasababisha kazi ipokee malipo.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hapana')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ndio, mchague')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _selectingId = app.id);
    try {
      await _service.selectApplication(widget.jobId, app.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Mwombaji amechaguliwa!'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Hitilafu: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _selectingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.jobTitle ?? 'Waombaji',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(cs),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 64, color: cs.error),
        const SizedBox(height: 12),
        Center(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        )),
      ]);
    }
    if (_applicants.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 100),
        Icon(Icons.inbox_outlined, size: 80, color: cs.onSurfaceVariant),
        const SizedBox(height: 12),
        Center(
          child: Text('Bado hakuna waombaji.',
              style: TextStyle(color: cs.onSurface, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Subiri kidogo — mara kazi ikionekana, waombaji watakuwa hapa.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ]);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _applicants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ApplicantCard(
        app: _applicants[i],
        isSelecting: _selectingId == _applicants[i].id,
        onSelect: () => _selectApplicant(_applicants[i]),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final JobApplication app;
  final bool isSelecting;
  final VoidCallback onSelect;

  const _ApplicantCard({
    required this.app,
    required this.isSelecting,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = NumberFormat('#,###');

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFFFF4ED),
                backgroundImage: (app.workerPhotoUrl != null &&
                        app.workerPhotoUrl!.isNotEmpty)
                    ? NetworkImage(app.workerPhotoUrl!)
                    : null,
                child: (app.workerPhotoUrl == null ||
                        app.workerPhotoUrl!.isEmpty)
                    ? Text(
                        (app.workerName ?? '?').characters.first.toUpperCase(),
                        style: const TextStyle(
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.workerName ?? 'Mwombaji',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TZS ${f.format(app.proposedAmount)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (app.etaText != null && app.etaText!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.schedule,
                            size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(app.etaText!,
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 11)),
                      ],
                    ]),
                  ],
                ),
              ),
              _StatusBadge(status: app.status),
            ],
          ),
          if (app.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                app.message,
                style: TextStyle(color: cs.onSurface, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (app.canBeSelectedByClient)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSelecting ? null : onSelect,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: isSelecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check, color: Colors.white),
                label: Text(
                  isSelecting ? 'Inachagua...' : 'Mchague mwombaji huyu',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.$1.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        cfg.$2,
        style: TextStyle(
            color: cfg.$1, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  (Color, String) _config(String s) {
    switch (s) {
      case 'applied':
        return (const Color(0xFF3B82F6), 'Mpya');
      case 'shortlisted':
        return (const Color(0xFFF59E0B), 'Iko mbele');
      case 'accepted_counter':
        return (const Color(0xFF8B5CF6), 'Counter');
      case 'countered':
        return (const Color(0xFF8B5CF6), 'Counter');
      case 'selected':
        return (const Color(0xFF22C55E), 'Amechaguliwa');
      case 'rejected':
        return (Colors.red, 'Amekataliwa');
      case 'withdrawn':
        return (Colors.grey, 'Ameondoa');
      default:
        return (Colors.grey, s);
    }
  }
}
