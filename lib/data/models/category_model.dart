/// Category Model
class Category {
  final int id;
  final String name;
  final String? slug;
  final String? icon;
  final String? color;

  Category({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.color,
  });

  /// Kwa API ya /feed (category=slug)
  String get feedSlug => (slug != null && slug!.isNotEmpty)
      ? slug!
      : name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '-');

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    if (v is double) return v.toInt();
    return fallback;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'icon': icon, 'color': color};
  }
}
