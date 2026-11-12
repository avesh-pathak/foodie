import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric, Tangent;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/order.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';
import '../utils/formatters.dart';
import '../widgets/bill_row.dart';
import '../widgets/foodie_page_route.dart';
import 'cart_screen.dart';
import 'support_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? _autoTimer;
  bool _autoPlay = false;

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    setState(() => _autoPlay = true);
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      _advance(silent: true);
    });
  }

  void _stopAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (mounted) setState(() => _autoPlay = false);
  }

  void _advance({bool silent = false}) {
    final FoodieAppState state = FoodieScope.read(context);
    final FoodOrder? order = state.orderById(widget.orderId);
    if (order == null || order.isDelivered) {
      _stopAutoPlay();
      return;
    }
    HapticFeedback.mediumImpact();
    state.advanceOrder(widget.orderId);
    final FoodOrder? updated = state.orderById(widget.orderId);
    if (updated?.isDelivered ?? false) {
      AppHaptics.delivered();
      _stopAutoPlay();
      if (!silent && mounted) {
        showFoodieSnack(
          context,
          'Order delivered! Find it in Order history.',
          icon: Icons.celebration_rounded,
        );
      }
    }
  }

  void _callRider(Rider rider) {
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Call ${rider.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(rider.phone, style: context.foodieType.h3),
            const SizedBox(height: 6),
            Text(rider.vehicle, style: context.foodieType.bodyMuted),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.foodie.surfaceWarm,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Calling is simulated in this demo. No call will be placed.',
                style: context.foodieType.small.copyWith(fontSize: 10.5),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              showFoodieSnack(
                this.context,
                'Demo call to ${rider.name} started',
                icon: Icons.call_rounded,
              );
            },
            icon: const Icon(Icons.call_rounded, size: 17),
            label: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _reorder(FoodOrder order) {
    final FoodieAppState state = FoodieScope.of(context);
    final int added = state.reorder(order);
    if (added == 0) {
      showFoodieSnack(context, 'Those dishes are no longer available.');
      return;
    }
    HapticFeedback.mediumImpact();
    showFoodieSnack(context, '$added items added back to your cart');
    Navigator.of(context).push(
      FoodiePageRoute<void>(page: const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final FoodOrder? order = state.orderById(widget.orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order tracking')),
        body: Center(
          child: Text(
            'This order could not be found.',
            style: context.foodieType.bodyMuted,
          ),
        ),
      );
    }
    final Rider rider = order.rider ?? MockData.riders.first;
    final bool delivered = order.isDelivered;
    final double progress = order.statusIndex / (orderStatuses.length - 1);

    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(
        title: const Text('Order tracking'),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).push(
              FoodiePageRoute<void>(page: const SupportScreen()),
            ),
            icon: const Icon(Icons.support_agent_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.foodie.primarySoft,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.sensors_rounded,
                            size: 12,
                            color: context.foodie.primaryInk,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DEMO TRACKING',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: context.foodie.primaryInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        formatDate(order.placedAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: context.foodieType.small.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: AppMotion.standard,
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    delivered
                        ? 'Delivered. Enjoy!'
                        : _statusHeadline(order.statusIndex),
                    key: ValueKey<int>(order.statusIndex),
                    style: context.foodieType.welcomeDisplay.copyWith(
                      fontSize: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: AppMotion.fast,
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  child: Text(
                    orderStatusDescriptions[order.statusIndex],
                    key: ValueKey<String>('description-${order.statusIndex}'),
                    style: context.foodieType.bodyMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: <Widget>[
                    _MetaPill(
                      icon: Icons.receipt_long_rounded,
                      text: order.id,
                    ),
                    _MetaPill(
                      icon: Icons.timer_outlined,
                      text: delivered
                          ? 'Delivered'
                          : '${math.max(1, order.etaMinutes - order.statusIndex * 4)} min ETA',
                      success: !delivered,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _LiveMap(
                  progress: progress,
                  rider: rider,
                  delivered: delivered,
                  statusIndex: order.statusIndex,
                ),
                const SizedBox(height: 20),
                _Timeline(order: order),
                const SizedBox(height: 20),
                _RiderCard(
                  rider: rider,
                  delivered: delivered,
                  onCall: () => _callRider(rider),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.foodie.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.foodie.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.science_outlined,
                            size: 18,
                            color: context.foodie.primary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Demo controls',
                            style: context.foodieType.h3.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Advance the order manually or let the demo play every 6 seconds. Nothing is sent to a real restaurant.',
                        style: context.foodieType.small.copyWith(fontSize: 10.5),
                      ),
                      if (!delivered) ...<Widget>[
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Auto-play status updates',
                                style: context.foodieType.body.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: _autoPlay,
                              onChanged: (bool value) {
                                if (value) {
                                  _startAutoPlay();
                                } else {
                                  _stopAutoPlay();
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _advance,
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 18,
                            ),
                            label: const Text('Simulate next status'),
                          ),
                        ),
                      ] else
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: context.foodie.successSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.check_circle_rounded,
                                color: context.foodie.success,
                                size: 19,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Delivered successfully. This order now lives in your history.',
                                  style: context.foodieType.small.copyWith(
                                    fontSize: 10.5,
                                    color: context.foodie.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.foodie.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.foodie.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Delivery details',
                            style: context.foodieType.h3.copyWith(
                              fontSize: 14.5,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.location_on_rounded,
                            size: 17,
                            color: context.foodie.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        order.address.label,
                        style: context.foodieType.label.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.address.oneLine,
                        style: context.foodieType.body.copyWith(fontSize: 12.5),
                      ),
                      if (order.instructions.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.foodie.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.edit_note_rounded,
                                size: 16,
                                color: context.foodie.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  order.instructions,
                                  style: context.foodieType.small.copyWith(
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 11),
                        child: Divider(),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: context.foodie.success,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.paymentMethod.label,
                              style: context.foodieType.body.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            currency(order.total),
                            style: context.foodieType.price.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.foodie.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.foodie.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Your order',
                        style: context.foodieType.h3.copyWith(fontSize: 14.5),
                      ),
                      const SizedBox(height: 8),
                      ...order.lines.map(
                        (OrderLine line) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.foodie.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: context.foodie.border,
                                  ),
                                ),
                                child: Text(
                                  '${line.quantity}',
                                  style: context.foodieType.label.copyWith(
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      line.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.foodieType.body.copyWith(
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    if (line.addOns.isNotEmpty)
                                      Text(
                                        line.addOns.join(' • '),
                                        style: context.foodieType.small.copyWith(
                                          fontSize: 9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                currency(line.total),
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
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      BillRow(
                        label: 'Item total',
                        value: currency(order.subtotal),
                      ),
                      BillRow(
                        label: 'Delivery fee',
                        value: currency(order.deliveryFee),
                      ),
                      BillRow(
                        label: 'Taxes & charges',
                        value: currency(order.taxes),
                      ),
                      if (order.discount > 0)
                        BillRow(
                          label: 'Coupon discount',
                          value: '− ${currency(order.discount)}',
                          valueColor: context.foodie.success,
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(),
                      ),
                      BillRow(
                        label: 'Paid',
                        value: currency(order.total),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (delivered)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _reorder(order),
                      icon: const Icon(Icons.replay_rounded, size: 19),
                      label: const Text('Reorder these items'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      FoodiePageRoute<void>(page: const SupportScreen()),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Need help with this order?'),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Demo experience • No live GPS or real delivery partner.',
                    style: context.foodieType.small.copyWith(
                      fontSize: 9.5,
                      color: context.foodie.subtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusHeadline(int index) {
    switch (index) {
      case 0:
        return 'Order placed!';
      case 1:
        return 'Kitchen accepted';
      case 2:
        return 'Cooking up a storm';
      case 3:
        return 'Ready for pickup';
      case 4:
        return 'On the way to you';
      default:
        return 'Delivered!';
    }
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
    this.success = false,
  });

  final IconData icon;
  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: success ? context.foodie.successSoft : context.foodie.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: success
              ? context.foodie.success.withValues(alpha: 0.2)
              : context.foodie.border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 12,
            color: success ? context.foodie.success : context.foodie.muted,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.foodieType.label.copyWith(
              fontSize: 9.5,
              color: success ? context.foodie.success : context.foodie.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMap extends StatelessWidget {
  const _LiveMap({
    required this.progress,
    required this.rider,
    required this.delivered,
    required this.statusIndex,
  });

  final double progress;
  final Rider rider;
  final bool delivered;
  final int statusIndex;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final FoodiePalette palette = context.foodie;
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: reduceMotion ? progress : 0, end: progress),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return CustomPaint(
                  painter: _MapPainter(progress: value, palette: palette),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(7),
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: palette.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'LIVE DEMO MAP',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: palette.overlayDark,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'NO GPS',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    delivered
                        ? Icons.check_circle_rounded
                        : statusIndex >= 4
                            ? Icons.delivery_dining_rounded
                            : Icons.soup_kitchen_rounded,
                    size: 17,
                    color: delivered ? palette.success : palette.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      delivered
                          ? 'Delivered by ${rider.name}'
                          : statusIndex >= 4
                              ? '${rider.name} is on the way'
                              : statusIndex >= 3
                                  ? '${rider.name} is picking up your order'
                                  : 'Your food is being prepared',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.label.copyWith(fontSize: 10),
                    ),
                  ),
                  Text(
                    delivered ? 'Delivered' : 'ETA ${math.max(1, 32 - statusIndex * 5)} min',
                    style: context.foodieType.label.copyWith(
                      fontSize: 9,
                      color: delivered ? palette.success : palette.primaryInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 50,
            child: _MapLabel(text: 'Kitchen', icon: Icons.storefront_rounded),
          ),
          Positioned(
            right: 12,
            top: 50,
            child: _MapLabel(text: 'You', icon: Icons.home_rounded),
          ),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: context.foodie.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 10, color: context.foodie.ink),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: context.foodie.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// The stylised live map.
///
/// The map is an illustration, not a theme surface: every tone is derived
/// from the palette and mixed so the road, the park, the route and the rider
/// marker stay legible on the canvas in either brightness. The palette is
/// handed in by the widget that creates the painter.
class _MapPainter extends CustomPainter {
  _MapPainter({required this.progress, required this.palette});

  final double progress;
  final FoodiePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final Color ground = palette.surfaceSunken;
    final Color block = Color.lerp(ground, palette.inkStrong, 0.05)!;
    final Color blockLight = Color.lerp(ground, palette.inkStrong, 0.02)!;
    final Color park = Color.lerp(ground, palette.veg, 0.3)!;
    final Color tree = Color.lerp(park, palette.inkStrong, 0.22)!;
    final Color roadBorder = Color.lerp(ground, palette.inkStrong, 0.13)!;
    final Color road = Color.lerp(ground, palette.surface, 0.85)!;

    final Paint background = Paint()..color = ground;
    canvas.drawRect(Offset.zero & size, background);

    // City blocks.
    final Paint blockPaint = Paint()..color = block;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.06, size.height * 0.08, size.width * 0.22, size.height * 0.22),
        const Radius.circular(7),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.64, size.height * 0.6, size.width * 0.28, size.height * 0.22),
        const Radius.circular(7),
      ),
      blockPaint,
    );
    final Paint blockLightPaint = Paint()..color = blockLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.48, size.height * 0.12, size.width * 0.2, size.height * 0.14),
        const Radius.circular(6),
      ),
      blockLightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.63, size.width * 0.2, size.height * 0.16),
        const Radius.circular(6),
      ),
      blockLightPaint,
    );

    // Park.
    final Paint parkPaint = Paint()..color = park;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.7, size.height * 0.1, size.width * 0.24, size.height * 0.26),
        const Radius.circular(12),
      ),
      parkPaint,
    );
    final Paint treePaint = Paint()..color = tree;
    for (int i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.75 + (i % 3) * 0.045),
          size.height * (0.14 + (i ~/ 3) * 0.055),
        ),
        5,
        treePaint,
      );
    }

    // Roads.
    final Paint roadBorderPaint = Paint()
      ..color = roadBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final Paint roadPaint = Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round;
    final Path mainRoad = Path()
      ..moveTo(-10, size.height * 0.4)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.6,
        size.height * 0.55,
        size.width + 10,
        size.height * 0.5,
      );
    canvas
      ..drawPath(mainRoad, roadBorderPaint)
      ..drawPath(mainRoad, roadPaint);
    final Path crossRoad = Path()
      ..moveTo(size.width * 0.58, -10)
      ..lineTo(size.width * 0.5, size.height + 10);
    canvas
      ..drawPath(crossRoad, roadBorderPaint)
      ..drawPath(crossRoad, roadPaint);

    // Route.
    final Path route = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.66,
        size.width * 0.38,
        size.height * 0.39,
        size.width * 0.55,
        size.height * 0.36,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.33,
        size.width * 0.76,
        size.height * 0.22,
        size.width * 0.83,
        size.height * 0.2,
      );
    canvas.drawPath(
      route,
      Paint()
        ..color = palette.surface.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    final Paint routePaint = Paint()
      ..color = palette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final PathMetric metric in route.computeMetrics()) {
      double distance = 0;
      const double dash = 8;
      const double gap = 6;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + dash, metric.length)),
          routePaint,
        );
        distance += dash + gap;
      }
    }

    // Restaurant marker.
    final Offset start = Offset(size.width * 0.18, size.height * 0.78);
    final Offset end = Offset(size.width * 0.83, size.height * 0.2);
    _drawMarker(
      canvas,
      start,
      palette.panelDark,
      Icons.storefront_rounded,
      Colors.white,
    );
    _drawMarker(
      canvas,
      end,
      palette.success,
      Icons.home_rounded,
      palette.onSuccess,
    );

    // Rider marker along route.
    final PathMetric? metric = route.computeMetrics().isEmpty
        ? null
        : route.computeMetrics().first;
    if (metric != null) {
      final Tangent? tangent =
          metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) {
        final Offset rider = tangent.position;
        canvas.drawCircle(
          rider,
          17,
          Paint()..color = palette.surface.withValues(alpha: 0.9),
        );
        canvas.drawCircle(rider, 13, Paint()..color = palette.primary);
        final Paint face = Paint()
          ..color = palette.onPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(rider + const Offset(-4, 4), 2.4, face);
        canvas.drawCircle(rider + const Offset(4, 4), 2.4, face);
        canvas.drawLine(
          rider + const Offset(-3, -1),
          rider + const Offset(3, 1),
          face,
        );
        canvas.drawLine(
          rider + const Offset(2, 1),
          rider + const Offset(4, 4),
          face,
        );
      }
    }

    // Street names.
    _text(
      canvas,
      '100 Feet Road',
      Offset(size.width * 0.3, size.height * 0.33),
      TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 7,
        color: palette.muted.withValues(alpha: 0.8),
        fontWeight: FontWeight.w600,
      ),
    );
    _text(
      canvas,
      'Indiranagar',
      Offset(size.width * 0.64, size.height * 0.76),
      TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 8,
        color: palette.muted.withValues(alpha: 0.7),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _drawMarker(
    Canvas canvas,
    Offset center,
    Color color,
    IconData icon,
    Color glyph,
  ) {
    canvas.drawCircle(center, 18, Paint()..color = Colors.white);
    canvas.drawCircle(center, 13, Paint()..color = color);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: 13,
          color: glyph,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _text(Canvas canvas, String text, Offset offset, TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.foodie.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Order journey',
                style: context.foodieType.h3.copyWith(fontSize: 14.5),
              ),
              const Spacer(),
              Text(
                '${order.statusIndex + 1} of ${orderStatuses.length}',
                style: context.foodieType.small.copyWith(fontSize: 9.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List<Widget>.generate(orderStatuses.length, (int index) {
            final bool done = index < order.statusIndex;
            final bool current = index == order.statusIndex;
            final bool delivered = order.isDelivered && index == orderStatuses.length - 1;
            final bool highlighted = done || current;
            final bool last = index == orderStatuses.length - 1;
            final DateTime stepTime = order.placedAt.add(
              Duration(minutes: index * 4),
            );
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: <Widget>[
                        if (current && !delivered)
                          _PulseDot(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: context.foodie.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: context.foodie.onPrimary,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: done || delivered
                                  ? context.foodie.success
                                  : current
                                      ? context.foodie.primary
                                      : context.foodie.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: highlighted
                                    ? (done || delivered
                                        ? context.foodie.success
                                        : context.foodie.primary)
                                    : context.foodie.border,
                              ),
                            ),
                            child: done || delivered
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: context.foodie.onSuccess,
                                  )
                                : null,
                          ),
                        if (!last)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: index < order.statusIndex
                                  ? context.foodie.success.withValues(
                                      alpha: 0.55,
                                    )
                                  : context.foodie.border,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: last ? 0 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  orderStatuses[index],
                                  style: context.foodieType.body.copyWith(
                                    fontWeight: highlighted
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                    color: highlighted
                                        ? context.foodie.inkStrong
                                        : context.foodie.muted,
                                  ),
                                ),
                              ),
                              Text(
                                highlighted ? formatDate(stepTime) : 'Pending',
                                style: context.foodieType.small.copyWith(
                                  fontSize: 8.5,
                                  color: highlighted
                                      ? context.foodie.muted
                                      : context.foodie.subtle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            orderStatusDescriptions[index],
                            style: context.foodieType.small.copyWith(
                              fontSize: 10,
                              color: highlighted
                                  ? context.foodie.muted
                                  : context.foodie.subtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.child});

  final Widget child;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return SizedBox(width: 24, height: 24, child: Center(child: widget.child));
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Container(
                width: 18 + 10 * _controller.value,
                height: 18 + 10 * _controller.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.foodie.primary.withValues(
                    alpha: 0.25 * (1 - _controller.value),
                  ),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({
    required this.rider,
    required this.delivered,
    required this.onCall,
  });

  final Rider rider;
  final bool delivered;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.foodie.border),
      ),
      child: Row(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: context.foodie.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.foodie.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  rider.name.split(' ').map((String part) => part[0]).take(2).join(),
                  style: context.foodieType.h3.copyWith(
                    color: context.foodie.primaryInk,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: delivered
                        ? context.foodie.success
                        : context.foodie.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.foodie.surface, width: 2),
                  ),
                  child: Icon(
                    delivered ? Icons.check_rounded : Icons.delivery_dining_rounded,
                    size: 11,
                    color: delivered
                        ? context.foodie.onSuccess
                        : context.foodie.onPrimary,
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
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        rider.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.foodieType.h3.copyWith(fontSize: 14.5),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: context.foodie.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rider.rating.toStringAsFixed(1),
                      style: context.foodieType.label.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  delivered ? 'Delivered your order' : 'Your delivery partner',
                  style: context.foodieType.small.copyWith(fontSize: 10.5),
                ),
                Text(
                  rider.vehicle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.foodieType.small.copyWith(fontSize: 9.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCall,
            style: IconButton.styleFrom(
              backgroundColor: context.foodie.primarySoft,
              foregroundColor: context.foodie.primaryInk,
              minimumSize: const Size(40, 40),
            ),
            icon: const Icon(Icons.call_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
