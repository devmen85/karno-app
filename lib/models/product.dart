class Product {
  final int id;
  final String name;
  final String slug;
  final String type; // simple, variable, grouped, external
  final String status; // publish, draft, pending, private
  final String description;
  final String shortDescription;
  final String regularPrice;
  final String salePrice;
  final String price;
  final int stockQuantity;
  final String stockStatus; // instock, outofstock, onbackorder
  final bool manageStock;
  final List<String> imageUrls;
  final List<int> categoryIds;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.status,
    required this.description,
    required this.shortDescription,
    required this.regularPrice,
    required this.salePrice,
    required this.price,
    required this.stockQuantity,
    required this.stockStatus,
    required this.manageStock,
    required this.imageUrls,
    required this.categoryIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? 'simple',
      status: json['status'] ?? 'draft',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      regularPrice: json['regular_price']?.toString() ?? '0',
      salePrice: json['sale_price']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      stockQuantity: json['stock_quantity'] ?? 0,
      stockStatus: json['stock_status'] ?? 'instock',
      manageStock: json['manage_stock'] ?? false,
      imageUrls: (json['images'] as List<dynamic>? ?? [])
          .map((img) => img['src'] as String)
          .toList(),
      categoryIds: (json['categories'] as List<dynamic>? ?? [])
          .map((cat) => cat['id'] as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'status': status,
      'description': description,
      'short_description': shortDescription,
      'regular_price': regularPrice,
      if (salePrice.isNotEmpty) 'sale_price': salePrice,
      'manage_stock': manageStock,
      'stock_quantity': stockQuantity,
      'stock_status': stockStatus,
      'categories': categoryIds.map((id) => {'id': id}).toList(),
    };
  }
}
