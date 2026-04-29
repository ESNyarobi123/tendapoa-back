import 'job_model.dart';

/// Wallet Model
class Wallet {
  final double balance;
  final double totalEarnings;
  final double pendingAmount;
  final List<Transaction>? transactions;

  Wallet({
    required this.balance,
    this.totalEarnings = 0,
    this.pendingAmount = 0,
    this.transactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) {
      if (v is String) return double.tryParse(v) ?? 0;
      if (v is num) return v.toDouble();
      return 0;
    }

    final held = toD(json['held_balance'] ?? json['pending_amount']);
    final avail = toD(json['available_balance'] ?? json['balance']);
    final rawBal = toD(json['balance']);

    return Wallet(
      balance: json['available_balance'] != null ? avail : rawBal,
      totalEarnings: json['total_earnings'] is String
          ? double.tryParse(json['total_earnings']) ?? 0
          : (json['total_earnings'] ?? json['total_earned'] ?? 0).toDouble(),
      pendingAmount: held,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((t) => Transaction.fromJson(t))
              .toList()
          : null,
    );
  }
}

/// Transaction Model
class Transaction {
  final int id;
  final String type;
  final double amount;
  final String status;
  final String? description;
  final DateTime? createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0),
      type: json['type'] ?? '',
      amount: json['amount'] is String
          ? double.tryParse(json['amount']) ?? 0
          : (json['amount'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? json['type']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// WalletTransaction au Withdrawal kutoka `/dashboard` ya mfanyakazi.
  factory Transaction.fromWorkerDashboardEntry(dynamic raw) {
    final json = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
    final hasMethod = json.containsKey('method');
    if (hasMethod) {
      final acct = json['account']?.toString() ?? '';
      final method = json['method']?.toString() ?? '';
      return Transaction(
        id: json['id'] is String
            ? int.tryParse(json['id']) ?? 0
            : (json['id'] ?? 0),
        type: 'withdrawal',
        amount: json['amount'] is String
            ? double.tryParse(json['amount']) ?? 0
            : (json['amount'] ?? 0).toDouble(),
        status: json['status']?.toString() ?? '',
        description: [method, acct].where((s) => s.isNotEmpty).join(' · '),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
    }
    return Transaction.fromJson(json);
  }
}

/// Worker Dashboard Model
class WorkerDashboard {
  final double available; // Wallet Balance
  final double earnTotal;
  final double withdrawn;
  final double heldBalance;
  final double thisMonthEarnings;
  final int doneCount;
  final List<Job> currentJobs;
  final List<Job> attentionJobs;
  final List<Job> completedJobs;
  final List<Transaction> earningsHistory;
  final List<Transaction> withdrawalsHistory;

  WorkerDashboard({
    required this.available,
    required this.earnTotal,
    required this.withdrawn,
    this.heldBalance = 0,
    this.thisMonthEarnings = 0,
    required this.doneCount,
    this.currentJobs = const [],
    this.attentionJobs = const [],
    this.completedJobs = const [],
    this.earningsHistory = const [],
    this.withdrawalsHistory = const [],
  });

  factory WorkerDashboard.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is String) return double.tryParse(val) ?? 0.0;
      if (val is num) return val.toDouble();
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is String) return int.tryParse(val) ?? 0;
      if (val is num) return val.toInt();
      return 0;
    }

    return WorkerDashboard(
      available: parseDouble(json['available']),
      earnTotal: parseDouble(json['earnTotal']),
      withdrawn: parseDouble(json['withdrawn']),
      heldBalance: parseDouble(json['held_balance']),
      thisMonthEarnings: parseDouble(json['thisMonthEarnings']),
      doneCount: parseInt(json['done']),
      currentJobs: json['currentJobs'] != null
          ? (json['currentJobs'] as List)
              .map((j) => Job.fromJson(Map<String, dynamic>.from(j as Map)))
              .toList()
          : [],
      attentionJobs: json['attention_jobs'] != null
          ? (json['attention_jobs'] as List)
              .map((j) => Job.fromJson(Map<String, dynamic>.from(j as Map)))
              .toList()
          : [],
      completedJobs: json['completedJobs'] != null
          ? (json['completedJobs'] as List)
              .map((j) => Job.fromJson(Map<String, dynamic>.from(j as Map)))
              .toList()
          : [],
      earningsHistory: json['earningsHistory'] != null
          ? (json['earningsHistory'] as List)
              .map((t) => Transaction.fromWorkerDashboardEntry(t))
              .toList()
          : [],
      withdrawalsHistory: json['withdrawalsHistory'] != null
          ? (json['withdrawalsHistory'] as List)
              .map((t) => Transaction.fromWorkerDashboardEntry(t))
              .toList()
          : [],
    );
  }
}
