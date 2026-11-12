import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/cart_item.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/bill_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/foodie_image.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/quantity_stepper.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final TextEditingController _couponController;
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final FoodieAppState state = FoodieScope.read(context);
    _couponController = TextEditingController(
      text: state.appliedCoupon?.code ?? '',
    );
    _instructionsController = TextEditingController(
      text: state.cookingInstructions,
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final FoodieAppState state = FoodieScope.of(context);
    final String? error = state.applyCoupon(_couponController.text);
    if (error != null) {
      showFoodieSnack(
        context,
        error,
        icon: Icons.error_outline_rounded,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _couponController.text = state.appliedCoupon?.code ?? '';
    });
    showFoodieSnack(context, 'Coupon applied. You saved ${currency(state.discountAmount)}!');
  }

  void _openCheckout() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      FoodiePageRoute<void>(page: const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final bool isEmpty = state.isCartEmpty;
    final List<String> kitchenNames = state.cart
        .map((CartItem item) =>
            MockData.restaurantById(item.food.restaurantId)?.name ?? 'Foodie')
        .toSet()
        .toList();
    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Your cart'),
            if (!isEmpty)
              Text(
                '${state.cartCount} ${state.cartCount == 1 ? 'item' : 'items'} • ${kitchenNames.length} ${kitchenNames.length == 1 ? 'kitchen' : 'kitchens'}',
                style: context.foodieType.small.copyWith(fontSize: 10.5),
              ),
          ],
        ),
        actions: <Widget>[
          if (!isEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (String value) {
                if (value == 'clear') _confirmClear(context, state);
              },
              itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear cart'),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: isEmpty
            ? EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Your cart is empty',
                message:
                    'Good food is only a few taps away. Browse our kitchens and add something delicious.',
                buttonLabel: 'Browse restaurants',
                onPressed: () => Navigator.of(context).pop(),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: context.foodie.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 17,
                              color: context.foodie.primaryInk,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              kitchenNames.join(' + '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.small.copyWith(
                                color: context.foodie.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Arrives in ${state.etaMinutes} min',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: context.foodieType.label.copyWith(
                                fontSize: 9.5,
                                color: context.foodie.infoInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.hasUnavailableCartItems)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.foodie.dangerSoft,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: context.foodie.danger),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.info_outline_rounded,
                                color: context.foodie.dangerInk,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Some items in your cart are sold out. Remove them to continue.',
                                  style: context.foodieType.body.copyWith(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: context.foodie.dangerInk,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.foodie.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: context.foodie.border),
                        ),
                        child: Column(
                          children: <Widget>[
                            ...state.cart.map(
                              (CartItem item) => _CartLineTile(
                                item: item,
                                onIncrement: () => state.incrementLine(item.key),
                                onDecrement: () => state.decrementLine(item.key),
                                onRemove: () => state.removeLine(item.key),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add more items'),
                      ),
                      const SizedBox(height: 10),
                      _SectionCard(
                        icon: Icons.local_offer_outlined,
                        title: 'Coupons & offers',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (state.appliedCoupon != null)
                              _AppliedCoupon(
                                coupon: state.appliedCoupon!,
                                discount: state.discountAmount,
                                onRemove: () {
                                  state.removeCoupon();
                                  _couponController.clear();
                                  setState(() {});
                                },
                              )
                            else ...<Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _couponController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _applyCoupon(),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter coupon code',
                                        prefixIcon: Icon(
                                          Icons.confirmation_number_outlined,
                                          size: 20,
                                        ),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _applyCoupon,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            context.foodie.primary,
                                        foregroundColor:
                                            context.foodie.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                        ),
                                      ),
                                      child: const Text('Apply'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: MockData.coupons
                                      .map(
                                        (Coupon coupon) => Padding(
                                          padding: const EdgeInsets.only(
                                            right: 7,
                                          ),
                                          child: ActionChip(
                                            label: Text(coupon.code),
                                            onPressed: () {
                                              _couponController.text =
                                                  coupon.code;
                                              setState(() {});
                                            },
                                            backgroundColor:
                                                context.foodie.surfaceMuted,
                                            side: BorderSide(
                                              color: context.foodie.border,
                                            ),
                                            labelStyle: context.foodieType.label
                                                .copyWith(fontSize: 9.5),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try FOODIE50 for 50% off up to ₹150.',
                                style: context.foodieType.small.copyWith(
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        icon: Icons.edit_note_rounded,
                        title: 'Cooking instructions',
                        subtitle: 'Optional — the kitchen will do its best.',
                        child: TextField(
                          controller: _instructionsController,
                          maxLines: 3,
                          maxLength: 180,
                          onChanged: state.setCookingInstructions,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. Less spicy, no onions, leave at the door…',
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'Bill details',
                        child: Column(
                          children: <Widget>[
                            BillRow(
                              label: 'Item total',
                              value: currency(state.subtotal),
                            ),
                            BillRow(
                              label: 'Delivery fee',
                              value: currency(state.deliveryFee),
                            ),
                            BillRow(
                              label: 'Taxes & charges (5%)',
                              value: currency(state.taxes),
                            ),
                            if (state.discountAmount > 0)
                              BillRow(
                                label:
                                    'Coupon discount (${state.appliedCoupon?.code})',
                                value: '− ${currency(state.discountAmount)}',
                                valueColor: context.foodie.successInk,
                                iconColor: context.foodie.successInk,
                                icon: Icons.local_offer_rounded,
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(),
                            ),
                            BillRow(
                              label: 'To pay',
                              value: currency(state.total),
                              emphasize: true,
                            ),
                            if (state.discountAmount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: context.foodie.successSoft,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.savings_outlined,
                                      size: 16,
                                      color: context.foodie.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'You’re saving ${currency(state.discountAmount)} on this order.',
                                      style: context.foodieType.small.copyWith(
                                        fontSize: 10.5,
                                        color: context.foodie.successInk,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: context.foodie.muted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Secure demo checkout • No real payment taken',
                            style: context.foodieType.small.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                decoration: BoxDecoration(
                  color: context.foodie.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.floating,
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget total = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'TOTAL',
                          style: context.foodieType.eyebrow.copyWith(
                            fontSize: 8.5,
                            letterSpacing: 0.9,
                            color: context.foodie.muted,
                          ),
                        ),
                        Text(
                          currency(state.total),
                          style: context.foodieType.h2.copyWith(fontSize: 20),
                        ),
                      ],
                    );
                    // The sheet's usable width decides how the action bar is
                    // arranged: side-by-side once there is room for both the
                    // total and the full button label, stacked otherwise.
                    // The button takes the space the total does not need, so
                    // the label never ellipsizes at theme size.
                    final Widget checkoutButton = SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.hasUnavailableCartItems ? null : _openCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.foodie.primary,
                          foregroundColor: context.foodie.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text(
                          'Proceed to checkout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                    if (constraints.maxWidth < 330) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 6, bottom: 8),
                            child: total,
                          ),
                          checkoutButton,
                        ],
                      );
                    }
                    return Row(
                      children: <Widget>[
                        total,
                        const SizedBox(width: 12),
                        Expanded(child: checkoutButton),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, FoodieAppState state) async {
    final bool? clear = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Clear your cart?'),
        content: const Text(
          'Every item will be removed. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep items'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );
    if (clear == true) {
      state.clearCart();
      if (mounted) Navigator.of(this.context).maybePop();
    }
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FoodieImage(
            asset: item.food.image,
            width: 70,
            height: 78,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.food.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.foodieType.h3.copyWith(fontSize: 13.5),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: context.foodie.subtle,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.addOns.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.addOns.map((addOn) => addOn.name).join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.small.copyWith(fontSize: 9.5),
                    ),
                  ),
                if (!item.food.isAvailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.foodie.dangerSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: context.foodie.danger),
                      ),
                      child: Text(
                        'Sold out',
                        style: context.foodieType.small.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: context.foodie.dangerInk,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text(
                      currency(item.unitPrice),
                      style: context.foodieType.price.copyWith(fontSize: 13.5),
                    ),
                    const Spacer(),
                    QuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.foodie.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: context.foodie.primaryInk),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.foodieType.h3.copyWith(fontSize: 14.5),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: context.foodieType.small.copyWith(fontSize: 10.5),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AppliedCoupon extends StatelessWidget {
  const _AppliedCoupon({
    required this.coupon,
    required this.discount,
    required this.onRemove,
  });

  final Coupon coupon;
  final double discount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.foodie.successSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: context.foodie.success.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            color: context.foodie.success,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${coupon.code} applied',
                  style: context.foodieType.label.copyWith(
                    fontSize: 11,
                    color: context.foodie.successInk,
                  ),
                ),
                Text(
                  discount > 0
                      ? 'You saved ${currency(discount)} on this order.'
                      : 'Add items worth ${currency(coupon.minOrder)} to unlock this.',
                  style: context.foodieType.small.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
