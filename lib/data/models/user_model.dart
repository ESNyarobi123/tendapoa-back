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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'muhitaji',
      phone: json['phone'],
      profilePhotoUrl: json['profile_photo_url'],
      lat: json['lat'] is String
          ? double.tryParse(json['lat'])
          : json['lat']?.toDouble(),
      lng: json['lng'] is String
          ? double.tryParse(json['lng'])
          : json['lng']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
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
