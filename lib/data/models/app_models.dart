class AppNotification {
  final String id;
  final String type;
  final String message;
  final int? jobId;
  final String? actionUrl;
  DateTime? readAt;
  final DateTime createdAt;
  final String? _explicitTitle;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    this.jobId,
    this.actionUrl,
    this.readAt,
    required this.createdAt,
    String? title,
  }) : _explicitTitle = title;

  bool get isRead => readAt != null;

  String get title {
    final explicit = _explicitTitle;
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    if (type.contains('WorkerAccepted')) return 'Mfanyakazi Amekubali';
    if (type.contains('JobStatus')) return 'Hali ya Kazi';
    if (type.contains('JobAvailable')) return 'Kazi Mpya';
    if (type.contains('JobApplication')) return 'Maombi Mapya';
    if (type.contains('PaymentReceived')) return 'Malipo';
    return 'Taarifa';
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: data['message']?.toString() ?? 'Hakuna maelezo',
      jobId: data['job_id'] != null
          ? int.tryParse(data['job_id'].toString())
          : null,
      actionUrl: data['action_url']?.toString(),
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      title: data['title']?.toString(),
    );
  }

  AppNotification copyWith({DateTime? readAt}) {
    return AppNotification(
      id: id,
      type: type,
      message: message,
      jobId: jobId,
      actionUrl: actionUrl,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      title: _explicitTitle,
    );
  }
}

/// Home Stats Model
class HomeStats {
  final int totalWorkers;
  final int totalJobs;
  final int activeJobs;

  HomeStats({
    required this.totalWorkers,
    required this.totalJobs,
    required this.activeJobs,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalWorkers: json['total_workers'] ?? 0,
      totalJobs: json['total_jobs'] ?? 0,
      activeJobs: json['active_jobs'] ?? 0,
    );
  }
}

/// Client Dashboard Model (for muhitaji)
class ClientDashboard {
  final String role;
  final int posted;
  final int completed;
  final double totalPaid;
  final List<PaymentHistory> paymentHistory;

  ClientDashboard({
    required this.role,
    required this.posted,
    required this.completed,
    required this.totalPaid,
    this.paymentHistory = const [],
  });

  factory ClientDashboard.fromJson(Map<String, dynamic> json) {
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

    return ClientDashboard(
      role: json['role'] ?? 'muhitaji',
      posted: parseInt(json['posted']),
      completed: parseInt(json['completed']),
      totalPaid: parseDouble(json['totalPaid']),
      paymentHistory: json['paymentHistory'] != null
          ? (json['paymentHistory'] as List)
              .map((p) => PaymentHistory.fromJson(p))
              .toList()
          : [],
    );
  }
}

/// Payment History Model
class PaymentHistory {
  final int id;
  final int? workOrderId;
  final String? orderId;
  final double amount;
  final String status;
  final String? channel;
  final String? reference;
  final DateTime? createdAt;
  final PaymentJob? job;

  PaymentHistory({
    required this.id,
    this.workOrderId,
    this.orderId,
    required this.amount,
    required this.status,
    this.channel,
    this.reference,
    this.createdAt,
    this.job,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] ?? 0,
      workOrderId: json['work_order_id'],
      orderId: json['order_id'],
      amount: json['amount'] is String
          ? double.tryParse(json['amount']) ?? 0
          : (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      channel: json['channel'],
      reference: json['reference'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      job: json['job'] != null ? PaymentJob.fromJson(json['job']) : null,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
}

/// Payment Job (simplified job info for payment history)
class PaymentJob {
  final int id;
  final String title;
  final int price;
  final String status;
  final String? imageUrl;

  PaymentJob({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    this.imageUrl,
  });

  factory PaymentJob.fromJson(Map<String, dynamic> json) {
    return PaymentJob(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price'] is String
          ? int.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0),
      status: json['status'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

/// App Settings Model
class AppSettings {
  final double commissionRate;
  final double minWithdrawal;
  final String systemCurrency;

  AppSettings({
    required this.commissionRate,
    required this.minWithdrawal,
    required this.systemCurrency,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      commissionRate: (json['commission_rate'] ?? 10).toDouble(),
      minWithdrawal: (json['min_withdrawal'] ?? 5000).toDouble(),
      systemCurrency: json['system_currency'] ?? 'TZS',
    );
  }
}
