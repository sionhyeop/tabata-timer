import 'package:flutter/widgets.dart';

import '../engine/intensity.dart';
import '../models/app_settings.dart';
import '../models/interval_step.dart';
import '../models/timer_mode.dart';
import '../models/workout_config.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension TimerModeL10n on TimerMode {
  String label(AppLocalizations s) => switch (this) {
    TimerMode.tabata => s.modeTabata,
    TimerMode.interval => s.modeInterval,
    TimerMode.emom => s.modeEmom,
    TimerMode.amrap => s.modeAmrap,
    TimerMode.forTime => s.modeForTime,
    TimerMode.rest => s.modeRest,
  };

  /// Short explanation shown under the mode chips.
  String description(AppLocalizations s) => switch (this) {
    TimerMode.tabata => s.modeTabataDesc,
    TimerMode.interval => s.modeIntervalDesc,
    TimerMode.emom => s.modeEmomDesc,
    TimerMode.amrap => s.modeAmrapDesc,
    TimerMode.forTime => s.modeForTimeDesc,
    TimerMode.rest => s.modeRestDesc,
  };
}

extension PhaseL10n on Phase {
  String label(AppLocalizations s) => switch (this) {
    Phase.prepare => s.phasePrepare,
    Phase.warmup => s.phaseWarmup,
    Phase.work => s.phaseWork,
    Phase.rest => s.phaseRest,
    Phase.setRest => s.phaseSetRest,
    Phase.cooldown => s.phaseCooldown,
  };
}

extension IntensityLevelL10n on IntensityLevel {
  /// How hard a plan looks, e.g. "고강도".
  String label(AppLocalizations s) => switch (this) {
    IntensityLevel.light => s.intensityLight,
    IntensityLevel.moderate => s.intensityModerate,
    IntensityLevel.vigorous => s.intensityVigorous,
    IntensityLevel.hard => s.intensityHard,
    IntensityLevel.extreme => s.intensityExtreme,
  };

  /// How a finished workout felt, e.g. "힘들어요".
  String rpeLabel(AppLocalizations s) => switch (this) {
    IntensityLevel.light => s.rpeLight,
    IntensityLevel.moderate => s.rpeModerate,
    IntensityLevel.vigorous => s.rpeVigorous,
    IntensityLevel.hard => s.rpeHard,
    IntensityLevel.extreme => s.rpeExtreme,
  };
}

extension AppearanceL10n on Appearance {
  String label(AppLocalizations s) => switch (this) {
    Appearance.system => s.systemDefault,
    Appearance.light => s.appearanceLight,
    Appearance.dark => s.appearanceDark,
  };
}

extension AppLanguageL10n on AppLanguage {
  /// Languages are named in themselves so anyone can find their own.
  String label(AppLocalizations s) => switch (this) {
    AppLanguage.system => s.systemDefault,
    AppLanguage.ko => '한국어',
    AppLanguage.en => 'English',
  };
}

/// Exact duration with units: "20초", "1분 30초", "2분" / "20 sec", "1 min 30 sec".
String formatDuration(AppLocalizations s, int sec) {
  final m = sec ~/ 60, rest = sec % 60;
  if (m == 0) return s.durationSec(rest);
  return rest == 0 ? s.durationMin(m) : s.durationMinSec(m, rest);
}

/// [formatDuration] as number and unit pieces, so the two can be styled
/// differently. Units carry a thin leading space; groups are space-separated.
List<({String text, bool isUnit})> durationParts(AppLocalizations s, int sec) {
  final m = sec ~/ 60;
  final rest = sec % 60;
  return [
    if (m > 0) ...[(text: '$m', isUnit: false), (text: ' ${s.unitMin}', isUnit: true)],
    if (m > 0 && rest > 0) (text: ' ', isUnit: true),
    if (rest > 0 || m == 0) ...[
      (text: '$rest', isUnit: false),
      (text: ' ${s.unitSec}', isUnit: true),
    ],
  ];
}

/// Human duration like "1시간 5분", "12분", "40초".
String formatMinutesLabel(AppLocalizations s, int totalSec) {
  if (totalSec < 60) return s.durationSec(totalSec);
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  if (h == 0) return s.durationMin(m);
  return m == 0 ? s.durationHour(h) : s.durationHourMin(h, m);
}

extension WorkoutConfigL10n on WorkoutConfig {
  /// The plan in a few pieces, e.g. (운동, 20초), (휴식, 10초), and the
  /// repeat counts 8라운드 / 2세트 flagged [repeat] so they can be shown
  /// as small "×8라운드" multipliers.
  List<({String label, String value, bool repeat})> summaryParts(AppLocalizations s) {
    String t(int sec) => formatDuration(s, sec);
    return switch (mode) {
      TimerMode.tabata || TimerMode.interval => [
        (label: s.phaseWork, value: t(workSec), repeat: false),
        if (restSec > 0) (label: s.phaseRest, value: t(restSec), repeat: false),
        (label: '', value: s.rounds(rounds), repeat: true),
        if (sets > 1) (label: '', value: s.sets(sets), repeat: true),
      ],
      TimerMode.emom => [
        (label: '', value: s.everyDuration(t(workSec)), repeat: false),
        (label: '', value: s.rounds(rounds), repeat: true),
      ],
      TimerMode.amrap => [(label: s.timeLimit, value: t(workSec), repeat: false)],
      TimerMode.forTime =>
        workSec > 0
            ? [(label: s.timeCap, value: t(workSec), repeat: false)]
            : [(label: '', value: s.noTimeCap, repeat: false)],
      TimerMode.rest => [(label: s.phaseRest, value: t(workSec), repeat: false)],
    };
  }
}
