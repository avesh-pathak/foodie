import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/app.dart';
import 'package:foodie/data/mock_data.dart';
import 'package:foodie/models/delivery_address.dart';
import 'package:foodie/models/food_item.dart';
import 'package:foodie/state/foodie_app_state.dart';

void main() {
  test('demo login personalises the customer and coupon maths works', () {
    final FoodieAppState state = FoodieAppState();
    state.login(identity: 'Avesh');
    expect(state.isLoggedIn, isTrue);
    expect(state.displayName, 'Avesh');

    final FoodItem biryani = MockData.dishById('f_chicken_biryani')!;
    state.addToCart(biryani, quantity: 2);
    expect(state.cartCount, 2);
    expect(state.subtotal, 658);
    expect(state.deliveryFee, 29);

    final String? error = state.applyCoupon('FOODIE50');
    expect(error, isNull);
    expect(state.discountAmount, 150);
    expect(state.total, closeTo(569.9, 0.01));
  });

  test('favourites stay in sync and orders move to history', () {
    final FoodieAppState state = FoodieAppState();
    state.login(identity: 'Maya');
    state.toggleRestaurantFavorite('hyderabadi_house');
    state.toggleDishFavorite('f_chicken_biryani');
    expect(state.favoriteRestaurants.single.name, 'Hyderabadi House');
    expect(state.favoriteDishes.single.id, 'f_chicken_biryani');

    final FoodItem dish = MockData.dishById('f_chicken_biryani')!;
    state.addToCart(dish, quantity: 2, note: 'Less spicy');
    state.applyCoupon('FOODIE50');
    final order = state.placeOrder();

    expect(state.isCartEmpty, isTrue);
    expect(state.activeOrders.single.id, order.id);
    expect(state.appliedCoupon, isNull);
    for (int i = 0; i < 5; i++) {
      state.advanceOrder(order.id);
    }
    expect(state.activeOrders, isEmpty);
    expect(state.pastOrders.first.id, order.id);

    final int added = state.reorder(state.pastOrders.first);
    expect(added, 2);
    expect(state.cartCount, 2);
  });

  test('addresses can be added, edited and removed', () {
    final FoodieAppState state = FoodieAppState();
    final int before = state.addresses.length;
    state.addAddress(
      label: 'Other',
      line1: '7, Mango Street',
      line2: 'Koramangala, Bengaluru 560034',
      type: AddressType.other,
    );
    expect(state.addresses.length, before + 1);
    final updated = state.addresses.last.copyWith(label: 'Studio');
    state.updateAddress(updated);
    expect(state.addresses.last.label, 'Studio');
    state.deleteAddress(updated.id);
    expect(state.addresses.length, before);
  });

  testWidgets('welcome screen opens the demo login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const FoodieApp());
    await tester.pumpAndSettle();

    expect(find.text('Delicious food,\ndelivered to you.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.ensureVisible(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to\nyour happy place.'), findsOneWidget);
    expect(find.text('Continue to Foodie'), findsOneWidget);
  });
}
