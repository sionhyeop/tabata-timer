import '../models/interval_step.dart';

/// Rough MET values: vigorous calisthenics / HIIT while working, light
/// activity while recovering. The get-ready countdown is not counted.
const _met = {
  Phase.work: 8.0,
  Phase.rest: 3.0,
  Phase.setRest: 3.0,
  Phase.warmup: 4.0,
  Phase.cooldown: 3.0,
};

/// kcal = MET × kg × hours, summed over phases.
int estimateKcal(Map<Phase, int> phaseMs, int weightKg) {
  var kcal = 0.0;
  phaseMs.forEach((phase, ms) {
    kcal += (_met[phase] ?? 0) * weightKg * ms / 3600000;
  });
  return kcal.round();
}
