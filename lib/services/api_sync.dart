import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/mock_data.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';

/// Pulls menu data from the Foodie backend and replaces the demo lists in
/// [MockData]. A periodic refresh gives the customer app near-real-time
/// updates until the Neon Realtime client is wired in.
enum ApiConnection { unknown, online, offline }

class ApiSync {
  /// Bumped after every successful menu/restaurant refresh so the app can
  /// rebuild without a manual pull-to-refresh.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static final ValueNotifier<ApiConnection> connection =
      ValueNotifier<ApiConnection>(ApiConnection.unknown);
  static bool hasLoadedOnce = false;

  ApiSync({String? baseUrl})
      : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001',
            );

  final String baseUrl;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await refresh();
    unawaited(_listen());
  }

  Future<void> _listen() async {
    while (_started) {
      try {
        final request = http.Request('GET', Uri.parse('$baseUrl/events'));
        final response = await http.Client().send(request);
        if (response.statusCode != 200) throw StateError('SSE ${response.statusCode}');
        bool changed = false;
        await for (final String line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.startsWith('event: change')) changed = true;
          if (line.startsWith('data:') && changed) {
            changed = false;
            await refresh();
          }
        }
      } catch (_) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
  }

  Future<void> refresh() async {
    try {
      final restaurantsRes = await http.get(Uri.parse('$baseUrl/restaurants'));
      if (restaurantsRes.statusCode != 200) return;
      final List<dynamic> rows = jsonDecode(restaurantsRes.body) as List<dynamic>;
      final List<Restaurant> next = <Restaurant>[];
      for (final dynamic row in rows) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        final menuRes = await http.get(Uri.parse('$baseUrl/menu?restaurantId=${r['id']}'));
        final List<dynamic> menuRows = menuRes.statusCode == 200 ? jsonDecode(menuRes.body) as List<dynamic> : <dynamic>[];
        next.add(_restaurant(r, menuRows));
      }
      if (next.isEmpty) return;
      MockData.restaurants
        ..clear()
        ..addAll(next);
      hasLoadedOnce = true;
      connection.value = ApiConnection.online;
      revision.value++;
    } catch (_) {
      // Keep the bundled demo data when the backend is unreachable.
      connection.value = ApiConnection.offline;
    }
  }

  Restaurant _restaurant(Map<String, dynamic> r, List<dynamic> menuRows) {
    final List<FoodItem> menu = menuRows.map((dynamic e) {
      final Map<String, dynamic> m = e as Map<String, dynamic>;
      return FoodItem(
        id: '${m['id']}',
        restaurantId: '${m['restaurantId']}',
        name: '${m['name']}',
        description: '${m['description'] ?? ''}',
        price: double.tryParse('${m['price']}') ?? 0,
        image: '${m['image'] ?? ''}',
        rating: double.tryParse('${m['rating']}') ?? 0,
        ratingCount: (m['ratingCount'] as num?)?.toInt() ?? 0,
        isVeg: m['isVeg'] == true,
        category: '${m['category'] ?? ''}',
        homeCategory: m['homeCategory'] as String?,
        isBestseller: m['isBestseller'] == true,
        isRecommended: m['isRecommended'] == true,
        isAvailable: m['isAvailable'] != false,
        addOns: (m['addOns'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic a) => AddOn(name: '${(a as Map<String, dynamic>)['name']}', price: double.tryParse('${a['price']}') ?? 0))
            .toList(),
      );
    }).toList();
    return Restaurant(
      id: '${r['id']}',
      name: '${r['name']}',
      tagline: '${r['tagline'] ?? ''}',
      description: '${r['description'] ?? ''}',
      coverImage: '${r['coverImage'] ?? ''}',
      rating: double.tryParse('${r['rating']}') ?? 0,
      ratingCount: (r['ratingCount'] as num?)?.toInt() ?? 0,
      cuisines: List<String>.from(r['cuisines'] ?? const <String>[]),
      deliveryMinutes: (r['deliveryMinutes'] as num?)?.toInt() ?? 30,
      deliveryFee: double.tryParse('${r['deliveryFee']}') ?? 0,
      priceForTwo: (r['priceForTwo'] as num?)?.toInt() ?? 0,
      distanceKm: double.tryParse('${r['distanceKm']}') ?? 0,
      categories: List<String>.from(r['categories'] ?? const <String>[]),
      offer: '${r['offer'] ?? ''}',
      menuCategories: List<String>.from(r['menuCategories'] ?? const <String>[]),
      menu: menu,
      isPromoted: r['isPromoted'] == true,
      isAvailable: r['isAvailable'] != false,
    );
  }
}