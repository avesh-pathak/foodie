import 'package:flutter/material.dart';

class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final String id;
  final String label;
  final IconData icon;

  /// The cuisine hue. Use as a fill with a white label, or as ink on
  /// [softColor] — both directions clear 4.5:1.
  final Color color;

  /// The tinted companion to [color]. Use as a background for [color] ink.
  final Color softColor;
}
