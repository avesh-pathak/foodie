import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/mock_data.dart';
import '../models/delivery_address.dart';
import '../models/order.dart';

class OrdersApi {
  OrdersApi({String? baseUrl})
      : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001',
            );

  final String baseUrl;

  Future<void> place(FoodOrder order, DeliveryAddress address) async {
    final body = <String, dynamic>{
      'id': order.id,
      'customerName': 'Foodie Customer',
      'deliveryAddress': address.oneLine,
      'locality': address.line2,
      'paymentMethod': order.paymentMethod.label,
      'subtotal': order.subtotal,
      'deliveryFee': order.deliveryFee,
      'discount': order.discount,
      'gst': order.taxes,
      'total': order.total,
      'couponCode': order.couponCode,
      'items': order.lines.map((OrderLine line) {
        final dish = MockData.dishById(line.foodId);
        return {
          'menuItemId': line.foodId,
          'restaurantId': dish?.restaurantId ?? '',
          'name': line.name,
          'price': line.unitPrice,
          'quantity': line.quantity,
          'isVeg': dish?.isVeg ?? true,
          'addOns': line.addOns,
        };
      }).toList(),
    };
    try {
      await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {
      // Checkout remains usable offline.
    }
  }
}