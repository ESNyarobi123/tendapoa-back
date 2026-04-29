import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/services.dart';

/// Kazi nilizochapisha mwenyewe (mfanyakazi-poster) + idadi ya waombaji.
/// Backend: `GET /api/worker/posted-jobs`.
class WorkerPostedJobsScreen extends StatefulWidget {
  const WorkerPostedJobsScreen({super.key});

  @override
  State<WorkerPostedJobsScreen> createState() => _WorkerPostedJobsScreenState();
}

class _WorkerPostedJobsScreenState extends State<WorkerPostedJobsScreen> {
  final _service = JobService();
  bool _loading = true;
  String? _error;
  List<_PostedJobItem> _items = [];

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
      final res = await _service.getWorkerPostedJobs();
      final raw = res['data'];
      final list = raw is List ? raw : <dynamic>[];
      _items = list
          .map((e) =>
              _PostedJobItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Kazi nilizochapisha',
            style: TextStyle(fontWeight: FontWeight.bold)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            tooltip: 'Onyesha upya',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(cs),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRouter.workerPostJob)
            .then((_) => _load()),
        backgroundColor: const Color(0xFFF97316),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Chapisha kazi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 64, color: cs.error),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Jaribu tena'),
          ),
        ),
      ]);
    }
    if (_items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 100),
        Icon(Icons.work_outline, size: 80, color: cs.onSurfaceVariant),
        const SizedBox(height: 12),
        Center(
          child: Text('Bado hujachapisha kazi yoyote',
              style: TextStyle(color: cs.onSurface, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Bofya "+ Chapisha kazi" hapo chini kuanza.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
        ),
      ]);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostedJobCard(item: _items[i], onChanged: _load),
    );
  }
}

class _PostedJobCard extends StatelessWidget {
  final _PostedJobItem item;
  final VoidCallback onChanged;
  const _PostedJobCard({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = NumberFormat('#,###');

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.workerJobApplicants,
            arguments: {'job_id': item.id, 'job_title': item.title},
          ).then((_) => onChanged());
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  _StatusChip(status: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.attach_money, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('TZS ${f.format(item.price)}',
                    style: TextStyle(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(_relative(item.createdAt),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ]),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: item.applicationsCount > 0
                      ? const Color(0xFFFFF4ED)
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 18,
                    color: item.applicationsCount > 0
                        ? const Color(0xFFF97316)
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.applicationsCount > 0
                          ? '${item.applicationsCount} ${item.applicationsCount == 1 ? 'mwombaji' : 'waombaji'}'
                          : 'Hakuna maombi bado',
                      style: TextStyle(
                        color: item.applicationsCount > 0
                            ? const Color(0xFFF97316)
                            : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: cs.onSurfaceVariant, size: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relative(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'sasa hivi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika';
    if (diff.inHours < 24) return '${diff.inHours} saa';
    if (diff.inDays < 30) return '${diff.inDays} siku';
    return DateFormat('dd MMM').format(dt);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

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
        style:
            TextStyle(color: cfg.$1, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  (Color, String) _config(String s) {
    switch (s) {
      case 'open':
      case 'posted':
        return (const Color(0xFF10B981), 'Wazi');
      case 'awaiting_payment':
        return (const Color(0xFFF59E0B), 'Inasubiri malipo');
      case 'funded':
      case 'in_progress':
      case 'assigned':
        return (const Color(0xFF3B82F6), 'Inaendelea');
      case 'submitted':
        return (const Color(0xFF8B5CF6), 'Imewasilishwa');
      case 'completed':
        return (const Color(0xFF22C55E), 'Imekamilika');
      case 'cancelled':
      case 'expired':
        return (Colors.grey, 'Imefungwa');
      default:
        return (Colors.grey, s);
    }
  }
}

class _PostedJobItem {
  final int id;
  final String title;
  final int price;
  final String status;
  final int applicationsCount;
  final DateTime? createdAt;
  final String? imageUrl;

  _PostedJobItem({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.applicationsCount,
    this.createdAt,
    this.imageUrl,
  });

  factory _PostedJobItem.fromJson(Map<String, dynamic> j) {
    return _PostedJobItem(
      id: (j['id'] as num?)?.toInt() ?? 0,
      title: j['title']?.toString() ?? '',
      price: (j['price'] is String)
          ? int.tryParse(j['price']) ?? 0
          : (j['price'] as num?)?.toInt() ?? 0,
      status: j['status']?.toString() ?? 'open',
      applicationsCount: (j['applications_count'] as num?)?.toInt() ?? 0,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      imageUrl: j['image_url']?.toString(),
    );
  }
}
