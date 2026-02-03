import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

class PaymentWaitScreen extends StatefulWidget {
  final Job job;
  const PaymentWaitScreen({super.key, required this.job});

  @override
  State<PaymentWaitScreen> createState() => _PaymentWaitScreenState();
}

class _PaymentWaitScreenState extends State<PaymentWaitScreen> {
  final JobService _jobService = JobService();
  Timer? _pollingTimer;
  int _secondsRemaining = 60;
  bool _isSuccess = false;
  String _statusMessage =
      'Tafadhali kagua simu yako na uingize PIN ya M-Pesa...';

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isSuccess || _secondsRemaining == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        final updatedJob = await _jobService.getJobDetails(widget.job.id);
        if (updatedJob.status != 'pending_payment') {
          timer.cancel();
          setState(() {
            _isSuccess = true;
            _statusMessage = 'Malipo Yamefanikiwa! Kazi yako sasa ipo hewani.';
          });

          // Refresh context providers
          if (mounted) {
            context.read<ClientProvider>().loadMyJobs(silent: true);
          }

          // Navigate back after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) Navigator.pop(context, true);
          });
        }
      } catch (e) {
        print('Polling Error: $e');
      }

      if (_secondsRemaining == 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _statusMessage =
              'Muda umeisha. Tafadhali jaribu tena ikiwa malipo hayajakamilika.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ANIMATED ICON
            if (!_isSuccess)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: const Icon(Icons.phonelink_ring_rounded,
                          size: 60, color: AppColors.primary)
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                          duration: 1.seconds,
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          curve: Curves.easeInOut)
                      .then()
                      .scale(
                          duration: 1.seconds,
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(1, 1),
                          curve: Curves.easeInOut),
                ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                        size: 70, color: Colors.white)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
              ),

            const SizedBox(height: 50),

            // STATUS TEXT
            Text(
              _isSuccess ? 'MUAMALA UMEKAMILIKA' : 'SUBIRI KIDOGO...',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: _isSuccess
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            // TIMER OR BUTTON
            if (!_isSuccess && _secondsRemaining > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569)),
                ),
              ),

            if (_secondsRemaining == 0 && !_isSuccess)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('RUDI NYUMA',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 20),

            if (!_isSuccess)
              Text(
                'Usifunge ukurasa huu mpaka utakapopata uthibitisho.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4), fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}
