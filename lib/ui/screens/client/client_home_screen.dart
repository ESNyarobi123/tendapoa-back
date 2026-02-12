import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart';
import '../../../providers/providers.dart';
import '../chat/chat_list_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _ClientHomeTab(),
    const _ClientMyJobsTab(),
    const _ClientChatTab(),
    const _ClientDashboardTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, context.tr('nyumbani_nav'), 0),
              _buildNavItem(context, Icons.work_outline_rounded, context.tr('kazi_zangu_nav'), 1),
              _buildNavItem(context, Icons.chat_bubble_outline_rounded, context.tr('inbox_nav'), 2),
              _buildNavItem(context, Icons.grid_view_rounded, context.tr('dash_nav'), 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : AppColors.textLight,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// === HOME TAB (NYUMBANI) ===
class _ClientHomeTab extends StatefulWidget {
  const _ClientHomeTab();

  @override
  State<_ClientHomeTab> createState() => _ClientHomeTabState();
}

class _ClientHomeTabState extends State<_ClientHomeTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
        if (mounted) _loadData();
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = context.read<ClientProvider>();
    provider.loadUnreadCounts();
    provider.loadMyJobs();
    provider.loadNearbyWorkers(
      lat: AppConstants.defaultLat,
      lng: AppConstants.defaultLng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = context.watch<ClientProvider>();
    final user = context.watch<AuthProvider>().user;
    final categories = context.watch<AppProvider>().categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Blue Header with Wave
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Main Blue Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row - Logo and Profile
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/tendalogo.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.surface,
                                          child: const Icon(
                                            Icons.handyman_rounded,
                                            color: AppColors.primary,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Tendapoa',
                                          style: const TextStyle(
                                            color: AppColors.surface,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          'Pata Mfanyakazi Karibu Nawe',
                                          style: TextStyle(
                                            color: AppColors.surface.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: AppColors.surface,
                                    ),
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRouter.notifications,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      AppRouter.editProfile,
                                    );
                                    if (result == true && mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.surface,
                                        backgroundImage:
                                            user?.profilePhotoUrl != null
                                                ? NetworkImage(
                                                    user!.profilePhotoUrl!)
                                                : null,
                                        child: user?.profilePhotoUrl == null
                                            ? Text(
                                                user?.name.isNotEmpty == true
                                                    ? user!.name[0]
                                                    : 'U',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.surface,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 8,
                                            color: AppColors.surface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Greeting
                        Text(
                          'Habari, ${user?.name.split(' ')[0] ?? 'Mteja'}! 👋',
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Je, unahitaji msaada gani leo?',
                          style: TextStyle(
                            color: AppColors.surface.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        // Post Job Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRouter.postJob,
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                            label: Text(
                              context.tr('post_job_new').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: AppColors.surface,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.work_outline,
                      value: '${clientProvider.myJobs.length}',
                      label: context.tr('myJobs'),
                      iconColor: AppColors.primary,
                      bgColor: const Color(0xFFEEF2FF),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.check_circle_outline,
                      value:
                          '${clientProvider.myJobs.where((j) => j.status == 'completed').length}',
                      label: context.tr('completed_tab'),
                      iconColor: const Color(0xFF22C55E),
                      bgColor: const Color(0xFFDCFCE7),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      value: 'TZS 0',
                      label: 'Umelipa',
                      iconColor: const Color(0xFFF97316),
                      bgColor: const Color(0xFFFFF7ED),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Jobs Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('recent_jobs_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        context.tr('view_all'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Job Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: clientProvider.myJobs.isEmpty
                    ? _buildEmptyJobs()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: clientProvider.myJobs.take(5).length,
                        itemBuilder: (ctx, i) => _buildHorizontalJobCard(
                          clientProvider.myJobs[i],
                        ),
                      ),
              ),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.tr('categories_title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${categories.length} aina',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCategoryItem(categories[index]),
                  childCount: categories.length > 8 ? 8 : categories.length,
                ),
              ),
            ),

            // Show More Categories Button
            if (categories.length > 8)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${context.tr('view_all_categories')} (${categories.length})',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalJobCard(Job job) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.jobDetails,
        arguments: {'job': job},
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Stack(
                children: [
                  job.imageUrl != null && job.imageUrl!.isNotEmpty
                      ? Image.network(
                          job.imageUrl!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: AppColors.surfaceLight,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textLight,
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          color: AppColors.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.work_outline_rounded,
                              color: AppColors.textLight,
                              size: 32,
                            ),
                          ),
                        ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(job.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(context, job.status),
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TZS ${job.price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category cat) {
    final color = _parseColor(cat.color);
    final icon = _getCategoryIcon(cat.name);
    
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category jobs
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat.name.length > 12 ? '${cat.name.substring(0, 10)}...' : cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('clean') || lowerName.contains('safisha')) {
      return Icons.cleaning_services_rounded;
    } else if (lowerName.contains('home') || lowerName.contains('nyumba')) {
      return Icons.home_rounded;
    } else if (lowerName.contains('office') || lowerName.contains('ofisi')) {
      return Icons.business_rounded;
    } else if (lowerName.contains('garden') || lowerName.contains('bustani') || lowerName.contains('shamba')) {
      return Icons.grass_rounded;
    } else if (lowerName.contains('care') || lowerName.contains('grooming')) {
      return Icons.spa_rounded;
    } else if (lowerName.contains('space') || lowerName.contains('outside')) {
      return Icons.park_rounded;
    } else if (lowerName.contains('other') || lowerName.contains('nyingine')) {
      return Icons.more_horiz_rounded;
    } else if (lowerName.contains('repair') || lowerName.contains('fundi')) {
      return Icons.build_rounded;
    } else if (lowerName.contains('plumb') || lowerName.contains('bomba')) {
      return Icons.plumbing_rounded;
    } else if (lowerName.contains('electric') || lowerName.contains('umeme')) {
      return Icons.electrical_services_rounded;
    } else if (lowerName.contains('paint') || lowerName.contains('rangi')) {
      return Icons.format_paint_rounded;
    } else if (lowerName.contains('move') || lowerName.contains('hamisha')) {
      return Icons.local_shipping_rounded;
    } else if (lowerName.contains('cook') || lowerName.contains('pika')) {
      return Icons.restaurant_rounded;
    } else if (lowerName.contains('laundry') || lowerName.contains('nguo')) {
      return Icons.local_laundry_service_rounded;
    }
    return Icons.handyman_rounded;
  }

  Widget _buildEmptyJobs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('no_jobs_posted_yet'),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
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
        return const Color(0xFFF97316);
      case 'pending':
      case 'pending_payment':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case 'in_progress':
      case 'assigned':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusText(BuildContext context, String status) {
    switch (status) {
      case 'open':
      case 'posted':
        return context.tr('status_open');
      case 'pending':
      case 'pending_payment':
        return context.tr('status_pending_payment');
      case 'accepted':
      case 'in_progress':
      case 'assigned':
        return context.tr('status_in_progress');
      case 'completed':
        return context.tr('status_completed');
      case 'cancelled':
        return context.tr('status_cancelled');
      default:
        return status;
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

// === KAZI ZANGU TAB ===
class _ClientMyJobsTab extends StatefulWidget {
  const _ClientMyJobsTab();

  @override
  State<_ClientMyJobsTab> createState() => _ClientMyJobsTabState();
}

class _ClientMyJobsTabState extends State<_ClientMyJobsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadMyJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper methods for filtering
  List<Job> _getInProgressJobs(List<Job> jobs) =>
      jobs.where((j) => j.status == 'accepted' || j.status == 'in_progress' || j.status == 'assigned').toList();
  
  List<Job> _getCompletedJobs(List<Job> jobs) =>
      jobs.where((j) => j.status == 'completed').toList();
  
  List<Job> _getPostedJobs(List<Job> jobs) =>
      jobs.where((j) => j.status == 'posted' || j.status == 'open').toList();
  
  List<Job> _getPendingPaymentJobs(List<Job> jobs) =>
      jobs.where((j) => j.status == 'pending_payment' || j.status == 'pending').toList();
  
  List<Job> _getCancelledJobs(List<Job> jobs) =>
      jobs.where((j) => j.status == 'cancelled').toList();

  @override
  Widget build(BuildContext context) {
    final clientProvider = context.watch<ClientProvider>();
    final allJobs = clientProvider.myJobs;
    final inProgressJobs = _getInProgressJobs(allJobs);
    final completedJobs = _getCompletedJobs(allJobs);
    final postedJobs = _getPostedJobs(allJobs);
    final pendingPaymentJobs = _getPendingPaymentJobs(allJobs);
    final cancelledJobs = _getCancelledJobs(allJobs);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => clientProvider.loadMyJobs(),
        color: AppColors.primary,
        child: Column(
          children: [
            // Gradient Header with Stats
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('myJobs'),
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${context.tr('all_tab')}: ${allJobs.length}',
                                style: TextStyle(
                                  color: AppColors.surface.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // Refresh Button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: clientProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.surface,
                                      ),
                                    )
                                  : const Icon(Icons.refresh_rounded, color: AppColors.surface),
                              onPressed: () => clientProvider.loadMyJobs(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats Cards Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildStatCard(
                            icon: Icons.hourglass_empty_rounded,
                            count: postedJobs.length,
                            label: context.tr('status_open'),
                            color: const Color(0xFFF97316),
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            icon: Icons.sync_rounded,
                            count: inProgressJobs.length,
                            label: context.tr('status_in_progress'),
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            icon: Icons.check_circle_rounded,
                            count: completedJobs.length,
                            label: context.tr('status_completed'),
                            color: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tabs
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        dividerColor: Colors.transparent,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.surface.withOpacity(0.8),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        tabs: [
                          _buildTabChip(context.tr('all_tab'), allJobs.length, _tabController.index == 0),
                          _buildTabChip(context.tr('status_pending_payment'), pendingPaymentJobs.length, _tabController.index == 1),
                          _buildTabChip(context.tr('status_open'), postedJobs.length, _tabController.index == 2),
                          _buildTabChip(context.tr('status_in_progress'), inProgressJobs.length, _tabController.index == 3),
                          _buildTabChip(context.tr('status_completed'), completedJobs.length, _tabController.index == 4),
                          _buildTabChip(context.tr('status_cancelled'), cancelledJobs.length, _tabController.index == 5),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobList(allJobs),
                  _buildPendingPaymentJobList(pendingPaymentJobs),
                  _buildJobList(postedJobs),
                  _buildJobList(inProgressJobs),
                  _buildJobList(completedJobs),
                  _buildJobList(cancelledJobs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.surface.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.surface, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                color: AppColors.surface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.surface.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int count, bool isSelected) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: AppColors.surface.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPaymentJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Color(0xFF22C55E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('status_pending_payment'),
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('all_paid_msg'),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => _buildPendingPaymentJobCard(jobs[i]),
    );
  }

  Widget _buildPendingPaymentJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Warning Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, 
                    color: Color(0xFFEF4444), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr('payment_status_waiting'),
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Job Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                          ? Image.network(
                              job.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.work_outline_rounded, 
                                  color: Color(0xFFEF4444), size: 28),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.work_outline_rounded, 
                                color: Color(0xFFEF4444), size: 28),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  job.categoryName ?? 'Kazi',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('amount_to_pay_label'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'TZS ${_formatJobPrice(job.price)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    // Delete Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(job),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: Text(context.tr('delete_job_btn').toUpperCase()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Retry Payment Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _retryPayment(job),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(context.tr('retry_payment_btn').toUpperCase()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Job job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, 
                color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            Text(context.tr('confirm_delete_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          context.tr('confirm_delete_job'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('no').toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: AppColors.surface,
            ),
            child: Text(context.tr('yes_delete').toUpperCase()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final jobService = JobService();
        await jobService.cancelJob(job.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${context.tr('job_deleted')}'),
              backgroundColor: const Color(0xFF22C55E),
            ),
          );
          context.read<ClientProvider>().loadMyJobs();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${context.tr('error_prefix')}: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  Future<void> _retryPayment(Job job) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF22C55E)),
              const SizedBox(height: 20),
              Text(
                context.tr('initiating_payment'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('wait'),
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );

      final jobService = JobService();
      final result = await jobService.retryPayment(job.id);
      
      if (mounted) Navigator.pop(context); // Close loading dialog

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📱 ${context.tr('confirm_payment_phone')}'),
            backgroundColor: const Color(0xFF22C55E),
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Start polling for payment status
        _pollPaymentStatus(job.id);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${context.tr('error_prefix')}: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _pollPaymentStatus(int jobId) async {
    final jobService = JobService();
    int attempts = 0;
    const maxAttempts = 30; // Poll for 60 seconds (30 * 2 seconds)

    while (attempts < maxAttempts && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;

      try {
        final status = await jobService.pollPayment(jobId);
        if (status['done'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${context.tr('payment_success_msg')}'),
                backgroundColor: const Color(0xFF22C55E),
              ),
            );
            context.read<ClientProvider>().loadMyJobs();
          }
          return;
        }
      } catch (e) {
        // Continue polling
      }
    }
  }

  Widget _buildJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_off_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('no_jobs_here'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('jobs_will_appear_here'),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => _buildJobCard(jobs[i]),
    );
  }

  Widget _buildJobCard(Job job) {
    final statusColor = _getStatusColor(job.status);
    final hasWorker = job.workerId != null;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.jobDetails,
        arguments: {'job': job},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                  ? Image.network(
                      job.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(statusColor),
                    )
                  : _buildImagePlaceholder(statusColor),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(context, job.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Category & Price Row
                  Row(
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          job.categoryName ?? 'Other',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Price
                      Text(
                        'TZS ${_formatJobPrice(job.price)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bottom Row: Worker/Date/Action
                  Row(
                    children: [
                      // Worker or Date
                      if (hasWorker) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, size: 12, color: Color(0xFF3B82F6)),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.workerName ?? context.tr('worker_role'),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (job.createdAt != null) ...[
                        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(context, job.createdAt!),
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      // Completion Code or Arrow
                      if (job.completionCode != null && (job.status == 'in_progress' || job.status == 'assigned'))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.key_rounded, size: 10, color: Color(0xFF22C55E)),
                              const SizedBox(width: 3),
                              Text(
                                job.completionCode!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color color) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.work_outline_rounded, size: 28, color: color.withOpacity(0.5)),
    );
  }

  String _formatJobPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final locale = Localizations.localeOf(context).languageCode;
    final isSw = locale == 'sw';
    final ago = context.tr('time_ago_suffix');

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return isSw ? '${context.tr('time_minutes')} ${diff.inMinutes} $ago' : '${diff.inMinutes} ${context.tr('time_minutes')} $ago';
      }
      return isSw ? '${context.tr('time_hours')} ${diff.inHours} $ago' : '${diff.inHours} ${context.tr('time_hours')} $ago';
    } else if (diff.inDays == 1) {
      return context.tr('yesterday');
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ${context.tr('time_days')} $ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
      case 'posted':
        return const Color(0xFFF97316);
      case 'pending':
      case 'pending_payment':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case 'in_progress':
      case 'assigned':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusText(BuildContext context, String status) {
    switch (status) {
      case 'open':
      case 'posted':
        return context.tr('status_open');
      case 'pending':
      case 'pending_payment':
        return context.tr('status_pending_payment');
      case 'accepted':
      case 'in_progress':
      case 'assigned':
        return context.tr('status_in_progress');
      case 'completed':
        return context.tr('status_completed');
      case 'cancelled':
        return context.tr('status_cancelled');
      default:
        return status;
    }
  }
}

// === CHAT TAB ===
class _ClientChatTab extends StatelessWidget {
  const _ClientChatTab();

  @override
  Widget build(BuildContext context) {
    return const ChatListScreen();
  }
}

// === DASHBOARD TAB (PROFILE) ===
class _ClientDashboardTab extends StatefulWidget {
  const _ClientDashboardTab();

  @override
  State<_ClientDashboardTab> createState() => _ClientDashboardTabState();
}

class _ClientDashboardTabState extends State<_ClientDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await context.read<ClientProvider>().loadDashboard();
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final clientProvider = context.watch<ClientProvider>();
    final dashboard = clientProvider.dashboard;
    final isLoading = clientProvider.isDashboardLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Gradient Header with Profile
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                    child: Column(
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('dash_nav'),
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.surface,
                                            ),
                                          )
                                        : const Icon(Icons.refresh_rounded, color: AppColors.surface),
                                    onPressed: _loadData,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.settings_outlined, color: AppColors.surface),
                                    onPressed: () => Navigator.pushNamed(context, AppRouter.settingsPage),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Profile Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.surface.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              // Avatar with badge
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surface, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: AppColors.surface,
                                      backgroundImage: user?.profilePhotoUrl != null
                                          ? NetworkImage(user!.profilePhotoUrl!)
                                          : null,
                                      child: user?.profilePhotoUrl == null
                                          ? Text(
                                              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, size: 12, color: AppColors.surface),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name ?? 'Mteja',
                                      style: const TextStyle(
                                        color: AppColors.surface,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? '',
                                      style: TextStyle(
                                        color: AppColors.surface.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (user?.phone != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        user!.phone!,
                                        style: TextStyle(
                                          color: AppColors.surface.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Muhitaji',
                                  style: TextStyle(
                                    color: AppColors.surface,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Wallet Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.surface, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                context.tr('wallet_balance'),
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (clientProvider.walletBalance > 0)
                            GestureDetector(
                              onTap: () => _showWithdrawDialog(context, clientProvider),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.arrow_upward_rounded, size: 16, color: Color(0xFF7C3AED)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Toa Pesa',
                                      style: TextStyle(
                                        color: Color(0xFF7C3AED),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TZS ',
                            style: TextStyle(
                              color: AppColors.surface,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          clientProvider.isWalletLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.surface,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _formatCurrency(clientProvider.walletBalance),
                                  style: const TextStyle(
                                    color: AppColors.surface,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                        ],
                      ),
                      if (clientProvider.walletBalance > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            context.tr('refund_from_cancelled'),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Total Paid Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, AppColors.success],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.payments_rounded, color: AppColors.surface, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('client_budget'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'TZS ${_formatCurrency(dashboard?.totalPaid ?? 0)}',
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${dashboard?.paymentHistory.length ?? 0} malipo',
                          style: const TextStyle(color: AppColors.surface, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats Grid (4 cards)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.post_add_rounded,
                          value: '${dashboard?.posted ?? 0}',
                          label: context.tr('posted_jobs_label'),
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.check_circle_rounded,
                          value: '${dashboard?.completed ?? 0}',
                          label: 'Zilizokamilika',
                          color: const Color(0xFF22C55E),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Payment History Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('dash_earnings_history'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (dashboard?.paymentHistory.isNotEmpty == true)
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          context.tr('view_all'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Payment History List
            if (dashboard?.paymentHistory.isEmpty ?? true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('no_transactions'),
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final payment = dashboard!.paymentHistory[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 8, 20, 8),
                      child: _buildPaymentCard(payment),
                    );
                  },
                  childCount: (dashboard?.paymentHistory.length ?? 0).clamp(0, 5),
                ),
              ),

            // Logout Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRouter.welcome);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  label: Text(
                    context.tr('logout'),
                    style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentHistory payment) {
    final isCompleted = payment.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isCompleted ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.job?.title ?? 'Malipo #${payment.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (payment.channel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          payment.channel!,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (payment.createdAt != null)
                      Text(
                        _formatPaymentDate(context, payment.createdAt!),
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TZS ${_formatCurrency(payment.amount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF22C55E).withOpacity(0.1)
                      : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted ? context.tr('status_completed') : context.tr('status_pending_payment'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPaymentDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final ago = context.tr('time_ago_suffix');

    if (diff.inDays == 0) {
      return context.tr('today');
    } else if (diff.inDays == 1) {
      return context.tr('yesterday');
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ${context.tr('time_days')} $ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showWithdrawDialog(BuildContext context, ClientProvider clientProvider) {
    final amountController = TextEditingController();
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    String selectedNetwork = 'vodacom';

    // Pre-fill phone from user
    final user = context.read<AuthProvider>().user;
    if (user?.phone != null) {
      phoneController.text = user!.phone!;
    }
    if (user?.name != null) {
      nameController.text = user!.name;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Title
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded, color: Color(0xFF7C3AED), size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Toa Pesa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.tr('balance_label')} TZS ${_formatCurrency(clientProvider.walletBalance)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Amount Field
                  const Text(
                    'Kiasi (TZS)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: context.tr('amount_hint'),
                      prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  Text(
                    context.tr('phone_number'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '07XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Registered Name Field
                  Text(
                    context.tr('mpesa_name_label'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: context.tr('mpesa_name_hint'),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Network Selection
                  const Text(
                    'Mtandao',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildNetworkChip('Vodacom', 'vodacom', selectedNetwork, (v) {
                        setModalState(() => selectedNetwork = v);
                      }),
                      _buildNetworkChip('Tigo', 'tigo', selectedNetwork, (v) {
                        setModalState(() => selectedNetwork = v);
                      }),
                      _buildNetworkChip('Airtel', 'airtel', selectedNetwork, (v) {
                        setModalState(() => selectedNetwork = v);
                      }),
                      _buildNetworkChip('Halotel', 'halotel', selectedNetwork, (v) {
                        setModalState(() => selectedNetwork = v);
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: clientProvider.isWithdrawing
                          ? null
                          : () async {
                              final amount = int.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
                              final phone = phoneController.text.trim();
                              final name = nameController.text.trim();

                              if (amount < 5000) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.tr('min_amount_error')),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                                return;
                              }

                              if (amount > clientProvider.walletBalance) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.tr('insufficient_balance_error')),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                                return;
                              }

                              if (phone.isEmpty || name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.tr('fill_all_fields')),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                                return;
                              }

                              try {
                                await clientProvider.submitWithdrawal(
                                  amount: amount,
                                  phoneNumber: phone,
                                  registeredName: name,
                                  networkType: selectedNetwork,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.tr('withdrawal_submitted')),
                                      backgroundColor: const Color(0xFF22C55E),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${context.tr("error_prefix")}: $e'),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: clientProvider.isWithdrawing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.surface,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'TOA PESA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkChip(String label, String value, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C3AED) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C3AED) : AppColors.grey200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
