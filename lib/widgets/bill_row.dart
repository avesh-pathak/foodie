import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One line of a bill summary.
///
/// The leading icon is neutral by default: green means savings, so only a
/// discount row is allowed to wear it.
class BillRow extends StatelessWidget {
  const BillRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;
  final IconData? icon;

  /// Colour of the leading icon. Defaults to the theme's muted ink so a bill
  /// row never implies success; a savings row falls back to the success ink
  /// instead.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    final bool isSavings =
        valueColor == palette.success || valueColor == palette.successInk;
    final Color resolvedIconColor =
        iconColor ?? (isSavings ? palette.successInk : palette.muted);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: emphasize ? 6 : 5),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 15, color: resolvedIconColor),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              style: emphasize
                  ? context.foodieType.h3.copyWith(fontSize: 15)
                  : context.foodieType.bodyMuted.copyWith(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: emphasize
                ? context.foodieType.h2.copyWith(fontSize: 18)
                : context.foodieType.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? palette.ink,
                  ),
          ),
        ],
      ),
    );
  }
}
