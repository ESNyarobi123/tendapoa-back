import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart';

/// Ombi la mfanyakazi kwenye kazi za muhitaji (inbox).
class ClientApplicationsScreen extends StatefulWidget {
  const ClientApplicationsScreen({super.key, this.embeddedInMainShell = false});

  /// Tab ya chini ya shell kuu — bila AppBar.
  final bool embeddedInMainShell;

  @override
  State<ClientApplicationsScreen> createState() => _ClientApplicationsScreenState();
}

class _ClientApplicationsScreenState extends State<ClientApplicationsScreen> {
  final JobService _jobService = JobService();
  List<JobApplication> _items = [];
  bool _loading = true;
  String? _error;
  String _filter = 'hatua';
  int _page = 1;
  bool _hasMore = false;
  int _lastPage = 1;

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
      final raw = await _jobService.getMyApplications(
        filter: _filter.isEmpty ? null : _filter,
        page: _page,
      );
      final data = raw['data'] as Map<String, dynamic>? ?? raw;
      final list = data['applications'] as List? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      final apps = list
          .map((e) => JobApplication.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items = apps;
        } else {
          _items = [..._items, ...apps];
        }
        _lastPage = pagination['last_page'] is int
            ? pagination['last_page'] as int
            : int.tryParse('${pagination['last_page']}') ?? 1;
        _hasMore = pagination['has_more'] == true ||
            (_page < _lastPage);
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
    final scheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final filterMenu = PopupMenuButton<String>(
      initialValue: _filter,
      onSelected: (v) {
        setState(() => _filter = v);
        _load(reset: true);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'hatua', child: Text('Yanayohitaji hatua')),
        PopupMenuItem(value: '', child: Text('Yote')),
      ],
    );
    final body = RefreshIndicator(
      color: scheme.primary,
      onRefresh: () => _load(reset: true),
      child: _buildBody(),
    );
    if (widget.embeddedInMainShell) {
      return Scaffold(
        backgroundColor: scheme.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 4, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.groups_rounded, color: scheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc?.settings_worker_inbox_client ?? 'Maombi ya wafanyakazi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    filterMenu,
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
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(loc?.settings_worker_inbox_client ?? 'Maombi ya wafanyakazi'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [filterMenu],
      ),
      body: body,
    );
  }

  Widget _buildBody() {
    final scheme = Theme.of(context).colorScheme;
    if (_loading && _items.isEmpty) {
      return Center(child: CircularProgressIndicator(color: scheme.primary));
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.inbox_outlined, size: 64, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Hakuna maombi bado',
              style: TextStyle(color: scheme.onSurfaceVariant),
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
        return _ApplicationTile(application: app);
      },
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          backgroundImage: application.workerPhotoUrl != null &&
                  application.workerPhotoUrl!.isNotEmpty
              ? NetworkImage(application.workerPhotoUrl!)
              : null,
          child: application.workerPhotoUrl == null
              ? Text(
                  (application.workerName?.isNotEmpty == true)
                      ? application.workerName![0].toUpperCase()
                      : 'W',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          application.workerName ?? 'Mfanyakazi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'TZS ${fmt.format(application.proposedAmount)} · ${application.status}',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            if (application.createdAt != null)
              Text(
                timeago.format(
                  application.createdAt!,
                  locale: Localizations.localeOf(context).languageCode,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.jobDetails,
            arguments: {'jobId': application.workOrderId},
          );
        },
      ),
    );
  }
}
