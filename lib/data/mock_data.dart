import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/delivery_address.dart';
import '../models/food_category.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/restaurant.dart';

class PromoBanner {
  const PromoBanner({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.image,
    required this.colors,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String code;
  final String image;
  final List<Color> colors;
}

class FaqItem {
  const FaqItem(this.question, this.answer);

  final String question;
  final String answer;
}

abstract final class MockData {
  /// Cuisine hues. Each hue means one cuisine and nothing else.
  ///
  /// Every pair below was checked with the WCAG 2.2 contrast formula:
  /// `color` on `softColor` and white on `color` both clear 4.5:1, so a
  /// hue can be used as a fill with a white label or as ink on its own tint
  /// without either direction failing. Hues are also spaced far enough apart
  /// to stay distinguishable in greyscale, and each one ships with an icon
  /// and a written label so colour is never the only signal.
  static const List<FoodCategory> categories = <FoodCategory>[
    FoodCategory(
      id: 'all',
      label: 'All',
      icon: Icons.grid_view_rounded,
      // The "All" tile is the brand tile, so it wears Zomato red rather than
      // borrowing a cuisine hue.
      color: Color(0xFFC4202F),
      softColor: Color(0xFFFDEBEE),
    ),
    FoodCategory(
      id: 'biryani',
      label: 'Biryani',
      icon: Icons.rice_bowl_rounded,
      color: Color(0xFFA8481F),
      softColor: Color(0xFFFFE7D8),
    ),
    FoodCategory(
      id: 'pizza',
      label: 'Pizza',
      icon: Icons.local_pizza_rounded,
      color: Color(0xFFB03A46),
      softColor: Color(0xFFFBE4E8),
    ),
    FoodCategory(
      id: 'burgers',
      label: 'Burgers',
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFF9A6206),
      softColor: Color(0xFFFFF0CF),
    ),
    FoodCategory(
      id: 'chinese',
      label: 'Chinese',
      icon: Icons.ramen_dining_rounded,
      color: Color(0xFF2E6E5C),
      softColor: Color(0xFFE4F3EE),
    ),
    FoodCategory(
      id: 'south-indian',
      label: 'South Indian',
      icon: Icons.set_meal_rounded,
      color: Color(0xFF56721F),
      softColor: Color(0xFFEFF3E1),
    ),
    FoodCategory(
      id: 'desserts',
      label: 'Desserts',
      icon: Icons.cake_rounded,
      color: Color(0xFF8E4160),
      softColor: Color(0xFFFBE8EF),
    ),
    FoodCategory(
      id: 'beverages',
      label: 'Beverages',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF3F5C93),
      softColor: Color(0xFFE8EEF9),
    ),
  ];

  /// Looks up a cuisine by its id.
  static FoodCategory? categoryById(String id) {
    for (final FoodCategory category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Looks up a cuisine by its label, case-insensitively.
  static FoodCategory? categoryByLabel(String label) {
    final String needle = label.trim().toLowerCase();
    for (final FoodCategory category in categories) {
      if (category.label.toLowerCase() == needle) return category;
    }
    return null;
  }

  /// The hue for a dish or restaurant, preferring the explicit category id
  /// and falling back to the display label.
  static FoodCategory? categoryFor(String? id, String? label) {
    if (id != null) {
      final FoodCategory? byId = categoryById(id);
      if (byId != null) return byId;
    }
    if (label != null) return categoryByLabel(label);
    return null;
  }

  static const List<PromoBanner> promos = <PromoBanner>[
    PromoBanner(
      eyebrow: 'WEEKEND FEAST',
      title: 'Flat 50% OFF',
      subtitle: 'On your first order above ₹399',
      code: 'FOODIE50',
      image: 'assets/images/promo_pizza.jpg',
      // Zomato red: white promo copy clears 5.8:1 over the lightest stop.
      colors: <Color>[Color(0xFF7A0F18), Color(0xFFC4202F)],
    ),
    PromoBanner(
      eyebrow: 'FREE DELIVERY',
      title: 'Dinner, delivered',
      subtitle: 'No delivery fee on orders above ₹199',
      code: 'FREEDEL',
      image: 'assets/images/promo_food.jpg',
      colors: <Color>[Color(0xFF273D2D), Color(0xFF48664D)],
    ),
    PromoBanner(
      eyebrow: 'SWEET TOOTH',
      title: 'Save 20%',
      subtitle: 'On cakes, kulfi & all things sweet',
      code: 'SWEET20',
      image: 'assets/images/promo_dessert.jpg',
      colors: <Color>[Color(0xFF4A293B), Color(0xFF81516A)],
    ),
  ];

  static const List<Coupon> coupons = <Coupon>[
    Coupon(
      code: 'FOODIE50',
      title: 'Flat 50% off',
      description: '50% off your order, up to ₹150.',
      kind: CouponKind.percent,
      value: 50,
      minOrder: 399,
      maxDiscount: 150,
    ),
    Coupon(
      code: 'WELCOME100',
      title: '₹100 off',
      description: 'A little welcome treat on orders above ₹499.',
      kind: CouponKind.flat,
      value: 100,
      minOrder: 499,
    ),
    Coupon(
      code: 'FREEDEL',
      title: 'Free delivery',
      description: 'We will take care of the delivery fee.',
      kind: CouponKind.freeDelivery,
      value: 0,
      minOrder: 199,
    ),
    Coupon(
      code: 'SWEET20',
      title: '20% off desserts',
      description: '20% off up to ₹80 on orders above ₹249.',
      kind: CouponKind.percent,
      value: 20,
      minOrder: 249,
      maxDiscount: 80,
    ),
  ];

  static const List<DeliveryAddress> addresses = <DeliveryAddress>[
    DeliveryAddress(
      id: 'addr_home',
      label: 'Home',
      line1: '12, Rosewood Residency, Indiranagar',
      line2: '100 Feet Road, Bengaluru 560038',
      type: AddressType.home,
      isDefault: true,
    ),
    DeliveryAddress(
      id: 'addr_work',
      label: 'Work',
      line1: 'Foodie Labs, 4th floor, WeWork Galaxy',
      line2: 'Residency Road, Bengaluru 560025',
      type: AddressType.work,
    ),
    DeliveryAddress(
      id: 'addr_other',
      label: 'Other',
      line1: '42, Lakeview Apartments, HSR Layout',
      line2: 'Sector 2, Bengaluru 560102',
      type: AddressType.other,
    ),
  ];

  static const List<Rider> riders = <Rider>[
    Rider(
      name: 'Avesh Mehta',
      phone: '+91 98765 43210',
      vehicle: 'Honda Activa • KA 01 AB 4821',
      rating: 4.9,
    ),
    Rider(
      name: 'Aarav Singh',
      phone: '+91 98450 11223',
      vehicle: 'TVS Jupiter • KA 05 CX 9087',
      rating: 4.8,
    ),
    Rider(
      name: 'Imran Khan',
      phone: '+91 99001 22334',
      vehicle: 'Bajaj Chetak • KA 03 EV 7712',
      rating: 4.9,
    ),
  ];

  static const List<String> popularSearches = <String>[
    'Biryani',
    'Margherita',
    'Momos',
    'Chocolate cake',
    'Dosa',
  ];

  static const List<FaqItem> faqs = <FaqItem>[
    FaqItem(
      'How do I track my order?',
      'Open the Orders tab and tap your active order. You will see a live demo timeline and rider details. You can also use “Simulate next status” to move the demo order forward.',
    ),
    FaqItem(
      'Can I change my delivery address?',
      'Yes. During checkout, tap your address to choose another saved address or add a new one. Saved addresses can be managed from Profile → Saved addresses.',
    ),
    FaqItem(
      'How do coupon codes work?',
      'Add items to your cart, open the cart screen and enter a code such as FOODIE50 or WELCOME100. The discount is calculated locally and shown in your bill.',
    ),
    FaqItem(
      'What payment methods are supported?',
      'This is a demo app, so Cash on Delivery, UPI and Card are simulated. We never collect real payment details or process a payment.',
    ),
    FaqItem(
      'Can I reorder a past meal?',
      'Absolutely. Open Orders → History, select an order and tap “Reorder”. The items are added to your cart again.',
    ),
    FaqItem(
      'How do I clear my demo data?',
      'Go to Profile → Settings → Reset demo data. This clears the cart, favourites and orders from the current session. Your login stays active.',
    ),
  ];

  static final List<Restaurant> restaurants = <Restaurant>[
    const Restaurant(
      id: 'hyderabadi_house',
      name: 'Hyderabadi House',
      tagline: 'Slow-cooked dum biryani & royal Mughlai plates',
      description:
          'A neighbourhood favourite for fragrant, slow-cooked biryani. Every handi is sealed with dough, cooked on dum and opened just before it reaches you.',
      coverImage: 'assets/images/cover_hyderabadi.jpg',
      rating: 4.6,
      ratingCount: 2840,
      cuisines: <String>['Biryani', 'Mughlai', 'North Indian'],
      deliveryMinutes: 32,
      deliveryFee: 29,
      priceForTwo: 450,
      distanceKm: 2.4,
      categories: <String>['biryani'],
      offer: '50% OFF up to ₹120',
      menuCategories: <String>['Biryani', 'Curries', 'Desserts', 'Beverages'],
      menu: <FoodItem>[
        FoodItem(
          id: 'f_chicken_biryani',
          restaurantId: 'hyderabadi_house',
          name: 'Hyderabadi Chicken Dum Biryani',
          description:
              'Long-grain basmati, saffron, tender chicken and fried onions. Served with raita and mirchi ka salan.',
          price: 329,
          image: 'assets/images/dish_biryani.jpg',
          rating: 4.8,
          ratingCount: 2314,
          isVeg: false,
          category: 'Biryani',
          homeCategory: 'biryani',
          isBestseller: true,
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Extra raita', price: 29),
            AddOn(name: 'Extra mirchi ka salan', price: 39),
            AddOn(name: 'Make it boneless', price: 60),
          ],
        ),
        FoodItem(
          id: 'f_paneer_butter_masala',
          restaurantId: 'hyderabadi_house',
          name: 'Paneer Butter Masala',
          description:
              'Velvety tomato-cashew gravy, charred paneer and a swirl of cream. Perfect with butter naan.',
          price: 289,
          image: 'assets/images/dish_paneer.jpg',
          rating: 4.6,
          ratingCount: 1082,
          isVeg: true,
          category: 'Curries',
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Butter naan', price: 49),
            AddOn(name: 'Extra creamy', price: 30),
          ],
        ),
        FoodItem(
          id: 'f_andhra_chicken',
          restaurantId: 'hyderabadi_house',
          name: 'Andhra Chicken Curry',
          description:
              'Fiery, slow-simmered chicken curry with curry leaves, black pepper and a bold ghee finish.',
          price: 319,
          image: 'assets/images/dish_andhra_curry.jpg',
          rating: 4.5,
          ratingCount: 674,
          isVeg: false,
          category: 'Curries',
        ),
        FoodItem(
          id: 'f_gulab_jamun',
          restaurantId: 'hyderabadi_house',
          name: 'Warm Gulab Jamun',
          description:
              'Soft milk dumplings soaked in cardamom-scented syrup. Two pieces, served warm.',
          price: 119,
          image: 'assets/images/dish_gulab_jamun.jpg',
          rating: 4.7,
          ratingCount: 912,
          isVeg: true,
          category: 'Desserts',
          homeCategory: 'desserts',
          addOns: <AddOn>[
            AddOn(name: 'Extra rabri', price: 25),
          ],
        ),
        FoodItem(
          id: 'f_masala_chai',
          restaurantId: 'hyderabadi_house',
          name: 'Kadak Masala Chai',
          description:
              'Assam tea brewed with ginger, cardamom and cloves. Comfort in a cup.',
          price: 79,
          image: 'assets/images/dish_chai.jpg',
          rating: 4.6,
          ratingCount: 520,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
          addOns: <AddOn>[
            AddOn(name: 'Extra ginger', price: 10),
          ],
        ),
      ],
    ),
    const Restaurant(
      id: 'napoli_pizzeria',
      name: 'Napoli Pizzeria',
      tagline: 'Wood-fired sourdough pizza, Naples style',
      description:
          'Naturally leavened dough, San Marzano tomatoes and mozzarella pulled fresh every morning. Baked at 450°C for that perfect leopard-spotted crust.',
      coverImage: 'assets/images/cover_napoli.jpg',
      rating: 4.5,
      ratingCount: 1986,
      cuisines: <String>['Italian', 'Pizza', 'Pasta'],
      deliveryMinutes: 28,
      deliveryFee: 39,
      priceForTwo: 600,
      distanceKm: 3.1,
      categories: <String>['pizza'],
      offer: 'Buy 1 Get 1 on medium pizzas',
      menuCategories: <String>['Pizza', 'Desserts', 'Beverages'],
      menu: <FoodItem>[
        FoodItem(
          id: 'f_margherita',
          restaurantId: 'napoli_pizzeria',
          name: 'Classic Margherita',
          description:
              'San Marzano tomato, fior di latte mozzarella, fresh basil and a drizzle of olive oil.',
          price: 299,
          image: 'assets/images/dish_margherita.jpg',
          rating: 4.7,
          ratingCount: 1440,
          isVeg: true,
          category: 'Pizza',
          homeCategory: 'pizza',
          isBestseller: true,
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Extra mozzarella', price: 49),
            AddOn(name: 'Jalapeños', price: 29),
            AddOn(name: 'Garlic dip', price: 20),
          ],
        ),
        FoodItem(
          id: 'f_farmhouse_pizza',
          restaurantId: 'napoli_pizzeria',
          name: 'Farmhouse Pizza',
          description:
              'Bell peppers, sweet corn, red onion, mushrooms and generous mozzarella on tomato base.',
          price: 449,
          image: 'assets/images/dish_farmhouse.jpg',
          rating: 4.6,
          ratingCount: 826,
          isVeg: true,
          category: 'Pizza',
          homeCategory: 'pizza',
          addOns: <AddOn>[
            AddOn(name: 'Extra cheese', price: 49),
            AddOn(name: 'Peri peri sprinkle', price: 15),
          ],
        ),
        FoodItem(
          id: 'f_tandoori_paneer_pizza',
          restaurantId: 'napoli_pizzeria',
          name: 'Tandoori Paneer Pizza',
          description:
              'Smoky tandoori paneer, red onion, mint drizzle and a warm garam masala finish.',
          price: 499,
          image: 'assets/images/dish_tandoori_paneer.jpg',
          rating: 4.5,
          ratingCount: 611,
          isVeg: true,
          category: 'Pizza',
          homeCategory: 'pizza',
        ),
        FoodItem(
          id: 'f_tiramisu',
          restaurantId: 'napoli_pizzeria',
          name: 'Espresso Tiramisu',
          description:
              'Mascarpone, espresso-soaked ladyfingers and a dusting of dark cocoa.',
          price: 249,
          image: 'assets/images/dish_tiramisu.jpg',
          rating: 4.8,
          ratingCount: 356,
          isVeg: true,
          category: 'Desserts',
          homeCategory: 'desserts',
        ),
        FoodItem(
          id: 'f_cold_coffee',
          restaurantId: 'napoli_pizzeria',
          name: 'Italian Cold Coffee',
          description:
              'Double espresso, cold milk and a soft cocoa foam. Lightly sweetened.',
          price: 149,
          image: 'assets/images/dish_cold_coffee.jpg',
          rating: 4.4,
          ratingCount: 284,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
        ),
      ],
    ),
    const Restaurant(
      id: 'burger_barn',
      name: 'Burger Barn',
      tagline: 'Smashed patties, toasted brioche & big flavours',
      description:
          'A tiny burger joint with a big grill. We smash our patties thin for crisp edges, stack them in buttery brioche and never skip the house sauce.',
      coverImage: 'assets/images/cover_burger.jpg',
      rating: 4.4,
      ratingCount: 1560,
      cuisines: <String>['American', 'Burgers', 'Fast Food'],
      deliveryMinutes: 24,
      deliveryFee: 29,
      priceForTwo: 400,
      distanceKm: 1.8,
      categories: <String>['burgers'],
      offer: 'Free peri-peri fries above ₹499',
      menuCategories: <String>['Burgers', 'Beverages'],
      menu: <FoodItem>[
        FoodItem(
          id: 'f_classic_cheeseburger',
          restaurantId: 'burger_barn',
          name: 'Classic Cheeseburger',
          description:
              'Double smashed patty, aged cheddar, pickles, onion and Burger Barn special sauce.',
          price: 249,
          image: 'assets/images/dish_cheeseburger.jpg',
          rating: 4.6,
          ratingCount: 1208,
          isVeg: false,
          category: 'Burgers',
          homeCategory: 'burgers',
          isBestseller: true,
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Extra cheese slice', price: 40),
            AddOn(name: 'Smoked bacon', price: 70),
            AddOn(name: 'Peri-peri fries', price: 69),
          ],
        ),
        FoodItem(
          id: 'f_bbq_burger',
          restaurantId: 'burger_barn',
          name: 'Smoky BBQ Burger',
          description:
              'Charred beef patty, crispy onions, smoked cheddar and a sticky bourbon BBQ glaze.',
          price: 299,
          image: 'assets/images/dish_bbq_burger.jpg',
          rating: 4.5,
          ratingCount: 742,
          isVeg: false,
          category: 'Burgers',
          homeCategory: 'burgers',
          addOns: <AddOn>[
            AddOn(name: 'Extra patty', price: 90),
            AddOn(name: 'Jalapeños', price: 25),
          ],
        ),
        FoodItem(
          id: 'f_crispy_chicken_burger',
          restaurantId: 'burger_barn',
          name: 'Crispy Chicken Burger',
          description:
              'Buttermilk-fried chicken thigh, crunchy slaw, pickles and honey-mustard mayo.',
          price: 279,
          image: 'assets/images/dish_crispy_burger.jpg',
          rating: 4.5,
          ratingCount: 690,
          isVeg: false,
          category: 'Burgers',
          homeCategory: 'burgers',
        ),
        FoodItem(
          id: 'f_burger_lime_soda',
          restaurantId: 'burger_barn',
          name: 'Fresh Lime Soda',
          description:
              'Fresh lime, chilled soda and a pinch of black salt. Sweet or salted.',
          price: 99,
          image: 'assets/images/dish_lime_soda.jpg',
          rating: 4.3,
          ratingCount: 258,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
        ),
        FoodItem(
          id: 'f_burger_cold_coffee',
          restaurantId: 'burger_barn',
          name: 'Cold Coffee Shake',
          description:
              'Cold brew blended with vanilla ice cream and a chocolate drizzle.',
          price: 139,
          image: 'assets/images/dish_cold_coffee.jpg',
          rating: 4.4,
          ratingCount: 301,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
        ),
      ],
    ),
    const Restaurant(
      id: 'wok_and_roll',
      name: 'Wok & Roll',
      tagline: 'Wok-tossed noodles, momos & midnight cravings',
      description:
          'High flame, strong flavours and plenty of chilli. Our noodles are tossed to order and our momos are pleated by hand every morning.',
      coverImage: 'assets/images/cover_wok.jpg',
      rating: 4.3,
      ratingCount: 1248,
      cuisines: <String>['Chinese', 'Asian', 'Momos'],
      deliveryMinutes: 35,
      deliveryFee: 39,
      priceForTwo: 500,
      distanceKm: 4.2,
      categories: <String>['chinese'],
      offer: '20% OFF on orders above ₹349',
      menuCategories: <String>['Momos', 'Noodles & Rice', 'Starters'],
      menu: <FoodItem>[
        FoodItem(
          id: 'f_veg_momos',
          restaurantId: 'wok_and_roll',
          name: 'Steamed Veg Momos',
          description:
              'Eight hand-pleated momos packed with cabbage, carrot and spring onion. Served with chilli chutney.',
          price: 179,
          image: 'assets/images/dish_momos.jpg',
          rating: 4.7,
          ratingCount: 1104,
          isVeg: true,
          category: 'Momos',
          homeCategory: 'chinese',
          isBestseller: true,
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Extra chilli chutney', price: 20),
            AddOn(name: 'Schezwan drizzle', price: 30),
          ],
        ),
        FoodItem(
          id: 'f_chilli_garlic_noodles',
          restaurantId: 'wok_and_roll',
          name: 'Chilli Garlic Noodles',
          description:
              'Springy hakka noodles tossed with garlic, dried red chilli, soy and crunchy vegetables.',
          price: 239,
          image: 'assets/images/dish_noodles.jpg',
          rating: 4.5,
          ratingCount: 884,
          isVeg: true,
          category: 'Noodles & Rice',
          homeCategory: 'chinese',
          addOns: <AddOn>[
            AddOn(name: 'Add egg', price: 35),
            AddOn(name: 'Extra spicy', price: 0),
          ],
        ),
        FoodItem(
          id: 'f_schezwan_fried_rice',
          restaurantId: 'wok_and_roll',
          name: 'Schezwan Fried Rice',
          description:
              'Wok-charred rice, crunchy greens and a punchy house-made schezwan sauce.',
          price: 229,
          image: 'assets/images/dish_fried_rice.jpg',
          rating: 4.4,
          ratingCount: 620,
          isVeg: true,
          category: 'Noodles & Rice',
          homeCategory: 'chinese',
        ),
        FoodItem(
          id: 'f_spring_rolls',
          restaurantId: 'wok_and_roll',
          name: 'Crispy Spring Rolls',
          description:
              'Golden, flaky rolls stuffed with julienned vegetables. Four pieces with sweet chilli dip.',
          price: 199,
          image: 'assets/images/dish_spring_rolls.jpg',
          rating: 4.3,
          ratingCount: 412,
          isVeg: true,
          category: 'Starters',
          homeCategory: 'chinese',
        ),
      ],
    ),
    const Restaurant(
      id: 'dosa_junction',
      name: 'Dosa Junction',
      tagline: 'Crispy dosas, filter coffee & a little nostalgia',
      description:
          'A modern take on the neighbourhood tiffin room. Stone-ground batter, house podi and coffee that is still poured the old-fashioned way.',
      coverImage: 'assets/images/cover_dosa.jpg',
      rating: 4.7,
      ratingCount: 2104,
      cuisines: <String>['South Indian', 'Breakfast', 'Tiffin'],
      deliveryMinutes: 22,
      deliveryFee: 19,
      priceForTwo: 250,
      distanceKm: 1.2,
      categories: <String>['south-indian'],
      offer: 'Free filter coffee above ₹299',
      menuCategories: <String>['Dosas', 'Tiffin', 'Beverages'],
      menu: <FoodItem>[
        FoodItem(
          id: 'f_masala_dosa',
          restaurantId: 'dosa_junction',
          name: 'Ghee Roast Masala Dosa',
          description:
              'Extra-crisp dosa roasted in ghee, filled with spiced potato masala. Served with sambar and two chutneys.',
          price: 189,
          image: 'assets/images/dish_dosa.jpg',
          rating: 4.8,
          ratingCount: 1802,
          isVeg: true,
          category: 'Dosas',
          homeCategory: 'south-indian',
          isBestseller: true,
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Extra podi', price: 20),
            AddOn(name: 'Extra chutney', price: 25),
          ],
        ),
        FoodItem(
          id: 'f_idli_sambar',
          restaurantId: 'dosa_junction',
          name: 'Idli Sambar',
          description:
              'Three pillowy steamed idlis with lentil sambar, coconut chutney and a spoon of ghee.',
          price: 129,
          image: 'assets/images/dish_idli.jpg',
          rating: 4.6,
          ratingCount: 720,
          isVeg: true,
          category: 'Tiffin',
          homeCategory: 'south-indian',
        ),
        FoodItem(
          id: 'f_medu_vada',
          restaurantId: 'dosa_junction',
          name: 'Medu Vada',
          description:
              'Crisp outside, soft inside. Two urad dal vadas with sambar and chutney.',
          price: 149,
          image: 'assets/images/dish_vada.jpg',
          rating: 4.5,
          ratingCount: 534,
          isVeg: true,
          category: 'Tiffin',
          homeCategory: 'south-indian',
        ),
        FoodItem(
          id: 'f_filter_coffee',
          restaurantId: 'dosa_junction',
          name: 'Filter Coffee',
          description:
              'Strong South Indian decoction, hot milk and just the right amount of sugar.',
          price: 69,
          image: 'assets/images/dish_filter_coffee.jpg',
          rating: 4.7,
          ratingCount: 912,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
        ),
      ],
    ),
    const Restaurant(
      id: 'sweet_tooth',
      name: 'Sweet Tooth',
      tagline: 'Small-batch cakes, kulfi & happy endings',
      description:
          'A tiny bakery with a serious sweet tooth. Everything is baked in small batches, and the kulfi is churned slowly with real mango.',
      coverImage: 'assets/images/cover_sweet.jpg',
      rating: 4.8,
      ratingCount: 1732,
      cuisines: <String>['Desserts', 'Bakery', 'Beverages'],
      deliveryMinutes: 20,
      deliveryFee: 29,
      priceForTwo: 350,
      distanceKm: 1.6,
      categories: <String>['desserts'],
      offer: 'Flat ₹50 off above ₹399',
      menuCategories: <String>['Cakes', 'Frozen', 'Beverages'],
      menu: <FoodItem>[
        FoodItem(
          id: 'f_chocolate_cake',
          restaurantId: 'sweet_tooth',
          name: 'Molten Chocolate Cake',
          description:
              'Warm dark-chocolate cake with a gooey centre. Best enjoyed with vanilla ice cream.',
          price: 219,
          image: 'assets/images/dish_chocolate_cake.jpg',
          rating: 4.9,
          ratingCount: 1402,
          isVeg: true,
          category: 'Cakes',
          homeCategory: 'desserts',
          isBestseller: true,
          isRecommended: true,
          addOns: <AddOn>[
            AddOn(name: 'Vanilla ice cream', price: 50),
            AddOn(name: 'Extra chocolate sauce', price: 30),
          ],
        ),
        FoodItem(
          id: 'f_cupcakes',
          restaurantId: 'sweet_tooth',
          name: 'Blueberry Cupcakes',
          description:
              'Two soft vanilla cupcakes folded with blueberries and topped with cream-cheese frosting.',
          price: 179,
          image: 'assets/images/dish_cupcakes.jpg',
          rating: 4.6,
          ratingCount: 388,
          isVeg: true,
          category: 'Cakes',
          homeCategory: 'desserts',
        ),
        FoodItem(
          id: 'f_mango_kulfi',
          restaurantId: 'sweet_tooth',
          name: 'Mango Kulfi',
          description:
              'Slow-churned kulfi with Alphonso mango, pistachio and a hint of cardamom.',
          price: 149,
          image: 'assets/images/dish_kulfi.jpg',
          rating: 4.8,
          ratingCount: 764,
          isVeg: true,
          category: 'Frozen',
          homeCategory: 'desserts',
          isRecommended: true,
        ),
        FoodItem(
          id: 'f_lime_soda',
          restaurantId: 'sweet_tooth',
          name: 'Fresh Lime Soda',
          description:
              'Zesty lime, fizzy soda and a pinch of black salt. Sweet or salted.',
          price: 99,
          image: 'assets/images/dish_lime_soda.jpg',
          rating: 4.4,
          ratingCount: 188,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
        ),
        FoodItem(
          id: 'f_berry_mocktail',
          restaurantId: 'sweet_tooth',
          name: 'Berry Mocktail',
          description:
              'Muddled berries, mint, lime and tonic. Bright, bubbly and completely alcohol-free.',
          price: 169,
          image: 'assets/images/dish_mocktail.jpg',
          rating: 4.5,
          ratingCount: 241,
          isVeg: true,
          category: 'Beverages',
          homeCategory: 'beverages',
        ),
      ],
    ),
  ];

  static List<Restaurant> get popularRestaurants =>
      List<Restaurant>.unmodifiable(restaurants);

  static List<FoodItem> get recommendedDishes {
    final List<FoodItem> dishes = <FoodItem>[];
    for (final Restaurant restaurant in restaurants) {
      dishes.addAll(restaurant.menu.where((FoodItem item) => item.isRecommended));
    }
    return List<FoodItem>.unmodifiable(dishes);
  }

  static List<FoodItem> get allDishes {
    final List<FoodItem> dishes = <FoodItem>[];
    for (final Restaurant restaurant in restaurants) {
      dishes.addAll(restaurant.menu);
    }
    return List<FoodItem>.unmodifiable(dishes);
  }

  static Restaurant? restaurantById(String id) {
    for (final Restaurant restaurant in restaurants) {
      if (restaurant.id == id) return restaurant;
    }
    return null;
  }

  static FoodItem? dishById(String id) {
    for (final FoodItem item in allDishes) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<FoodOrder> sampleOrders() {
    final DeliveryAddress home = addresses.first;
    final FoodItem biryani = dishById('f_chicken_biryani')!;
    final FoodItem gulab = dishById('f_gulab_jamun')!;
    final FoodItem pizza = dishById('f_farmhouse_pizza')!;
    final FoodItem tiramisu = dishById('f_tiramisu')!;
    final FoodItem cake = dishById('f_chocolate_cake')!;
    final FoodItem coffee = dishById('f_filter_coffee')!;

    return <FoodOrder>[
      FoodOrder(
        id: 'FD24091801',
        lines: <OrderLine>[
          OrderLine(
            foodId: biryani.id,
            name: biryani.name,
            image: biryani.image,
            quantity: 1,
            unitPrice: 358,
            addOns: const <String>['Extra raita'],
          ),
          OrderLine(
            foodId: cake.id,
            name: cake.name,
            image: cake.image,
            quantity: 1,
            unitPrice: cake.price,
          ),
        ],
        subtotal: 577,
        deliveryFee: 29,
        taxes: 29,
        discount: 100,
        total: 535,
        address: home,
        paymentMethod: PaymentMethod.upi,
        placedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        etaMinutes: 30,
        statusIndex: 5,
        couponCode: 'WELCOME100',
        rider: riders.first,
      ),
      FoodOrder(
        id: 'FD24091202',
        lines: <OrderLine>[
          OrderLine(
            foodId: pizza.id,
            name: pizza.name,
            image: pizza.image,
            quantity: 1,
            unitPrice: pizza.price,
          ),
          OrderLine(
            foodId: tiramisu.id,
            name: tiramisu.name,
            image: tiramisu.image,
            quantity: 1,
            unitPrice: tiramisu.price,
          ),
        ],
        subtotal: 698,
        deliveryFee: 39,
        taxes: 35,
        discount: 0,
        total: 772,
        address: home,
        paymentMethod: PaymentMethod.card,
        placedAt: DateTime.now().subtract(const Duration(days: 9, hours: 5)),
        etaMinutes: 28,
        statusIndex: 5,
        rider: riders[1],
      ),
      FoodOrder(
        id: 'FD24090503',
        lines: <OrderLine>[
          OrderLine(
            foodId: gulab.id,
            name: gulab.name,
            image: gulab.image,
            quantity: 2,
            unitPrice: gulab.price,
          ),
          OrderLine(
            foodId: coffee.id,
            name: coffee.name,
            image: coffee.image,
            quantity: 2,
            unitPrice: coffee.price,
          ),
        ],
        subtotal: 376,
        deliveryFee: 19,
        taxes: 19,
        discount: 50,
        total: 364,
        address: addresses[1],
        paymentMethod: PaymentMethod.cod,
        placedAt: DateTime.now().subtract(const Duration(days: 16)),
        etaMinutes: 22,
        statusIndex: 5,
        rider: riders[2],
      ),
    ];
  }
}
