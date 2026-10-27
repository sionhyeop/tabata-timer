import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tabata_timer/data/default_routines.dart';
import 'package:tabata_timer/engine/workout_plan.dart';
import 'package:tabata_timer/l10n/l10n.dart';
import 'package:tabata_timer/models/app_settings.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_config.dart';
import 'package:tabata_timer/models/workout_record.dart';
import 'package:tabata_timer/services/app_language.dart';
import 'package:tabata_timer/services/cue_player.dart';
import 'package:tabata_timer/utils/format.dart';

import 'widget_test.dart' show pumpApp;

final en = lookupAppLocalizations(const Locale('en'));
final ko = lookupAppLocalizations(const Locale('ko'));

void main() {
  test('every message is translated', () {
    Set<String> keys(String path) => {
      for (final k in (jsonDecode(File(path).readAsStringSync()) as Map).keys)
        if (!k.toString().startsWith('@')) k.toString(),
    };
    expect(keys('lib/l10n/app_ko.arb'), keys('lib/l10n/app_en.arb'));
  });

  group('app locale', () {
    test('system picks the first language the app speaks, else English', () {
      Locale pick(List<Locale> device) => resolveAppLocale(AppLanguage.system, device);
      expect(pick(const [Locale('ko', 'KR')]), const Locale('ko'));
      expect(pick(const [Locale('ja'), Locale('ko')]), const Locale('ko'));
      expect(pick(const [Locale('en', 'GB')]), const Locale('en'));
      expect(pick(const [Locale('fr', 'FR')]), const Locale('en'));
      expect(pick(const []), const Locale('en'));
    });

    test('an explicit choice wins over the device', () {
      expect(resolveAppLocale(AppLanguage.en, const [Locale('ko')]), const Locale('en'));
      expect(resolveAppLocale(AppLanguage.ko, const [Locale('en')]), const Locale('ko'));
    });

    test('the setting round-trips and defaults to the system', () {
      expect(const AppSettings().language, AppLanguage.system);
      final json = const AppSettings(language: AppLanguage.en).toJson();
      expect(AppSettings.fromJson(json).language, AppLanguage.en);
    });

    test('a chosen voice only applies to its own language', () {
      const s = AppSettings(voiceName: 'Yuna', voiceLocale: 'ko-KR');
      expect(s.voiceFor('ko')?.name, 'Yuna');
      expect(s.voiceFor('en'), isNull);
    });
  });

  group('formatting', () {
    setUpAll(initializeDateFormatting);

    test('durations', () {
      expect(formatDuration(ko, 20), '20초');
      expect(formatDuration(ko, 90), '1분 30초');
      expect(formatDuration(en, 20), '20 sec');
      expect(formatDuration(en, 90), '1 min 30 sec');
      expect(formatDuration(en, 120), '2 min');
      expect(formatMinutesLabel(en, 3900), '1 hr 5 min');
      expect(formatMinutesLabel(ko, 3900), '1시간 5분');
    });

    test('dates and times', () {
      final d = DateTime(2026, 10, 25, 21, 30); // a Sunday
      expect(formatDateLabel(d, 'ko'), '10월 25일 (일)');
      expect(formatTimeOfDay(d, 'ko'), '오후 9:30');
      expect(weekdayLabel(d, 'ko'), '일');
      expect(formatDateLabel(d, 'en'), 'Sun, Oct 25');
      expect(formatTimeOfDay(d, 'en'), matches(RegExp(r'^9:30\sPM$')));
      expect(weekdayLabel(d, 'en'), 'Sun');
    });

    test('routine summary', () {
      final c = WorkoutConfig.defaults(TimerMode.tabata).copyWith(sets: 2);
      expect(
        [for (final p in c.summaryParts(en)) '${p.label}|${p.value}'],
        ['Work|20 sec', 'Rest|10 sec', '|8 rounds', '|2 sets'],
      );
      expect(en.rounds(1), '1 round');
      expect(ko.rounds(8), '8라운드');
    });
  });

  group('voice in English', () {
    test('plain intervals', () {
      final tabata = buildSteps(WorkoutConfig.defaults(TimerMode.tabata));
      expect(stepAnnouncement(tabata[0], tabata[1], TimerMode.tabata, en), 'Go');
      expect(stepAnnouncement(tabata[1], tabata[2], TimerMode.tabata, en), 'Rest');
      expect(stepAnnouncement(tabata.last, null, TimerMode.tabata, en), 'Last round! Go');
    });

    test('circuit with exercise names', () {
      final circuit = WorkoutConfig.defaults(TimerMode.interval)
          .copyWith(rounds: 2, sets: 2, exercises: ['Squats', 'Burpees']);
      final steps = buildSteps(circuit, prepareSec: 10);
      String say(int i) =>
          stepAnnouncement(steps[i], i + 1 < steps.length ? steps[i + 1] : null, circuit.mode, en);
      expect(say(0), 'Get ready. First up, Squats');
      expect(say(1), 'Squats, go');
      expect(say(2), 'Rest. Next up, Burpees');
      expect(say(4), 'Set rest. Next, set 2');
      expect(say(5), 'Set 2. Squats, go');
    });
  });

  // Layout overflows fail the test, so this also checks English fits.
  testWidgets('an English device gets English screens', (tester) async {
    final services = await pumpApp(tester, locale: const Locale('en', 'US'));
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Tabata'), findsWidgets);
    expect(find.text('20\u2009sec'), findsOneWidget);
    expect(find.text('Total time'), findsOneWidget);

    await tester.tap(find.text('Interval'));
    await tester.pumpAndSettle();
    expect(find.text('Set rest'), findsOneWidget);

    await tester.tap(find.text('Routines'));
    await tester.pumpAndSettle();
    expect(find.text('My routines'), findsOneWidget);
    expect(find.text('Classic Tabata'), findsOneWidget);

    final now = DateTime.now();
    for (var day = 0; day < 12; day++) {
      services.history.add(
        WorkoutRecord(
          id: 'r$day',
          name: 'Classic Tabata',
          mode: TimerMode.tabata,
          startedAt: now.subtract(Duration(days: day)),
          activeMs: 240000,
          completed: true,
          workRounds: 8,
          rpe: 3,
          kcal: 36,
        ),
      );
    }
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('🔥 12-day streak'), findsOneWidget);
    expect(find.text('4:00 · 8 rounds · 36 kcal'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Sound effects'), findsOneWidget);
  });

  testWidgets('switching language renames untouched default routines only', (tester) async {
    final services = await pumpApp(tester);
    final routines = services.routines;
    final home = routines.byId('preset-hometraining')!;
    routines.save(routines.byId('preset-classic')!.copyWith(name: '내 타바타'));
    expect(home.name, '홈트 타바타');

    services.settings.update((s) => s.copyWith(language: AppLanguage.en));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    expect(routines.byId('preset-hometraining')!.name, 'Home Tabata');
    expect(routines.byId('preset-hometraining')!.exercises, defaultRoutines(en)[1].exercises);
    expect(routines.byId('preset-classic')!.name, '내 타바타');

    services.settings.update((s) => s.copyWith(language: AppLanguage.ko));
    await tester.pumpAndSettle();
    expect(find.text('시작'), findsOneWidget);
    expect(routines.byId('preset-hometraining')!.name, '홈트 타바타');
  });
}
