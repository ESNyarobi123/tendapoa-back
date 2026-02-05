import '../models/wallet_model.dart';
import 'api_service.dart';

class WalletService {
  static WalletService? _instance;
  final ApiService _api = ApiService();

  WalletService._internal();

  factory WalletService() {
    _instance ??= WalletService._internal();
    return _instance!;
  }

  Future<Wallet> getWallet() async {
    final response = await _api.get('/wallet');
    final data = response.data!['data'] ?? response.data!;
    return Wallet.fromJson(data);
  }

  /// Get wallet balance for any user (muhitaji or mfanyakazi)
  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _api.get('/withdrawal/wallet');
    final data = response.data!['data'] ?? response.data!;
    return {
      'balance': (data['balance'] ?? 0).toDouble(),
      'user_id': data['user_id'],
      'created_at': data['created_at'],
    };
  }

  /// Submit withdrawal request
  /// Required fields: amount, phone_number, registered_name, network_type, method
  Future<Map<String, dynamic>> submitWithdrawal({
    required int amount,
    required String phoneNumber,
    required String registeredName,
    required String networkType,
    String method = 'mobile_money',
  }) async {
    final response = await _api.post('/withdrawal/submit', body: {
      'amount': amount.toString(),
      'phone_number': phoneNumber,
      'registered_name': registeredName,
      'network_type': networkType,
      'method': method,
    });
    return response.data!;
  }

  /// Get withdrawal history (for mfanyakazi/admin only currently)
  Future<List<Map<String, dynamic>>> getWithdrawalHistory() async {
    final response = await _api.get('/withdrawal/history');
    final data = response.data!['data'];
    if (data is Map && data['data'] != null) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
