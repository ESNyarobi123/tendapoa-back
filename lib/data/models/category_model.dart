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
  String get feedSlug =>
      (slug != null && slug!.isNotEmpty)
          ? slug!
          : name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '-');

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug']?.toString(),
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'icon': icon, 'color': color};
  }
}
