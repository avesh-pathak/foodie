import 'food_item.dart';

class CartItem {
  const CartItem({
    required this.food,
    required this.quantity,
    this.addOns = const <AddOn>[],
    this.note = '',
  });

  final FoodItem food;
  final int quantity;
  final List<AddOn> addOns;
  final String note;

  String get key =>
      '${food.id}::${addOns.map((AddOn addOn) => addOn.name).join('|')}::${note.trim()}';

  double get unitPrice =>
      food.price + addOns.fold<double>(0, (total, addOn) => total + addOn.price);

  double get total => unitPrice * quantity;

  CartItem copyWith({
    int? quantity,
    List<AddOn>? addOns,
    String? note,
  }) {
    return CartItem(
      food: food,
      quantity: quantity ?? this.quantity,
      addOns: addOns ?? this.addOns,
      note: note ?? this.note,
    );
  }
}

class Coupon {
  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    required this.kind,
    required this.value,
    required this.minOrder,
    this.maxDiscount,
  });

  final String code;
  final String title;
  final String description;
  final CouponKind kind;
  final double value;
  final double minOrder;
  final double? maxDiscount;

  double discountFor(double subtotal, double deliveryFee) {
    if (subtotal < minOrder) return 0;
    switch (kind) {
      case CouponKind.percent:
        final double raw = subtotal * value / 100;
        return maxDiscount == null ? raw : raw.clamp(0, maxDiscount!).toDouble();
      case CouponKind.flat:
        return value.clamp(0, subtotal).toDouble();
      case CouponKind.freeDelivery:
        return deliveryFee;
    }
  }

  String get eligibilityLabel => 'Min. order ₹${minOrder.round()}';
}

enum CouponKind { percent, flat, freeDelivery }
