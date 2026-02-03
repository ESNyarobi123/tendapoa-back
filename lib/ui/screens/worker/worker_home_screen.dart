import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';
import '../../widgets/job_card.dart';
import '../../widgets/filter_modal.dart';
import '../chat/chat_list_screen.dart';
import '../../widgets/withdrawal_modal.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeFeedTab(),
          _MyJobsTab(),
          ChatListScreen(),
          _DashboardTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)
        ]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFF97316),
          unselectedItemColor: const Color(0xFF94A3B8),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Gundua'),
            BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                activeIcon: Icon(Icons.business_center_rounded),
                label: 'Kazi Zangu'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Meseji'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashibodi'),
          ],
        ),
      ),
    );
  }
}

// === NYUMBANI (HOME FEED) TAB ===
class _HomeFeedTab extends StatelessWidget {
  const _HomeFeedTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final worker = context.watch<WorkerProvider>();

    return RefreshIndicator(
      onRefresh: () => worker.loadJobsFeed(),
      color: const Color(0xFFF97316),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35)),
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
                              'Habari, ${user?.name.split(' ')[0] ?? 'Mfanyakazi'}!',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Text('Tafuta kazi karibu nawe leo',
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
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: Color(0xFF94A3B8), size: 22),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintText: 'Tafuta kazi hapa...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        children: [
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(18)),
                            child: IconButton(
                                icon: const Icon(Icons.tune_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => const FilterModal(),
                                  );
                                }),
                          ),
                          if (worker.selectedCategory != null ||
                              worker.selectedDistance != null)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 2)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // QUICK STATS STRIP
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFF1F5F9))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat(
                      'Salio',
                      'TZS ${NumberFormat('#,###').format(worker.wallet?.balance ?? 0)}',
                      Icons.account_balance_wallet_rounded,
                      const Color(0xFF10B981)),
                  Container(
                      width: 1, height: 30, color: const Color(0xFFF1F5F9)),
                  _buildMiniStat('Kazi', '${worker.dashboard?.doneCount ?? 0}',
                      Icons.check_circle_rounded, const Color(0xFF3B82F6)),
                  Container(
                      width: 1, height: 30, color: const Color(0xFFF1F5F9)),
                  _buildMiniStat(
                      'Zilizo Active',
                      '${worker.currentActiveJob != null ? 1 : 0}',
                      Icons.bolt_rounded,
                      const Color(0xFFF97316)),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            sliver: SliverToBoxAdapter(
                child: Text('Kazi Zinazopatikana',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)))),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 100),
            sliver: worker.isLoading && worker.availableJobs.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFF97316))))
                : worker.availableJobs.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(child: Text('Hakuna kazi kwa sasa.')))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => JobCard(
                            job: worker.availableJobs[index],
                            onTap: () => Navigator.pushNamed(
                                context, AppRouter.jobDetails, arguments: {
                              'job': worker.availableJobs[index]
                            }),
                          ),
                          childCount: worker.availableJobs.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E293B))),
        Text(label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 22), onPressed: onTap),
    );
  }
}

// === KAZI ZANGU (MY JOBS) TAB ===
class _MyJobsTab extends StatefulWidget {
  const _MyJobsTab();

  @override
  State<_MyJobsTab> createState() => _MyJobsTabState();
}

class _MyJobsTabState extends State<_MyJobsTab> {
  @override
  void initState() {
    super.initState();
    context.read<WorkerProvider>().refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final worker = context.watch<WorkerProvider>();
    final activeJob = worker.currentActiveJob;

    return Scaffold(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeJob != null) ...[
              const Text('KAZI YA SASA',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF97316),
                      letterSpacing: 1)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text('INAENDELEA',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.bolt_rounded,
                            color: Color(0xFFF97316)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(activeJob.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('TZS ${activeJob.price}',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRouter.workerActiveJob),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: const Text('THIBITISHA UKAMILISHAJI',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Maombi Yangu (Applications)',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                Icon(Icons.filter_list_rounded,
                    color: Color(0xFF94A3B8), size: 20),
              ],
            ),
            const SizedBox(height: 20),

            // Empty state for applications if none
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.search_off_rounded,
                          size: 40, color: Colors.blue[50])),
                  const SizedBox(height: 20),
                  const Text('Bado hujaomba kazi yoyote.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// === DASHBOARD TAB ===
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final worker = context.watch<WorkerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.white24, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.profilePhotoUrl != null
                              ? NetworkImage(user!.profilePhotoUrl!)
                              : null,
                          child: user?.profilePhotoUrl == null
                              ? Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0]
                                      : 'W',
                                  style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Mtumiaji',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Text('FUNDI ALIYEIDHINISHWA',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                      ),
                      _buildHeaderIcon(Icons.settings_outlined, () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // WALLET LARGE CARD
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SALIO LAKO LA SASA',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                              const SizedBox(height: 5),
                              Text(
                                  'TZS ${NumberFormat('#,###').format(worker.wallet?.balance ?? 0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.wallet_rounded,
                                  color: Colors.white, size: 28)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => WithdrawalModal(
                                    currentBalance:
                                        (worker.wallet?.balance ?? 0)
                                            .toDouble(),
                                    onSubmitted: () => context
                                        .read<WorkerProvider>()
                                        .refreshAll()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFF97316),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18))),
                          child: const Text('TOA PESA (WITHDRAW)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // STATS GRID
                Row(
                  children: [
                    _buildStatBox(
                        'Total Income',
                        'TZS ${NumberFormat('#,###').format(worker.dashboard?.earnTotal ?? 0)}',
                        Icons.payments_rounded,
                        const Color(0xFF22C55E)),
                    const SizedBox(width: 15),
                    _buildStatBox(
                        'Works Done',
                        '${worker.dashboard?.doneCount ?? 0}',
                        Icons.verified_rounded,
                        const Color(0xFF3B82F6)),
                  ],
                ),

                const SizedBox(height: 40),

                _buildMenuTitle('Mipangilio ya Akaunti'),
                _buildDashMenuItem(
                    Icons.person_outline_rounded, 'Hariri Taarifa Zako', () {}),
                _buildDashMenuItem(
                    Icons.verified_user_outlined, 'Vigezo vya Uhakiki', () {}),
                _buildDashMenuItem(Icons.history_rounded, 'Historia ya Muamala',
                    () => Navigator.pushNamed(context, AppRouter.wallet)),

                const SizedBox(height: 30),

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
                    label: const Text('Toka (Logout)',
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

  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 15),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            Text(title,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTitle(String text) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 15),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 1)));
  }

  Widget _buildDashMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF64748B), size: 18)),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Color(0xFFE2E8F0)),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 22), onPressed: onTap),
    );
  }
}
