import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/order.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../theme/app_motion.dart';
import '../utils/app_haptics.dart';
import '../utils/formatters.dart';
import '../widgets/foodie_page_route.dart';
import 'order_tracking_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppHaptics.orderPlaced();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final FoodOrder? order =
        FoodieScope.of(context).orderById(widget.orderId);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.foodie.background,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _controller.value,
                      palette: context.foodie,
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 18),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: reduceMotion ? 1 : 0,
                            end: 1,
                          ),
                          duration: reduceMotion
                              ? Duration.zero
                              : AppMotion.celebration,
                          curve: AppMotion.emphasized,
                          builder:
                              (BuildContext context, double value, Widget? child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: context.foodie.successSoft,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: context.foodie.success.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 32,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: context.foodie.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: context.foodie.onSuccess,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'Order placed!',
                          style: context.foodieType.welcomeDisplay.copyWith(
                            fontSize: 38,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your food is being prepared with love. We will keep you posted at every step.',
                          textAlign: TextAlign.center,
                          style: context.foodieType.bodyMuted.copyWith(
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: context.foodie.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  _SuccessStat(
                                    icon: Icons.receipt_long_rounded,
                                    label: 'Order ID',
                                    value: order?.id ?? '—',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 38,
                                    color: context.foodie.border,
                                  ),
                                  _SuccessStat(
                                    icon: Icons.timer_outlined,
                                    label: 'Estimated',
                                    value: order == null
                                        ? '—'
                                        : '${order.etaMinutes}–${order.etaMinutes + 6} min',
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Divider(),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 17,
                                    color: context.foodie.primaryInk,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      order == null
                                          ? ''
                                          : 'Delivering to ${order.address.label} • ${order.address.line1}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.foodieType.small.copyWith(
                                        fontSize: 11,
                                        color: context.foodie.ink,
                                      ),
                                    ),
                                  ),
                                  if (order != null)
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: order.id),
                                        );
                                        HapticFeedback.selectionClick();
                                        showFoodieSnack(
                                          context,
                                          'Order ID copied',
                                        );
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            context.foodie.surfaceMuted,
                                        minimumSize: const Size(32, 32),
                                      ),
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        size: 15,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: order == null
                                ? null
                                : () {
                                    Navigator.of(context).pushReplacement(
                                      FoodiePageRoute<void>(
                                        page: OrderTrackingScreen(
                                          orderId: order.id,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.foodie.primary,
                              foregroundColor: context.foodie.onPrimary,
                              disabledBackgroundColor:
                                  context.foodie.primarySoft,
                              disabledForegroundColor: context.foodie.subtle,
                            ),
                            icon: const Icon(
                              Icons.local_shipping_outlined,
                              size: 20,
                            ),
                            label: const Text('Track my order'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _goHome,
                            child: const Text('Back to home'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'This is a demo order. You can simulate each delivery step from the tracking screen.',
                          textAlign: TextAlign.center,
                          style: context.foodieType.small.copyWith(
                            fontSize: 10,
                            color: context.foodie.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessStat extends StatelessWidget {
  const _SuccessStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.foodie.surfaceWarm,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 17, color: context.foodie.primaryInk),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: context.foodieType.label.copyWith(
                    fontSize: 8.5,
                    color: context.foodie.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.foodieType.h3.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.palette});

  /// Corner radius of a confetti piece — a fraction of the smallest radius
  /// token, because a piece is a painted particle, not a surface.
  static const double _pieceRadius = AppRadius.sm / 8;

  final double progress;

  /// The themed palette. A painter has no [BuildContext] of its own, so the
  /// widget that creates it hands the colours over.
  final FoodiePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> colors = <Color>[
      palette.primary,
      palette.gold,
      palette.success,
      palette.info,
      palette.danger,
    ];
    final math.Random random = math.Random(11);
    for (int i = 0; i < 44; i++) {
      final double startX = random.nextDouble() * size.width;
      final double drift = (random.nextDouble() - 0.5) * 80;
      final double delay = random.nextDouble() * 0.35;
      final double local = ((progress - delay) / 0.65).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final double y = -20 + local * (size.height + 40);
      final double x = startX + drift * local;
      final Paint paint = Paint()
        ..color = colors[i % colors.length].withValues(
          alpha: (1 - local * 1.25).clamp(0.0, 1.0),
        );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * 6 + i);
      if (i.isEven) {
        canvas.drawCircle(Offset.zero, 2.5 + (i % 3), paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 4,
              height: 9,
            ),
            const Radius.circular(_pieceRadius),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
