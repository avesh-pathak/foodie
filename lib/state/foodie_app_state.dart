import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/cart_item.dart';
import '../models/delivery_address.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/restaurant.dart';

class FoodieAppState extends ChangeNotifier {
  FoodieAppState() {
    _orders = MockData.sampleOrders();
  }

  String? _displayName;
  String? _contact;
  String _homeCategory = 'all';
  String _searchQuery = '';
  String _selectedAddressId = MockData.addresses.first.id;
  String _cookingInstructions = '';
  bool _notificationsEnabled = true;
  bool _offersEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  final List<DeliveryAddress> _addresses =
      List<DeliveryAddress>.of(MockData.addresses);
  final List<CartItem> _cart = <CartItem>[];
  final Set<String> _favoriteRestaurantIds = <String>{};
  final Set<String> _favoriteDishIds = <String>{};
  final List<String> _recentSearches = <String>[];
  late List<FoodOrder> _orders;

  Coupon? _appliedCoupon;
  PaymentMethod _paymentMethod = PaymentMethod.cod;

  bool get isLoggedIn => _displayName != null && _displayName!.isNotEmpty;
  String get displayName => _displayName ?? 'Guest';
  String get contact => _contact ?? 'hello@foodie.demo';
  String get firstName => displayName.split(' ').first;
  String get avatarInitials {
    final List<String> parts = displayName
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'F';
    if (parts.length == 1) {
      return parts.first.substring(0, math.min(2, parts.first.length)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get homeCategory => _homeCategory;
  String get searchQuery => _searchQuery;
  String get cookingInstructions => _cookingInstructions;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get offersEnabled => _offersEnabled;

  /// Which palette the app renders with.
  ThemeMode get themeMode => _themeMode;
  List<String> get recentSearches => List<String>.unmodifiable(_recentSearches);

  List<DeliveryAddress> get addresses => List<DeliveryAddress>.unmodifiable(_addresses);
  DeliveryAddress get selectedAddress {
    return _addresses.firstWhere(
      (DeliveryAddress address) => address.id == _selectedAddressId,
      orElse: () => _addresses.first,
    );
  }

  List<CartItem> get cart => List<CartItem>.unmodifiable(_cart);
  bool get isCartEmpty => _cart.isEmpty;
  int get cartCount => _cart.fold<int>(0, (sum, item) => sum + item.quantity);

  List<FoodOrder> get orders => List<FoodOrder>.unmodifiable(_orders);
  List<FoodOrder> get activeOrders {
    final List<FoodOrder> active =
        _orders.where((FoodOrder order) => order.isActive).toList();
    active.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List<FoodOrder>.unmodifiable(active);
  }

  List<FoodOrder> get pastOrders {
    final List<FoodOrder> past =
        _orders.where((FoodOrder order) => order.isDelivered).toList();
    past.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List<FoodOrder>.unmodifiable(past);
  }

  List<Restaurant> get favoriteRestaurants => MockData.restaurants
      .where((Restaurant restaurant) => _favoriteRestaurantIds.contains(restaurant.id))
      .toList();

  List<FoodItem> get favoriteDishes => MockData.allDishes
      .where((FoodItem item) => _favoriteDishIds.contains(item.id))
      .toList();

  List<Restaurant> get filteredRestaurants {
    if (_homeCategory == 'all') return MockData.popularRestaurants;
    return MockData.popularRestaurants
        .where((Restaurant restaurant) =>
            restaurant.categories.contains(_homeCategory) ||
            restaurant.menu.any(
              (FoodItem item) => item.homeCategory == _homeCategory,
            ))
        .toList();
  }

  List<FoodItem> get filteredRecommendedDishes {
    if (_homeCategory == 'all') return MockData.recommendedDishes;
    return MockData.recommendedDishes
        .where((FoodItem item) => item.homeCategory == _homeCategory)
        .toList();
  }

  Coupon? get appliedCoupon => _appliedCoupon;
  PaymentMethod get paymentMethod => _paymentMethod;
  bool get notificationsOn => _notificationsEnabled;
  bool get offersOn => _offersEnabled;

  double get subtotal =>
      _cart.fold<double>(0, (sum, item) => sum + item.total);

  double get deliveryFee {
    if (_cart.isEmpty) return 0;
    final Set<String> restaurantIds =
        _cart.map((CartItem item) => item.food.restaurantId).toSet();
    double highest = 0;
    for (final String id in restaurantIds) {
      final Restaurant? restaurant = MockData.restaurantById(id);
      if (restaurant != null && restaurant.deliveryFee > highest) {
        highest = restaurant.deliveryFee;
      }
    }
    return highest;
  }

  double get taxes => _round(subtotal * 0.05);

  double get discountAmount {
    final Coupon? coupon = _appliedCoupon;
    if (coupon == null) return 0;
    return _round(coupon.discountFor(subtotal, deliveryFee));
  }

  double get total =>
      _round(math.max(0, subtotal + deliveryFee + taxes - discountAmount));

  int get etaMinutes {
    if (_cart.isEmpty) return 30;
    int longest = 30;
    for (final CartItem item in _cart) {
      final Restaurant? restaurant =
          MockData.restaurantById(item.food.restaurantId);
      if (restaurant != null && restaurant.deliveryMinutes > longest) {
        longest = restaurant.deliveryMinutes;
      }
    }
    return longest;
  }

  double _round(double value) => (value * 100).roundToDouble() / 100;

  void login({required String identity}) {
    final String cleaned = identity.trim();
    _displayName = cleaned;
    if (cleaned.contains('@') || RegExp(r'\d{7,}').hasMatch(cleaned)) {
      _contact = cleaned;
    } else {
      _contact = 'hello@foodie.demo';
    }
    notifyListeners();
  }

  void updateProfile({required String name, required String contact}) {
    if (name.trim().isEmpty) return;
    _displayName = name.trim();
    _contact = contact.trim().isEmpty ? 'hello@foodie.demo' : contact.trim();
    notifyListeners();
  }

  void logout() {
    _displayName = null;
    _contact = null;
    _cart.clear();
    _appliedCoupon = null;
    _favoriteRestaurantIds.clear();
    _favoriteDishIds.clear();
    _recentSearches.clear();
    _addresses
      ..clear()
      ..addAll(MockData.addresses);
    _selectedAddressId = MockData.addresses.first.id;
    _orders = MockData.sampleOrders();
    _homeCategory = 'all';
    _searchQuery = '';
    _cookingInstructions = '';
    _paymentMethod = PaymentMethod.cod;
    _notificationsEnabled = true;
    _offersEnabled = true;
    notifyListeners();
  }

  void resetDemoData() {
    _cart.clear();
    _appliedCoupon = null;
    _favoriteRestaurantIds.clear();
    _favoriteDishIds.clear();
    _orders = <FoodOrder>[];
    _homeCategory = 'all';
    _searchQuery = '';
    _cookingInstructions = '';
    _addresses
      ..clear()
      ..addAll(MockData.addresses);
    _selectedAddressId = MockData.addresses.first.id;
    notifyListeners();
  }

  void setHomeCategory(String categoryId) {
    if (_homeCategory == categoryId) {
      _homeCategory = 'all';
    } else {
      _homeCategory = categoryId;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addRecentSearch(String query) {
    final String cleaned = query.trim();
    if (cleaned.isEmpty) return;
    _recentSearches.removeWhere(
      (String item) => item.toLowerCase() == cleaned.toLowerCase(),
    );
    _recentSearches.insert(0, cleaned);
    if (_recentSearches.length > 6) {
      _recentSearches.removeLast();
    }
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  List<Restaurant> searchRestaurants(String query, {String category = 'all'}) {
    final String q = query.trim().toLowerCase();
    return MockData.restaurants.where((Restaurant restaurant) {
      final bool categoryMatch =
          category == 'all' || restaurant.categories.contains(category);
      if (!categoryMatch) return false;
      if (q.isEmpty) return true;
      final bool nameMatch = restaurant.name.toLowerCase().contains(q) ||
          restaurant.cuisines.any((String c) => c.toLowerCase().contains(q)) ||
          restaurant.tagline.toLowerCase().contains(q);
      final bool dishMatch = restaurant.menu.any((FoodItem item) =>
          item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q));
      return nameMatch || dishMatch;
    }).toList();
  }

  List<FoodItem> searchDishes(String query, {String category = 'all'}) {
    final String q = query.trim().toLowerCase();
    return MockData.allDishes.where((FoodItem item) {
      final bool categoryMatch = category == 'all' ||
          item.homeCategory == category ||
          item.category.toLowerCase() == category;
      if (!categoryMatch) return false;
      if (q.isEmpty) return true;
      final Restaurant? restaurant = MockData.restaurantById(item.restaurantId);
      return item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          (restaurant?.name.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  bool isRestaurantFavorite(String id) => _favoriteRestaurantIds.contains(id);
  bool isDishFavorite(String id) => _favoriteDishIds.contains(id);

  void toggleRestaurantFavorite(String id) {
    if (!_favoriteRestaurantIds.add(id)) {
      _favoriteRestaurantIds.remove(id);
    }
    notifyListeners();
  }

  void toggleDishFavorite(String id) {
    if (!_favoriteDishIds.add(id)) {
      _favoriteDishIds.remove(id);
    }
    notifyListeners();
  }

  int quantityForDish(String dishId) {
    return _cart
        .where((CartItem item) => item.food.id == dishId)
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  void addToCart(
    FoodItem food, {
    int quantity = 1,
    List<AddOn> addOns = const <AddOn>[],
    String note = '',
  }) {
    if (quantity < 1) return;
    final CartItem incoming = CartItem(
      food: food,
      quantity: quantity,
      addOns: addOns,
      note: note.trim(),
    );
    final int index =
        _cart.indexWhere((CartItem item) => item.key == incoming.key);
    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(
        quantity: _cart[index].quantity + quantity,
      );
    } else {
      _cart.add(incoming);
    }
    notifyListeners();
  }

  String? firstLineKeyForDish(String dishId) {
    for (final CartItem item in _cart) {
      if (item.food.id == dishId) return item.key;
    }
    return null;
  }

  void incrementDish(String dishId) {
    final String? key = firstLineKeyForDish(dishId);
    if (key != null) incrementLine(key);
  }

  void decrementDish(String dishId) {
    final String? key = firstLineKeyForDish(dishId);
    if (key != null) decrementLine(key);
  }

  void incrementLine(String key) {
    final int index = _cart.indexWhere((CartItem item) => item.key == key);
    if (index < 0) return;
    _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
    notifyListeners();
  }

  void decrementLine(String key) {
    final int index = _cart.indexWhere((CartItem item) => item.key == key);
    if (index < 0) return;
    if (_cart[index].quantity <= 1) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].copyWith(
        quantity: _cart[index].quantity - 1,
      );
    }
    if (_cart.isEmpty) _appliedCoupon = null;
    notifyListeners();
  }

  void removeLine(String key) {
    _cart.removeWhere((CartItem item) => item.key == key);
    if (_cart.isEmpty) _appliedCoupon = null;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _appliedCoupon = null;
    _cookingInstructions = '';
    notifyListeners();
  }

  String? applyCoupon(String rawCode) {
    final String code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return 'Enter a coupon code to continue.';
    if (_cart.isEmpty) return 'Add something delicious to your cart first.';
    final Coupon? coupon = MockData.coupons
        .where((Coupon item) => item.code == code)
        .firstOrNull;
    if (coupon == null) return 'That code is not valid. Try FOODIE50.';
    if (subtotal < coupon.minOrder) {
      final double gap = coupon.minOrder - subtotal;
      return 'Add ₹${gap.round()} more to use ${coupon.code}.';
    }
    _appliedCoupon = coupon;
    notifyListeners();
    return null;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void setCookingInstructions(String value) {
    _cookingInstructions = value;
    notifyListeners();
  }

  void setDeliveryAddress(String addressId) {
    if (_addresses.any((DeliveryAddress address) => address.id == addressId)) {
      _selectedAddressId = addressId;
      notifyListeners();
    }
  }

  void addAddress({
    required String label,
    required String line1,
    required String line2,
    required AddressType type,
    bool makeDefault = false,
  }) {
    final String id = 'addr_${DateTime.now().microsecondsSinceEpoch}';
    if (makeDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(
      DeliveryAddress(
        id: id,
        label: label,
        line1: line1,
        line2: line2,
        type: type,
        isDefault: makeDefault || _addresses.isEmpty,
      ),
    );
    _selectedAddressId = id;
    notifyListeners();
  }

  void updateAddress(DeliveryAddress updated) {
    final int index =
        _addresses.indexWhere((DeliveryAddress item) => item.id == updated.id);
    if (index < 0) return;
    if (updated.isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        if (i != index) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
    }
    _addresses[index] = updated;
    notifyListeners();
  }

  void deleteAddress(String id) {
    if (_addresses.length <= 1) return;
    _addresses.removeWhere((DeliveryAddress address) => address.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.first.id;
    }
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setOffersEnabled(bool value) {
    _offersEnabled = value;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  FoodOrder? orderById(String id) {
    for (final FoodOrder order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  FoodOrder placeOrder() {
    if (_cart.isEmpty) {
      throw StateError('Cannot place an empty order.');
    }
    final String orderId =
        'FD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final FoodOrder order = FoodOrder(
      id: orderId,
      lines: _cart
          .map(
            (CartItem item) => OrderLine(
              foodId: item.food.id,
              name: item.food.name,
              image: item.food.image,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              addOns: item.addOns.map((AddOn addOn) => addOn.name).toList(),
            ),
          )
          .toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      taxes: taxes,
      discount: discountAmount,
      total: total,
      address: selectedAddress,
      paymentMethod: _paymentMethod,
      placedAt: DateTime.now(),
      etaMinutes: etaMinutes,
      instructions: _cookingInstructions,
      couponCode: _appliedCoupon?.code,
      rider: MockData.riders[_orders.length % MockData.riders.length],
    );
    _orders.insert(0, order);
    _cart.clear();
    _appliedCoupon = null;
    _cookingInstructions = '';
    notifyListeners();
    return order;
  }

  void advanceOrder(String orderId) {
    final int index = _orders.indexWhere((FoodOrder order) => order.id == orderId);
    if (index < 0) return;
    final FoodOrder order = _orders[index];
    if (order.isDelivered) return;
    _orders[index] = order.copyWith(
      statusIndex: math.min(order.statusIndex + 1, orderStatuses.length - 1),
    );
    notifyListeners();
  }

  int reorder(FoodOrder order) {
    int added = 0;
    for (final OrderLine line in order.lines) {
      final FoodItem? item = MockData.dishById(line.foodId);
      if (item == null) continue;
      final List<AddOn> addOns = item.addOns
          .where((AddOn addOn) => line.addOns.contains(addOn.name))
          .toList();
      addToCart(item, quantity: line.quantity, addOns: addOns);
      added += line.quantity;
    }
    return added;
  }
}
