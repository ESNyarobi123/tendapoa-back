import '../models/wallet_model.dart';
import 'api_service.dart';

class WalletService {
  final ApiService _api = ApiService();

  Future<Wallet> getWallet() async {
    final response = await _api.get('/wallet');
    final data = response.data!['data'] ?? response.data!;
    return Wallet.fromJson(data);
  }

  Future<double> getWalletBalance() async {
    final response = await _api.get('/withdrawal/wallet');
    return (response.data!['balance'] ?? 0).toDouble();
  }

  Future<void> submitWithdrawal(double amount, String phone) async {
    await _api.post('/withdrawal/submit', body: {
      'amount': amount,
      'phone_number': phone,
    });
  }

  Future<List<Map<String, dynamic>>> getWithdrawalHistory() async {
    final response = await _api.get('/withdrawal/history');
    final List data = response.data!['data'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }
}
