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
    return Wallet(
      balance: json['balance'] is String
          ? double.tryParse(json['balance']) ?? 0
          : (json['balance'] ?? 0).toDouble(),
      totalEarnings: json['total_earnings'] is String
          ? double.tryParse(json['total_earnings']) ?? 0
          : (json['total_earnings'] ?? 0).toDouble(),
      pendingAmount: json['pending_amount'] is String
          ? double.tryParse(json['pending_amount']) ?? 0
          : (json['pending_amount'] ?? 0).toDouble(),
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
      status: json['status'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

/// Worker Dashboard Model
class WorkerDashboard {
  final double available; // Wallet Balance
  final double earnTotal;
  final double withdrawn;
  final int doneCount;
  final List<Job> currentJobs;
  final List<Job> completedJobs;
  final List<Transaction> earningsHistory;
  final List<Transaction> withdrawalsHistory;

  WorkerDashboard({
    required this.available,
    required this.earnTotal,
    required this.withdrawn,
    required this.doneCount,
    this.currentJobs = const [],
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
      doneCount: parseInt(json['done']),
      currentJobs: json['currentJobs'] != null
          ? (json['currentJobs'] as List).map((j) => Job.fromJson(j)).toList()
          : [],
      completedJobs: json['completedJobs'] != null
          ? (json['completedJobs'] as List).map((j) => Job.fromJson(j)).toList()
          : [],
      earningsHistory: json['earningsHistory'] != null
          ? (json['earningsHistory'] as List)
              .map((t) => Transaction.fromJson(t))
              .toList()
          : [],
      withdrawalsHistory: json['withdrawalsHistory'] != null
          ? (json['withdrawalsHistory'] as List)
              .map((t) => Transaction.fromJson(t))
              .toList()
          : [],
    );
  }
}
