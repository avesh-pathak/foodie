class AddOn {
  const AddOn({
    required this.name,
    required this.price,
  });

  final String name;
  final double price;
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.rating,
    required this.ratingCount,
    required this.isVeg,
    required this.category,
    this.homeCategory,
    this.isBestseller = false,
    this.isRecommended = false,
    this.addOns = const <AddOn>[],
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final double rating;
  final int ratingCount;
  final bool isVeg;
  final String category;
  final String? homeCategory;
  final bool isBestseller;
  final bool isRecommended;
  final List<AddOn> addOns;
}
