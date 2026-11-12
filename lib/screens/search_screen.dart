import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/food_category.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/dish_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/foodie_image.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/item_customization_sheet.dart';
import '../widgets/rating_badge.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/section_header.dart';
import '../widgets/veg_badge.dart';
import 'restaurant_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FoodieScope.read(context).searchQuery,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runSearch(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    FoodieScope.of(context)
      ..setSearchQuery(value)
      ..addRecentSearch(value);
    _focusNode.unfocus();
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    FoodieScope.of(context).setSearchQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final String query = state.searchQuery;
    final List<Restaurant> restaurants =
        state.searchRestaurants(query, category: _category);
    final List<FoodItem> dishes =
        state.searchDishes(query, category: _category);
    final bool showDiscovery = query.trim().isEmpty && _category == 'all';

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
                            'DISCOVER',
                            style: context.foodieType.eyebrow,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Find your flavour.',
                            style:
                                context.foodieType.h1.copyWith(fontSize: 26),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.foodie.surfaceWarm,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: context.foodie.primaryInk,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: (String value) {
                    state.setSearchQuery(value);
                  },
                  onSubmitted: (String value) {
                    if (value.trim().isNotEmpty) _runSearch(value.trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search “biryani”, “pizza”, “momos”…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: context.foodie.primaryInk,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            onPressed: _clear,
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 19,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 7),
                  itemBuilder: (BuildContext context, int index) {
                    final FoodCategory category = MockData.categories[index];
                    final bool selected = category.id == _category;
                    // The selected filter wears the cuisine's own hue, so the
                    // row reads as a colour language rather than a brand blob.
                    final Color fill = selected
                        ? cuisineOn(
                            category.color,
                            Colors.white,
                            context.foodie.inkStrong,
                          )
                        : context.foodie.surface;
                    return FilterChip(
                      label: Text(category.label),
                      selected: selected,
                      showCheckmark: false,
                      side: BorderSide(
                        color: selected ? fill : context.foodie.border,
                      ),
                      backgroundColor: context.foodie.surface,
                      selectedColor: fill,
                      labelStyle: context.foodieType.label.copyWith(
                        fontSize: 11,
                        color: selected ? Colors.white : context.foodie.ink,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) {
                        setState(() {
                          _category =
                              category.id == _category ? 'all' : category.id;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: showDiscovery
                      ? _DiscoveryView(
                          key: const ValueKey<String>('discovery'),
                          state: state,
                          onSearch: _runSearch,
                        )
                      : _ResultsView(
                          key: ValueKey<String>('$query-$_category'),
                          state: state,
                          query: query,
                          restaurants: restaurants,
                          dishes: dishes,
                          onClearFilters: () {
                            _controller.clear();
                            state.setSearchQuery('');
                            setState(() => _category = 'all');
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

class _DiscoveryView extends StatelessWidget {
  const _DiscoveryView({
    super.key,
    required this.state,
    required this.onSearch,
  });

  final FoodieAppState state;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final List<Restaurant> trending = MockData.restaurants.take(3).toList();
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
      children: <Widget>[
        if (state.recentSearches.isNotEmpty) ...<Widget>[
          Row(
            children: <Widget>[
              Text('Recent searches', style: context.foodieType.h3),
              const Spacer(),
              TextButton(
                onPressed: state.clearRecentSearches,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...state.recentSearches.map(
            (String query) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSearch(query),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: context.foodie.muted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          query,
                          style: context.foodieType.body.copyWith(
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.north_west_rounded,
                        size: 16,
                        color: context.foodie.subtle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        Text('Popular right now', style: context.foodieType.h3),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MockData.popularSearches.map((String query) {
            return ActionChip(
              avatar: Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: context.foodie.primaryInk,
              ),
              label: Text(query),
              onPressed: () => onSearch(query),
              backgroundColor: context.foodie.surface,
              side: BorderSide(color: context.foodie.border),
              labelStyle: context.foodieType.label.copyWith(fontSize: 11),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            );
          }).toList(),
        ),
        const SizedBox(height: 26),
        const SectionHeader(
          title: 'Trending kitchens',
          subtitle: 'The places everyone is talking about.',
          padding: EdgeInsets.zero,
        ),
        ...trending.map(
          (Restaurant restaurant) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SearchRestaurantTile(
              restaurant: restaurant,
              isFavorite: state.isRestaurantFavorite(restaurant.id),
              onFavorite: () => state.toggleRestaurantFavorite(restaurant.id),
              onTap: () => Navigator.of(context).push(
                FoodiePageRoute<void>(
                  page: RestaurantScreen(
                    restaurant: restaurant,
                    heroTag: 'search_${restaurant.id}',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.foodie.surfaceWarm,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.foodie.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: context.foodie.primaryInk,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Can’t decide?',
                      style: context.foodieType.h3.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'The Hyderabadi Dum Biryani has 2.3k five-star fans.',
                      style: context.foodieType.small.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onSearch('Biryani'),
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: context.foodie.primaryInk,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    super.key,
    required this.state,
    required this.query,
    required this.restaurants,
    required this.dishes,
    required this.onClearFilters,
  });

  final FoodieAppState state;
  final String query;
  final List<Restaurant> restaurants;
  final List<FoodItem> dishes;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty && dishes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 118),
        children: <Widget>[
          EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No delicious matches',
            message: query.trim().isEmpty
                ? 'There is nothing in this category yet. Try another flavour.'
                : 'We could not find anything for “$query”. Try a different dish or cuisine.',
            buttonLabel: 'Clear filters',
            onPressed: onClearFilters,
          ),
        ],
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 118),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                query.trim().isEmpty
                    ? 'Browse results'
                    : 'Results for “$query”',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.foodieType.h3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.foodie.surfaceWarm,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${restaurants.length + dishes.length} found',
                style: context.foodieType.label.copyWith(
                  fontSize: 9,
                  color: context.foodie.primaryInk,
                ),
              ),
            ),
          ],
        ),
        if (restaurants.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            'KITCHENS',
            style: context.foodieType.eyebrow.copyWith(
              color: context.foodie.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...restaurants.map(
            (Restaurant restaurant) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SearchRestaurantTile(
                restaurant: restaurant,
                isFavorite: state.isRestaurantFavorite(restaurant.id),
                onFavorite: () => state.toggleRestaurantFavorite(restaurant.id),
                onTap: () => Navigator.of(context).push(
                  FoodiePageRoute<void>(
                    page: RestaurantScreen(
                      restaurant: restaurant,
                      heroTag: 'search_${restaurant.id}',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (dishes.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            'DISHES',
            style: context.foodieType.eyebrow.copyWith(
              color: context.foodie.muted,
            ),
          ),
          const SizedBox(height: 2),
          ...dishes.map((FoodItem dish) {
            final int quantity = state.quantityForDish(dish.id);
            return DishListTile(
              item: dish,
              isFavorite: state.isDishFavorite(dish.id),
              quantity: quantity,
              onTap: () => showItemCustomization(context, dish),
              onAdd: () => showItemCustomization(context, dish),
              onIncrement: () => state.incrementDish(dish.id),
              onDecrement: () => state.decrementDish(dish.id),
              onFavorite: () {
                HapticFeedback.selectionClick();
                state.toggleDishFavorite(dish.id);
              },
            );
          }),
        ],
      ],
    );
  }
}

class _SearchRestaurantTile extends StatelessWidget {
  const _SearchRestaurantTile({
    required this.restaurant,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FoodCategory? cuisine = cuisineForRestaurant(restaurant);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Row(
            children: <Widget>[
              FoodieImage(
                asset: restaurant.coverImage,
                width: 84,
                height: 84,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                            style: context.foodieType.h3.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavorite,
                          size: 28,
                          showShadow: false,
                          backgroundColor: context.foodie.background,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        if (cuisine != null) ...<Widget>[
                          CuisineDot(color: cuisine.color, size: 6),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            restaurant.cuisineLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.foodieType.small.copyWith(
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        RatingBadge(
                          rating: restaurant.rating,
                          compact: true,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${restaurant.deliveryMinutes} min',
                          style: context.foodieType.small.copyWith(
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.circle,
                          size: 2.5,
                          color: context.foodie.subtle,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '₹${restaurant.deliveryFee.round()} delivery',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.foodieType.small.copyWith(
                              fontSize: 10.5,
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
    );
  }
}
