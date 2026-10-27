// App Store screenshots, one language per run, on a 6.9" iPhone simulator:
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/store_screenshots_test.dart \
//     --dart-define=STORE_LANG=ko -d <iPhone 17 Pro Max>
//
// PNGs land in build/screenshots/store_<lang>_*.png.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/app.dart';
import 'package:tabata_timer/data/app_scope.dart';
import 'package:tabata_timer/data/default_routines.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:tabata_timer/models/app_settings.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_record.dart';
import 'package:tabata_timer/ui/history/history_tab.dart';
import 'package:tabata_timer/ui/widgets/aurora_background.dart';
import 'package:tabata_timer/ui/workout/summary_page.dart';

const _lang = String.fromEnvironment('STORE_LANG', defaultValue: 'ko');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    await tester.pump();
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 100));
    await binding.takeScreenshot('store_${_lang}_$name');
  }

  testWidgets('store screenshots', (tester) async {
    AuroraBackground.motion = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final language = _lang == 'en' ? AppLanguage.en : AppLanguage.ko;
    final s = lookupAppLocalizations(Locale(_lang));
    final services = AppServices(prefs);
    await services.cues.init();
    services.settings.update(
      (x) => x.copyWith(appearance: Appearance.dark, language: language, soundOn: false),
    );

    // A good week: Saturday evening, five sessions since Monday.
    final today = DateTime(2026, 10, 31, 20, 30);
    HistoryTab.clock = () => today;
    final presets = {for (final p in defaultRoutines(s)) p.id: p};
    final week = [
      (5, 4, 8, 3, 'preset-classic'),
      (4, 26, 18, 4, 'preset-circuit'),
      (3, 12, 0, 3, 'preset-amrap12'),
      (2, 9, 16, 5, 'preset-double'),
      (1, 30, 30, 2, 'preset-hiit3030'),
      (0, 4, 8, 4, 'preset-hometraining'),
      (7, 10, 10, 3, 'preset-emom10'),
      (6, 4, 8, 3, 'preset-classic'),
    ];
    for (final (daysAgo, minutes, rounds, rpe, id) in week) {
      final preset = presets[id]!;
      services.history.add(
        WorkoutRecord(
          id: 'seed-$daysAgo',
          name: preset.name,
          mode: preset.mode,
          startedAt: DateTime(today.year, today.month, today.day - daysAgo, 7 + daysAgo * 2, 10),
          activeMs: minutes * 60000,
          completed: true,
          workRounds: rounds,
          amrapRounds: preset.mode == TimerMode.amrap ? 9 : 0,
          rpe: rpe,
          kcal: minutes * 9,
        ),
      );
    }

    await tester.pumpWidget(TabataApp(services: services));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    await shot(tester, '2_timer');

    // The circuit routine, mid-squat, then its rest.
    await tester.tap(find.text(s.tabRoutines));
    await tester.pumpAndSettle();
    await shot(tester, '3_routines');
    await tester.tap(find.bySemanticsLabel(s.startRoutine(presets['preset-hometraining']!.name)));
    await wait(tester, 800);
    await tester.tap(find.byTooltip(s.startNow));
    await wait(tester, 3200);
    await shot(tester, '1_workout');
    await tester.tap(find.byTooltip(s.next));
    await wait(tester, 2600);
    await shot(tester, '4_rest');
    await tester.tap(find.byTooltip(s.stopConfirm));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.stopConfirm).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.tabHistory));
    await tester.pumpAndSettle();
    await shot(tester, '5_history');

    unawaited(
      Navigator.of(tester.element(find.byType(HomeShell))).push(
        MaterialPageRoute<void>(
          builder: (_) => SummaryPage(record: services.history.records.first),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.rpeHard));
    await tester.pumpAndSettle();
    await shot(tester, '6_summary');
    await tester.tap(find.text(s.close));
    await tester.pumpAndSettle();

    services.settings.update((x) => x.copyWith(appearance: Appearance.light));
    await tester.tap(find.text(s.tabTimer).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.modeInterval));
    await tester.pumpAndSettle();
    await shot(tester, '7_light');

    await prefs.clear();
  });
}
