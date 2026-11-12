import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The app's primary call to action.
///
/// The default fill is the theme's `primary` and the label wears the
/// theme's `onPrimary`, so the pair stays legible on either brightness.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    final Color fill = backgroundColor ?? palette.primary;
    final Color foreground = foregroundColor ?? palette.onPrimary;

    // A busy button keeps its active fill so the spinner reads as work in
    // progress; only a genuinely disabled button drops to the soft wash.
    final Color disabledFill = isLoading
        ? fill
        : backgroundColor == null
            ? palette.primarySoft
            : fill.withValues(alpha: 0.45);
    final Color disabledForeground = isLoading
        ? foreground
        : foregroundColor == null
            ? palette.subtle
            : foreground.withValues(alpha: 0.6);

    final Widget content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.foodieType.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
              if (icon != null) ...<Widget>[
                const SizedBox(width: 10),
                Icon(icon, size: 20, color: foreground),
              ],
            ],
          );

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: foreground,
          disabledBackgroundColor: disabledFill,
          disabledForegroundColor: disabledForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: content,
      ),
    );
  }
}
