import 'package:flutter/animation.dart';

/// Shared motion vocabulary. Keep UI transitions under 300 ms.
abstract final class AppMotion {
  static const Duration press = Duration(milliseconds: 140);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration entrance = Duration(milliseconds: 380);
  static const Duration celebration = Duration(milliseconds: 850);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutBack;
}
