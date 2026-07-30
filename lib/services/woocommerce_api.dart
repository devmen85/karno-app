import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/category_tag.dart';

/// Handles all communication with a WooCommerce store's REST API.
/// Docs: https://woocommerce.github.io/woocommerce-rest-api-docs/
class WooCommerceApi {
  late Dio _dio;
  String? siteUrl;
  String? consumerKey;
  String? consumerSecret;

  static final WooCommerceApi _instance = WooCommerceApi._internal();
  factory WooCommerceApi() => _instance;
  WooCommerceApi._internal();

  /// Load saved credentials from local storage (set during login/setup screen).
  Future<bool> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    siteUrl = prefs.getString('site_url');
    consumerKey = prefs.getString('consumer_key');
    consumerSecret = prefs.getString('consumer_secret');
    if (siteUrl != null && consumerKey != null && consumerSecret != null) {
      _initDio();
      return true;
    }
    return false;
  }

  /// Save credentials and initialize the API client.
  /// [url] should look like: https://yourstore.com
  /// Keys are generated in WordPress Admin -> WooCommerce -> Settings -> Advanced -> REST API
  Future<void> saveCredentials({
    required String url,
    required String key,
    required String secret,
  }) async {
    siteUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    consumerKey = key;
    consumerSecret = secret;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('site_url', siteUrl!);
    await prefs.setString('consumer_key', key);
    await prefs.setString('consumer_secret', secret);

    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: '$siteUrl/wp-json/wc/v3',
      queryParameters: {
        'consumer_key': consumerKey,
        'consumer_secret': consumerSecret,
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  /// Quick connectivity/credentials check.
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/products', queryParameters: {'per_page': 1});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Product>> getProducts({int page = 1, int perPage = 20, String? search}) async {
    final response = await _dio.get('/products', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (response.data as List).map((p) => Product.fromJson(p)).toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data);
  }

  Future<Product> createProduct(Product product) async {
    final response = await _dio.post('/products', data: product.toJson());
    return Product.fromJson(response.data);
  }

  Future<Product> updateProduct(int id, Product product) async {
    final response = await _dio.put('/products/$id', data: product.toJson());
    return Product.fromJson(response.data);
  }

  Future<void> deleteProduct(int id, {bool force = true}) async {
    await _dio.delete('/products/$id', queryParameters: {'force': force});
  }

  // ---------------- Orders ----------------

  Future<List<Order>> getOrders({int page = 1, int perPage = 20, String? status}) async {
    final response = await _dio.get('/orders', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (status != null && status != 'all') 'status': status,
      'orderby': 'date',
      'order': 'desc',
    });
    return (response.data as List).map((o) => Order.fromJson(o)).toList();
  }

  Future<Order> getOrder(int id) async {
    final response = await _dio.get('/orders/$id');
    return Order.fromJson(response.data);
  }

  Future<Order> updateOrderStatus(int id, String status) async {
    final response = await _dio.put('/orders/$id', data: {'status': status});
    return Order.fromJson(response.data);
  }

  Future<List<OrderNote>> getOrderNotes(int orderId) async {
    final response = await _dio.get('/orders/$orderId/notes');
    return (response.data as List).map((n) => OrderNote.fromJson(n)).toList();
  }

  Future<void> addOrderNote(int orderId, String note, {bool customerNote = false}) async {
    await _dio.post('/orders/$orderId/notes', data: {
      'note': note,
      'customer_note': customerNote,
    });
  }

  /// Used by the notification service to detect newly created orders.
  Future<List<Order>> getOrdersCreatedAfter(DateTime after) async {
    final response = await _dio.get('/orders', queryParameters: {
      'after': after.toUtc().toIso8601String(),
      'orderby': 'date',
      'order': 'desc',
      'per_page': 20,
    });
    return (response.data as List).map((o) => Order.fromJson(o)).toList();
  }

  // ---------------- Customers ----------------

  Future<List<Customer>> getCustomers({int page = 1, int perPage = 20, String? search}) async {
    final response = await _dio.get('/customers', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (response.data as List).map((c) => Customer.fromJson(c)).toList();
  }

  Future<Customer> getCustomer(int id) async {
    final response = await _dio.get('/customers/$id');
    return Customer.fromJson(response.data);
  }

  // ---------------- Categories ----------------

  Future<List<ProductCategory>> getCategories({int page = 1, int perPage = 50}) async {
    final response = await _dio.get('/products/categories', queryParameters: {
      'page': page,
      'per_page': perPage,
    });
    return (response.data as List).map((c) => ProductCategory.fromJson(c)).toList();
  }

  Future<ProductCategory> createCategory(String name, {int parent = 0}) async {
    final response = await _dio.post('/products/categories', data: {
      'name': name,
      if (parent != 0) 'parent': parent,
    });
    return ProductCategory.fromJson(response.data);
  }

  Future<ProductCategory> updateCategory(int id, String name) async {
    final response = await _dio.put('/products/categories/$id', data: {'name': name});
    return ProductCategory.fromJson(response.data);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('/products/categories/$id', queryParameters: {'force': true});
  }

  // ---------------- Tags ----------------

  Future<List<ProductTag>> getTags({int page = 1, int perPage = 50}) async {
    final response = await _dio.get('/products/tags', queryParameters: {
      'page': page,
      'per_page': perPage,
    });
    return (response.data as List).map((t) => ProductTag.fromJson(t)).toList();
  }

  Future<ProductTag> createTag(String name) async {
    final response = await _dio.post('/products/tags', data: {'name': name});
    return ProductTag.fromJson(response.data);
  }

  Future<void> deleteTag(int id) async {
    await _dio.delete('/products/tags/$id', queryParameters: {'force': true});
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    siteUrl = null;
    consumerKey = null;
    consumerSecret = null;
  }
}
