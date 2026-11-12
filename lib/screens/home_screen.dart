import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/cart_item.dart';
import '../models/food_category.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/address_widgets.dart';
import '../widgets/dish_card.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/item_customization_sheet.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/section_header.dart';
import 'addresses_screen.dart';
import 'cart_screen.dart';
import 'offers_screen.dart';
import 'restaurant_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final FoodCategory selectedCategory = MockData.categories.firstWhere(
      (FoodCategory category) => category.id == state.homeCategory,
      orElse: () => MockData.categories.first,
    );
    final Size size = MediaQuery.sizeOf(context);
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width > 760 ? 760 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 118),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _HomeHeader(
                  state: state,
                  onAvatarTap: () => onSelectTab(4),
                  onCartTap: () => Navigator.of(context).push(
                    FoodiePageRoute<void>(page: const CartScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LocationSelector(
                  state: state,
                  onTap: () => _showAddressSelector(context),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SearchBar(
                  onTap: () => onSelectTab(1),
                ),
              ),
              const SizedBox(height: 20),
              const _PromoCarousel(),
              const SizedBox(height: 26),
              SectionHeader(
                title: 'What are you craving?',
                subtitle: 'Pick a mood, we will handle the rest.',
                actionLabel: 'All',
                onAction: () {
                  if (state.homeCategory != 'all') {
                    state.setHomeCategory(state.homeCategory);
                  }
                },
              ),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 9),
                  itemBuilder: (BuildContext context, int index) {
                    final FoodCategory category = MockData.categories[index];
                    return _CategoryTile(
                      category: category,
                      selected: category.id == state.homeCategory,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        state.setHomeCategory(category.id);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              SectionHeader(
                title: state.homeCategory == 'all'
                    ? 'Popular near you'
                    : '${selectedCategory.label} near you',
                subtitle: state.homeCategory == 'all'
                    ? 'Neighbourhood favourites, ready in minutes.'
                    : 'Handpicked kitchens for your ${selectedCategory.label.toLowerCase()} mood.',
                actionLabel: 'See all',
                onAction: () {
                  state.setSearchQuery('');
                  onSelectTab(1);
                },
              ),
              if (state.filteredRestaurants.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _InlineEmpty(
                    icon: Icons.storefront_outlined,
                    title: 'No kitchens in this mood yet',
                    message: 'Try another category or explore all restaurants.',
                    actionLabel: 'Show all',
                    onAction: () => state.setHomeCategory('all'),
                  ),
                )
              else
                SizedBox(
                  height: 326,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.filteredRestaurants.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (BuildContext context, int index) {
                      final Restaurant restaurant =
                          state.filteredRestaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        heroTag: 'home_${restaurant.id}',
                        isFavorite: state.isRestaurantFavorite(restaurant.id),
                        onFavorite: () {
                          HapticFeedback.selectionClick();
                          state.toggleRestaurantFavorite(restaurant.id);
                        },
                        onTap: () => Navigator.of(context).push(
                          FoodiePageRoute<void>(
                            page: RestaurantScreen(
                              restaurant: restaurant,
                              heroTag: 'home_${restaurant.id}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Made for your mood',
                subtitle: 'Bestsellers and little cravings we love.',
                actionLabel: 'Explore',
                onAction: () {
                  state.setSearchQuery('');
                  onSelectTab(1);
                },
              ),
              if (state.filteredRecommendedDishes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _InlineEmpty(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Nothing here just yet',
                    message: 'Switch categories to discover more delicious picks.',
                    actionLabel: 'Show all',
                    onAction: () => state.setHomeCategory('all'),
                  ),
                )
              else
                SizedBox(
                  height: 306,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.filteredRecommendedDishes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final FoodItem dish =
                          state.filteredRecommendedDishes[index];
                      return DishCard(
                        item: dish,
                        isFavorite: state.isDishFavorite(dish.id),
                        onFavorite: () {
                          HapticFeedback.selectionClick();
                          state.toggleDishFavorite(dish.id);
                        },
                        onAdd: () => showItemCustomization(context, dish),
                        onTap: () => showItemCustomization(context, dish),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Today’s offers',
                subtitle: 'A little extra on the side.',
                actionLabel: 'All offers',
                onAction: () => Navigator.of(context).push(
                  FoodiePageRoute<void>(page: const OffersScreen()),
                ),
              ),
              SizedBox(
                height: 122,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.coupons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final Coupon coupon = MockData.coupons[index];
                    return _OfferStrip(
                      coupon: coupon,
                      onTap: () => Navigator.of(context).push(
                        FoodiePageRoute<void>(page: const OffersScreen()),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.foodie.panelDark,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/promo_dessert.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.22,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Still hungry?',
                              style: context.foodieType.h2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Search every dish across all our kitchens.',
                              style: context.foodieType.small.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: () => onSelectTab(1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: context.foodie.panelDark,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.search_rounded, size: 17),
                                label: const Text('Explore menu'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.takeout_dining_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Made with butter & a little code',
                  style: context.foodieType.small.copyWith(
                    fontSize: 10.5,
                    color: context.foodie.subtle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddressSelector(BuildContext context) async {
    final FoodieAppState state = FoodieScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Deliver to', style: context.foodieType.h2),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        FoodiePageRoute<void>(
                          page: const AddressesScreen(),
                        ),
                      );
                    },
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...state.addresses.map(
                (address) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AddressOption(
                    address: address,
                    selected: address.id == state.selectedAddress.id,
                    onTap: () {
                      state.setDeliveryAddress(address.id);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    showAddressForm(context);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add a new address'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.state,
    required this.onAvatarTap,
    required this.onCartTap,
  });

  final FoodieAppState state;
  final VoidCallback onAvatarTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greetingFor(DateTime.now()).toUpperCase(),
                style: context.foodieType.eyebrow,
              ),
              const SizedBox(height: 3),
              Text(
                'Hello, ${state.displayName}!',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.foodieType.h1.copyWith(fontSize: 25),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _CartIconButton(
          count: state.cartCount,
          onTap: onCartTap,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.foodie.primarySoft,
              shape: BoxShape.circle,
              boxShadow: AppShadows.soft,
            ),
            alignment: Alignment.center,
            child: Text(
              state.avatarInitials,
              style: context.foodieType.h3.copyWith(
                color: context.foodie.primaryInk,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open cart, $count items',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: context.foodie.borderStrong),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.shopping_bag_outlined,
                color: context.foodie.ink,
                size: 22,
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: context.foodie.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: context.foodie.surface,
                        width: 1.5,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: AppMotion.fast,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.7, end: 1)
                              .animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Text(
                        '$count',
                        key: ValueKey<int>(count),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FoodieType.bodyFamily,
                          fontSize: 9,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: context.foodie.onPrimary,
                        ),
                      ),
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

class _LocationSelector extends StatelessWidget {
  const _LocationSelector({required this.state, required this.onTap});

  final FoodieAppState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: <Widget>[
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: context.foodie.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: context.foodie.primaryInk,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'DELIVERING TO',
                      style: context.foodieType.eyebrow.copyWith(
                        fontSize: 8,
                        letterSpacing: 0.8,
                        color: context.foodie.muted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${state.selectedAddress.label} • ${state.selectedAddress.line1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.foodie.primaryInk,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.borderStrong),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search_rounded,
                color: context.foodie.primaryInk,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search restaurants or dishes',
                  style: context.foodieType.bodyMuted.copyWith(
                    color: context.foodie.subtle,
                    fontSize: 13.5,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.foodie.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: context.foodie.ink,
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The widget can be disposed before the first frame lands; without this
      // guard the periodic timer would outlive the carousel and keep firing
      // against a torn-down controller.
      if (!mounted) return;
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted || !_controller.hasClients) return;
        if (MediaQuery.disableAnimationsOf(context)) return;
        final int next = (_index + 1) % MockData.promos.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    final double bannerHeight =
        174 + (textScale - 1).clamp(0.0, 0.3) * 240;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: bannerHeight,
            child: PageView.builder(
              controller: _controller,
              itemCount: MockData.promos.length,
              onPageChanged: (int index) => setState(() => _index = index),
              itemBuilder: (BuildContext context, int index) {
                final PromoBanner promo = MockData.promos[index];
                return _PromoCard(
                  promo: promo,
                  onTap: () => Navigator.of(context).push(
                    FoodiePageRoute<void>(page: const OffersScreen()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(MockData.promos.length, (int i) {
              final bool active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? context.foodie.primaryInk
                      : context.foodie.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo, required this.onTap});

  final PromoBanner promo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: promo.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: AppShadows.floating,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 190,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Colors.transparent, Colors.black],
                        stops: <double>[0, 0.42],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: FoodieImageAsset(promo.image),
                  ),
                ),
                // Scrim under the copy so the white type stays legible on
                // every banner gradient.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          context.foodie.overlayDark.withValues(alpha: 0.35),
                          context.foodie.overlayDark.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const <double>[0, 0.62, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: context.foodie.overlayDark.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        promo.eyebrow,
                        style: TextStyle(
                          fontFamily: FoodieType.bodyFamily,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                          color: Colors.white.withValues(alpha: 0.73),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        promo.title,
                        style: context.foodieType.display.copyWith(
                          color: Colors.white,
                          fontSize: 29,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      SizedBox(
                        width: 195,
                        child: Text(
                          promo.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FoodieType.bodyFamily,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          'CODE  ${promo.code}',
                          style: const TextStyle(
                            fontFamily: FoodieType.bodyFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
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
    );
  }
}

class FoodieImageAsset extends StatelessWidget {
  const FoodieImageAsset(this.asset, {super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return ColoredBox(color: context.foodie.primaryInk);
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final FoodCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    // The selected tile wears the cuisine's own hue, deepened only as far
    // as it must be to carry a white icon and label.
    final Color fill =
        cuisineOn(category.color, Colors.white, palette.inkStrong);
    // The authored `softColor` is a pale pastel that only works on a light
    // canvas, so the unselected well is built from the hue at low alpha over
    // the themed surface — it then reads on either brightness.
    final Color well = selected
        ? Colors.white.withValues(alpha: 0.18)
        : Color.alphaBlend(
            category.color.withValues(alpha: 0.16),
            palette.surface,
          );
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 74,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? fill : context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: selected
                ? null
                : Border.all(color: context.foodie.border),
            boxShadow: selected ? AppShadows.soft : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: well,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  category.icon,
                  size: 20,
                  color: selected ? Colors.white : category.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FoodieType.bodyFamily,
                  fontSize: 9.8,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : context.foodie.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferStrip extends StatelessWidget {
  const _OfferStrip({required this.coupon, required this.onTap});

  final Coupon coupon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 252,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.foodie.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  color: context.foodie.primaryInk,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      coupon.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.h3.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      coupon.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.small.copyWith(fontSize: 10.5),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      coupon.code,
                      style: context.foodieType.label.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.8,
                        color: context.foodie.primaryInk,
                      ),
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

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.foodie.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.foodie.surfaceWarm,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: context.foodie.primaryInk),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.foodieType.h3.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: context.foodieType.small.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
