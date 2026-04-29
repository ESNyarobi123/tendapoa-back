import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/wallet_service.dart';

class DepositWaitScreen extends StatefulWidget {
  final int transactionId;
  final int amount;

  const DepositWaitScreen({
    super.key,
    required this.transactionId,
    required this.amount,
  });

  @override
  State<DepositWaitScreen> createState() => _DepositWaitScreenState();
}

class _DepositWaitScreenState extends State<DepositWaitScreen>
    with SingleTickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 120;
  bool _isSuccess = false;
  bool _isFailed = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isSuccess || _secondsRemaining == 0) {
        timer.cancel();
        if (_secondsRemaining == 0 && !_isSuccess && mounted) {
          setState(() => _isFailed = true);
        }
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  void _startPolling() {
    _pollStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isSuccess || _isFailed) {
        timer.cancel();
        return;
      }
      _pollStatus();
    });
  }

  Future<void> _pollStatus() async {
    try {
      final result =
          await _walletService.pollDeposit(widget.transactionId);
      if (result['done'] == true && mounted) {
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();
        setState(() => _isSuccess = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      debugPrint('Deposit poll error: $e');
    }
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Close
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: scheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _buildMainContent(),
              const Spacer(),
              _buildBottomSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated circle
        _buildStatusIcon(),
        const SizedBox(height: 35),

        // Status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusLabel,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: _statusColor,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Message
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 25),

        // Timer
        if (!_isSuccess && !_isFailed) _buildTimer(),

        const SizedBox(height: 25),

        // Amount card
        _buildAmountCard(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    if (_isSuccess) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, Color(0xFF059669)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
      ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms);
    }

    if (_isFailed) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.error, Color(0xFFDC2626)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.close_rounded, size: 60, color: Colors.white),
      ).animate().shake(duration: 500.ms);
    }

    // Waiting — clean pulse
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success
                    .withValues(alpha: 0.1 + (_pulseController.value * 0.15)),
                blurRadius: 25 + (_pulseController.value * 20),
                spreadRadius: _pulseController.value * 8,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                size: 45, color: AppColors.success),
          ),
        );
      },
    );
  }

  Widget _buildTimer() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _formattedTime,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          color: _secondsRemaining < 30 ? scheme.error : scheme.onSurface,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_downward_rounded,
                color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('deposit_title'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'TZS ${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final scheme = Theme.of(context).colorScheme;
    if (_isSuccess) {
      return Text(
        context.tr('deposit_success_redirect'),
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
      );
    }

    if (_isFailed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, false),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            context.tr('go_back_btn'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: scheme.onPrimary,
            ),
          ),
        ),
      );
    }

    // Waiting
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(Icons.phone_android_rounded, context.tr('deposit_step_phone')),
            _buildStepDivider(),
            _buildStep(Icons.dialpad_rounded, context.tr('deposit_step_pin')),
            _buildStepDivider(),
            _buildStep(Icons.check_circle_outline_rounded, context.tr('deposit_step_confirm')),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('payment_dont_close'),
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: scheme.primary),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 30,
      height: 1,
      margin: const EdgeInsets.only(bottom: 20),
      color: scheme.outlineVariant,
    );
  }

  Color get _statusColor {
    if (_isSuccess) return AppColors.success;
    if (_isFailed) return AppColors.error;
    return AppColors.success;
  }

  String get _statusLabel {
    if (_isSuccess) return context.tr('deposit_status_done');
    if (_isFailed) return context.tr('deposit_status_failed');
    return context.tr('deposit_status_processing');
  }

  String get _statusMessage {
    if (_isSuccess) return context.tr('deposit_success_msg');
    if (_isFailed) return context.tr('deposit_timeout_msg');
    return context.tr('deposit_waiting_msg');
  }
}
