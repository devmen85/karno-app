import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/woocommerce_api.dart';
import '../services/notification_service.dart';
import 'product_edit_screen.dart';
import 'order_list_screen.dart';
import 'customer_list_screen.dart';
import 'category_tag_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _api = WooCommerceApi();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    NotificationService().init().then((_) => NotificationService().startPolling());
  }

  Future<void> _loadProducts({String? search}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await _api.getProducts(search: search);
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطا در دریافت محصولات';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محصولات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              NotificationService().stopPolling();
              await _api.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text('Woocer', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('محصولات'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('سفارش‌ها'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('مشتریان'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: const Text('دسته‌بندی‌ها و برچسب‌ها'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryTagScreen()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجوی محصول...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (v) => _loadProducts(search: v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : RefreshIndicator(
                        onRefresh: () => _loadProducts(),
                        child: ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return ListTile(
                              leading: p.imageUrls.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: p.imageUrls.first,
                                      width: 50, height: 50, fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image, size: 40),
                              title: Text(p.name),
                              subtitle: Text(
                                '${p.price} تومان · ${p.stockStatus == 'instock' ? 'موجود' : 'ناموجود'}',
                              ),
                              trailing: Text('#${p.id}'),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductEditScreen(product: p)),
                                );
                                _loadProducts();
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductEditScreen(product: null)),
          );
          _loadProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
