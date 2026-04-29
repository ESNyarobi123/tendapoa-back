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
    final bal = (data['balance'] ?? 0).toDouble();
    final held = (data['held_balance'] ?? 0).toDouble();
    final avail = (data['available_balance'] ?? data['balance'] ?? 0).toDouble();
    return {
      'balance': bal,
      'held_balance': held,
      'available_balance': avail,
      'user_id': data['user_id'],
      'created_at': data['created_at'],
    };
  }

  /// Initiate a deposit via ClickPesa USSD Push
  /// Required: amount (int), phone_number (String)
  /// Returns: {success, transaction_id, message}
  Future<Map<String, dynamic>> deposit({
    required int amount,
    required String phoneNumber,
  }) async {
    final response = await _api.post('/wallet/deposit', body: {
      'amount': amount,
      'phone_number': phoneNumber,
    });
    return response.data!;
  }

  /// Poll deposit status
  /// Returns: {done: bool, status: String}
  Future<Map<String, dynamic>> pollDeposit(int transactionId) async {
    final response = await _api.get('/wallet/deposit/$transactionId/poll');
    return {
      'done': response.data!['done'] ?? false,
      'status': response.data!['status'] ?? 'pending',
    };
  }

  /// Submit withdrawal request via ClickPesa payout
  /// Required fields: amount, phone_number
  Future<Map<String, dynamic>> submitWithdrawal({
    required int amount,
    required String phoneNumber,
    required String registeredName,
    required String networkType,
    String method = 'mobile_money',
  }) async {
    final response = await _api.post('/wallet/withdraw', body: {
      'amount': amount,
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
