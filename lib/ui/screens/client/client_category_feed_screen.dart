import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart';

/// Kazi za aina fulani (kutoka `/feed`).
class ClientCategoryFeedScreen extends StatefulWidget {
  const ClientCategoryFeedScreen({super.key, required this.category});

  final Category category;

  @override
  State<ClientCategoryFeedScreen> createState() => _ClientCategoryFeedScreenState();
}

class _ClientCategoryFeedScreenState extends State<ClientCategoryFeedScreen> {
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  bool _loading = true;
  String? _error;

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
      final response = await _jobService.getFeed(category: widget.category.feedSlug);
      final List raw = response['jobs'] ?? response['data'] ?? [];
      final jobs = raw.map((j) => Job.fromJson(Map<String, dynamic>.from(j as Map))).toList();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: scheme.primary));
    }
    if (_error != null) {
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
    if (_jobs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              'Hakuna kazi katika aina hii kwa sasa',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      );
    }
    final fmt = NumberFormat('#,###');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jobs.length,
      itemBuilder: (context, i) {
        final job = _jobs[i];
        final cs = Theme.of(context).colorScheme;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                  ? Image.network(job.imageUrl!, width: 64, height: 64, fit: BoxFit.cover)
                  : Container(
                      width: 64,
                      height: 64,
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.work_outline_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
            ),
            title: Text(
              job.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurface),
            ),
            subtitle: Text(
              'TZS ${fmt.format(job.price)} · ${job.status}',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.jobDetails,
                arguments: {'job': job},
              );
            },
          ),
        );
      },
    );
  }
}
