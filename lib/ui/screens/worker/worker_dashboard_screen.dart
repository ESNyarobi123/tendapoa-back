import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart' as job_svc;
import '../../../data/services/wallet_service.dart';
import '../../../providers/providers.dart';
import 'withdrawal_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  bool _isLoading = true;
  WorkerDashboard? _dashboard;
  List<Transaction> _earningsHistory = [];
  List<Transaction> _withdrawalHistory = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final jobService = job_svc.JobService();
      final dashboard = await jobService.getWorkerDashboard();
      
      // Mock history data for UI demonstration
      // In production, this would come from the API
      final mockEarnings = [
        Transaction(
          id: 1,
          type: 'job_completion',
          amount: 4500,
          status: 'completed',
          description: 'Job completion payment (Job #85) - 10% Service Fee Deducted',
          createdAt: DateTime(2026, 1, 31),
        ),
        Transaction(
          id: 2,
          type: 'job_completion',
          amount: 2700000,
          status: 'completed',
          description: 'Job completion payment (Job #90) - 10% Service Fee Deducted',
          createdAt: DateTime(2026, 1, 31),
        ),
        Transaction(
          id: 3,
          type: 'job_completion',
          amount: 3938,
          status: 'completed',
          description: 'Job completion payment (Job #87) - 10% Service Fee Deducted',
          createdAt: DateTime(2026, 1, 29),
        ),
        Transaction(
          id: 4,
          type: 'job_completion',
          amount: 5000,
          status: 'completed',
          description: 'Job completion payment',
          createdAt: DateTime(2025, 10, 16),
        ),
        Transaction(
          id: 5,
          type: 'job_completion',
          amount: 30000,
          status: 'completed',
          description: 'Job completion payment',
          createdAt: DateTime(2025, 10, 14),
        ),
      ];

      final mockWithdrawals = [
        Transaction(
          id: 1,
          type: 'withdrawal',
          amount: 10000,
          status: 'completed',
          createdAt: DateTime(2026, 1, 29),
        ),
        Transaction(
          id: 2,
          type: 'withdrawal',
          amount: 5000,
          status: 'completed',
          createdAt: DateTime(2025, 10, 14),
        ),
      ];

      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          _earningsHistory = mockEarnings;
          _withdrawalHistory = mockWithdrawals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openWithdrawalScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WithdrawalScreen(
          currentBalance: (_dashboard?.available ?? 0).toDouble(),
        ),
      ),
    );
    
    // Refresh dashboard if withdrawal was submitted
    if (result == true) {
      _loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final balance = _dashboard?.available ?? 0;
    final totalEarnings = _dashboard?.earnTotal ?? 0;
    final withdrawn = _dashboard?.withdrawn ?? 0;
    final completedJobs = _dashboard?.doneCount ?? 0;
    const monthlyJobs = 0.0; // Would come from API

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Blue Header with Profile
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Profile Picture
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  image: user?.profilePhotoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(user!.profilePhotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: user?.profilePhotoUrl == null
                                    ? Center(
                                        child: Text(
                                          user?.name.isNotEmpty == true
                                              ? user!.name[0].toUpperCase()
                                              : 'W',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name ?? 'Mfanyakazi',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF97316),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Mfanyakazi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Settings Icon
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Wallet Card (Orange)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
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
                                    const Text(
                                      'SALIO LAKO',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'TZS ${NumberFormat('#,###').format(balance)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Withdraw Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _openWithdrawalScreen,
                                icon: const Icon(
                                  Icons.download,
                                  color: Color(0xFFF97316),
                                ),
                                label: const Text(
                                  'TOA PESA (Withdraw)',
                                  style: TextStyle(
                                    color: Color(0xFFF97316),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stats Grid (2x2)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildStatCard(
                            icon: Icons.trending_up,
                            iconBgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF22C55E),
                            value: 'TZS ${NumberFormat('#,###').format(totalEarnings)}',
                            label: 'Mapato Jumla',
                          ),
                          _buildStatCard(
                            icon: Icons.download,
                            iconBgColor: const Color(0xFFFFEDD5),
                            iconColor: const Color(0xFFF97316),
                            value: 'TZS ${NumberFormat('#,###').format(withdrawn)}',
                            label: 'Imechukuliwa',
                          ),
                          _buildStatCard(
                            icon: Icons.check_circle,
                            iconBgColor: const Color(0xFFDBEAFE),
                            iconColor: AppColors.primary,
                            value: '$completedJobs',
                            label: 'Kazi Zilizomalizika',
                          ),
                          _buildStatCard(
                            icon: Icons.calendar_today,
                            iconBgColor: const Color(0xFFFCE7F3),
                            iconColor: const Color(0xFFEC4899),
                            value: '$monthlyJobs',
                            label: 'Kazi za Mwezi',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Historia ya Mapato
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Historia ya Mapato',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.wallet);
                            },
                            child: const Text(
                              'Ona Zote',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Earnings History List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildEarningItem(_earningsHistory[index]),
                      childCount: _earningsHistory.length,
                    ),
                  ),

                  // Historia ya Uchukuliaji
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Historia ya Uchukuliaji',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Withdrawal History List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildWithdrawalItem(_withdrawalHistory[index]),
                      childCount: _withdrawalHistory.length,
                    ),
                  ),

                  // Logout Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await context.read<AuthProvider>().logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.welcome,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFEF4444),
                          ),
                          label: const Text(
                            'Toka',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFF22C55E),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Job completion payment',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ TZS ${NumberFormat('#,###').format(transaction.amount)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.download,
              color: Color(0xFFF97316),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdrawal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- TZS ${NumberFormat('#,###').format(transaction.amount)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
