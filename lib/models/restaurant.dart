import 'food_item.dart';

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.coverImage,
    required this.rating,
    required this.ratingCount,
    required this.cuisines,
    required this.deliveryMinutes,
    required this.deliveryFee,
    required this.priceForTwo,
    required this.distanceKm,
    required this.categories,
    required this.offer,
    required this.menuCategories,
    required this.menu,
    this.isPromoted = false,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final String coverImage;
  final double rating;
  final int ratingCount;
  final List<String> cuisines;
  final int deliveryMinutes;
  final double deliveryFee;
  final int priceForTwo;
  final double distanceKm;
  final List<String> categories;
  final String offer;
  final List<String> menuCategories;
  final List<FoodItem> menu;
  final bool isPromoted;
  final bool isAvailable;

  String get cuisineLabel => cuisines.join(' • ');
}
