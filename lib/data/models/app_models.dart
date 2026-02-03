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
