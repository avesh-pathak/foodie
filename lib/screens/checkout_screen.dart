import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cart_item.dart';
import '../models/delivery_address.dart';
import '../models/order.dart';
import '../services/orders_api.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/address_widgets.dart';
import '../widgets/bill_row.dart';
import '../widgets/foodie_page_route.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _placingOrder = false;

  Future<void> _selectAddress(FoodieAppState state) async {
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
                    child: Text(
                      'Delivery address',
                      style: context.foodieType.h2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      showAddressForm(context);
                    },
                    child: const Text('Add new'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...state.addresses.map(
                (DeliveryAddress address) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AddressOption(
                    address: address,
                    selected: address.id == state.selectedAddress.id,
                    onTap: () {
                      state.setDeliveryAddress(address.id);
                      Navigator.of(sheetContext).pop();
                    },
                    onEdit: () => showAddressForm(
                      context,
                      initial: address,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editInstructions(FoodieAppState state) async {
    final TextEditingController controller =
        TextEditingController(text: state.cookingInstructions);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Cooking instructions', style: context.foodieType.h2),
              const SizedBox(height: 6),
              Text(
                'Tell the kitchen about allergies, spice levels or anything else.',
                style: context.foodieType.bodyMuted,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                maxLength: 180,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Less spicy, no onions, leave at the door…',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    state.setCookingInstructions(controller.text.trim());
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Save instructions'),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _placeOrder(FoodieAppState state) async {
    if (_placingOrder || state.isCartEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _placingOrder = true);
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    final FoodOrder order = state.placeOrder();
    // Persist the order so the admin app and analytics see it.
    OrdersApi().place(order, state.selectedAddress);
    Navigator.of(context).pushAndRemoveUntil(
      FoodiePageRoute<void>(
        page: OrderSuccessScreen(orderId: order.id),
      ),
      (Route<dynamic> route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    if (state.isCartEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Text(
            'Your cart is empty.',
            style: context.foodieType.bodyMuted,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
              children: <Widget>[
                _StepStrip(),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Delivering to',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.foodieType.h2,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectAddress(state),
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AddressOption(
                  address: state.selectedAddress,
                  selected: true,
                  onTap: () => _selectAddress(state),
                  onEdit: () => showAddressForm(
                    context,
                    initial: state.selectedAddress,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: context.foodie.info,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Estimated delivery in ${state.etaMinutes}–${state.etaMinutes + 6} min',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.foodieType.small.copyWith(
                          fontSize: 11,
                          color: context.foodie.infoInk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Payment method', style: context.foodieType.h2),
                const SizedBox(height: 6),
                Text(
                  'All payments are simulated. We never ask for real payment details.',
                  style: context.foodieType.small.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 10),
                ...PaymentMethod.values.map(
                  (PaymentMethod method) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PaymentTile(
                      method: method,
                      selected: state.paymentMethod == method,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        state.setPaymentMethod(method);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (state.hasUnavailableCartItems)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                            'Some items are sold out. Remove them from your cart to place the order.',
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Order summary',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.foodieType.h2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.foodie.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${state.cartCount} ${state.cartCount == 1 ? 'item' : 'items'}',
                        style: context.foodieType.label.copyWith(
                          fontSize: 9,
                          color: context.foodie.primaryInk,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: context.foodie.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.foodie.border),
                  ),
                  child: Column(
                    children: <Widget>[
                      ...state.cart.map(
                        (CartItem item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.foodie.surfaceMuted,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: context.foodie.border,
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: context.foodieType.label.copyWith(
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.food.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.foodieType.body.copyWith(
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              Text(
                                currency(item.total),
                                style: context.foodieType.body.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Divider(),
                      ),
                      BillRow(
                        label: 'Item total',
                        value: currency(state.subtotal),
                      ),
                      BillRow(
                        label: 'Delivery fee',
                        value: currency(state.deliveryFee),
                      ),
                      BillRow(
                        label: 'Taxes & charges',
                        value: currency(state.taxes),
                      ),
                      if (state.discountAmount > 0)
                        BillRow(
                          label: 'Coupon (${state.appliedCoupon?.code})',
                          value: '− ${currency(state.discountAmount)}',
                          valueColor: context.foodie.successInk,
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Divider(),
                      ),
                      BillRow(
                        label: 'Total',
                        value: currency(state.total),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(15),
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
                          Icon(
                            Icons.edit_note_rounded,
                            size: 17,
                            color: context.foodie.primaryInk,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Cooking instructions',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.foodieType.h3.copyWith(
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _editInstructions(state),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                      Text(
                        state.cookingInstructions.isEmpty
                            ? 'No instructions added. Tap edit if you have any requests.'
                            : state.cookingInstructions,
                        style: context.foodieType.small.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.foodie.surfaceWarm,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        size: 17,
                        color: context.foodie.primaryInk,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a demo checkout. Placing an order does not charge you and no payment details are collected.',
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
      bottomNavigationBar: SafeArea(
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
                    'TO PAY',
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
              final double buttonWidth =
                  (constraints.maxWidth * 0.58).clamp(150.0, 210.0);
              final Widget placeOrder = SizedBox(
                width: buttonWidth,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_placingOrder || state.hasUnavailableCartItems)
                      ? null
                      : () => _placeOrder(state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.foodie.primary,
                    foregroundColor: context.foodie.onPrimary,
                    disabledBackgroundColor: context.foodie.primarySoft,
                    disabledForegroundColor: context.foodie.subtle,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: _placingOrder
                      ? SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: context.foodie.primaryInk,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                'Place order',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 7),
                            Icon(Icons.check_rounded, size: 19),
                          ],
                        ),
                ),
              );
              if (constraints.maxWidth < 310) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 8),
                      child: total,
                    ),
                    placeOrder,
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: total),
                  const SizedBox(width: 10),
                  Flexible(fit: FlexFit.loose, child: placeOrder),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StepStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _Step(label: 'Cart', done: true),
        Expanded(child: _Line(done: true)),
        _Step(label: 'Checkout', active: true),
        Expanded(child: _Line(done: false)),
        const _Step(label: 'Done'),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, this.done = false, this.active = false});

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = done || active;
    return Column(
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: highlighted
                ? context.foodie.primary
                : context.foodie.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: highlighted
                  ? context.foodie.primary
                  : context.foodie.borderStrong,
            ),
          ),
          child: done
              ? Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: context.foodie.onPrimary,
                )
              : active
                  ? Icon(
                      Icons.circle,
                      size: 7,
                      color: context.foodie.onPrimary,
                    )
                  : null,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: context.foodieType.label.copyWith(
            fontSize: 8.5,
            color: highlighted
                ? context.foodie.primaryInk
                : context.foodie.muted,
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 16, left: 5, right: 5),
      color: done ? context.foodie.primary : context.foodie.borderStrong,
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (method) {
      case PaymentMethod.cod:
        return Icons.payments_outlined;
      case PaymentMethod.upi:
        return Icons.qr_code_2_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? context.foodie.primarySoft
                : context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? context.foodie.primary
                  : context.foodie.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? context.foodie.primary
                      : context.foodie.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _icon,
                  size: 20,
                  color: selected
                      ? context.foodie.onPrimary
                      : context.foodie.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      method.label,
                      style: context.foodieType.h3.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.hint,
                      style: context.foodieType.small.copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              if (method == PaymentMethod.upi)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.foodie.warningSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'DEMO',
                    style: context.foodieType.label.copyWith(
                      fontSize: 7,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                      color: context.foodie.warningInk,
                    ),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? context.foodie.primary
                        : context.foodie.borderStrong,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: context.foodie.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
