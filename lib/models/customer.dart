class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int ordersCount;
  final String totalSpent;
  final DateTime dateCreated;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.ordersCount,
    required this.totalSpent,
    required this.dateCreated,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Customer.fromJson(Map<String, dynamic> json) {
    final billing = json['billing'] ?? {};
    return Customer(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: billing['phone'] ?? '',
      ordersCount: json['orders_count'] ?? 0,
      totalSpent: json['total_spent']?.toString() ?? '0',
      dateCreated: DateTime.tryParse(json['date_created'] ?? '') ?? DateTime.now(),
    );
  }
}
