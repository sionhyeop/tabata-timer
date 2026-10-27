import '../l10n/app_localizations.dart';
import '../models/timer_mode.dart';
import '../models/workout_config.dart';

/// Seeded into the Routines tab on first launch, in the app's language.
List<WorkoutConfig> defaultRoutines(AppLocalizations s) => [
  WorkoutConfig(
    id: 'preset-classic',
    name: s.presetClassic,
    mode: TimerMode.tabata,
    workSec: 20,
    restSec: 10,
    rounds: 8,
  ),
  WorkoutConfig(
    id: 'preset-hometraining',
    name: s.presetHome,
    mode: TimerMode.tabata,
    workSec: 20,
    restSec: 10,
    rounds: 8,
    exercises: [s.exSquat, s.exPushUp, s.exBurpee, s.exJumpingJack],
  ),
  WorkoutConfig(
    id: 'preset-beginner',
    name: s.presetBeginner,
    mode: TimerMode.tabata,
    workSec: 20,
    restSec: 20,
    rounds: 6,
  ),
  WorkoutConfig(
    id: 'preset-double',
    name: s.presetDouble,
    mode: TimerMode.tabata,
    workSec: 20,
    restSec: 10,
    rounds: 8,
    sets: 2,
    setRestSec: 60,
  ),
  WorkoutConfig(
    id: 'preset-hiit3030',
    name: s.presetHiit3030,
    mode: TimerMode.interval,
    workSec: 30,
    restSec: 30,
    rounds: 10,
    warmupSec: 60,
    cooldownSec: 60,
  ),
  WorkoutConfig(
    id: 'preset-circuit',
    name: s.presetCircuit,
    mode: TimerMode.interval,
    workSec: 40,
    restSec: 20,
    rounds: 6,
    sets: 3,
    setRestSec: 60,
    exercises: [s.exSquat, s.exPushUp, s.exBurpee, s.exLunge, s.exMountainClimber, s.exPlank],
  ),
  WorkoutConfig(
    id: 'preset-emom10',
    name: s.presetEmom10,
    mode: TimerMode.emom,
    workSec: 60,
    rounds: 10,
  ),
  WorkoutConfig(
    id: 'preset-amrap12',
    name: s.presetAmrap12,
    mode: TimerMode.amrap,
    workSec: 12 * 60,
  ),
  WorkoutConfig(
    id: 'preset-fortime20',
    name: s.presetForTime20,
    mode: TimerMode.forTime,
    workSec: 20 * 60,
  ),
];
