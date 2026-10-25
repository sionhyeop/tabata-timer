enum Phase {
  prepare('준비'),
  warmup('웜업'),
  work('운동'),
  rest('휴식'),
  setRest('세트 휴식'),
  cooldown('쿨다운');

  const Phase(this.label);

  final String label;
}

/// One segment of a workout timeline.
class IntervalStep {
  const IntervalStep({
    required this.phase,
    required this.durationMs,
    this.round = 0,
    this.totalRounds = 0,
    this.set = 0,
    this.totalSets = 0,
    this.label,
    this.countUp = false,
  });

  final Phase phase;

  /// `null` means open-ended (For Time without a cap).
  final int? durationMs;

  /// 1-based; 0 when the step does not belong to a round.
  final int round;
  final int totalRounds;
  final int set;
  final int totalSets;

  /// Exercise name, if the routine names its rounds.
  final String? label;

  /// Display elapsed time instead of remaining time.
  final bool countUp;

  bool get isLastRound => round > 0 && round == totalRounds && set == totalSets;

  IntervalStep copyWith({int? durationMs}) => IntervalStep(
    phase: phase,
    durationMs: durationMs ?? this.durationMs,
    round: round,
    totalRounds: totalRounds,
    set: set,
    totalSets: totalSets,
    label: label,
    countUp: countUp,
  );
}
