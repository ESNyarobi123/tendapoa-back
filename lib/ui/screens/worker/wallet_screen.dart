import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../widgets/withdrawal_modal.dart';
import '../../widgets/deposit_modal.dart';
import '../client/deposit_wait_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  bool _isLoading = true;
  Wallet? _wallet;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await _walletService.getWallet();
      if (mounted) {
        setState(() {
          _wallet = wallet;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: cs.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: cs.onSurface, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(context.tr('wallet_my_wallet'),
            style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadWallet,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PREMIUM BALANCE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.walletAccent,
                            AppColors.walletAccentDark
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  AppColors.walletAccent.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('wallet_balance_now'),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 10),
                          Text(
                            'TZS ${NumberFormat('#,###').format(_wallet?.balance ?? 0)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              _buildActionBtn(context.tr('wallet_withdraw'),
                                  Icons.arrow_outward_rounded, () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => WithdrawalModal(
                                    currentBalance: _wallet?.balance ?? 0,
                                    onSubmitted: _loadWallet,
                                  ),
                                );
                              }),
                              const SizedBox(width: 15),
                              _buildActionBtn(context.tr('wallet_add_balance'),
                                  Icons.add_rounded, () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => DepositModal(
                                    currentBalance: _wallet?.balance ?? 0,
                                    onInitiated: (txnId) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DepositWaitScreen(
                                            transactionId: txnId,
                                            amount: 0,
                                          ),
                                        ),
                                      ).then((success) {
                                        if (success == true) _loadWallet();
                                      });
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // HISTORY HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('wallet_payment_history'),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface)),
                        TextButton(
                            onPressed: () {},
                            child: Text(context.tr('wallet_view_all'),
                                style:
                                    const TextStyle(color: AppColors.primary))),
                      ],
                    ),
                    const SizedBox(height: 15),

                    if (_wallet?.transactions == null ||
                        _wallet!.transactions!.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.history_rounded,
                                size: 48, color: cs.onSurfaceVariant),
                            const SizedBox(height: 10),
                            Text(context.tr('wallet_no_history'),
                                style: TextStyle(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      )
                    else
                      ..._wallet!.transactions!
                          .map((t) => _buildTransactionItem(t)),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction t) {
    final isCredit = t.type == 'credit' || t.amount > 0;
    final cs = Theme.of(context).colorScheme;
    final creditBg = AppColors.success.withValues(
        alpha: context.tpBrightness == Brightness.dark ? 0.28 : 0.14);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.tpCardElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit ? creditBg : context.tpMutedFill,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color:
                  isCredit ? AppColors.success : cs.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    t.description ??
                        (isCredit
                            ? context.tr('wallet_credit')
                            : context.tr('wallet_debit')),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(
                    t.createdAt != null
                        ? DateFormat('d MMM, yyyy').format(t.createdAt!)
                        : '',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isCredit ? "+" : "-"} ${NumberFormat('#,###').format(t.amount.abs())}',
            style: TextStyle(
              color:
                  isCredit ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
