/// Safe int/double parsers (shared with Job model).
int _parseInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? fallback;
  if (v is double) return v.toInt();
  return fallback;
}

int? _parseIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  if (v is double) return v.toInt();
  return null;
}

/// Ombi la mfanyakazi (job_applications) — lingana na backend.
class JobApplication {
  final int id;
  final int workOrderId;
  final int workerId;
  final int proposedAmount;
  final String message;
  final String? etaText;
  final String status;
  final int? counterAmount;
  final String? clientResponseNote;
  final String? workerName;
  final String? workerPhotoUrl;

  /// Kutoka `job` nested (orodha ya mfanyakazi).
  final String? jobTitle;
  final String? clientName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobApplication({
    required this.id,
    required this.workOrderId,
    required this.workerId,
    required this.proposedAmount,
    required this.message,
    this.etaText,
    required this.status,
    this.counterAmount,
    this.clientResponseNote,
    this.workerName,
    this.workerPhotoUrl,
    this.jobTitle,
    this.clientName,
    this.createdAt,
    this.updatedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: _parseInt(json['id']),
      workOrderId: _parseInt(json['work_order_id']),
      workerId: _parseInt(json['worker_id']),
      proposedAmount: _parseInt(json['proposed_amount']),
      message: json['message']?.toString() ?? '',
      etaText: json['eta_text']?.toString(),
      status: json['status']?.toString() ?? 'applied',
      counterAmount: _parseIntOrNull(json['counter_amount']),
      clientResponseNote: json['client_response_note']?.toString(),
      workerName: json['worker']?['name']?.toString(),
      workerPhotoUrl: json['worker']?['profile_photo_url']?.toString(),
      jobTitle: json['job']?['title']?.toString(),
      clientName: json['job']?['muhitaji']?['name']?.toString() ??
          json['job']?['user']?['name']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  bool get canBeSelectedByClient {
    return status == 'applied' ||
        status == 'shortlisted' ||
        status == 'accepted_counter';
  }
}
