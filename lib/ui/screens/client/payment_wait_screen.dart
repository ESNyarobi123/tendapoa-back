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
  int _secondsRemaining = 120; // 2 minutes
  bool _isSuccess = false;
  bool _isFailed = false;
  bool _isRetrying = false;
  String _statusKey = 'payment_check_phone';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
          setState(() {
            _isFailed = true;
            _statusKey = 'payment_timeout';
          });
        }
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  void _startPolling() {
    // Poll immediately first
    _pollPaymentStatus();

    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (_isSuccess || _isFailed) {
        timer.cancel();
        return;
      }
      await _pollPaymentStatus();
    });
  }

  Future<void> _pollPaymentStatus() async {
    try {
      final result = await _jobService.pollPayment(widget.job.id);
      final done = result['done'] == true;

      if (done) {
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();

        if (mounted) {
          setState(() {
            _isSuccess = true;
            _statusKey = 'payment_success_msg';
          });

          // Refresh jobs
          context.read<ClientProvider>().loadMyJobs(silent: true);

          // Navigate to home after delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.clientHome,
                (route) => false,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Polling Error: $e');
    }
  }

  Future<void> _retryPayment() async {
    setState(() {
      _isRetrying = true;
      _isFailed = false;
      _statusKey = 'payment_retrying';
    });

    try {
      await _jobService.retryPayment(widget.job.id);

      if (mounted) {
        setState(() {
          _isRetrying = false;
          _secondsRemaining = 120;
          _statusKey = 'payment_check_phone';
        });
        _startPolling();
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _isFailed = true;
          _statusKey = 'payment_retry_failed';
        });
      }
    }
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Close button (top right)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => _showExitDialog(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                ),
              ),

              const Spacer(),

              // Main Content
              _buildMainContent(),

              const Spacer(),

              // Bottom Actions
              _buildBottomActions(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated Icon
        _buildAnimatedIcon(),

        const SizedBox(height: 40),

        // Status Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusLabel(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: _getStatusColor(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Status Message
        Text(
          context.tr(_statusKey),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 30),

        // Timer (only when waiting)
        if (!_isSuccess && !_isFailed) _buildTimer(),

        // Job Info Card
        const SizedBox(height: 30),
        _buildJobInfoCard(),
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    if (_isSuccess) {
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 80, color: Colors.white)
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
      ).animate().scale(begin: const Offset(0.5, 0.5), duration: 400.ms);
    }

    if (_isFailed) {
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.error, Color(0xFFDC2626)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.close_rounded, size: 80, color: Colors.white),
      ).animate().shake(duration: 500.ms);
    }

    // Waiting state with pulse animation
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15 + (_pulseController.value * 0.15)),
                blurRadius: 30 + (_pulseController.value * 20),
                spreadRadius: _pulseController.value * 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
              ),
              // Inner content
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: _secondsRemaining < 30 ? AppColors.error : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            _formattedTime,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: _secondsRemaining < 30 ? AppColors.error : AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'TZS ${_formatPrice(widget.job.price)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_isSuccess) {
      return const SizedBox.shrink();
    }

    if (_isFailed) {
      return Column(
        children: [
          // Retry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRetrying ? null : _retryPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isRetrying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          context.tr('payment_retry_btn'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 15),
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.tr('cancel_and_go_back'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // Waiting state
    return Column(
      children: [
        Text(
          context.tr('payment_dont_close'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.4),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(Icons.phone_android_rounded, context.tr('payment_check_phone_label')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInfoChip(Icons.lock_outline_rounded, context.tr('payment_enter_pin')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInfoChip(Icons.check_circle_outline_rounded, context.tr('payment_confirm')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_isSuccess) return AppColors.success;
    if (_isFailed) return AppColors.error;
    return AppColors.primary;
  }

  String _getStatusLabel() {
    if (_isSuccess) return context.tr('payment_status_completed');
    if (_isFailed) return context.tr('payment_status_failed');
    return context.tr('payment_status_waiting');
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('payment_exit_title')),
        content: Text(context.tr('payment_exit_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('continue_waiting')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
            ),
            child: Text(context.tr('leave_btn')),
          ),
        ],
      ),
    );
  }
}
