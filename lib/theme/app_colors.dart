import 'package:flutter/material.dart';

import '../models/interval_step.dart';

/// Design tokens. See docs/PLANNING.md §7.
///
/// A cool palette built around the app icon's indigo → azure → aqua
/// gradient, on a navy-tinted dark base.
abstract final class AppColors {
  static const bg = Color(0xFF0E1117);
  static const surface = Color(0xFF171B24);
  static const surfaceHigh = Color(0xFF232A38);
  static const navBar = Color(0xFF12161E);
  static const border = Color(0xFF283042);

  static const accentDeep = Color(0xFF5457FF);
  static const accent = Color(0xFF3D7BFF);
  static const accentAlt = Color(0xFF1FC7E9);
  static const grayButton = Color(0xFF3A4256);

  static const textPrimary = Color(0xFFF1F4FA);
  static const textSecondary = Color(0xFF98A1B5);
  static const textTertiary = Color(0xFF5E6679);
  static const cardCaption = Color(0xFFC6CCDA);

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
