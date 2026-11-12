import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/food_category.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import 'foodie_image.dart';
import 'rating_badge.dart';
import 'veg_badge.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.isFavorite,
    required this.onFavorite,
    required this.heroTag,
    this.width = 286,
  });

  final Restaurant restaurant;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final String heroTag;
  final double width;

  @override
  Widget build(BuildContext context) {
    final FoodCategory? cuisine = cuisineForRestaurant(restaurant);
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            decoration: BoxDecoration(
              color: context.foodie.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Hero(
                      tag: heroTag,
                      child: FoodieImage(
                        asset: restaurant.coverImage,
                        width: width,
                        height: 146,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavorite,
                        size: 34,
                      ),
                    ),
                    if (restaurant.isPromoted)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.foodie.overlayDark,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text(
                            'PROMOTED',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: RatingBadge(
                        rating: restaurant.rating,
                        ratingCount: restaurant.ratingCount,
                        light: true,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.foodie.surface.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${restaurant.deliveryMinutes} min',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: context.foodie.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              restaurant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.h3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const VegBadge(isVeg: true, size: 13),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          if (cuisine != null) ...<Widget>[
                            CuisineDot(color: cuisine.color),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              restaurant.cuisineLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.small,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.delivery_dining_rounded,
                            size: 15,
                            color: context.foodie.muted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${currencyLabel(restaurant.deliveryFee)} delivery',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.small
                                  .copyWith(fontSize: 11.5),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: context.foodie.muted,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${restaurant.distanceKm} km',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.small
                                  .copyWith(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                      if (restaurant.offer.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.foodie.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.local_offer_rounded,
                                size: 12,
                                color: context.foodie.primaryInk,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  restaurant.offer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: context.foodie.primaryInk,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String currencyLabel(double value) => '₹${value.round()}';

/// The cuisine a kitchen belongs to, resolved against the category palette.
/// A kitchen whose cuisine has no category of its own simply carries no
/// hue — the written label still carries the meaning.
FoodCategory? cuisineForRestaurant(Restaurant restaurant) {
  for (final String id in restaurant.categories) {
    final int index = MockData.categories.indexWhere(
      (FoodCategory category) => category.id == id,
    );
    if (index >= 0) return MockData.categories[index];
  }
  for (final String cuisine in restaurant.cuisines) {
    final int index = MockData.categories.indexWhere(
      (FoodCategory category) =>
          category.id != 'all' &&
          category.label.toLowerCase() == cuisine.toLowerCase(),
    );
    if (index >= 0) return MockData.categories[index];
  }
  return null;
}

/// The cuisine a dish belongs to, resolved against the category palette.
FoodCategory? cuisineForDish(FoodItem item) {
  final String? id = item.homeCategory;
  if (id != null) {
    final int index = MockData.categories.indexWhere(
      (FoodCategory category) => category.id == id,
    );
    if (index >= 0) return MockData.categories[index];
  }
  final int index = MockData.categories.indexWhere(
    (FoodCategory category) =>
        category.id != 'all' &&
        category.label.toLowerCase() == item.category.toLowerCase(),
  );
  return index >= 0 ? MockData.categories[index] : null;
}

/// A cuisine hue, deepened towards the ink ramp only as far as it has to be
/// so that it clears 4.5:1 against [against]. Hues that already carry a
/// label are left exactly as authored.
///
/// [ink] is the colour the hue is deepened towards — callers pass the
/// theme's ink (`context.foodie.inkStrong`) so the ramp follows the active
/// brightness. It falls back to the light palette's ink when a caller has
/// no theme to hand.
Color cuisineOn(Color hue, Color against, [Color? ink]) {
  final Color target = ink ?? FoodiePalette.light.inkStrong;
  if (_contrast(hue, against) >= 4.5) return hue;
  Color colour = hue;
  for (double step = 0.1; step <= 0.6; step += 0.1) {
    colour = Color.lerp(hue, target, step) ?? hue;
    if (_contrast(colour, against) >= 4.6) break;
  }
  return colour;
}

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// A small cuisine marker. The dot only ever sits next to a written label,
/// so the colour is never the only signal.
class CuisineDot extends StatelessWidget {
  const CuisineDot({super.key, required this.color, this.size = 7});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
