import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/food_category.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'foodie_image.dart';
import 'quantity_stepper.dart';
import 'rating_badge.dart';
import 'restaurant_card.dart';
import 'veg_badge.dart';

class DishCard extends StatelessWidget {
  const DishCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    required this.onAdd,
    this.width = 220,
  });

  final FoodItem item;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final double width;

  @override
  Widget build(BuildContext context) {
    final Restaurant? restaurant = MockData.restaurantById(item.restaurantId);
    final FoodCategory? cuisine = cuisineForDish(item);
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
              border: Border.all(
                  color: context.foodie.border.withValues(alpha: 0.75)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    FoodieImage(
                      asset: item.image,
                      width: width,
                      height: 132,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavorite,
                        size: 31,
                      ),
                    ),
                    if (item.isBestseller)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.foodie.overlayDark,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text(
                            'BESTSELLER',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 7.8,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 10,
                      bottom: 8,
                      child: RatingBadge(
                        rating: item.rating,
                        compact: true,
                        light: true,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          VegBadge(isVeg: item.isVeg, size: 13),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  context.foodieType.h3.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: <Widget>[
                          CuisineTag(label: item.category, cuisine: cuisine),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              restaurant?.name ?? 'Foodie kitchen',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.small
                                  .copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              currency(item.price),
                              style: context.foodieType.price
                                  .copyWith(fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: onAdd,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.foodie.primary,
                                foregroundColor: context.foodie.onPrimary,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                minimumSize: const Size(54, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

class DishListTile extends StatelessWidget {
  const DishListTile({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.quantity = 0,
    this.showAddButton = true,
  });

  final FoodItem item;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int quantity;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    final Restaurant? restaurant = MockData.restaurantById(item.restaurantId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  FoodieImage(
                    asset: item.image,
                    width: 104,
                    height: 112,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  Positioned(
                    left: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.foodie.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: VegBadge(isVeg: item.isVeg, size: 12),
                    ),
                  ),
                  if (item.isBestseller)
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.foodie.overlayDark,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text(
                          'BESTSELLER',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 6.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                context.foodieType.h3.copyWith(fontSize: 15.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavorite,
                          size: 30,
                          showShadow: false,
                          backgroundColor: context.foodie.background,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        RatingBadge(rating: item.rating, compact: true),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            restaurant?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                context.foodieType.small.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.small.copyWith(fontSize: 11.3),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: <Widget>[
                        Text(
                          currency(item.price),
                          style:
                              context.foodieType.price.copyWith(fontSize: 15),
                        ),
                        const Spacer(),
                        if (!showAddButton)
                          const SizedBox.shrink()
                        else if (quantity > 0)
                          QuantityStepper(
                            quantity: quantity,
                            onIncrement: onIncrement,
                            onDecrement: onDecrement,
                            compact: true,
                          )
                        else
                          OutlineAddButton(onTap: onAdd),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cuisine a dish belongs to, as a soft tinted tag. The written label
/// carries the meaning; the hue only adds identity.
class CuisineTag extends StatelessWidget {
  const CuisineTag({super.key, required this.label, required this.cuisine});

  final String label;
  final FoodCategory? cuisine;

  @override
  Widget build(BuildContext context) {
    final FoodCategory? category = cuisine;
    final FoodiePalette palette = context.foodie;
    // The authored `softColor` is a pale pastel that only works on a light
    // canvas, so the chip is built from the cuisine hue at low alpha over
    // the themed surface — the tint then reads on either brightness.
    final Color background = category == null
        ? palette.surfaceMuted
        : Color.alphaBlend(
            category.color.withValues(alpha: 0.18),
            palette.surface,
          );
    final Color ink = category == null
        ? palette.muted
        : cuisineOn(category.color, background, palette.inkStrong);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: ink,
        ),
      ),
    );
  }
}
