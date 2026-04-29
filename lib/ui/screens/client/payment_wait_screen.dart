import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

class PaymentWaitScreen extends StatefulWidget {
  final Job job;
  const PaymentWaitScreen({super.key, required this.job});

  @override
  State<PaymentWaitScreen> createState() => _PaymentWaitScreenState();
}

class _PaymentWaitScreenState extends State<PaymentWaitScreen>
    with SingleTickerProviderStateMixin {
  final JobService _jobService = JobService();
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 120;
  bool _isSuccess = false;
  bool _isFailed = false;
  bool _isRetrying = false;

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
    _pollPaymentStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isSuccess || _isFailed) {
        timer.cancel();
        return;
      }
      _pollPaymentStatus();
    });
  }

  Future<void> _pollPaymentStatus() async {
    try {
      final result = await _jobService.pollPayment(widget.job.id);
      if (result['done'] == true && mounted) {
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();
        setState(() => _isSuccess = true);
        context.read<ClientProvider>().loadMyJobs(silent: true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRouter.clientHome, (route) => false);
          }
        });
      }
    } catch (e) {
      debugPrint('Polling Error: $e');
    }
  }

  Future<void> _retryPayment() async {
    setState(() {
      _isRetrying = true;
      _isFailed = false;
    });
    try {
      await _jobService.retryPayment(widget.job.id);
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _secondsRemaining = 120;
        });
        _startPolling();
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _isFailed = true;
        });
      }
    }
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  // ─── BUILD ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: _showExitDialog,
                  child: Container(
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
              _buildStatusIcon(),
              const SizedBox(height: 32),
              _buildStatusPill(),
              const SizedBox(height: 16),
              _buildStatusMessage(),
              const SizedBox(height: 28),
              if (!_isSuccess && !_isFailed) _buildTimer(),
              if (!_isSuccess && !_isFailed) const SizedBox(height: 28),
              _buildJobCard(),
              const Spacer(),
              _buildBottomActions(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STATUS ICON ────────────────────────────────────────────────────

  Widget _buildStatusIcon() {
    const double size = 120;

    if (_isSuccess) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.success, Color(0xFF059669)]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
      )
          .animate()
          .scale(begin: const Offset(0.5, 0.5), duration: 500.ms)
          .then()
          .shimmer(duration: 800.ms);
    }

    if (_isFailed) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.error, Color(0xFFDC2626)]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.error.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        child: const Icon(Icons.close_rounded, size: 60, color: Colors.white),
      ).animate().shake(duration: 500.ms);
    }

    // Waiting — clean concentric pulse
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final v = _pulseController.value;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.08 + v * 0.12),
                blurRadius: 25 + v * 20,
                spreadRadius: v * 8,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                scheme.primary.withValues(alpha: 0.12),
                scheme.primary.withValues(alpha: 0.04),
              ]),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              size: 44,
              color: scheme.primary,
            ),
          ),
        );
      },
    );
  }

  // ─── STATUS PILL ────────────────────────────────────────────────────

  Widget _buildStatusPill() {
    final scheme = Theme.of(context).colorScheme;
    final color = _isSuccess
        ? AppColors.success
        : _isFailed
            ? AppColors.error
            : scheme.primary;
    final label = _isSuccess
        ? context.tr('payment_status_completed')
        : _isFailed
            ? context.tr('payment_status_failed')
            : context.tr('payment_status_waiting');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: color)),
    );
  }

  // ─── STATUS MESSAGE ─────────────────────────────────────────────────

  Widget _buildStatusMessage() {
    final scheme = Theme.of(context).colorScheme;
    final key = _isSuccess
        ? 'payment_success_msg'
        : _isFailed
            ? 'payment_timeout'
            : 'payment_check_phone';
    return Text(
      context.tr(key),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
        height: 1.4,
      ),
    );
  }

  // ─── TIMER ──────────────────────────────────────────────────────────

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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        _formattedTime,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 3,
          color:
              _secondsRemaining < 30 ? scheme.error : scheme.onSurface,
        ),
      ),
    );
  }

  // ─── JOB CARD ───────────────────────────────────────────────────────

  Widget _buildJobCard() {
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
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              color: scheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'TZS ${_formatPrice(widget.job.price)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM ACTIONS ─────────────────────────────────────────────────

  Widget _buildBottomActions() {
    if (_isSuccess) return const SizedBox.shrink();

    if (_isFailed) {
      final scheme = Theme.of(context).colorScheme;
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRetrying ? null : _retryPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isRetrying
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: scheme.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20, color: scheme.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('payment_retry_btn'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.tr('cancel_and_go_back'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // Waiting
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(Icons.phone_android_rounded,
                context.tr('payment_check_phone_label')),
            _stepDivider(),
            _buildStep(Icons.dialpad_rounded, context.tr('payment_enter_pin')),
            _stepDivider(),
            _buildStep(Icons.check_circle_outline_rounded,
                context.tr('payment_confirm')),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          context.tr('payment_dont_close'),
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
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

  Widget _stepDivider() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        width: 28,
        height: 1,
        margin: const EdgeInsets.only(bottom: 20),
        color: scheme.outlineVariant);
  }

  void _showExitDialog() {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('payment_exit_title')),
        content: Text(context.tr('payment_exit_message')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('continue_waiting'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
            child: Text(context.tr('leave_btn')),
          ),
        ],
      ),
    );
  }
}
