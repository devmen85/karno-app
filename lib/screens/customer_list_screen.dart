import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/woocommerce_api.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _api = WooCommerceApi();
  final _searchController = TextEditingController();
  List<Customer> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? search}) async {
    setState(() => _loading = true);
    try {
      final customers = await _api.getCustomers(search: search);
      setState(() {
        _customers = customers;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مشتریان')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجوی مشتری (نام یا ایمیل)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (v) => _load(search: v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _load(),
                    child: ListView.builder(
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final c = _customers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(c.fullName.isNotEmpty ? c.fullName[0] : '?'),
                          ),
                          title: Text(c.fullName.isEmpty ? c.email : c.fullName),
                          subtitle: Text('${c.email}\n${c.ordersCount} سفارش · ${c.totalSpent} تومان خرید'),
                          isThreeLine: true,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
