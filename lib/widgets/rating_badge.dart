import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A rating pill.
///
/// A rating is a positive signal, so it wears the success hue — but the two
/// variants never mix roles: the filled variant carries the theme's
/// `onSuccess` label on `success`, and the light variant, which sits over
/// photography, carries `successInk` on a chip that is always light enough
/// for that ink to read.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.ratingCount,
    this.compact = false,
    this.light = false,
  });

  final double rating;
  final int? ratingCount;
  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    // The light variant floats over photography, so its chip is painted with
    // the themed surface instead of a fixed white — that keeps `successInk`
    // legible on either brightness.
    final Color background =
        light ? palette.surface.withValues(alpha: 0.92) : palette.success;
    final Color foreground = light ? palette.successInk : palette.onSuccess;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.star_rounded, size: compact ? 13 : 15, color: foreground),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: context.foodieType.label.copyWith(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
          if (ratingCount != null && !compact) ...<Widget>[
            const SizedBox(width: 4),
            Text(
              '(${_compactCount(ratingCount!)})',
              style: context.foodieType.small.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _compactCount(int count) {
    if (count >= 1000) {
      final double value = count / 1000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}k';
    }
    return '$count';
  }
}
