import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart' as job_svc;
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
                                              : context.tr('worker_role').isNotEmpty ? context.tr('worker_role')[0].toUpperCase() : 'W',
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
                                      user?.name ?? context.tr('worker_role'),
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
                                        color: AppColors.walletAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        context.tr('worker_role'),
                                        style: const TextStyle(
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
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, AppRouter.settingsPage),
                                child: Container(
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
                            colors: [AppColors.walletAccent, AppColors.walletAccentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.walletAccent.withOpacity(0.3),
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
                                    Text(
                                      context.tr('dash_balance_label'),
                                      style: const TextStyle(
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
                                  color: AppColors.walletAccent,
                                ),
                                label: Text(
                                  context.tr('dash_withdraw_btn'),
                                  style: const TextStyle(
                                    color: AppColors.walletAccent,
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
                            iconColor: AppColors.success,
                            value: 'TZS ${NumberFormat('#,###').format(totalEarnings)}',
                            label: context.tr('dash_total_earnings'),
                          ),
                          _buildStatCard(
                            icon: Icons.download,
                            iconBgColor: const Color(0xFFFFEDD5),
                            iconColor: AppColors.walletAccent,
                            value: 'TZS ${NumberFormat('#,###').format(withdrawn)}',
                            label: context.tr('dash_withdrawn'),
                          ),
                          _buildStatCard(
                            icon: Icons.check_circle,
                            iconBgColor: const Color(0xFFDBEAFE),
                            iconColor: AppColors.primary,
                            value: '$completedJobs',
                            label: context.tr('dash_jobs_completed'),
                          ),
                          _buildStatCard(
                            icon: Icons.calendar_today,
                            iconBgColor: const Color(0xFFFCE7F3),
                            iconColor: const Color(0xFFEC4899),
                            value: '$monthlyJobs',
                            label: context.tr('dash_monthly_jobs'),
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
                          Text(
                            context.tr('dash_earnings_history'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.wallet);
                            },
                            child: Text(
                              context.tr('view_all_btn'),
                              style: const TextStyle(
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

                  // Withdrawal history header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('dash_withdrawal_history'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
                            color: AppColors.error,
                          ),
                          label: Text(
                            context.tr('leave_btn'),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
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
        border: Border.all(color: AppColors.grey200),
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
              color: AppColors.success,
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
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
              color: AppColors.success,
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
        border: Border.all(color: AppColors.grey200),
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
              color: AppColors.walletAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('dash_withdraw_btn'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
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
              color: AppColors.walletAccent,
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
