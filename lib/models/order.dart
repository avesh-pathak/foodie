import 'delivery_address.dart';

enum PaymentMethod { cod, upi, card }

extension PaymentMethodDetails on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Credit / Debit Card';
    }
  }

  String get hint {
    switch (this) {
      case PaymentMethod.cod:
        return 'Pay when your food arrives';
      case PaymentMethod.upi:
        return 'Google Pay, PhonePe, Paytm';
      case PaymentMethod.card:
        return 'Visa, Mastercard, RuPay';
    }
  }
}

class Rider {
  const Rider({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.rating,
  });

  final String name;
  final String phone;
  final String vehicle;
  final double rating;
}

class OrderLine {
  const OrderLine({
    required this.foodId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.unitPrice,
    this.addOns = const <String>[],
  });

  final String foodId;
  final String name;
  final String image;
  final int quantity;
  final double unitPrice;
  final List<String> addOns;

  double get total => unitPrice * quantity;
}

class FoodOrder {
  FoodOrder({
    required this.id,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.discount,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.placedAt,
    required this.etaMinutes,
    this.statusIndex = 0,
    this.instructions = '',
    this.couponCode,
    this.rider,
  });

  final String id;
  final List<OrderLine> lines;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final double total;
  final DeliveryAddress address;
  final PaymentMethod paymentMethod;
  final DateTime placedAt;
  final int etaMinutes;
  final int statusIndex;
  final String instructions;
  final String? couponCode;
  final Rider? rider;

  bool get isDelivered => statusIndex >= orderStatuses.length - 1;
  bool get isActive => !isDelivered;

  int get itemCount => lines.fold<int>(0, (sum, line) => sum + line.quantity);

  FoodOrder copyWith({
    int? statusIndex,
    Rider? rider,
  }) {
    return FoodOrder(
      id: id,
      lines: lines,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      taxes: taxes,
      discount: discount,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      placedAt: placedAt,
      etaMinutes: etaMinutes,
      statusIndex: statusIndex ?? this.statusIndex,
      instructions: instructions,
      couponCode: couponCode,
      rider: rider ?? this.rider,
    );
  }
}

const List<String> orderStatuses = <String>[
  'Order placed',
  'Restaurant accepted',
  'Preparing food',
  'Ready for pickup',
  'Out for delivery',
  'Delivered',
];

/// Order journey states, mapped to one semantic hue each.
///
/// Colour is never the only signal - every state also carries an icon and
/// a written label.
enum OrderPhase { queued, preparing, moving, delivered, cancelled }

/// Maps a journey stage onto the semantic colour role that describes it.
///
/// The stage index is the same one used by [orderStatuses]; the phase is
/// what the UI paints with. Orange is never used to mean "preparing" — that
/// would collide with the brand — and green always means completed.
OrderPhase phaseForStatusIndex(int index) {
  if (index <= 1) return OrderPhase.queued;
  if (index <= 3) return OrderPhase.preparing;
  if (index == 4) return OrderPhase.moving;
  return OrderPhase.delivered;
}

const List<String> orderStatusDescriptions = <String>[
  'We have received your order.',
  'The restaurant is confirming your dishes.',
  'Our chefs are cooking something delicious.',
  'Your order is packed and waiting for the rider.',
  'Your rider is on the way to your doorstep.',
  'Enjoy your meal. Bon appétit!',
];
