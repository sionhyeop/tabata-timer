import 'package:flutter/material.dart';

import 'app_colors.dart';

const tabularFigures = [FontFeature.tabularFigures()];

final appDarkTheme = buildAppTheme(AppPalette.dark);
final appLightTheme = buildAppTheme(AppPalette.light);

ThemeData buildAppTheme(AppPalette p) {
  final dark = identical(p, AppPalette.dark);
  final base = ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    useMaterial3: true,
    colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentAlt,
      surface: p.surface,
      onSurface: p.textPrimary,
      error: AppColors.accent,
    ),
    extensions: [p],
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    splashFactory: InkRipple.splashFactory,
    textTheme: base.textTheme.apply(bodyColor: p.textPrimary, displayColor: p.textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) || !dark ? Colors.white : const Color(0xFFBCC3D2),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.accent
            : (dark ? p.surfaceHigh : p.grayButton),
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: p.textTertiary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      // Light mode lifts the menu just above the card it opens from.
      color: dark ? p.surfaceHigh : const Color(0xFFF8F9FB),
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(color: p.textPrimary, fontSize: 15),
    ),
    snackBarTheme: SnackBarThemeData(
      // Inverted in light mode so the toast stands out from the cards.
      backgroundColor: dark ? p.surfaceHigh : const Color(0xFF2A303C),
      contentTextStyle: TextStyle(color: dark ? p.textPrimary : AppPalette.dark.textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceHigh,
      hintStyle: TextStyle(color: p.textTertiary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionHandleColor: AppColors.accent,
    ),
  );
}
