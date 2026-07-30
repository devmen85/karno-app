class ProductCategory {
  final int id;
  final String name;
  final String slug;
  final int parent;
  final int count;
  final String? imageUrl;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.parent,
    required this.count,
    this.imageUrl,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      parent: json['parent'] ?? 0,
      count: json['count'] ?? 0,
      imageUrl: json['image']?['src'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (parent != 0) 'parent': parent,
      };
}

class ProductTag {
  final int id;
  final String name;
  final String slug;
  final int count;

  ProductTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}
