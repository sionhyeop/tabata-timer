/// Labels and descriptions live in l10n.dart.
enum TimerMode {
  tabata,
  interval,
  emom,
  amrap,
  forTime,
  rest;

  static TimerMode fromName(String? name) =>
      TimerMode.values.firstWhere((m) => m.name == name, orElse: () => TimerMode.tabata);
}
