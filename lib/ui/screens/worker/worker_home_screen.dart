import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';

import '../chat/chat_list_screen.dart';
import '../common/map_screen.dart';
import 'worker_jobs_screen.dart';
import 'worker_dashboard_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WorkerProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeFeedTab(),
          WorkerJobsScreen(),
          ChatListScreen(),
          WorkerDashboardScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textLight,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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

// === NYUMBANI (HOME FEED) TAB ===
class _HomeFeedTab extends StatefulWidget {
  const _HomeFeedTab();

  @override
  State<_HomeFeedTab> createState() => _HomeFeedTabState();
}

class _HomeFeedTabState extends State<_HomeFeedTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = context.read<WorkerProvider>();
    provider.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final worker = context.watch<WorkerProvider>();
    final user = context.watch<AuthProvider>().user;
    final viewMapLabel = context.tr('view_map');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Blue Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
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
                    // Top Row - Logo and Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/tendalogo.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.handyman,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.tr('appTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Notification Icon
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRouter.notifications);
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Map Icon
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MapScreen(
                                      jobs: worker.availableJobs,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.map_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Profile
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
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: user?.profilePhotoUrl != null
                                          ? Image.network(
                                              user!.profilePhotoUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : Center(
                                              child: Text(
                                                user?.name.isNotEmpty == true
                                                    ? user!.name[0].toUpperCase()
                                                    : 'W',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF97316),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 8,
                                        color: Colors.white,
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
                      '${context.tr('hello')}, ${user?.name.split(' ').firstOrNull ?? context.tr('worker_role')}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      context.tr('search_jobs_hint'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: AppColors.textLight,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: context.tr('search_jobs_hint'),
                                      hintStyle: const TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Filter Button (Orange)
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Quick Stats Row
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.primary,
                      iconBgColor: const Color(0xFFDBEAFE),
                      value: 'TZS ${NumberFormat('#,###').format(worker.wallet?.balance ?? 0)}',
                      label: context.tr('wallet_balance'),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE2E8F0),
                    ),
                    _buildStatItem(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      iconBgColor: const Color(0xFFD1FAE5),
                      value: '${worker.dashboard?.doneCount ?? 0}',
                      label: context.tr('jobs_done'),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE2E8F0),
                    ),
                    _buildStatItem(
                      icon: Icons.work_outline,
                      iconColor: const Color(0xFFF97316),
                      iconBgColor: const Color(0xFFFFEDD5),
                      value: '${worker.activeJobs.length}',
                      label: context.tr('active_tab'),
                    ),
                  ],
                ),
              ),
            ),

            // Available Jobs Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('job_market_label'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapScreen(
                              jobs: worker.availableJobs,
                              fetchFromApi: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              viewMapLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
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

            // Jobs List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: worker.isLoading && worker.availableJobs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : worker.availableJobs.isEmpty
                      ? SliverToBoxAdapter(
                          child: _buildEmptyJobs(),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildJobCard(worker.availableJobs[index]),
                            childCount: worker.availableJobs.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard(Job job) {
    final distanceInfo = job.distanceInfo;
    final distance = job.distance;
    final isNearby = distanceInfo?.isNear ?? (distance != null && distance <= 5);
    final isModerate = distanceInfo?.isModerate ?? (distance != null && distance > 5 && distance <= 15);

    // Distance badge colors
    Color distanceBgColor;
    Color distanceTextColor;
    if (isNearby) {
      distanceBgColor = const Color(0xFFDCFCE7);
      distanceTextColor = const Color(0xFF22C55E);
    } else if (isModerate) {
      distanceBgColor = const Color(0xFFFEF3C7);
      distanceTextColor = const Color(0xFFF59E0B);
    } else {
      distanceBgColor = const Color(0xFFF1F5F9);
      distanceTextColor = AppColors.textSecondary;
    }

    final distanceLabel = distanceInfo?.label ?? 
        (distance != null ? '${distance.toStringAsFixed(1)} km' : '');

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                  ? Image.network(
                      job.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildCompactPlaceholder(),
                    )
                  : _buildCompactPlaceholder(),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Category Row
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
                      if (job.categoryName != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            job.categoryIcon ?? job.categoryName!,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price & Distance Row
                  Row(
                    children: [
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TZS ${NumberFormat('#,###').format(job.price)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ),
                      if (distanceLabel.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: distanceBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isNearby ? Icons.near_me : Icons.location_on_outlined,
                                size: 10,
                                color: distanceTextColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                distanceLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: distanceTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bottom Row: Client & Time
                  Row(
                    children: [
                      // Client Avatar
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                          image: job.userPhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(job.userPhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: job.userPhotoUrl == null
                            ? Center(
                                child: Text(
                                  job.userName?.isNotEmpty == true
                                      ? job.userName![0].toUpperCase()
                                      : 'M',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          job.userName ?? context.tr('client_label'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Time
                      if (job.createdAt != null) ...[
                        Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(
                          _getTimeAgo(context, job.createdAt!),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                      const SizedBox(width: 8),
                      // Arrow
                      Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
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

  Widget _buildCompactPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF97316).withOpacity(0.15),
            const Color(0xFFF97316).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.work_outline_rounded,
        size: 30,
        color: const Color(0xFFF97316).withOpacity(0.5),
      ),
    );
  }

  Widget _buildEmptyJobs() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_jobs_available'),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final locale = Localizations.localeOf(context).languageCode;
    final isSw = locale == 'sw';
    final ago = context.tr('time_ago_suffix');

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      final unit = months > 1 ? context.tr('time_months') : context.tr('time_month');
      return '$months $unit $ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${context.tr('time_days')} $ago';
    } else if (difference.inHours > 0) {
      return isSw ? '${context.tr('time_hours')} ${difference.inHours} $ago' : '${difference.inHours} ${context.tr('time_hours')} $ago';
    } else if (difference.inMinutes > 0) {
      return isSw ? '${context.tr('time_minutes')} ${difference.inMinutes} $ago' : '${difference.inMinutes} ${context.tr('time_minutes')} $ago';
    } else {
      return context.tr('now');
    }
  }
}
