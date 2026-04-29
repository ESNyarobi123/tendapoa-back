import 'job_application_model.dart';

/// Job Model
class Job {
  final int id;
  final String title;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final int price;
  final String status;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final String? addressText;
  final String? phone;
  final int? userId;
  final String? userName;
  final String? userPhotoUrl;
  final String? userPhone;
  final int? workerId;
  final String? workerName;
  final String? workerPhotoUrl;

  /// Mfanyakazi aliyechaguliwa kabla ya malipo (escrow)
  final int? selectedWorkerId;
  final String? selectedWorkerName;
  final String? selectedWorkerPhotoUrl;

  /// Kiasi kilichokubaliwa baada ya kuchagua mfanyakazi
  final int? agreedAmount;
  final String? completionCode;
  final DateTime? createdAt;
  final double? distance;
  final DistanceInfo? distanceInfo;
  final List<JobComment>? comments;
  final List<JobApplication>? applications;

  Job({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.price,
    required this.status,
    this.imageUrl,
    this.lat,
    this.lng,
    this.addressText,
    this.phone,
    this.userId,
    this.userName,
    this.userPhotoUrl,
    this.userPhone,
    this.workerId,
    this.workerName,
    this.workerPhotoUrl,
    this.selectedWorkerId,
    this.selectedWorkerName,
    this.selectedWorkerPhotoUrl,
    this.agreedAmount,
    this.completionCode,
    this.createdAt,
    this.distance,
    this.distanceInfo,
    this.comments,
    this.applications,
  });

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    if (v is double) return v.toInt();
    return fallback;
  }

  static int? _parseIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }

  static double? _parseDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    // Parse distance from distance_info if available
    double? parsedDistance;
    if (json['distance_info'] != null &&
        json['distance_info']['distance'] != null) {
      final d = json['distance_info']['distance'];
      parsedDistance = d is String ? double.tryParse(d) : d?.toDouble();
    } else if (json['distance'] != null) {
      final d = json['distance'];
      parsedDistance = d is String ? double.tryParse(d) : d?.toDouble();
    }

    return Job(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: _parseIntOrNull(json['category_id']),
      categoryName: json['category']?['name']?.toString() ??
          json['category_name']?.toString(),
      categoryIcon: json['category']?['icon']?.toString() ??
          json['category_icon']?.toString(),
      price: _parseInt(json['price']),
      status: json['status']?.toString() ?? 'open',
      imageUrl: json['image_url']?.toString(),
      lat: _parseDoubleOrNull(json['lat']),
      lng: _parseDoubleOrNull(json['lng']),
      addressText: json['address_text']?.toString(),
      phone: json['phone']?.toString(),
      userId: _parseIntOrNull(json['user_id']),
      userName: json['muhitaji']?['name']?.toString() ??
          json['user']?['name']?.toString() ??
          json['user_name']?.toString(),
      userPhotoUrl: json['muhitaji']?['profile_photo_url']?.toString() ??
          json['user']?['profile_photo_url']?.toString() ??
          json['user_photo_url']?.toString(),
      userPhone: json['muhitaji']?['phone']?.toString() ??
          json['user']?['phone']?.toString() ??
          json['user_phone']?.toString(),
      workerId:
          _parseIntOrNull(json['accepted_worker_id'] ?? json['worker_id']),
      workerName: json['accepted_worker']?['name']?.toString() ??
          json['worker']?['name']?.toString() ??
          json['worker_name']?.toString(),
      workerPhotoUrl:
          json['accepted_worker']?['profile_photo_url']?.toString() ??
              json['worker']?['profile_photo_url']?.toString(),
      selectedWorkerId: _parseIntOrNull(json['selected_worker_id']),
      selectedWorkerName: json['selected_worker']?['name']?.toString(),
      selectedWorkerPhotoUrl:
          json['selected_worker']?['profile_photo_url']?.toString(),
      agreedAmount: _parseIntOrNull(json['agreed_amount']),
      completionCode: json['completion_code']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      distance: parsedDistance,
      distanceInfo: json['distance_info'] != null
          ? DistanceInfo.fromJson(json['distance_info'])
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((c) => JobComment.fromJson(c))
              .toList()
          : null,
      applications: json['applications'] != null
          ? (json['applications'] as List)
              .map((a) => JobApplication.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  // API returns: posted, in_progress, assigned, completed, cancelled
  bool get isOpen => status == 'open' || status == 'posted';
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isAccepted =>
      status == 'accepted' || status == 'in_progress' || status == 'assigned';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// Kuna mfanyakazi aliyefungwa (aliyekubaliwa au aliyechaguliwa kabla ya malipo).
  bool get hasWorkerOrSelection => workerId != null || selectedWorkerId != null;

  /// Kazi bado inapokea maombi mapya (mfumo mpya).
  bool get acceptsNewApplications =>
      (status == 'open' || status == 'posted') &&
      selectedWorkerId == null &&
      workerId == null;

  /// Mfanyakazi huyu tayari amewasilisha ombi (ikiwa API imerudisha `applications`).
  bool workerHasApplication(int? workerUserId) {
    if (workerUserId == null || applications == null) return false;
    return applications!.any((a) => a.workerId == workerUserId);
  }

  int get displayAgreedOrPrice => agreedAmount ?? price;

  String get effectiveWorkerDisplayName =>
      workerName ?? selectedWorkerName ?? 'Mfanyakazi';

  bool get isAwaitingPayment => status == 'awaiting_payment';
  bool get isFunded => status == 'funded';
  bool get isSubmitted =>
      status == 'submitted' || status == 'ready_for_confirmation';

  /// Mfanyakazi aliyeidhinishwa (baada ya escrow).
  bool isAcceptedWorker(int? userId) =>
      userId != null && workerId != null && workerId == userId;

  /// Umechaguliwa, mteja bado hajalipa escrow.
  bool isPendingEscrowAsSelectedWorker(int? userId) =>
      userId != null && isAwaitingPayment && selectedWorkerId == userId;
}

/// Job Comment / Application
class JobComment {
  final int id;
  final int jobId;
  final int userId;
  final String? userName;
  final String? userPhoto;
  final String message;
  final int? proposedPrice;
  final bool isApplication;
  final DateTime? createdAt;

  JobComment({
    required this.id,
    required this.jobId,
    required this.userId,
    this.userName,
    this.userPhoto,
    required this.message,
    this.proposedPrice,
    this.isApplication = false,
    this.createdAt,
  });

  factory JobComment.fromJson(Map<String, dynamic> json) {
    return JobComment(
      id: Job._parseInt(json['id']),
      jobId: Job._parseInt(json['work_order_id'] ?? json['job_id']),
      userId: Job._parseInt(json['user_id']),
      userName:
          json['user']?['name']?.toString() ?? json['user_name']?.toString(),
      userPhoto: json['user']?['profile_photo_url']?.toString(),
      message: json['message']?.toString() ?? '',
      proposedPrice:
          Job._parseIntOrNull(json['bid_amount'] ?? json['proposed_price']),
      isApplication: json['is_application'] == true ||
          json['is_application'] == 1 ||
          json['is_application'] == '1',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

/// Nearby Workers Response
class NearbyWorkersResponse {
  final int count;
  final List<NearbyWorker> workers;

  NearbyWorkersResponse({required this.count, required this.workers});

  factory NearbyWorkersResponse.fromJson(Map<String, dynamic> json) {
    return NearbyWorkersResponse(
      count: json['count'] ?? 0,
      workers: json['workers'] != null
          ? (json['workers'] as List)
              .map((w) => NearbyWorker.fromJson(w))
              .toList()
          : [],
    );
  }
}

class NearbyWorker {
  final int id;
  final String name;
  final double? lat;
  final double? lng;
  final double? distance;

  NearbyWorker(
      {required this.id,
      required this.name,
      this.lat,
      this.lng,
      this.distance});

  factory NearbyWorker.fromJson(Map<String, dynamic> json) {
    return NearbyWorker(
      id: Job._parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      lat: Job._parseDoubleOrNull(json['lat']),
      lng: Job._parseDoubleOrNull(json['lng']),
      distance: Job._parseDoubleOrNull(json['distance']),
    );
  }
}

/// Distance Info from API
class DistanceInfo {
  final double? distance;
  final String category; // near, moderate, far, unknown
  final String color;
  final String bgColor;
  final String textColor;
  final String label;

  DistanceInfo({
    this.distance,
    required this.category,
    required this.color,
    required this.bgColor,
    required this.textColor,
    required this.label,
  });

  factory DistanceInfo.fromJson(Map<String, dynamic> json) {
    return DistanceInfo(
      distance: json['distance'] is String
          ? double.tryParse(json['distance'])
          : json['distance']?.toDouble(),
      category: json['category'] ?? 'unknown',
      color: json['color'] ?? '#6b7280',
      bgColor: json['bg_color'] ?? '#f3f4f6',
      textColor: json['text_color'] ?? '#6b7280',
      label: json['label'] ?? 'Umbali haujulikani',
    );
  }

  bool get isNear => category == 'near';
  bool get isModerate => category == 'moderate';
  bool get isFar => category == 'far';
  bool get isUnknown => category == 'unknown';
}
