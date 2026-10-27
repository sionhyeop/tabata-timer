import 'package:flutter/material.dart';

import '../models/interval_step.dart';

/// Design tokens. See docs/PLANNING.md §7.
///
/// A cool palette built around the app icon's indigo → azure → aqua
/// gradient. These colors are the same in light and dark mode; the
/// neutrals that change live in [AppPalette].
abstract final class AppColors {
  static const accentDeep = Color(0xFF5457FF);
  static const accent = Color(0xFF3D7BFF);
  static const accentAlt = Color(0xFF1FC7E9);

  static const prepare = Color(0xFF8B5CF6);
  static const work = accent;
  static const rest = Color(0xFF14B8A6);
  static const setRest = Color(0xFF0EA5E9);
  static const warmCool = Color(0xFF64748B);

  static const accentGradient = LinearGradient(colors: [accentDeep, accent, accentAlt]);

  /// Effort scale, light → max (mint → sky → azure → indigo → violet).
  /// Used by the intensity meter and the post-workout rating.
  static const intensityRamp = [
    Color(0xFF2DD4BF),
    Color(0xFF38BDF8),
    Color(0xFF3D7BFF),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static Color phase(Phase phase) => switch (phase) {
    Phase.prepare => prepare,
    Phase.work => work,
    Phase.rest => rest,
    Phase.setRest => setRest,
    Phase.warmup || Phase.cooldown => warmCool,
  };
}

/// Backgrounds, text and lines for one appearance: a navy-tinted dark, or
/// a soft slate light that stays clear of pure white.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.navBar,
    required this.border,
    required this.grayButton,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.cardCaption,
    required this.scrim,
    required this.glow,
  });

  static const dark = AppPalette(
    bg: Color(0xFF0E1117),
    surface: Color(0xFF171B24),
    surfaceHigh: Color(0xFF232A38),
    navBar: Color(0xFF12161E),
    border: Color(0xFF283042),
    grayButton: Color(0xFF3A4256),
    textPrimary: Color(0xFFF1F4FA),
    textSecondary: Color(0xFF98A1B5),
    textTertiary: Color(0xFF5E6679),
    cardCaption: Color(0xFFC6CCDA),
    scrim: Color(0xB3000000),
    glow: 1,
  );

  static const light = AppPalette(
    bg: Color(0xFFE4E8EF),
    surface: Color(0xFFF0F2F6),
    surfaceHigh: Color(0xFFDFE3EB),
    navBar: Color(0xFFEBEEF3),
    border: Color(0xFFCDD3DE),
    grayButton: Color(0xFFC9D0DC),
    textPrimary: Color(0xFF161B26),
    textSecondary: Color(0xFF545D70),
    textTertiary: Color(0xFF828A9B),
    cardCaption: Color(0xFF3A4252),
    scrim: Color(0x66000000),
    glow: 0.55,
  );

  final Color bg;

  /// Cards.
  final Color surface;

  /// Chips and buttons inside cards.
  final Color surfaceHigh;
  final Color navBar;
  final Color border;

  /// Secondary buttons (취소) and inactive bars.
  final Color grayButton;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color cardCaption;

  /// Behind dialogs.
  final Color scrim;

  /// Strength of the aurora behind the main screens; light mode keeps it
  /// faint so the screen doesn't turn lavender.
  final double glow;

  static AppPalette of(BuildContext context) => Theme.of(context).extension<AppPalette>()!;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceHigh: mix(surfaceHigh, other.surfaceHigh),
      navBar: mix(navBar, other.navBar),
      border: mix(border, other.border),
      grayButton: mix(grayButton, other.grayButton),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      cardCaption: mix(cardCaption, other.cardCaption),
      scrim: mix(scrim, other.scrim),
      glow: glow + (other.glow - glow) * t,
    );
  }
}
