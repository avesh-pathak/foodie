class Order {
  final String id;
  final String customerName;
  final String status;
  final String locality;
  final double total;
  final String paymentMethod;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.locality,
    required this.total,
    this.paymentMethod = '',
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        customerName: j['customerName'] ?? '',
        status: j['status'] ?? 'pending',
        locality: j['locality'] ?? '',
        total: double.tryParse('${j['total']}') ?? 0,
        paymentMethod: j['paymentMethod'] ?? '',
        createdAt: j['createdAt'] != null ? DateTime.tryParse('${j['createdAt']}') : null,
      );
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final String restaurantId;
  OrderItem({required this.name, required this.price, required this.quantity, required this.restaurantId});
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: j['name'] ?? '',
        price: double.tryParse('${j['price']}') ?? 0,
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        restaurantId: j['restaurantId'] ?? '',
      );
}

class AnalyticsOverview {
  final int totalOrders;
  final double totalRevenue;
  final double aov;
  final int cancelled;
  final int returned;
  AnalyticsOverview({required this.totalOrders, required this.totalRevenue, required this.aov, required this.cancelled, required this.returned});
  factory AnalyticsOverview.fromJson(Map<String, dynamic> j) => AnalyticsOverview(
        totalOrders: (j['total_orders'] as num?)?.toInt() ?? 0,
        totalRevenue: double.tryParse('${j['total_revenue']}') ?? 0,
        aov: double.tryParse('${j['aov']}') ?? 0,
        cancelled: (j['cancelled'] as num?)?.toInt() ?? 0,
        returned: (j['returned'] as num?)?.toInt() ?? 0,
      );
}