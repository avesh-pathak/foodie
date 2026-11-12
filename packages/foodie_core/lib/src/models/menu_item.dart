class MenuItem {
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

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description = '',
    required this.price,
    this.image = '',
    this.rating = 0,
    this.ratingCount = 0,
    this.isVeg = true,
    required this.category,
    this.homeCategory,
    this.isBestseller = false,
    this.isRecommended = false,
    this.addOns = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
        id: j['id'],
        restaurantId: j['restaurantId'],
        name: j['name'],
        description: j['description'] ?? '',
        price: double.tryParse('${j['price']}') ?? 0,
        image: j['image'] ?? '',
        rating: double.tryParse('${j['rating']}') ?? 0,
        ratingCount: int.tryParse('${j['ratingCount']}') ?? 0,
        isVeg: j['isVeg'] ?? true,
        category: j['category'] ?? '',
        homeCategory: j['homeCategory'],
        isBestseller: j['isBestseller'] ?? false,
        isRecommended: j['isRecommended'] ?? false,
        addOns: (j['addOns'] as List?)?.map((e) => AddOn.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'rating': rating,
        'ratingCount': ratingCount,
        'isVeg': isVeg,
        'category': category,
        'homeCategory': homeCategory,
        'isBestseller': isBestseller,
        'isRecommended': isRecommended,
        'addOns': addOns.map((e) => e.toJson()).toList(),
      };
}

class AddOn {
  final String name;
  final double price;
  AddOn({required this.name, required this.price});
  factory AddOn.fromJson(Map<String, dynamic> j) => AddOn(name: j['name'], price: (j['price'] as num).toDouble());
  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}