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
  final String? completionCode;
  final DateTime? createdAt;
  final double? distance;
  final DistanceInfo? distanceInfo;
  final List<JobComment>? comments;

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
    this.completionCode,
    this.createdAt,
    this.distance,
    this.distanceInfo,
    this.comments,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Parse distance from distance_info if available
    double? parsedDistance;
    if (json['distance_info'] != null && json['distance_info']['distance'] != null) {
      final d = json['distance_info']['distance'];
      parsedDistance = d is String ? double.tryParse(d) : d?.toDouble();
    } else if (json['distance'] != null) {
      final d = json['distance'];
      parsedDistance = d is String ? double.tryParse(d) : d?.toDouble();
    }

    return Job(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      categoryId: json['category_id'],
      categoryName: json['category']?['name'] ?? json['category_name'],
      categoryIcon: json['category']?['icon'] ?? json['category_icon'],
      price: json['price'] is String
          ? int.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0),
      status: json['status'] ?? 'open',
      imageUrl: json['image_url'],
      lat: json['lat'] is String
          ? double.tryParse(json['lat'])
          : json['lat']?.toDouble(),
      lng: json['lng'] is String
          ? double.tryParse(json['lng'])
          : json['lng']?.toDouble(),
      addressText: json['address_text'],
      phone: json['phone'],
      userId: json['user_id'],
      userName: json['muhitaji']?['name'] ?? json['user']?['name'] ?? json['user_name'],
      userPhotoUrl:
          json['muhitaji']?['profile_photo_url'] ?? json['user']?['profile_photo_url'] ?? json['user_photo_url'],
      userPhone: json['muhitaji']?['phone'] ?? json['user']?['phone'] ?? json['user_phone'],
      workerId: json['accepted_worker_id'] ?? json['worker_id'],
      workerName: json['accepted_worker']?['name'] ?? json['worker']?['name'] ?? json['worker_name'],
      completionCode: json['completion_code'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
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
    );
  }

  // API returns: posted, in_progress, assigned, completed, cancelled
  bool get isOpen => status == 'open' || status == 'posted';
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isAccepted => status == 'accepted' || status == 'in_progress' || status == 'assigned';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
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
      id: json['id'] ?? 0,
      jobId: json['work_order_id'] ?? json['job_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user']?['name'] ?? json['user_name'],
      userPhoto: json['user']?['profile_photo_url'],
      message: json['message'] ?? '',
      proposedPrice: json['bid_amount'] ?? json['proposed_price'],
      isApplication: json['is_application'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: json['lat'] is String
          ? double.tryParse(json['lat'])
          : json['lat']?.toDouble(),
      lng: json['lng'] is String
          ? double.tryParse(json['lng'])
          : json['lng']?.toDouble(),
      distance: json['distance'] is String
          ? double.tryParse(json['distance'])
          : json['distance']?.toDouble(),
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
