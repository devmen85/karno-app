import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/woocommerce_api.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _api = WooCommerceApi();
  List<Order> _orders = [];
  bool _loading = true;
  String _statusFilter = 'all';

  final _statusOptions = {
    'all': 'همه',
    'pending': 'در انتظار پرداخت',
    'processing': 'در حال پردازش',
    'on-hold': 'در انتظار',
    'completed': 'تکمیل‌شده',
    'cancelled': 'لغوشده',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final orders = await _api.getOrders(status: _statusFilter);
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سفارش‌ها'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _statusOptions.entries.map((e) {
                final selected = _statusFilter == e.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _statusFilter = e.key);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _orders.isEmpty
                  ? ListView(children: const [
                      Padding(padding: EdgeInsets.all(32), child: Center(child: Text('سفارشی یافت نشد')))
                    ])
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final o = _orders[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(o.status).withOpacity(0.15),
                            child: Text('#${o.id}',
                                style: TextStyle(fontSize: 11, color: _statusColor(o.status))),
                          ),
                          title: Text(o.customerName.isEmpty ? 'مهمان' : o.customerName),
                          subtitle: Text('${orderStatusLabels[o.status] ?? o.status} · ${o.total} تومان'),
                          trailing: Text(
                            '${o.dateCreated.year}/${o.dateCreated.month}/${o.dateCreated.day}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)));
                            _load();
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
