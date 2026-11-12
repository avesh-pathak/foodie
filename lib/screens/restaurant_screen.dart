import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/foodie_image.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/item_customization_sheet.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/rating_badge.dart';
import '../widgets/veg_badge.dart';
import 'cart_screen.dart';
import 'offers_screen.dart';

enum _DietFilter { all, veg, nonVeg }

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({
    super.key,
    required this.restaurant,
    required this.heroTag,
  });

  final Restaurant restaurant;
  final String heroTag;

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String _selectedCategory = 'All';
  _DietFilter _dietFilter = _DietFilter.all;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _matchesDiet(FoodItem item) {
    switch (_dietFilter) {
      case _DietFilter.all:
        return true;
      case _DietFilter.veg:
        return item.isVeg;
      case _DietFilter.nonVeg:
        return !item.isVeg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final bool isFavorite = state.isRestaurantFavorite(widget.restaurant.id);
    final List<String> categories = <String>[
      'All',
      ...widget.restaurant.menuCategories,
    ];
    final List<FoodItem> filteredMenu = widget.restaurant.menu
        .where(
          (FoodItem item) =>
              _selectedCategory == 'All' || item.category == _selectedCategory,
        )
        .where(_matchesDiet)
        .toList();

    final List<String> visibleCategories = _selectedCategory == 'All'
        ? widget.restaurant.menuCategories
        : <String>[_selectedCategory];

    return Scaffold(
      backgroundColor: context.foodie.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 286,
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            backgroundColor: context.foodie.background,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _RoundIconButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? context.foodie.primaryInk
                      : context.foodie.ink,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    state.toggleRestaurantFavorite(widget.restaurant.id);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.heroTag,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FoodieImage(asset: widget.restaurant.coverImage),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            context.foodie.overlayDark.withValues(alpha: 0.45),
                            Colors.transparent,
                            context.foodie.overlayDark,
                          ],
                          stops: const <double>[0, 0.5, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.foodie.primary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                widget.restaurant.offer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FoodieType.bodyFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: context.foodie.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: context.foodie.surface.withValues(
                                alpha: 0.92,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.timer_outlined,
                                  size: 13,
                                  color: context.foodie.ink,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.restaurant.deliveryMinutes} min',
                                  style: context.foodieType.label.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.foodie.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.restaurant.name,
                              style: context.foodieType.display.copyWith(
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.restaurant.tagline,
                              style: context.foodieType.bodyMuted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      RatingBadge(
                        rating: widget.restaurant.rating,
                        ratingCount: widget.restaurant.ratingCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: widget.restaurant.cuisines
                        .map(
                          (String cuisine) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: context.foodie.surface,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: context.foodie.border,
                              ),
                            ),
                            child: Text(
                              cuisine,
                              style: context.foodieType.small.copyWith(
                                fontSize: 10.5,
                                color: context.foodie.ink,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        FoodiePageRoute<void>(page: const OffersScreen()),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: context.foodie.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: context.foodie.primaryInk.withValues(
                              alpha: 0.22,
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.foodie.surface.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(
                                Icons.local_offer_rounded,
                                size: 17,
                                color: context.foodie.primaryInk,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.restaurant.offer,
                                    style: context.foodieType.h3.copyWith(
                                      fontSize: 13,
                                      color: context.foodie.primaryInk,
                                    ),
                                  ),
                                  Text(
                                    'Plus bank offers at checkout',
                                    style: context.foodieType.small.copyWith(
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.foodie.primaryInk,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      _InfoPill(
                        icon: Icons.delivery_dining_rounded,
                        label: '${widget.restaurant.deliveryMinutes} min',
                        sub: 'delivery',
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        icon: Icons.currency_rupee_rounded,
                        label: '₹${widget.restaurant.deliveryFee.round()}',
                        sub: 'delivery fee',
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        icon: Icons.people_alt_outlined,
                        label: '₹${widget.restaurant.priceForTwo}',
                        sub: 'for two',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    widget.restaurant.description,
                    style: context.foodieType.bodyMuted.copyWith(
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Explore the menu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.foodieType.h2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DietToggle(
                        value: _dietFilter,
                        onChanged: (_DietFilter filter) {
                          HapticFeedback.selectionClick();
                          setState(() => _dietFilter = filter);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 37,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 7),
                      itemBuilder: (BuildContext context, int index) {
                        final String category = categories[index];
                        final bool selected = category == _selectedCategory;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: context.foodie.primary,
                          backgroundColor: context.foodie.surface,
                          side: BorderSide(
                            color: selected
                                ? context.foodie.primary
                                : context.foodie.border,
                          ),
                          labelStyle: context.foodieType.label.copyWith(
                            fontSize: 11,
                            color: selected
                                ? context.foodie.onPrimary
                                : context.foodie.ink,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (filteredMenu.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.no_food_rounded,
                              color: context.foodie.subtle,
                              size: 38,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No dishes match this filter',
                              style: context.foodieType.bodyMuted,
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                _selectedCategory = 'All';
                                _dietFilter = _DietFilter.all;
                              }),
                              child: const Text('Reset filters'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...visibleCategories.expand((String category) {
                      final List<FoodItem> items = filteredMenu
                          .where(
                            (FoodItem item) =>
                                _selectedCategory != 'All' ||
                                item.category == category,
                          )
                          .toList();
                      if (items.isEmpty) return const <Widget>[];
                      return <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 8),
                          child: Row(
                            children: <Widget>[
                              Text(
                                category,
                                style: context.foodieType.h3.copyWith(
                                fontSize: 16,
                              ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '${items.length} ${items.length == 1 ? 'dish' : 'dishes'}',
                                style: context.foodieType.small.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...items.map(
                          (FoodItem item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MenuDishTile(
                              item: item,
                              quantity: state.quantityForDish(item.id),
                              isFavorite: state.isDishFavorite(item.id),
                              onFavorite: () {
                                HapticFeedback.selectionClick();
                                state.toggleDishFavorite(item.id);
                              },
                              onTap: () => showItemCustomization(context, item),
                              onAdd: () => showItemCustomization(context, item),
                              onIncrement: () => state.incrementDish(item.id),
                              onDecrement: () => state.decrementDish(item.id),
                            ),
                          ),
                        ),
                      ];
                    }),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'All prices inclusive of applicable taxes.',
                      style: context.foodieType.small.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 116),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: state.cartCount == 0
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ViewCartBar(
                count: state.cartCount,
                subtotal: state.subtotal,
                onTap: () => Navigator.of(context).push(
                  FoodiePageRoute<void>(page: const CartScreen()),
                ),
              ),
            ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Optional override. Defaults to the themed ink colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: context.foodie.surface.withValues(alpha: 0.93),
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, size: 21, color: color ?? context.foodie.ink),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.sub,
  });

  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(
          color: context.foodie.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.foodie.border),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 17, color: context.foodie.primaryInk),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: context.foodieType.h3.copyWith(fontSize: 12.5),
              ),
            ),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.foodieType.small.copyWith(fontSize: 8.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietToggle extends StatelessWidget {
  const _DietToggle({required this.value, required this.onChanged});

  final _DietFilter value;
  final ValueChanged<_DietFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.foodie.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _DietDot(
            color: context.foodie.veg,
            selected: value == _DietFilter.veg,
            onTap: () => onChanged(_DietFilter.veg),
            label: 'Veg',
          ),
          _DietDot(
            color: context.foodie.nonVeg,
            selected: value == _DietFilter.nonVeg,
            onTap: () => onChanged(_DietFilter.nonVeg),
            label: 'Non-veg',
          ),
        ],
      ),
    );
  }
}

class _DietDot extends StatelessWidget {
  const _DietDot({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.label,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.foodieType.label.copyWith(
                fontSize: 9,
                // The diet hue stays on the marker; the label itself uses
                // the ink ramp so it always clears 4.5:1.
                color: selected ? context.foodie.ink : context.foodie.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDishTile extends StatelessWidget {
  const _MenuDishTile({
    required this.item,
    required this.quantity,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final FoodItem item;
  final int quantity;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  FoodieImage(
                    asset: item.image,
                    width: 108,
                    height: 118,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: context.foodie.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: VegBadge(isVeg: item.isVeg, size: 12),
                    ),
                  ),
                  if (item.isBestseller)
                    Positioned(
                      bottom: 5,
                      left: 5,
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
                            fontFamily: FoodieType.bodyFamily,
                            fontSize: 6.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (!item.isAvailable)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.foodie.danger,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text(
                          'Sold out',
                          style: TextStyle(
                            fontFamily: FoodieType.bodyFamily,
                            fontSize: 6.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
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
                            style: context.foodieType.h3.copyWith(fontSize: 15),
                          ),
                        ),
                        FavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavorite,
                          size: 26,
                          showShadow: false,
                          backgroundColor: context.foodie.background,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        RatingBadge(rating: item.rating, compact: true),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${item.ratingCount} ratings',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.foodieType.small.copyWith(
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.small.copyWith(fontSize: 10.7),
                    ),
                    const SizedBox(height: 7),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final Widget price = Text(
                          currency(item.price),
                          style: context.foodieType.price.copyWith(
                            fontSize: 14.5,
                          ),
                        );
                        final Widget action = !item.isAvailable
                            ? Container(
                                height: 36,
                                constraints: const BoxConstraints(minWidth: 72),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.foodie.surfaceMuted,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(color: context.foodie.border),
                                ),
                                child: Text(
                                  'Sold out',
                                  style: context.foodieType.label.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: context.foodie.subtle,
                                  ),
                                ),
                              )
                            : quantity > 0
                                ? QuantityStepper(
                                    quantity: quantity,
                                    onIncrement: onIncrement,
                                    onDecrement: onDecrement,
                                    compact: true,
                                  )
                                : OutlineAddButton(onTap: onAdd);
                        if (constraints.maxWidth < 168) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              price,
                              const SizedBox(height: 6),
                              action,
                            ],
                          );
                        }
                        return Row(
                          children: <Widget>[
                            price,
                            const Spacer(),
                            action,
                          ],
                        );
                      },
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

class _ViewCartBar extends StatelessWidget {
  const _ViewCartBar({
    required this.count,
    required this.subtotal,
    required this.onTap,
  });

  final int count;
  final double subtotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: context.foodie.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.floating,
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.foodie.onPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: FoodieType.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.foodie.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'View cart',
                    style: context.foodieType.h3.copyWith(
                      color: context.foodie.onPrimary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    currency(subtotal),
                    style: TextStyle(
                      fontFamily: FoodieType.bodyFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: context.foodie.onPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                color: context.foodie.onPrimary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
