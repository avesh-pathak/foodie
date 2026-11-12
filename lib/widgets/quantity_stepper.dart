import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
    this.minimum = 1,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    final double height = compact ? 34 : 40;
    final double iconSize = compact ? 15 : 17;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.foodie.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepButton(
            icon: quantity <= minimum
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            onTap: onDecrement,
            iconSize: iconSize,
            semanticLabel:
                quantity <= minimum ? 'Remove item' : 'Decrease quantity',
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '$quantity',
              key: ValueKey<int>(quantity),
              style: context.foodieType.label.copyWith(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                color: context.foodie.onPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            iconSize: iconSize,
            semanticLabel: 'Increase quantity',
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.iconSize,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        radius: 22,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: iconSize,
            color: context.foodie.onPrimary,
          ),
        ),
      ),
    );
  }
}

class OutlineAddButton extends StatelessWidget {
  const OutlineAddButton({
    super.key,
    required this.onTap,
    this.label = 'ADD',
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add $label to cart',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 36,
          constraints: const BoxConstraints(minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: context.foodie.primaryInk, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.foodieType.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: context.foodie.primaryInk,
            ),
          ),
        ),
      ),
    );
  }
}
