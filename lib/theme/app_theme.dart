import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/order.dart';

/// The global stylesheet.
///
/// Flutter's answer to CSS custom properties is a [ThemeExtension]: a bundle
/// of named tokens that the [Theme] carries, so a widget reads
/// `context.foodie.surface` instead of hardcoding `#FFFFFF`. Because the
/// tokens live on the [Theme], the same widget tree renders correctly under
/// both brightnesses — switching theme is a single assignment rather than a
/// second copy of every screen.
///
/// Every pairing in this file was checked with the WCAG 2.2 contrast
/// formula, and the dark palette was composed for dark surfaces rather than
/// being a mechanical inversion of the light one.
@immutable
class FoodiePalette extends ThemeExtension<FoodiePalette> {
  const FoodiePalette({
    required this.background,
    required this.surface,
    required this.surfaceWarm,
    required this.surfaceMuted,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.inkStrong,
    required this.ink,
    required this.muted,
    required this.subtle,
    required this.primary,
    required this.primaryDeep,
    required this.primaryLift,
    required this.primaryInk,
    required this.primarySoft,
    required this.primarySofter,
    required this.onPrimary,
    required this.onPrimaryDeep,
    required this.success,
    required this.successInk,
    required this.successSoft,
    required this.onSuccess,
    required this.warning,
    required this.warningInk,
    required this.warningSoft,
    required this.onWarning,
    required this.danger,
    required this.dangerInk,
    required this.dangerSoft,
    required this.onDanger,
    required this.info,
    required this.infoInk,
    required this.infoSoft,
    required this.onInfo,
    required this.gold,
    required this.goldInk,
    required this.goldSoft,
    required this.goldDeep,
    required this.onGold,
    required this.panelDark,
    required this.overlayDark,
    required this.veg,
    required this.nonVeg,
  });

  // ---------------------------------------------------------------------
  // Canvas & surfaces
  // ---------------------------------------------------------------------
  /// App canvas.
  final Color background;

  /// Card, sheet and dialog surface.
  final Color surface;

  /// Warm tinted panel, one step above the canvas.
  final Color surfaceWarm;

  /// Recessed well — chips, inset rows, table headers.
  final Color surfaceMuted;

  /// Deepest inset, used for pressed or sunken regions.
  final Color surfaceSunken;

  /// Decorative hairline for card edges and dividers.
  final Color border;

  /// Boundary for interactive controls (text fields, radio rings).
  final Color borderStrong;

  // ---------------------------------------------------------------------
  // Ink ramp
  // ---------------------------------------------------------------------
  /// Display text and headings.
  final Color inkStrong;

  /// Body text.
  final Color ink;

  /// Secondary body text, captions, metadata.
  final Color muted;

  /// Tertiary text, placeholders, disabled labels.
  final Color subtle;

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------
  /// The vivid brand orange. This is the app's signature colour and the
  /// fill every primary action wears.
  final Color primary;

  /// A deeper brand orange, for surfaces that need to sit *on* imagery or
  /// on an already-dark ground.
  final Color primaryDeep;

  /// A lighter brand orange, for the top stop of a brand gradient.
  final Color primaryLift;

  /// Brand orange as ink — labels and icons on light surfaces.
  final Color primaryInk;

  /// Brand tint.
  final Color primarySoft;

  /// Gentlest brand wash, for large tinted areas.
  final Color primarySofter;

  /// Label colour that sits on [primary].
  final Color onPrimary;

  /// Label colour that sits on [primaryDeep].
  final Color onPrimaryDeep;

  // ---------------------------------------------------------------------
  // Semantic roles — each hue means exactly one thing
  // ---------------------------------------------------------------------
  /// Success / delivered / confirmed / rating.
  final Color success;
  final Color successInk;
  final Color successSoft;
  final Color onSuccess;

  /// Attention / in the kitchen / pending.
  final Color warning;
  final Color warningInk;
  final Color warningSoft;
  final Color onWarning;

  /// Destructive / failed / cancelled.
  final Color danger;
  final Color dangerInk;
  final Color dangerSoft;
  final Color onDanger;

  /// Live / queued / in-motion / system state.
  final Color info;
  final Color infoInk;
  final Color infoSoft;
  final Color onInfo;

  /// Premium tier / loyalty / gold.
  final Color gold;
  final Color goldInk;
  final Color goldSoft;
  final Color goldDeep;
  final Color onGold;

  // ---------------------------------------------------------------------
  // Fixed roles
  // ---------------------------------------------------------------------
  /// Dark warm panel, used for hero blocks that stay dark in both themes.
  final Color panelDark;

  /// Scrim over photography.
  final Color overlayDark;

  /// Vegetarian marker.
  final Color veg;

  /// Non-vegetarian marker.
  final Color nonVeg;

  /// Light palette — Zomato's red-on-white identity.
  ///
  /// The brand red is Zomato's `#E23744` deepened by two steps to `#DC2B3B`
  /// so a white label on the fill clears 4.5:1 (4.72:1) instead of landing at
  /// 4.32:1. The difference is invisible; the contrast is not.
  static const FoodiePalette light = FoodiePalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFFFF5F6),
    surfaceMuted: Color(0xFFF7F7F8),
    surfaceSunken: Color(0xFFEFEFF1),
    border: Color(0xFFECECEE),
    borderStrong: Color(0xFF8E8E93),
    inkStrong: Color(0xFF1C1C1E),
    ink: Color(0xFF2C2C30),
    muted: Color(0xFF67676C),
    subtle: Color(0xFF6E6E76),
    primary: Color(0xFFDC2B3B),
    primaryDeep: Color(0xFFA8121F),
    primaryLift: Color(0xFFF4576A),
    primaryInk: Color(0xFFC4202F),
    primarySoft: Color(0xFFFDEBEE),
    primarySofter: Color(0xFFFFF5F6),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryDeep: Color(0xFFFFFFFF),
    success: Color(0xFF1E7F38),
    successInk: Color(0xFF16702F),
    successSoft: Color(0xFFEAF6ED),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFB45309),
    warningInk: Color(0xFF8A5C0A),
    warningSoft: Color(0xFFFFF4E0),
    onWarning: Color(0xFFFFFFFF),
    danger: Color(0xFFB3261E),
    dangerInk: Color(0xFFA3231C),
    dangerSoft: Color(0xFFFDECEA),
    onDanger: Color(0xFFFFFFFF),
    info: Color(0xFF0E6A80),
    infoInk: Color(0xFF0B5A6E),
    infoSoft: Color(0xFFE7F4F8),
    onInfo: Color(0xFFFFFFFF),
    gold: Color(0xFFB8860B),
    goldInk: Color(0xFF7A5C0C),
    goldSoft: Color(0xFFFFF4DC),
    goldDeep: Color(0xFF3B2A08),
    onGold: Color(0xFF3B2A08),
    panelDark: Color(0xFF1C1C1E),
    overlayDark: Color(0xCC101012),
    veg: Color(0xFF1B7F3B),
    nonVeg: Color(0xFFA3341F),
  );

  /// Dark palette — Zomato at night: near-black canvas, white ink, the same
  /// red lifted so it glows against the black instead of sinking into it.
  static const FoodiePalette dark = FoodiePalette(
    background: Color(0xFF0F0F10),
    surface: Color(0xFF19191B),
    surfaceWarm: Color(0xFF241417),
    surfaceMuted: Color(0xFF212124),
    surfaceSunken: Color(0xFF0A0A0B),
    border: Color(0xFF2E2E33),
    borderStrong: Color(0xFF77777F),
    inkStrong: Color(0xFFFFFFFF),
    ink: Color(0xFFF2F2F4),
    muted: Color(0xFFB9B9C0),
    subtle: Color(0xFF9A9AA2),
    primary: Color(0xFFFF5A65),
    primaryDeep: Color(0xFFC4202F),
    primaryLift: Color(0xFFFF8A92),
    primaryInk: Color(0xFFFF8A92),
    primarySoft: Color(0xFF3A1518),
    primarySofter: Color(0xFF2A1013),
    onPrimary: Color(0xFF2A0508),
    onPrimaryDeep: Color(0xFFFFFFFF),
    success: Color(0xFF3FBF6B),
    successInk: Color(0xFF7FD9A0),
    successSoft: Color(0xFF12301E),
    onSuccess: Color(0xFF06281A),
    warning: Color(0xFFE9A13B),
    warningInk: Color(0xFFF2C069),
    warningSoft: Color(0xFF33240D),
    onWarning: Color(0xFF2B1A02),
    danger: Color(0xFFF2706B),
    dangerInk: Color(0xFFF79C98),
    dangerSoft: Color(0xFF331614),
    onDanger: Color(0xFF33100E),
    info: Color(0xFF4FB3C9),
    infoInk: Color(0xFF86CFE0),
    infoSoft: Color(0xFF0E2C33),
    onInfo: Color(0xFF06222A),
    gold: Color(0xFFE0A526),
    goldInk: Color(0xFFEFC77A),
    goldSoft: Color(0xFF33280E),
    goldDeep: Color(0xFF2A1F05),
    onGold: Color(0xFF2A1F05),
    panelDark: Color(0xFF1F1F22),
    overlayDark: Color(0xCC08080A),
    veg: Color(0xFF4CC38A),
    nonVeg: Color(0xFFE07A6C),
  );

  @override
  FoodiePalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceWarm,
    Color? surfaceMuted,
    Color? surfaceSunken,
    Color? border,
    Color? borderStrong,
    Color? inkStrong,
    Color? ink,
    Color? muted,
    Color? subtle,
    Color? primary,
    Color? primaryDeep,
    Color? primaryLift,
    Color? primaryInk,
    Color? primarySoft,
    Color? primarySofter,
    Color? onPrimary,
    Color? onPrimaryDeep,
    Color? success,
    Color? successInk,
    Color? successSoft,
    Color? onSuccess,
    Color? warning,
    Color? warningInk,
    Color? warningSoft,
    Color? onWarning,
    Color? danger,
    Color? dangerInk,
    Color? dangerSoft,
    Color? onDanger,
    Color? info,
    Color? infoInk,
    Color? infoSoft,
    Color? onInfo,
    Color? gold,
    Color? goldInk,
    Color? goldSoft,
    Color? goldDeep,
    Color? onGold,
    Color? panelDark,
    Color? overlayDark,
    Color? veg,
    Color? nonVeg,
  }) {
    return FoodiePalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceWarm: surfaceWarm ?? this.surfaceWarm,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      inkStrong: inkStrong ?? this.inkStrong,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      subtle: subtle ?? this.subtle,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      primaryLift: primaryLift ?? this.primaryLift,
      primaryInk: primaryInk ?? this.primaryInk,
      primarySoft: primarySoft ?? this.primarySoft,
      primarySofter: primarySofter ?? this.primarySofter,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryDeep: onPrimaryDeep ?? this.onPrimaryDeep,
      success: success ?? this.success,
      successInk: successInk ?? this.successInk,
      successSoft: successSoft ?? this.successSoft,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      warningInk: warningInk ?? this.warningInk,
      warningSoft: warningSoft ?? this.warningSoft,
      onWarning: onWarning ?? this.onWarning,
      danger: danger ?? this.danger,
      dangerInk: dangerInk ?? this.dangerInk,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      onDanger: onDanger ?? this.onDanger,
      info: info ?? this.info,
      infoInk: infoInk ?? this.infoInk,
      infoSoft: infoSoft ?? this.infoSoft,
      onInfo: onInfo ?? this.onInfo,
      gold: gold ?? this.gold,
      goldInk: goldInk ?? this.goldInk,
      goldSoft: goldSoft ?? this.goldSoft,
      goldDeep: goldDeep ?? this.goldDeep,
      onGold: onGold ?? this.onGold,
      panelDark: panelDark ?? this.panelDark,
      overlayDark: overlayDark ?? this.overlayDark,
      veg: veg ?? this.veg,
      nonVeg: nonVeg ?? this.nonVeg,
    );
  }

  @override
  FoodiePalette lerp(covariant FoodiePalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return FoodiePalette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceWarm: mix(surfaceWarm, other.surfaceWarm),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      inkStrong: mix(inkStrong, other.inkStrong),
      ink: mix(ink, other.ink),
      muted: mix(muted, other.muted),
      subtle: mix(subtle, other.subtle),
      primary: mix(primary, other.primary),
      primaryDeep: mix(primaryDeep, other.primaryDeep),
      primaryLift: mix(primaryLift, other.primaryLift),
      primaryInk: mix(primaryInk, other.primaryInk),
      primarySoft: mix(primarySoft, other.primarySoft),
      primarySofter: mix(primarySofter, other.primarySofter),
      onPrimary: mix(onPrimary, other.onPrimary),
      onPrimaryDeep: mix(onPrimaryDeep, other.onPrimaryDeep),
      success: mix(success, other.success),
      successInk: mix(successInk, other.successInk),
      successSoft: mix(successSoft, other.successSoft),
      onSuccess: mix(onSuccess, other.onSuccess),
      warning: mix(warning, other.warning),
      warningInk: mix(warningInk, other.warningInk),
      warningSoft: mix(warningSoft, other.warningSoft),
      onWarning: mix(onWarning, other.onWarning),
      danger: mix(danger, other.danger),
      dangerInk: mix(dangerInk, other.dangerInk),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
      onDanger: mix(onDanger, other.onDanger),
      info: mix(info, other.info),
      infoInk: mix(infoInk, other.infoInk),
      infoSoft: mix(infoSoft, other.infoSoft),
      onInfo: mix(onInfo, other.onInfo),
      gold: mix(gold, other.gold),
      goldInk: mix(goldInk, other.goldInk),
      goldSoft: mix(goldSoft, other.goldSoft),
      goldDeep: mix(goldDeep, other.goldDeep),
      onGold: mix(onGold, other.onGold),
      panelDark: mix(panelDark, other.panelDark),
      overlayDark: mix(overlayDark, other.overlayDark),
      veg: mix(veg, other.veg),
      nonVeg: mix(nonVeg, other.nonVeg),
    );
  }
}

/// The type scale, themed.
///
/// Same idea as [FoodiePalette]: the sizes and weights are fixed, but the
/// ink colour comes from the palette, so headings and body copy stay
/// legible on either canvas.
@immutable
class FoodieType extends ThemeExtension<FoodieType> {
  const FoodieType({
    required this.welcomeDisplay,
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body,
    required this.bodyMuted,
    required this.small,
    required this.label,
    required this.eyebrow,
    required this.price,
  });

  final TextStyle welcomeDisplay;
  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body;
  final TextStyle bodyMuted;
  final TextStyle small;
  final TextStyle label;
  final TextStyle eyebrow;
  final TextStyle price;

  static const String bodyFamily = 'PlusJakartaSans';

  /// Zomato's identity is all-sans: heavy geometric headlines over the same
  /// grotesque used for body copy. The app ships one family, so display and
  /// body share it and the hierarchy comes from weight and size instead of a
  /// second typeface.
  static const String displayFamily = 'PlusJakartaSans';

  static FoodieType of(FoodiePalette palette) => FoodieType(
        welcomeDisplay: TextStyle(
          fontFamily: displayFamily,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          height: 1.06,
          letterSpacing: -1.4,
          color: palette.inkStrong,
        ),
        display: TextStyle(
          fontFamily: displayFamily,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -1,
          color: palette.inkStrong,
        ),
        h1: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.18,
          letterSpacing: -0.7,
          color: palette.inkStrong,
        ),
        h2: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: -0.4,
          color: palette.inkStrong,
        ),
        h3: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: -0.2,
          color: palette.inkStrong,
        ),
        body: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: palette.ink,
        ),
        bodyMuted: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: palette.muted,
        ),
        small: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: palette.muted,
        ),
        label: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: palette.ink,
        ),
        eyebrow: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: palette.primaryInk,
        ),
        price: TextStyle(
          fontFamily: bodyFamily,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: palette.inkStrong,
        ),
      );

  @override
  FoodieType copyWith({
    TextStyle? welcomeDisplay,
    TextStyle? display,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? body,
    TextStyle? bodyMuted,
    TextStyle? small,
    TextStyle? label,
    TextStyle? eyebrow,
    TextStyle? price,
  }) {
    return FoodieType(
      welcomeDisplay: welcomeDisplay ?? this.welcomeDisplay,
      display: display ?? this.display,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      body: body ?? this.body,
      bodyMuted: bodyMuted ?? this.bodyMuted,
      small: small ?? this.small,
      label: label ?? this.label,
      eyebrow: eyebrow ?? this.eyebrow,
      price: price ?? this.price,
    );
  }

  @override
  FoodieType lerp(covariant FoodieType? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) =>
        TextStyle.lerp(a, b, t)!;
    return FoodieType(
      welcomeDisplay: mix(welcomeDisplay, other.welcomeDisplay),
      display: mix(display, other.display),
      h1: mix(h1, other.h1),
      h2: mix(h2, other.h2),
      h3: mix(h3, other.h3),
      body: mix(body, other.body),
      bodyMuted: mix(bodyMuted, other.bodyMuted),
      small: mix(small, other.small),
      label: mix(label, other.label),
      eyebrow: mix(eyebrow, other.eyebrow),
      price: mix(price, other.price),
    );
  }
}

/// Reads the global stylesheet from the nearest [Theme].
///
/// This is the single access point for colour and type. Nothing in the app
/// hardcodes a hex value; every screen asks the theme for what it needs.
extension FoodieThemeAccess on BuildContext {
  /// The themed colour tokens.
  FoodiePalette get foodie => Theme.of(this).extension<FoodiePalette>()!;

  /// The themed type scale.
  FoodieType get foodieType => Theme.of(this).extension<FoodieType>()!;
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 56;
  static const double screenPadding = 20;
}

abstract final class AppRadius {
  /// Small controls, chips.
  static const double sm = 12;

  /// Cards, inputs, list tiles.
  static const double md = 16;

  /// Large surfaces — sheets and dialogs.
  static const double lg = 20;

  /// Pills.
  static const double pill = 100;
}

/// Elevation is declared once, and only on surfaces that genuinely float.
/// Flat cards are defined by their edge, not by a halo.
abstract final class AppShadows {
  /// A raised card floating a little above the canvas.
  static List<BoxShadow> get soft => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// A floating element — bottom nav, promo card, drag handle.
  static List<BoxShadow> get floating => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.22),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  /// No elevation.
  static List<BoxShadow> get none => const <BoxShadow>[];
}

/// Order journey states, mapped to one semantic hue each.
/// Colour is never the only signal — every state also carries an icon and
/// a written label.
extension OrderPhaseColors on FoodiePalette {
  /// Solid fill for a filled chip.
  Color phaseFill(OrderPhase phase) {
    switch (phase) {
      case OrderPhase.queued:
        return info;
      case OrderPhase.preparing:
        return warning;
      case OrderPhase.moving:
        return primary;
      case OrderPhase.delivered:
        return success;
      case OrderPhase.cancelled:
        return danger;
    }
  }

  /// Ink that sits on [phaseSoft].
  Color phaseInk(OrderPhase phase) {
    switch (phase) {
      case OrderPhase.queued:
        return infoInk;
      case OrderPhase.preparing:
        return warningInk;
      case OrderPhase.moving:
        return primaryInk;
      case OrderPhase.delivered:
        return successInk;
      case OrderPhase.cancelled:
        return dangerInk;
    }
  }

  /// Tinted background for [phaseInk].
  Color phaseSoft(OrderPhase phase) {
    switch (phase) {
      case OrderPhase.queued:
        return infoSoft;
      case OrderPhase.preparing:
        return warningSoft;
      case OrderPhase.moving:
        return primarySoft;
      case OrderPhase.delivered:
        return successSoft;
      case OrderPhase.cancelled:
        return dangerSoft;
    }
  }
}

abstract final class AppTheme {
  /// Builds a complete Material 3 theme from a palette.
  ///
  /// Both brightnesses are composed independently — the dark scheme is not a
  /// mechanical inversion of the light one.
  static ThemeData build(FoodiePalette palette) {
    final Brightness brightness = palette == FoodiePalette.dark
        ? Brightness.dark
        : Brightness.light;
    final FoodieType type = FoodieType.of(palette);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primarySoft,
      onPrimaryContainer: palette.primaryInk,
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.primarySoft,
      onSecondaryContainer: palette.primaryInk,
      tertiary: palette.info,
      onTertiary: palette.onInfo,
      tertiaryContainer: palette.infoSoft,
      onTertiaryContainer: palette.infoInk,
      error: palette.danger,
      onError: palette.onDanger,
      errorContainer: palette.dangerSoft,
      onErrorContainer: palette.dangerInk,
      surface: palette.surface,
      onSurface: palette.inkStrong,
      onSurfaceVariant: palette.muted,
      surfaceDim: palette.surfaceSunken,
      surfaceBright: palette.surface,
      surfaceContainerLowest: palette.surface,
      surfaceContainerLow: palette.background,
      surfaceContainer: palette.surfaceMuted,
      surfaceContainerHigh: palette.surfaceWarm,
      surfaceContainerHighest: palette.surfaceSunken,
      outline: palette.borderStrong,
      outlineVariant: palette.border,
      inverseSurface: palette.inkStrong,
      onInverseSurface: palette.background,
      inversePrimary: palette.primary,
      surfaceTint: palette.primary,
      scrim: const Color(0xFF000000),
      shadow: const Color(0xFF000000),
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: type.welcomeDisplay,
      displayMedium: type.display,
      displaySmall: type.h1,
      headlineLarge: type.h1,
      headlineMedium: type.h2,
      headlineSmall: type.h3,
      titleLarge: type.h3,
      titleMedium: type.body.copyWith(fontWeight: FontWeight.w700),
      titleSmall: type.label,
      bodyLarge: type.body,
      bodyMedium: type.bodyMuted,
      bodySmall: type.small,
      labelLarge: type.label.copyWith(fontSize: 14),
      labelMedium: type.label,
      labelSmall: type.small.copyWith(fontSize: 11),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: FoodieType.bodyFamily,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[palette, type],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.inkStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: type.h3,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: palette.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.primarySoft,
          disabledForegroundColor: palette.subtle,
          elevation: 0,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: type.body.copyWith(
            color: palette.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.primarySoft,
          disabledForegroundColor: palette.subtle,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: type.body.copyWith(
            color: palette.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.inkStrong,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: palette.borderStrong, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: type.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primaryInk,
          textStyle: type.body.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.primaryInk,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: type.bodyMuted.copyWith(color: palette.subtle),
        labelStyle: type.bodyMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.danger, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.primary,
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelStyle: type.label.copyWith(color: palette.ink),
        secondaryLabelStyle: type.label.copyWith(color: palette.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        showCheckmark: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        showDragHandle: true,
        dragHandleColor: palette.borderStrong,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: type.h2,
        contentTextStyle: type.bodyMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: type.body.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.onPrimary;
          }
          return palette.subtle;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return palette.surfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return palette.borderStrong;
        }),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primary,
        selectionColor: palette.primarySoft,
        selectionHandleColor: palette.primary,
      ),
    );
  }

  /// Zomato light theme — red on white.
  static ThemeData get light => build(FoodiePalette.light);

  /// Zomato dark theme — red on near-black, composed for dark surfaces
  /// rather than inverted from the light one.
  static ThemeData get dark => build(FoodiePalette.dark);
}
