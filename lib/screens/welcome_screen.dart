import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/foodie_image.dart';
import '../widgets/foodie_logo.dart';
import '../widgets/foodie_page_route.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    if (WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _reveal(Widget child, double begin, double end) {
    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  void _openLogin() {
    Navigator.of(context).push(
      FoodiePageRoute<void>(page: const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(painter: _WelcomeBackdrop(palette)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Every size is derived from the height the phone actually
                // gives us. On a 568 dp screen the collage shrinks, the
                // supporting copy is dropped and the type scales down; on a
                // tall phone the collage grows back. The scroll view is only
                // a safety net for extreme text scaling — at normal sizes the
                // Get Started button always lands above the fold.
                final double available = constraints.maxHeight;
                final bool condensed = available < 700;
                final double heroHeight =
                    (available * 0.29).clamp(138.0, 252.0);
                final double headlineSize =
                    (available * 0.046).clamp(26.0, 38.0);
                final bool showBody = available >= 585;
                final bool showChips = available >= 520;
                final double contentWidth = math.max(
                  1.0,
                  math.min(480.0, constraints.maxWidth - 40),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(0, available - 30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _reveal(const _WelcomeHeader(), 0, 0.4),
                            SizedBox(height: condensed ? 12 : 20),
                            _reveal(
                              _HeroCollage(
                                height: heroHeight,
                                compact: condensed,
                              ),
                              0.12,
                              0.68,
                            ),
                            SizedBox(height: condensed ? 16 : 24),
                            _reveal(
                              Text(
                                'Delicious food,\ndelivered to you.',
                                maxLines: 3,
                                style: context.foodieType.welcomeDisplay
                                    .copyWith(fontSize: headlineSize),
                              ),
                              0.3,
                              0.82,
                            ),
                            if (showBody) ...<Widget>[
                              SizedBox(height: condensed ? 8 : 12),
                              _reveal(
                                Text(
                                  'Biryani, pizza, desserts — the food you '
                                  'love, delivered fresh and fast.',
                                  maxLines: 3,
                                  style: context.foodieType.bodyMuted.copyWith(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                0.4,
                                0.9,
                              ),
                            ],
                            if (showChips) ...<Widget>[
                              SizedBox(height: condensed ? 12 : 18),
                              _reveal(
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    _FeatureChip(
                                      icon: Icons.restaurant_menu_rounded,
                                      label: '40+ kitchens',
                                      compact: condensed,
                                    ),
                                    _FeatureChip(
                                      icon: Icons.delivery_dining_rounded,
                                      label: 'Live tracking',
                                      compact: condensed,
                                    ),
                                    _FeatureChip(
                                      icon: Icons.bolt_rounded,
                                      label: '30 min avg.',
                                      compact: condensed,
                                    ),
                                  ],
                                ),
                                0.48,
                                0.94,
                              ),
                            ],
                            SizedBox(height: condensed ? 16 : 26),
                            _reveal(
                              PrimaryButton(
                                label: 'Get Started',
                                icon: Icons.arrow_forward_rounded,
                                height: condensed ? 50 : 54,
                                onPressed: _openLogin,
                              ),
                              0.58,
                              1,
                            ),
                            _reveal(
                              Center(
                                child: TextButton(
                                  onPressed: _openLogin,
                                  child: const Text('I already have an account'),
                                ),
                              ),
                              0.62,
                              1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand lockup plus the delivery city — the Foodie-style top strip.
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(flex: 3, child: FoodieLogo(size: 40)),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: context.foodie.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: context.foodie.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.location_on_rounded,
                  size: 13,
                  color: context.foodie.primaryInk,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Bengaluru',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.foodie.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCollage extends StatelessWidget {
  const _HeroCollage({required this.height, required this.compact});

  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    final double inset = compact ? 12 : 18;
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.floating,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const FoodieImage(
                      asset: 'assets/images/promo_food.jpg',
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            palette.overlayDark.withValues(alpha: 0.10),
                            palette.overlayDark.withValues(alpha: 0.05),
                            palette.overlayDark,
                          ],
                          stops: const <double>[0, 0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: inset,
                      top: inset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: palette.primary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text(
                          'FRESHLY MADE • LOCALLY LOVED',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 8,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: inset,
                      right: inset,
                      bottom: inset,
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            // Foodie's signature: a green star badge.
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: palette.success,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '4.8',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      '20k+ ratings',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: compact ? 40 : 48,
                            height: compact ? 40 : 48,
                            decoration: BoxDecoration(
                              color: palette.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.takeout_dining_rounded,
                              color: palette.onPrimary,
                              size: compact ? 21 : 24,
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
          if (height >= 182)
            Positioned(
              right: -8,
              top: compact ? 54 : 74,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.rotate(
                    angle: (1 - value) * 0.3,
                    child: Transform.scale(scale: value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: palette.border),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: palette.primaryInk,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '30 MIN',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: palette.inkStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: context.foodie.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.foodie.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: compact ? 13 : 14,
            color: context.foodie.primaryInk,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: compact ? 10.5 : 11,
              fontWeight: FontWeight.w700,
              color: context.foodie.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative washes behind the welcome copy.
///
/// The painter has no [BuildContext], so the palette is handed in by the
/// widget that creates it.
class _WelcomeBackdrop extends CustomPainter {
  const _WelcomeBackdrop(this.palette);

  final FoodiePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint red = Paint()
      ..color = palette.primarySoft.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.93, size.height * 0.04),
      size.width * 0.42,
      red,
    );
    final Paint wash = Paint()
      ..color = palette.primarySofter
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-size.width * 0.1, size.height * 0.48),
      size.width * 0.34,
      wash,
    );

    final Paint dot = Paint()
      ..color = palette.primary.withValues(alpha: 0.10);
    for (int i = 0; i < 18; i++) {
      final double x = size.width * (0.06 + ((i * 37) % 88) / 100);
      final double y = size.height * (0.02 + ((i * 61) % 96) / 100);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * 0.5, dot);
    }

    final Path arc = Path()
      ..moveTo(size.width * 0.65, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.72,
        size.width * 0.98,
        size.height * 0.95,
      );
    canvas.drawPath(
      arc,
      Paint()
        ..color = palette.primary.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WelcomeBackdrop oldDelegate) =>
      oldDelegate.palette != palette;
}
