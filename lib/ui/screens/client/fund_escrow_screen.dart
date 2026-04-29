import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../../data/services/job_service.dart';
import '../../../providers/providers.dart';

/// Malipo ya escrow baada ya kuchagua mfanyakazi (`awaiting_payment`).
class FundEscrowScreen extends StatefulWidget {
  const FundEscrowScreen({super.key, required this.job});

  final Job job;

  @override
  State<FundEscrowScreen> createState() => _FundEscrowScreenState();
}

class _FundEscrowScreenState extends State<FundEscrowScreen> {
  final JobService _jobService = JobService();
  final TextEditingController _phoneController = TextEditingController();
  bool _busy = false;
  Timer? _pollTimer;
  late Job _job;
  String? _statusNote;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  int get _amount => _job.displayAgreedOrPrice;

  Future<void> _payWallet() async {
    setState(() {
      _busy = true;
      _statusNote = null;
    });
    try {
      final updated = await _jobService.fundJobFromWallet(_job.id);
      if (!mounted) return;
      await context.read<ClientProvider>().loadDashboard();
      if (!mounted) return;
      await context.read<ClientProvider>().loadWalletBalance();
      if (!mounted) return;
      setState(() {
        _job = updated;
        _busy = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Malipo yamefanikiwa!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _statusNote = e.toString();
      });
    }
  }

  Future<void> _payExternal() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weka nambari ya simu')),
      );
      return;
    }
    setState(() {
      _busy = true;
      _statusNote = null;
    });
    try {
      await _jobService.fundJobExternal(_job.id, phone);
      if (!mounted) return;
      setState(() => _busy = false);
      _startPolling();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subiri USSD kwenye simu yako…')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _statusNote = e.toString();
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final r = await _jobService.pollJobFund(_job.id);
        final done = r['done'] == true;
        final st = r['status']?.toString() ?? '';
        if (done && st == 'COMPLETED') {
          _pollTimer?.cancel();
          if (!mounted) return;
          await context.read<ClientProvider>().loadDashboard();
          if (!mounted) return;
          await context.read<ClientProvider>().loadWalletBalance();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Malipo yamekamilika!')),
          );
          Navigator.pop(context, true);
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wallet = context.watch<ClientProvider>().walletBalance;
    final fmt = NumberFormat('#,###');
    final canWallet = wallet >= _amount;

    if (_job.status != 'awaiting_payment') {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: const Text('Malipo'),
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _job.status == 'funded' || _job.status == 'in_progress'
                  ? 'Kazi tayari imelipiwa.'
                  : 'Hali ya kazi si awaiting_payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Lipa escrow'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _job.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kiasi kilichokubaliwa: TZS ${fmt.format(_amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Salio linalopatikana: TZS ${fmt.format(wallet.toInt())}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          if (_statusNote != null) ...[
            const SizedBox(height: 12),
            Text(_statusNote!, style: TextStyle(color: scheme.error)),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _busy || !canWallet ? null : _payWallet,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(canWallet ? 'Lipa kutoka pochi' : 'Salio halitoshi kwenye pochi'),
          ),
          const SizedBox(height: 32),
          Text(
            'Au lipa kwa simu (USSD)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: '07XXXXXXXX au 2557XXXXXXXX',
              hintStyle: TextStyle(color: scheme.onSurfaceVariant),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _payExternal,
            child: const Text('Anzisha malipo ya nje'),
          ),
        ],
      ),
    );
  }
}
