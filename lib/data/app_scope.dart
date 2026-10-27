import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_language.dart';
import '../services/cue_player.dart';
import 'history_store.dart';
import 'routine_store.dart';
import 'settings_store.dart';
import 'timer_setup_store.dart';

class AppServices {
  AppServices._({
    required this.settings,
    required this.language,
    required this.setup,
    required this.routines,
    required this.history,
    required this.cues,
  });

  factory AppServices(SharedPreferences prefs, {bool silent = false}) {
    final settings = SettingsStore(prefs);
    final language = AppLanguageController(settings);
    final routines = RoutineStore(prefs, language.strings)..localizePresets(language.strings);
    language.addListener(() => routines.localizePresets(language.strings));
    return AppServices._(
      settings: settings,
      language: language,
      setup: TimerSetupStore(prefs),
      routines: routines,
      history: HistoryStore(prefs),
      cues: CuePlayer(settings, language, silent: silent),
    );
  }

  final SettingsStore settings;
  final AppLanguageController language;
  final TimerSetupStore setup;
  final RoutineStore routines;
  final HistoryStore history;
  final CuePlayer cues;
}

/// Makes [AppServices] reachable from any widget. The stores are
/// [ChangeNotifier]s; widgets listen with [ListenableBuilder].
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
