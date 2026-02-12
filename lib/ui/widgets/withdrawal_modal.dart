import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/wallet_service.dart';

class WithdrawalModal extends StatefulWidget {
  final double currentBalance;
  final VoidCallback onSubmitted;

  const WithdrawalModal({
    super.key,
    required this.currentBalance,
    required this.onSubmitted,
  });

  @override
  State<WithdrawalModal> createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends State<WithdrawalModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _walletService = WalletService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        top: 25,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(context.tr('withdrawal_request_title'),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.walletAccent, size: 20),
                  const SizedBox(width: 12),
                  Text('${context.tr('balance_label')} ',
                      style:
                          TextStyle(color: Colors.orange[900], fontSize: 13)),
                  Text('${AppConstants.currency} ${widget.currentBalance}',
                      style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildLabel(context.tr('amount_to_withdraw_label')),
            _buildInput(
              controller: _amountController,
              hint: '0.00',
              icon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return context.tr('enter_amount_required');
                final amount = double.tryParse(val);
                if (amount == null) return context.tr('invalid_number_error');
                if (amount < 2000) return context.tr('min_2000_error');
                if (amount > widget.currentBalance) return context.tr('insufficient_balance_error');
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel(context.tr('payment_phone_label')),
            _buildInput(
              controller: _phoneController,
              hint: '07XXXXXXXX',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.isEmpty) return context.tr('enter_phone_required');
                if (val.length < 10) return context.tr('invalid_number_error');
                return null;
              },
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(context.tr('submit_request_btn').toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
              fontSize: 13)),
    );
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final amount = int.parse(_amountController.text.replaceAll(',', ''));
      await _walletService.submitWithdrawal(
        amount: amount,
        phoneNumber: _phoneController.text,
        registeredName: _phoneController.text, // Using phone as name fallback
        networkType: 'vodacom', // Default network
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.tr('withdrawal_success_msg')),
              backgroundColor: const Color(0xFF22C55E)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${context.tr('error_prefix')}: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
