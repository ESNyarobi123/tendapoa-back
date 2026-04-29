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
      id: json['id'] ?? 0,
      workOrderId: json['work_order_id'] ?? 0,
      workerId: json['worker_id'] ?? 0,
      proposedAmount: json['proposed_amount'] is String
          ? int.tryParse(json['proposed_amount']) ?? 0
          : (json['proposed_amount'] ?? 0) as int,
      message: json['message']?.toString() ?? '',
      etaText: json['eta_text']?.toString(),
      status: json['status']?.toString() ?? 'applied',
      counterAmount: json['counter_amount'] != null
          ? (json['counter_amount'] is String
              ? int.tryParse(json['counter_amount'])
              : json['counter_amount'] as int?)
          : null,
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
