import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// FSSAI-style diet marker.
///
/// Colour is never the only signal: a vegetarian item is a square frame
/// with a filled circle, a non-vegetarian item is a triangle frame with a
/// filled triangle — the distinction survives greyscale and colour blindness.
class VegBadge extends StatelessWidget {
  const VegBadge({super.key, required this.isVeg, this.size = 15});

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    // A painter has no BuildContext, so the themed marker colour is handed
    // to it by the widget that owns the palette.
    final Color color = isVeg ? context.foodie.veg : context.foodie.nonVeg;
    return Semantics(
      label: isVeg ? 'Vegetarian' : 'Non vegetarian',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DietMarkerPainter(color: color, isVeg: isVeg),
        ),
      ),
    );
  }
}

class _DietMarkerPainter extends CustomPainter {
  const _DietMarkerPainter({required this.color, required this.isVeg});

  final Color color;
  final bool isVeg;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round;
    final Paint fill = Paint()..color = color;

    if (isVeg) {
      const double inset = 0.7;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, w - inset * 2, h - inset * 2),
          Radius.circular(w * 0.18),
        ),
        stroke,
      );
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.32, fill);
      return;
    }

    final Path outline = Path()
      ..moveTo(w / 2, h * 0.08)
      ..lineTo(w * 0.93, h * 0.9)
      ..lineTo(w * 0.07, h * 0.9)
      ..close();
    canvas.drawPath(outline, stroke);

    final Path inner = Path()
      ..moveTo(w / 2, h * 0.41)
      ..lineTo(w * 0.76, h * 0.78)
      ..lineTo(w * 0.24, h * 0.78)
      ..close();
    canvas.drawPath(inner, fill);
  }

  @override
  bool shouldRepaint(covariant _DietMarkerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isVeg != isVeg;
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.backgroundColor,
    this.size = 36,
    this.showShadow = true,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  /// The plate behind the heart. Defaults to the themed surface, which is
  /// resolved at build time so it follows the active brightness.
  final Color? backgroundColor;
  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from favourites' : 'Add to favourites',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? context.foodie.surface,
            shape: BoxShape.circle,
            boxShadow: showShadow ? AppShadows.soft : AppShadows.none,
          ),
          child: TweenAnimationBuilder<double>(
            key: ValueKey<bool>(isFavorite),
            tween: Tween<double>(begin: 0.82, end: 1),
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            builder: (BuildContext context, double scale, Widget? child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: size * 0.48,
              color:
                  isFavorite ? context.foodie.primaryInk : context.foodie.ink,
            ),
          ),
        ),
      ),
    );
  }
}
