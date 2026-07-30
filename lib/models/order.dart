class OrderLineItem {
  final int productId;
  final String name;
  final int quantity;
  final String total;

  OrderLineItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.total,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      total: json['total']?.toString() ?? '0',
    );
  }
}

class OrderNote {
  final int id;
  final String note;
  final DateTime dateCreated;
  final bool customerNote; // true = visible to customer, false = private/internal

  OrderNote({
    required this.id,
    required this.note,
    required this.dateCreated,
    required this.customerNote,
  });

  factory OrderNote.fromJson(Map<String, dynamic> json) {
    return OrderNote(
      id: json['id'] ?? 0,
      note: json['note'] ?? '',
      dateCreated: DateTime.tryParse(json['date_created'] ?? '') ?? DateTime.now(),
      customerNote: json['customer_note'] ?? false,
    );
  }
}

class Order {
  final int id;
  final String status; // pending, processing, on-hold, completed, cancelled, refunded, failed
  final String total;
  final String currency;
  final DateTime dateCreated;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String paymentMethodTitle;
  final List<OrderLineItem> lineItems;

  Order({
    required this.id,
    required this.status,
    required this.total,
    required this.currency,
    required this.dateCreated,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.paymentMethodTitle,
    required this.lineItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final billing = json['billing'] ?? {};
    return Order(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      total: json['total']?.toString() ?? '0',
      currency: json['currency'] ?? '',
      dateCreated: DateTime.tryParse(json['date_created'] ?? '') ?? DateTime.now(),
      customerName: '${billing['first_name'] ?? ''} ${billing['last_name'] ?? ''}'.trim(),
      customerEmail: billing['email'] ?? '',
      customerPhone: billing['phone'] ?? '',
      paymentMethodTitle: json['payment_method_title'] ?? '',
      lineItems: (json['line_items'] as List<dynamic>? ?? [])
          .map((li) => OrderLineItem.fromJson(li))
          .toList(),
    );
  }
}

/// Human-readable Persian labels for order statuses.
const Map<String, String> orderStatusLabels = {
  'pending': 'در انتظار پرداخت',
  'processing': 'در حال پردازش',
  'on-hold': 'در انتظار',
  'completed': 'تکمیل‌شده',
  'cancelled': 'لغوشده',
  'refunded': 'بازپرداخت‌شده',
  'failed': 'ناموفق',
};
