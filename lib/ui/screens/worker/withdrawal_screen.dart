import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/wallet_service.dart';

class WithdrawalScreen extends StatefulWidget {
  final double currentBalance;

  const WithdrawalScreen({
    super.key,
    required this.currentBalance,
  });

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _walletService = WalletService();

  String _selectedNetwork = 'vodacom';
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  List<Map<String, dynamic>> _withdrawalHistory = [];

  // Settings from API
  final int _minWithdrawal = 5000;
  final int _withdrawalFee = 500;

  final List<Map<String, dynamic>> _networks = [
    {'value': 'vodacom', 'label': 'M-Pesa', 'icon': '📱', 'color': const Color(0xFFE60000)},
    {'value': 'tigo', 'label': 'Tigo Pesa', 'icon': '💙', 'color': const Color(0xFF00A0DF)},
    {'value': 'airtel', 'label': 'Airtel Money', 'icon': '🔴', 'color': const Color(0xFFFF0000)},
    {'value': 'halotel', 'label': 'Halopesa', 'icon': '🟢', 'color': const Color(0xFF00AA00)},
    {'value': 'ttcl', 'label': 'T-Pesa', 'icon': '🟡', 'color': const Color(0xFFFFAA00)},
  ];

  @override
  void initState() {
    super.initState();
    _loadWithdrawalHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadWithdrawalHistory() async {
    try {
      final history = await _walletService.getWithdrawalHistory();
      if (mounted) {
        setState(() {
          _withdrawalHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  int get _netAmount {
    final amount = int.tryParse(_amountController.text) ?? 0;
    return amount > _withdrawalFee ? amount - _withdrawalFee : 0;
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(_amountController.text) ?? 0;
    final totalRequired = amount + _withdrawalFee;

    if (totalRequired > widget.currentBalance) {
      _showErrorSnackBar('${context.tr('withdrawal_insufficient')} ${NumberFormat('#,###').format(totalRequired)}');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _walletService.submitWithdrawal(
        amount: amount,
        phoneNumber: _phoneController.text.trim(),
        registeredName: _nameController.text.trim(),
        networkType: _selectedNetwork,
      );

      if (mounted) {
        _showSuccessDialog(amount);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = context.tr('withdrawal_failed_submit');
        if (e.toString().contains('halitoshi') || e.toString().toLowerCase().contains('insufficient')) {
          errorMessage = '${context.tr('withdrawal_insufficient')} ${NumberFormat('#,###').format(totalRequired)}';
        }
        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        final successTint = AppColors.success.withValues(
            alpha: cs.brightness == Brightness.dark ? 0.28 : 0.14);
        return Dialog(
          backgroundColor: cs.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: successTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('withdrawal_success_title'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${context.tr('withdrawal_success_body')} ${NumberFormat('#,###').format(amount)}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: cs.onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('withdrawal_success_footer'),
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return to dashboard with refresh flag
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.tr('withdrawal_ok_btn'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.walletAccent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.walletAccent, AppColors.walletAccentDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
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
                                  const SizedBox(height: 4),
                                  Text(
                                    'TZS ${NumberFormat('#,###').format(widget.currentBalance)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      context.tr('withdrawal_title'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('withdrawal_subtitle'),
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Field
                    _buildSectionTitle(context.tr('withdrawal_amount_section'), Icons.money),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                        hintText: context.tr('withdrawal_amount_hint'),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.walletAccent.withValues(
                                alpha: cs.brightness == Brightness.dark
                                    ? 0.22
                                    : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'TZS',
                            style: TextStyle(
                              color: AppColors.walletAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.65)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.65)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.walletAccent, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr('withdrawal_amount_required');
                        }
                        final amount = int.tryParse(value) ?? 0;
                        if (amount < _minWithdrawal) {
                          return '${context.tr('min_withdrawal_error')} (TZS ${NumberFormat('#,###').format(_minWithdrawal)})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    // Amount Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.tpMutedFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('withdrawal_min_label'),
                                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                              ),
                              Text(
                                'TZS ${NumberFormat('#,###').format(_minWithdrawal)}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('withdrawal_fee_label'),
                                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                              ),
                              Text(
                                'TZS ${NumberFormat('#,###').format(_withdrawalFee)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                              ),
                            ],
                          ),
                          if (_amountController.text.isNotEmpty) ...[
                            Divider(height: 16, color: cs.outlineVariant.withValues(alpha: 0.5)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('withdrawal_you_receive'),
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                                ),
                                Text(
                                  'TZS ${NumberFormat('#,###').format(_netAmount)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Network Selection
                    _buildSectionTitle(context.tr('withdrawal_network_section'), Icons.sim_card),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _networks.map((network) {
                        final isSelected = _selectedNetwork == network['value'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedNetwork = network['value']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (network['color'] as Color).withValues(alpha: 0.14)
                                  : context.tpCardElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? network['color'] as Color
                                    : cs.outlineVariant.withValues(alpha: 0.65),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (network['color'] as Color).withValues(alpha: 0.22),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(network['icon'], style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  network['label'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? network['color'] as Color
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.check_circle, color: network['color'] as Color, size: 18),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Phone Number
                    _buildSectionTitle(context.tr('withdrawal_phone_section'), Icons.phone),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: context.tr('withdrawal_phone_hint'),
                        prefixIcon: Icon(Icons.phone_android, color: cs.onSurfaceVariant),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.65)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.65)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.walletAccent, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr('withdrawal_phone_required');
                        }
                        if (value.length < 10) {
                          return context.tr('withdrawal_phone_invalid');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Registered Name
                    _buildSectionTitle(context.tr('withdrawal_name_section'), Icons.person),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: context.tr('withdrawal_name_hint'),
                        prefixIcon: Icon(Icons.badge, color: cs.onSurfaceVariant),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.65)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.65)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.walletAccent, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr('withdrawal_name_required');
                        }
                        if (value.length < 2) {
                          return context.tr('withdrawal_name_short');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitWithdrawal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.walletAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('withdrawal_submit_btn'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Warning Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.55)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: cs.onTertiaryContainer, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('withdrawal_important_note'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onTertiaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr('withdrawal_note_body'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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

          // Withdrawal History Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.history, color: cs.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('withdrawal_history_title'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // History List
          _isLoadingHistory
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.walletAccent),
                    ),
                  ),
                )
              : _withdrawalHistory.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: context.tpCardElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.45)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.history,
                                size: 48, color: cs.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              context.tr('withdrawal_no_history'),
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildHistoryItem(_withdrawalHistory[index]),
                        childCount: _withdrawalHistory.length,
                      ),
                    ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> withdrawal) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final status = withdrawal['status']?.toString().toLowerCase() ?? 'processing';
    final amount = withdrawal['amount'] ?? 0;
    final account = withdrawal['account'] ?? '';
    final networkType = withdrawal['network_type'] ?? '';
    final createdAt = withdrawal['created_at'] != null
        ? DateTime.parse(withdrawal['created_at'])
        : DateTime.now();

    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'paid':
        statusColor = AppColors.success;
        statusBgColor =
            AppColors.success.withValues(alpha: isDark ? 0.28 : 0.14);
        statusText = context.tr('withdrawal_status_paid');
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusBgColor = AppColors.error.withValues(alpha: isDark ? 0.28 : 0.14);
        statusText = context.tr('withdrawal_status_rejected');
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor =
            const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.28 : 0.14);
        statusText = context.tr('withdrawal_status_pending');
        statusIcon = Icons.hourglass_empty;
    }

    // Get network info
    final networkInfo = _networks.firstWhere(
      (n) => n['value'] == networkType,
      orElse: () => {'label': networkType, 'icon': '📱', 'color': Colors.grey},
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tpCardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          // Network Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (networkInfo['color'] as Color).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                networkInfo['icon'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TZS ${NumberFormat('#,###').format(amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$account • ${networkInfo['label']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
