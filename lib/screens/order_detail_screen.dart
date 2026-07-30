import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/woocommerce_api.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = WooCommerceApi();
  final _noteController = TextEditingController();
  Order? _order;
  List<OrderNote> _notes = [];
  bool _loading = true;
  bool _addingNote = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final order = await _api.getOrder(widget.orderId);
    final notes = await _api.getOrderNotes(widget.orderId);
    setState(() {
      _order = order;
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _changeStatus(String status) async {
    await _api.updateOrderStatus(widget.orderId, status);
    _load();
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;
    setState(() => _addingNote = true);
    await _api.addOrderNote(widget.orderId, _noteController.text.trim());
    _noteController.clear();
    await _load();
    setState(() => _addingNote = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final o = _order!;

    return Scaffold(
      appBar: AppBar(title: Text('سفارش #${o.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.customerName.isEmpty ? 'مهمان' : o.customerName,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (o.customerEmail.isNotEmpty) Text(o.customerEmail),
                  if (o.customerPhone.isNotEmpty) Text(o.customerPhone),
                  const SizedBox(height: 8),
                  Text('روش پرداخت: ${o.paymentMethodTitle}'),
                  Text('مبلغ کل: ${o.total} ${o.currency}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('وضعیت سفارش', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: orderStatusLabels.containsKey(o.status) ? o.status : null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: orderStatusLabels.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) _changeStatus(v);
            },
          ),
          const SizedBox(height: 16),
          Text('اقلام سفارش', style: Theme.of(context).textTheme.titleMedium),
          ...o.lineItems.map((li) => ListTile(
                title: Text(li.name),
                subtitle: Text('تعداد: ${li.quantity}'),
                trailing: Text('${li.total} ${o.currency}'),
              )),
          const Divider(height: 32),
          Text('یادداشت‌های سفارش', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._notes.map((n) => Card(
                child: ListTile(
                  title: Text(n.note),
                  subtitle: Text(
                      '${n.customerNote ? "قابل مشاهده برای مشتری" : "یادداشت داخلی"} · ${n.dateCreated}'),
                ),
              )),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'افزودن یادداشت داخلی...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _addingNote ? null : _addNote,
            child: _addingNote
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('افزودن یادداشت'),
          ),
        ],
      ),
    );
  }
}
