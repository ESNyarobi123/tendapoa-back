import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import '../../widgets/job_card.dart';
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
    const ChatListScreen(),
    const _ClientProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.roofing_rounded),
                activeIcon: Icon(Icons.house_rounded),
                label: 'Nyumbani'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: 'Kazi Zangu'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Meseji'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Wasifu'),
          ],
        ),
      ),
    );
  }
}

// === HOME TAB ===
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
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<ClientProvider>();
    provider.loadUnreadCounts();
    provider.loadMyJobs();
    provider.loadNearbyWorkers(
        lat: AppConstants.defaultLat, lng: AppConstants.defaultLng);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().categories;
    final clientProvider = context.watch<ClientProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // PREMIUM HEADER
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Habari, ${user?.name.split(' ')[0] ?? 'Mteja'}!',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text('Unahitaji msaidizi gani leo?',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14)),
                          ],
                        ),
                        _buildHeaderIcon(
                            Icons.notifications_none_rounded,
                            () => Navigator.pushNamed(
                                context, AppRouter.notifications)),
                      ],
                    ),
                    const SizedBox(height: 35),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.postJob),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.add_rounded,
                                  color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Post Kazi Mpya',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                  Text('Pata mafundi bingwa kwa haraka',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // QUICK STATS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Row(
                  children: [
                    _buildStatMiniCard(
                        'Kazi',
                        '${clientProvider.myJobs.length}',
                        Icons.work_history_rounded,
                        const Color(0xFF3B82F6)),
                    const SizedBox(width: 15),
                    _buildStatMiniCard(
                        'Meseji',
                        '${clientProvider.unreadChats}',
                        Icons.chat_rounded,
                        const Color(0xFFF97316)),
                    const SizedBox(width: 15),
                    _buildStatMiniCard(
                        'Zilizomalizika',
                        '${clientProvider.myJobs.where((j) => j.status == 'completed').length}',
                        Icons.verified_rounded,
                        const Color(0xFF10B981)),
                  ],
                ),
              ),
            ),

            // CATEGORIES
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 15),
                    child: Text('Kategoria Maarufu',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B))),
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        final cat = categories[i];
                        return _buildCategoryItem(cat);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // RECENT JOBS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kazi Zako za Karibu',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B))),
                    TextButton(
                        onPressed: () {},
                        child: const Text('Ona Zote',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 100),
              sliver: clientProvider.myJobs.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyJobs())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => JobCard(
                          job: clientProvider.myJobs[i],
                          onTap: () => Navigator.pushNamed(
                              context, AppRouter.jobDetails,
                              arguments: {'job': clientProvider.myJobs[i]}),
                          onRetryPayment: () => Navigator.pushNamed(
                              context, AppRouter.paymentWait,
                              arguments: {'job': clientProvider.myJobs[i]}),
                        ),
                        childCount: clientProvider.myJobs.take(3).length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 24), onPressed: onTap),
    );
  }

  Widget _buildStatMiniCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B))),
            Text(label,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category cat) {
    final color = _parseColor(cat.color);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Icon(Icons.category_rounded, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(cat.name,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildEmptyJobs() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Icon(Icons.assignment_add, size: 50, color: Colors.blue[50]),
          const SizedBox(height: 15),
          const Text('Bado huna kazi yoyote',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
        ],
      ),
    );
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

// === MY JOBS TAB ===
class _ClientMyJobsTab extends StatefulWidget {
  const _ClientMyJobsTab();

  @override
  State<_ClientMyJobsTab> createState() => _ClientMyJobsTabState();
}

class _ClientMyJobsTabState extends State<_ClientMyJobsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ClientProvider>().loadMyJobs();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = context.watch<ClientProvider>();
    final allJobs = clientProvider.myJobs;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Kazi Zangu',
              style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5)),
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Zote'),
              Tab(text: 'Pending'),
              Tab(text: 'Zilizokamilika')
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(allJobs),
            _buildList(allJobs.where((j) => j.status != 'completed').toList()),
            _buildList(allJobs.where((j) => j.status == 'completed').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Job> jobs) {
    if (jobs.isEmpty) return const Center(child: Text('Hakuna kazi hapa.'));
    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => JobCard(
        job: jobs[i],
        onTap: () => Navigator.pushNamed(context, AppRouter.jobDetails,
            arguments: {'job': jobs[i]}),
        onRetryPayment: () => Navigator.pushNamed(
            context, AppRouter.paymentWait,
            arguments: {'job': jobs[i]}),
      ),
    );
  }
}

// === PROFILE TAB ===
class _ClientProfileTab extends StatelessWidget {
  const _ClientProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1E40AF),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.white24, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.profilePhotoUrl != null
                              ? NetworkImage(user!.profilePhotoUrl!)
                              : null,
                          child: user?.profilePhotoUrl == null
                              ? Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0]
                                      : 'U',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color(0xFFF97316), shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(user?.name ?? 'Mteja',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(user?.email ?? '',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuSection('Akaunti', [
                  _buildMenuItem(
                      Icons.person_outline_rounded, 'Hariri Wasifu', () {}),
                  _buildMenuItem(Icons.notifications_none_rounded,
                      'Taarifa (Notifications)', () {}),
                ]),
                const SizedBox(height: 25),
                _buildMenuSection('Msaada', [
                  _buildMenuItem(
                      Icons.settings_outlined,
                      'Mipangilio (Settings)',
                      () =>
                          Navigator.pushNamed(context, AppRouter.settingsPage)),
                  _buildMenuItem(
                      Icons.help_outline_rounded, 'Kituo cha Msaada', () {}),
                  _buildMenuItem(
                      Icons.info_outline_rounded, 'Kuhusu Tendapoa', () {}),
                ]),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted)
                        Navigator.pushReplacementNamed(
                            context, AppRouter.welcome);
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: Color(0xFFEF4444)),
                    label: const Text('Toka kwenye Akaunti',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1))),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFF1F5F9))),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20)),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Color(0xFFE2E8F0)),
    );
  }
}
