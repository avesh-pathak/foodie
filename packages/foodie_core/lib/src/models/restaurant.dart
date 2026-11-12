class Restaurant {
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
  final bool isPromoted;

  Restaurant({
    required this.id,
    required this.name,
    this.tagline = '',
    this.description = '',
    this.coverImage = '',
    this.rating = 0,
    this.ratingCount = 0,
    this.cuisines = const [],
    this.deliveryMinutes = 30,
    this.deliveryFee = 0,
    this.priceForTwo = 0,
    this.distanceKm = 0,
    this.categories = const [],
    this.offer = '',
    this.menuCategories = const [],
    this.isPromoted = false,
  });

  factory Restaurant.fromJson(Map<String, dynamic> j) => Restaurant(
        id: j['id'],
        name: j['name'],
        tagline: j['tagline'] ?? '',
        description: j['description'] ?? '',
        coverImage: j['coverImage'] ?? '',
        rating: double.tryParse('${j['rating']}') ?? 0,
        ratingCount: int.tryParse('${j['ratingCount']}') ?? 0,
        cuisines: List<String>.from(j['cuisines'] ?? []),
        deliveryMinutes: int.tryParse('${j['deliveryMinutes']}') ?? 30,
        deliveryFee: double.tryParse('${j['deliveryFee']}') ?? 0,
        priceForTwo: int.tryParse('${j['priceForTwo']}') ?? 0,
        distanceKm: double.tryParse('${j['distanceKm']}') ?? 0,
        categories: List<String>.from(j['categories'] ?? []),
        offer: j['offer'] ?? '',
        menuCategories: List<String>.from(j['menuCategories'] ?? []),
        isPromoted: j['isPromoted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'description': description,
        'coverImage': coverImage,
        'rating': rating,
        'ratingCount': ratingCount,
        'cuisines': cuisines,
        'deliveryMinutes': deliveryMinutes,
        'deliveryFee': deliveryFee,
        'priceForTwo': priceForTwo,
        'distanceKm': distanceKm,
        'categories': categories,
        'offer': offer,
        'menuCategories': menuCategories,
        'isPromoted': isPromoted,
      };
}