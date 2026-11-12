import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/cart_item.dart';
import '../models/restaurant.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/foodie_image.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/section_header.dart';
import 'restaurant_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _copyCoupon(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    showFoodieSnack(context, '$code copied to clipboard');
  }

  void _applyCoupon(
    BuildContext context,
    FoodieAppState state,
    Coupon coupon,
  ) {
    final String? error = state.applyCoupon(coupon.code);
    if (error != null) {
      showFoodieSnack(
        context,
        error,
        icon: Icons.error_outline_rounded,
      );
      return;
    }
    HapticFeedback.mediumImpact();
    showFoodieSnack(
      context,
      '${coupon.code} applied. You saved ${currency(state.discountAmount)}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final List<Restaurant> restaurantsWithOffers = MockData.restaurants
        .where((Restaurant restaurant) => restaurant.offer.isNotEmpty)
        .toList();
    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(title: const Text('Offers & coupons')),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        context.foodie.panelDark,
                        Color.lerp(
                          context.foodie.panelDark,
                          context.foodie.primary,
                          0.24,
                        )!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/promo_pizza.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.14,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'A LITTLE TREAT',
                              style: context.foodieType.eyebrow.copyWith(
                                fontSize: 8.5,
                                letterSpacing: 1.2,
                                color: context.foodie.gold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'More food,\nless spend.',
                              style: context.foodieType.display.copyWith(
                                fontSize: 32,
                                color: Colors.white,
                                height: 1.02,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${MockData.coupons.length} handpicked offers for your next craving.',
                              style: context.foodieType.small.copyWith(
                                color: Colors.white.withValues(alpha: 0.68),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: context.foodie.gold,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: context.foodie.onGold,
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Coupon codes',
                  subtitle: 'Tap a code to copy, or apply it to your cart.',
                  padding: EdgeInsets.zero,
                ),
                ...MockData.coupons.map(
                  (Coupon coupon) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CouponCard(
                      coupon: coupon,
                      isApplied: state.appliedCoupon?.code == coupon.code,
                      onCopy: () => _copyCoupon(context, coupon.code),
                      onApply: () => _applyCoupon(context, state, coupon),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'Kitchen specials',
                  subtitle: 'Offers straight from our restaurant partners.',
                  padding: EdgeInsets.zero,
                ),
                ...restaurantsWithOffers.map(
                  (Restaurant restaurant) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OfferRestaurantTile(
                      restaurant: restaurant,
                      onTap: () => Navigator.of(context).push(
                        FoodiePageRoute<void>(
                          page: RestaurantScreen(
                            restaurant: restaurant,
                            heroTag: 'offers_${restaurant.id}',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.foodie.surfaceWarm,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17,
                        color: context.foodie.primaryInk,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offers are applied locally in this demo. No real money, codes or accounts are involved.',
                          style: context.foodieType.small.copyWith(
                            fontSize: 10.5,
                            color: context.foodie.ink,
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

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.isApplied,
    required this.onCopy,
    required this.onApply,
  });

  final Coupon coupon;
  final bool isApplied;
  final VoidCallback onCopy;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isApplied ? context.foodie.success : context.foodie.border,
          width: isApplied ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.foodie.goldSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    coupon.kind == CouponKind.freeDelivery
                        ? Icons.delivery_dining_rounded
                        : coupon.kind == CouponKind.percent
                            ? Icons.percent_rounded
                            : Icons.currency_rupee_rounded,
                    color: context.foodie.goldInk,
                    size: 22,
                  ),
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
                              coupon.title,
                              style: context.foodieType.h3.copyWith(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isApplied)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: context.foodie.successSoft,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                'APPLIED',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 7,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w800,
                                  color: context.foodie.successInk,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coupon.description,
                        style: context.foodieType.small.copyWith(
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${coupon.eligibilityLabel} • Valid on all kitchens',
                        style: context.foodieType.label.copyWith(
                          fontSize: 8.5,
                          color: context.foodie.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 1,
            width: double.infinity,
            child: CustomPaint(
              painter: _DashedDividerPainter(color: context.foodie.border),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: context.foodie.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: context.foodie.border),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          coupon.code,
                          style: context.foodieType.label.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.7,
                            color: context.foodie.goldInk,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: context.foodie.goldInk,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (isApplied)
                  Text(
                    'Saving active',
                    style: context.foodieType.label.copyWith(
                      fontSize: 9.5,
                      color: context.foodie.successInk,
                    ),
                  )
                else
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferRestaurantTile extends StatelessWidget {
  const _OfferRestaurantTile({
    required this.restaurant,
    required this.onTap,
  });

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Row(
            children: <Widget>[
              FoodieImage(
                asset: restaurant.coverImage,
                width: 66,
                height: 66,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.h3.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      restaurant.offer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.small.copyWith(
                        fontSize: 10.5,
                        color: context.foodie.primaryInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.foodie.subtle,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  _DashedDividerPainter({required this.color});

  /// The divider colour, handed in by the widget that owns the theme.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 12;
    while (x < size.width - 12) {
      canvas.drawLine(Offset(x, 0.5), Offset(x + 5, 0.5), paint);
      x += 9;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
