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
import '../../widgets/tendapoa_drawer.dart';
import 'worker_jobs_screen.dart';
import 'worker_my_applications_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WorkerProvider>().refreshAll();
    });
  }

  Widget _buildWorkerDrawer(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TendapoaDrawerHeader(
            gradientColors: const [Color(0xFFF97316), Color(0xFFEA580C)],
            appTitle: loc.appTitle,
            userName: user?.name,
            userEmail: user?.email,
            roleLabel: loc.settings_role_worker,
            profilePhotoUrl: user?.profilePhotoUrl,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              children: [
                TendapoaDrawerSectionLabel(label: loc.drawer_section_menu),
                TendapoaDrawerLink(
                  icon: Icons.dashboard_rounded,
                  title: loc.dashboard,
                  subtitle: loc.drawer_sub_dashboard,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.workerDashboard);
                  },
                ),
                TendapoaDrawerLink(
                  icon: Icons.map_rounded,
                  title: loc.view_map,
                  subtitle: loc.drawer_sub_map,
                  onTap: () {
                    Navigator.pop(context);
                    final worker = context.read<WorkerProvider>();
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => MapScreen(
                          jobs: worker.availableJobs,
                          fetchFromApi: true,
                        ),
                      ),
                    );
                  },
                ),
                TendapoaDrawerLink(
                  icon: Icons.notifications_active_rounded,
                  title: loc.notifications,
                  subtitle: loc.drawer_sub_notifications,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.notifications);
                  },
                ),
                TendapoaDrawerLink(
                  icon: Icons.account_balance_wallet_rounded,
                  title: loc.wallet_balance,
                  subtitle: loc.drawer_sub_wallet,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.wallet);
                  },
                ),
                TendapoaDrawerLink(
                  icon: Icons.add_circle_outline_rounded,
                  title: loc.post_job_title,
                  subtitle: loc.drawer_sub_post_worker,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.workerPostJob);
                  },
                ),
                TendapoaDrawerLink(
                  icon: Icons.settings_rounded,
                  title: loc.settings,
                  subtitle: loc.drawer_sub_settings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.settingsPage);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildWorkerDrawer(context),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeFeedTab(
            openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const WorkerJobsScreen(),
          const WorkerMyApplicationsScreen(embeddedInMainShell: true),
          const ChatListScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.home_rounded,
                  Icons.home_outlined,
                  loc.nyumbani_nav,
                  0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.work_rounded,
                  Icons.work_outline_rounded,
                  loc.kazi_zangu_nav,
                  1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.assignment_turned_in_rounded,
                  Icons.assignment_turned_in_outlined,
                  loc.worker_nav_maombi,
                  2,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.chat_bubble_rounded,
                  Icons.chat_bubble_outline_rounded,
                  loc.inbox_nav,
                  3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData iconSelected,
    IconData iconOutlined,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? iconSelected : iconOutlined,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                size: 22,
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// === NYUMBANI (HOME FEED) TAB ===
class _HomeFeedTab extends StatefulWidget {
  const _HomeFeedTab({required this.openDrawer});

  final VoidCallback openDrawer;

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            // Blue Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row - Logo and Icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: widget.openDrawer,
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
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
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  context.tr('appTitle'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                                  color: Colors.white.withValues(alpha: 0.2),
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
                                  color: Colors.white.withValues(alpha: 0.2),
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
                        color: Colors.white.withValues(alpha: 0.8),
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: context.tr('search_jobs_hint'),
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.tpShadowSoft,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.primary,
                        iconBgColor: const Color(0xFFDBEAFE),
                        value: 'TZS ${NumberFormat('#,###').format(worker.wallet?.balance ?? 0)}',
                        label: context.tr('wallet_balance'),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFD1FAE5),
                        value: '${worker.dashboard?.doneCount ?? 0}',
                        label: context.tr('jobs_done'),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.work_outline,
                        iconColor: const Color(0xFFF97316),
                        iconBgColor: const Color(0xFFFFEDD5),
                        value: '${worker.activeJobs.length}',
                        label: context.tr('active_tab'),
                      ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('job_market_label'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
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
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                viewMapLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
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

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      final cs = Theme.of(context).colorScheme;
      distanceBgColor = cs.surfaceContainerHighest;
      distanceTextColor = cs.onSurfaceVariant;
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
          color: context.tpCardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: context.tpShadowSoft,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final thumb = (maxW * 0.24).clamp(52.0, 80.0);

            final thumbChild = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                  ? Image.network(
                      job.imageUrl!,
                      width: thumb,
                      height: thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildCompactPlaceholder(size: thumb),
                    )
                  : _buildCompactPlaceholder(size: thumb),
            );

            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (job.categoryName != null)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.tpMutedFill,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              job.categoryIcon ?? job.categoryName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.1),
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
                    if (distanceLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: distanceBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isNearby
                                  ? Icons.near_me
                                  : Icons.location_on_outlined,
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
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
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
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: Text(
                        job.userName ?? context.tr('client_label'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (job.createdAt != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _getTimeAgo(context, job.createdAt!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            );

            if (maxW < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  thumbChild,
                  const SizedBox(height: 10),
                  details,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                thumbChild,
                const SizedBox(width: 12),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactPlaceholder({double size = 80}) {
    final iconSize = (size * 0.38).clamp(22.0, 30.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF97316).withValues(alpha: 0.15),
            const Color(0xFFF97316).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.work_outline_rounded,
        size: iconSize,
        color: const Color(0xFFF97316).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEmptyJobs() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_jobs_available'),
            style: TextStyle(
              color: cs.onSurfaceVariant,
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
