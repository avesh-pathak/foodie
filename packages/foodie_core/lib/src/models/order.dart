class Order {
  final String id;
  final String customerName;
  final String status;
  final String locality;
  final double total;
  final String paymentMethod;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final DateTime? preparingStartedAt;
  final DateTime? readyAt;
  final int? prepElapsedSeconds;
  final String? prepStatus;

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.locality,
    required this.total,
    this.paymentMethod = '',
    this.createdAt,
    this.confirmedAt,
    this.preparingStartedAt,
    this.readyAt,
    this.prepElapsedSeconds,
    this.prepStatus,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        customerName: j['customerName'] ?? '',
        status: j['status'] ?? 'pending',
        locality: j['locality'] ?? '',
        total: double.tryParse('${j['total']}') ?? 0,
        paymentMethod: j['paymentMethod'] ?? '',
        createdAt: j['createdAt'] != null ? DateTime.tryParse('${j['createdAt']}') : null,
        confirmedAt: j['confirmedAt'] != null ? DateTime.tryParse('${j['confirmedAt']}') : null,
        preparingStartedAt: j['preparingStartedAt'] != null ? DateTime.tryParse('${j['preparingStartedAt']}') : null,
        readyAt: j['readyAt'] != null ? DateTime.tryParse('${j['readyAt']}') : null,
        prepElapsedSeconds: (j['prepElapsedSeconds'] as num?)?.toInt(),
        prepStatus: j['prepStatus'] as String?,
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