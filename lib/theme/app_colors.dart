import 'package:flutter/material.dart';

import '../models/interval_step.dart';

/// Design tokens. See docs/PLANNING.md §7.
abstract final class AppColors {
  static const bg = Color(0xFF111216);
  static const surface = Color(0xFF1C1D23);
  static const surfaceHigh = Color(0xFF272930);
  static const navBar = Color(0xFF17181D);
  static const border = Color(0xFF2C2E36);

  static const accent = Color(0xFFF2133C);
  static const accentOrange = Color(0xFFF5781F);
  static const grayButton = Color(0xFF4A4E59);

  static const textPrimary = Color(0xFFF2F3F5);
  static const textSecondary = Color(0xFF9A9DA6);
  static const textTertiary = Color(0xFF62656F);

  static const prepare = Color(0xFFF5A524);
  static const work = accent;
  static const rest = Color(0xFF12B76A);
  static const setRest = Color(0xFF3D8BFD);
  static const warmCool = Color(0xFF8B5CF6);

  static const accentGradient = LinearGradient(colors: [accent, accentOrange]);

  static Color phase(Phase phase) => switch (phase) {
    Phase.prepare => prepare,
    Phase.work => work,
    Phase.rest => rest,
    Phase.setRest => setRest,
    Phase.warmup || Phase.cooldown => warmCool,
  };
}
