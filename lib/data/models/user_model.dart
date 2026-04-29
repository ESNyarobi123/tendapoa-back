/// User Model
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profilePhotoUrl;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profilePhotoUrl,
    this.lat,
    this.lng,
    this.createdAt,
  });

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    if (v is double) return v.toInt();
    return fallback;
  }

  static double? _parseDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'muhitaji',
      phone: json['phone']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      lat: _parseDoubleOrNull(json['lat']),
      lng: _parseDoubleOrNull(json['lng']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'lat': lat,
      'lng': lng,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isMuhitaji => role == 'muhitaji';
  bool get isMfanyakazi => role == 'mfanyakazi';
}
