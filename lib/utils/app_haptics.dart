import 'package:flutter/services.dart';

/// Small, purposeful feedback moments for the app.
///
/// Haptics are best-effort: devices without a haptic engine simply ignore them.
abstract final class AppHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> addToCart() => HapticFeedback.lightImpact();

  static Future<void> orderPlaced() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.mediumImpact();
  }

  static Future<void> delivered() async {
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
  }

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }
}
