import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart';

/// Maombi yote aliyowasilisha mfanyakazi (sawa na web).
class WorkerMyApplicationsScreen extends StatefulWidget {
  const WorkerMyApplicationsScreen({super.key, this.embeddedInMainShell = false});

  /// When true (main worker shell tab), no AppBar — title inline so bottom nav fits.
  final bool embeddedInMainShell;

  @override
  State<WorkerMyApplicationsScreen> createState() =>
      _WorkerMyApplicationsScreenState();
}

class _WorkerMyApplicationsScreenState extends State<WorkerMyApplicationsScreen> {
  final JobService _jobService = JobService();
  List<JobApplication> _items = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _page = 1;
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final raw = await _jobService.getWorkerApplications(page: _page);
      final data = raw['data'] as Map<String, dynamic>? ?? raw;
      final list = data['applications'] as List? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      final apps = list
          .map((e) =>
              JobApplication.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items = apps;
        } else {
          _items = [..._items, ...apps];
        }
        final last = pagination['last_page'];
        _hasMore = pagination['has_more'] == true ||
            (last is int && _page < last) ||
            (last is num && _page < last.toInt());
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading) return;
    setState(() => _page += 1);
    await _load(reset: false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final body = RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _load(reset: true),
      child: _buildBody(fmt),
    );
    if (widget.embeddedInMainShell) {
      final loc = AppLocalizations.of(context);
      final cs = Theme.of(context).colorScheme;
      return Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.assignment_turned_in_rounded,
                        color: cs.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc?.settings_my_applications_worker ?? 'Maombi yangu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings_my_applications_worker ?? 'Maombi yangu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }

  Widget _buildBody(NumberFormat fmt) {
    if (_loading && _items.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Icon(Icons.outbox_outlined, size: 72, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Bado hujaomba kazi yoyote',
              style: TextStyle(color: cs.onSurface, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tazama feed uombe kazi inayokufaa',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _items.length) {
          return TextButton(
            onPressed: _loadMore,
            child: const Text('Pakia zaidi'),
          );
        }
        final app = _items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.jobDetails,
                arguments: {'jobId': app.workOrderId},
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          app.workerName != null
                              ? 'Ombi lako'
                              : 'Ombi',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          app.status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.jobTitle ?? 'Kazi #${app.workOrderId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (app.clientName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mteja: ${app.clientName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'TZS ${fmt.format(app.proposedAmount)}',
                    style: const TextStyle(
                      color: Color(0xFFF97316),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (app.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      timeago.format(
                        app.createdAt!,
                        locale: Localizations.localeOf(context).languageCode,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'Gusa kwa maelezo',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
