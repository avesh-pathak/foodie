import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/dish_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/item_customization_sheet.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _showDishes = false;

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final List<Restaurant> restaurants = state.favoriteRestaurants;
    final List<FoodItem> dishes = state.favoriteDishes;
    final bool isEmpty =
        _showDishes ? dishes.isEmpty : restaurants.isEmpty;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'SAVED FOR LATER',
                            style: context.foodieType.eyebrow,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Your favourites.',
                            style:
                                context.foodieType.h1.copyWith(fontSize: 26),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.foodie.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 21,
                        color: context.foodie.primaryInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FavoriteSegmentedButton(
                  showDishes: _showDishes,
                  restaurantCount: restaurants.length,
                  dishCount: dishes.length,
                  onChanged: (bool value) => setState(() => _showDishes = value),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 118),
                        child: EmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: _showDishes
                              ? 'No favourite dishes yet'
                              : 'No favourite restaurants yet',
                          message:
                              'Tap the little heart on anything you love and it will be waiting for you here.',
                          buttonLabel: 'Explore food',
                          onPressed: () => widget.onSelectTab(1),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _showDishes
                            ? ListView.separated(
                                key: const ValueKey<String>('favourite-dishes'),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 118),
                                itemCount: dishes.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (BuildContext context, int index) {
                                  final FoodItem dish = dishes[index];
                                  final int quantity =
                                      state.quantityForDish(dish.id);
                                  return DishListTile(
                                    item: dish,
                                    isFavorite: true,
                                    quantity: quantity,
                                    onTap: () =>
                                        showItemCustomization(context, dish),
                                    onAdd: () =>
                                        showItemCustomization(context, dish),
                                    onIncrement: () =>
                                        state.incrementDish(dish.id),
                                    onDecrement: () =>
                                        state.decrementDish(dish.id),
                                    onFavorite: () {
                                      HapticFeedback.selectionClick();
                                      state.toggleDishFavorite(dish.id);
                                    },
                                  );
                                },
                              )
                            : LayoutBuilder(
                                key: const ValueKey<String>(
                                  'favourite-restaurants',
                                ),
                                builder: (
                                  BuildContext context,
                                  BoxConstraints constraints,
                                ) {
                                  return ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      20,
                                      118,
                                    ),
                                    itemCount: restaurants.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 14),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final Restaurant restaurant =
                                          restaurants[index];
                                      return RestaurantCard(
                                        restaurant: restaurant,
                                        width: constraints.maxWidth - 40,
                                        heroTag:
                                            'favorites_${restaurant.id}',
                                        isFavorite: true,
                                        onFavorite: () {
                                          HapticFeedback.selectionClick();
                                          state.toggleRestaurantFavorite(
                                            restaurant.id,
                                          );
                                        },
                                        onTap: () => Navigator.of(context).push(
                                          FoodiePageRoute<void>(
                                            page: RestaurantScreen(
                                              restaurant: restaurant,
                                              heroTag:
                                                  'favorites_${restaurant.id}',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteSegmentedButton extends StatelessWidget {
  const _FavoriteSegmentedButton({
    required this.showDishes,
    required this.restaurantCount,
    required this.dishCount,
    required this.onChanged,
  });

  final bool showDishes;
  final int restaurantCount;
  final int dishCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<bool>(
        segments: <ButtonSegment<bool>>[
          ButtonSegment<bool>(
            value: false,
            label: const Text('Restaurants'),
            icon: Badge(
              isLabelVisible: restaurantCount > 0,
              label: Text('$restaurantCount'),
              backgroundColor: showDishes
                  ? context.foodie.primary
                  : context.foodie.onPrimary,
              textColor: showDishes
                  ? context.foodie.onPrimary
                  : context.foodie.primary,
              child: const Icon(Icons.storefront_rounded, size: 17),
            ),
          ),
          ButtonSegment<bool>(
            value: true,
            label: const Text('Dishes'),
            icon: Badge(
              isLabelVisible: dishCount > 0,
              label: Text('$dishCount'),
              backgroundColor: showDishes
                  ? context.foodie.onPrimary
                  : context.foodie.primary,
              textColor: showDishes
                  ? context.foodie.primary
                  : context.foodie.onPrimary,
              child: const Icon(Icons.restaurant_menu_rounded, size: 17),
            ),
          ),
        ],
        selected: <bool>{showDishes},
        showSelectedIcon: false,
        onSelectionChanged: (Set<bool> values) => onChanged(values.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? context.foodie.primary
                : context.foodie.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? context.foodie.onPrimary
                : context.foodie.muted;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: context.foodie.border),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            context.foodieType.label.copyWith(fontSize: 11.5),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          ),
        ),
      ),
    );
  }
}
