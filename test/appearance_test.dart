import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/app_settings.dart';
import 'package:tabata_timer/theme/app_colors.dart';
import 'package:tabata_timer/theme/app_theme.dart';

import 'widget_test.dart' show pumpApp;

Brightness brightnessAt(WidgetTester tester, Finder finder) =>
    Theme.of(tester.element(finder)).brightness;

void main() {
  group('appearance setting', () {
    test('follows the system by default and round-trips', () {
      expect(const AppSettings().appearance, Appearance.system);
      final s = AppSettings.fromJson(const AppSettings(appearance: Appearance.light).toJson());
      expect(s.appearance, Appearance.light);
    });

    test('stored settings from before the option, or unknown values, follow the system', () {
      expect(AppSettings.fromJson({'soundOn': false}).appearance, Appearance.system);
      expect(AppSettings.fromJson({'appearance': 'sepia'}).appearance, Appearance.system);
    });
  });

  test('each theme carries its own palette', () {
    expect(appDarkTheme.brightness, Brightness.dark);
    expect(appDarkTheme.extension<AppPalette>(), AppPalette.dark);
    expect(appLightTheme.brightness, Brightness.light);
    expect(appLightTheme.extension<AppPalette>(), AppPalette.light);
    expect(appLightTheme.scaffoldBackgroundColor, AppPalette.light.bg);
  });

  testWidgets('settings switch the theme', (tester) async {
    final services = await pumpApp(tester);
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();

    final dark = find.text('다크');
    await tester.scrollUntilVisible(dark, 200);
    await tester.tap(dark);
    await tester.pumpAndSettle();
    expect(services.settings.value.appearance, Appearance.dark);
    expect(brightnessAt(tester, find.text('테마')), Brightness.dark);

    await tester.tap(find.text('라이트'));
    await tester.pumpAndSettle();
    expect(services.settings.value.appearance, Appearance.light);
    expect(brightnessAt(tester, find.text('테마')), Brightness.light);
  });

  testWidgets('the workout screen stays dark in light mode', (tester) async {
    final services = await pumpApp(tester);
    services.settings.update((s) => s.copyWith(appearance: Appearance.light));
    await tester.pumpAndSettle();
    expect(brightnessAt(tester, find.text('시작')), Brightness.light);

    await tester.tap(find.text('시작'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(brightnessAt(tester, find.text('준비')), Brightness.dark);

    await tester.tap(find.byTooltip('종료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('종료'));
    await tester.pumpAndSettle();
  });
}
