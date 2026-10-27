// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Spark Timer';

  @override
  String get tabTimer => 'Timer';

  @override
  String get tabRoutines => 'Routines';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get more => 'More';

  @override
  String get none => 'None';

  @override
  String get off => 'Off';

  @override
  String get start => 'Start';

  @override
  String get systemDefault => 'System';

  @override
  String get modeTabata => 'Tabata';

  @override
  String get modeInterval => 'Interval';

  @override
  String get modeEmom => 'EMOM';

  @override
  String get modeAmrap => 'AMRAP';

  @override
  String get modeForTime => 'For Time';

  @override
  String get modeRest => 'Rest';

  @override
  String get modeTabataDesc => '20s all-out + 10s rest × 8 rounds';

  @override
  String get modeIntervalDesc => 'Build your own with warm-up, sets and cool-down';

  @override
  String get modeEmomDesc => 'Start a new round at the top of every interval';

  @override
  String get modeAmrapDesc => 'As many rounds as possible within the time limit';

  @override
  String get modeForTimeDesc => 'Finish as fast as you can · stopwatch';

  @override
  String get modeRestDesc => 'Rest between sets · starts right away';

  @override
  String get phasePrepare => 'Get ready';

  @override
  String get phaseWarmup => 'Warm-up';

  @override
  String get phaseWork => 'Work';

  @override
  String get phaseRest => 'Rest';

  @override
  String get phaseSetRest => 'Set rest';

  @override
  String get phaseCooldown => 'Cool-down';

  @override
  String get intensityLight => 'Light';

  @override
  String get intensityModerate => 'Moderate';

  @override
  String get intensityVigorous => 'Vigorous';

  @override
  String get intensityHard => 'Hard';

  @override
  String get intensityExtreme => 'All-out';

  @override
  String intensitySemantics(String level, int value) {
    return 'Expected intensity $level, level $value of 5';
  }

  @override
  String get rpeLight => 'Easy';

  @override
  String get rpeModerate => 'Moderate';

  @override
  String get rpeVigorous => 'Hard';

  @override
  String get rpeHard => 'Very hard';

  @override
  String get rpeExtreme => 'Max';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get unitMin => 'min';

  @override
  String get unitSec => 'sec';

  @override
  String durationSec(int sec) {
    return '$sec sec';
  }

  @override
  String durationMin(int min) {
    return '$min min';
  }

  @override
  String durationMinSec(int min, int sec) {
    return '$min min $sec sec';
  }

  @override
  String durationHour(int hours) {
    return '$hours hr';
  }

  @override
  String durationHourMin(int hours, int min) {
    return '$hours hr $min min';
  }

  @override
  String kcal(int kcal) {
    return '$kcal kcal';
  }

  @override
  String rounds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds',
      one: '1 round',
    );
    return '$_temp0';
  }

  @override
  String sets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String laps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count laps',
      one: '1 lap',
    );
    return '$_temp0';
  }

  @override
  String everyDuration(String duration) {
    return 'Every $duration';
  }

  @override
  String get timeLimit => 'Time limit';

  @override
  String get timeCap => 'Time cap';

  @override
  String get noTimeCap => 'No time cap';

  @override
  String get fieldRounds => 'Rounds';

  @override
  String get fieldSets => 'Sets';

  @override
  String get fieldSetRest => 'Set rest';

  @override
  String get fieldInterval => 'Interval';

  @override
  String get fieldRestTime => 'Rest time';

  @override
  String stepDown(String label) {
    return 'Decrease $label';
  }

  @override
  String stepUp(String label) {
    return 'Increase $label';
  }

  @override
  String valueTapToEdit(String label, String value) {
    return '$label $value, tap to type a value';
  }

  @override
  String get noRest => 'No rest';

  @override
  String workShare(int percent) {
    return 'Work $percent%';
  }

  @override
  String restShare(int percent) {
    return 'Rest $percent%';
  }

  @override
  String ratioSemantics(int work, int workPercent, int rest, int restPercent, String ratio) {
    return 'Work $work seconds, $workPercent percent. Rest $rest seconds, $restPercent percent. Ratio $ratio';
  }

  @override
  String get timerGreeting => 'You\'ve got this';

  @override
  String get saveAsRoutine => 'Save as routine';

  @override
  String recentRoutine(String name) {
    return 'Recent · $name';
  }

  @override
  String myRoutineName(String mode) {
    return 'My $mode';
  }

  @override
  String get savedToRoutines => 'Saved to routines';

  @override
  String get summaryTotal => 'Total time';

  @override
  String get summaryMax => 'Max';

  @override
  String get summaryStopwatch => 'Stopwatch';

  @override
  String get summaryNoLimit => 'No limit';

  @override
  String get expectedIntensity => 'Expected intensity';

  @override
  String get routineName => 'Routine name';

  @override
  String get routineNameExample => 'e.g. Morning tabata';

  @override
  String routineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines',
      one: '1 routine',
    );
    return '$_temp0';
  }

  @override
  String get myRoutines => 'My routines';

  @override
  String get noRoutines => 'No saved routines yet.\nTap + to make your own.';

  @override
  String get newRoutine => 'New routine';

  @override
  String get editRoutine => 'Edit routine';

  @override
  String startRoutine(String name) {
    return 'Start $name';
  }

  @override
  String get deleteRoutineTitle => 'Delete this routine?';

  @override
  String deleteRoutineMessage(String name) {
    return '‘$name’ will be deleted.';
  }

  @override
  String routineCopyName(String name) {
    return '$name copy';
  }

  @override
  String get routineNameHint => 'Routine name (e.g. Morning tabata)';

  @override
  String get timerType => 'Timer type';

  @override
  String get noTimeLimit => 'No time limit';

  @override
  String totalDuration(String time) {
    return 'Total $time';
  }

  @override
  String get exercisesOptional => 'Exercises (optional)';

  @override
  String get exercisesHintOpen => 'Shown on the workout screen and read aloud.';

  @override
  String get exercisesHintRounds =>
      'Repeat in order, one per round. Shown on the workout screen and read aloud.';

  @override
  String get exerciseExample => 'e.g. Burpees';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get historyTagline => 'Consistency builds strength';

  @override
  String get weekTime => 'Workout time this week';

  @override
  String get recentWorkouts => 'Recent workouts';

  @override
  String get noHistory => 'No workouts yet.\nStart your first one!';

  @override
  String get today => 'Today';

  @override
  String workoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String streakDays(int count) {
    return '🔥 $count-day streak';
  }

  @override
  String get streakNone => '🔥 0 days';

  @override
  String get deleteRecordTitle => 'Delete this record?';

  @override
  String get stopped => 'Stopped';

  @override
  String finishedIn(String time) {
    return 'Done in $time';
  }

  @override
  String rpeTooltip(String label) {
    return 'Effort · $label';
  }

  @override
  String weeklyChartSemantics(String summary) {
    return 'Workout time by day: $summary';
  }

  @override
  String get sectionSound => 'Sound & vibration';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsSub => 'Countdown beeps and transitions';

  @override
  String get voiceGuide => 'Voice guidance';

  @override
  String get voiceGuideSub => 'Says things like “Go” and “Rest. Next up, burpees”';

  @override
  String get tickBeep => 'Beep every second';

  @override
  String get tickBeepSub => 'A short beep each second while the timer runs';

  @override
  String get voice => 'Voice';

  @override
  String get voiceAutoSummary => 'Auto · the most natural English voice';

  @override
  String get vibration => 'Vibration';

  @override
  String get soundTest => 'Test sound';

  @override
  String get countdownBeeps => 'Countdown beeps';

  @override
  String get countdownBeepsSub => 'Short beeps before each interval ends';

  @override
  String get prepareTime => 'Get-ready time';

  @override
  String get prepareTimeSub => 'Time to get into position after pressing start';

  @override
  String get halfwayAlert => 'Halfway alert';

  @override
  String get halfwayAlertSub => 'Calls out the halfway point of intervals 30s or longer';

  @override
  String get sectionDisplay => 'Display';

  @override
  String get theme => 'Theme';

  @override
  String get themeSub => 'System follows your device\'s light or dark setting';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'System follows your device\'s language';

  @override
  String get keepScreenOn => 'Keep screen on during workouts';

  @override
  String get keepScreenOnSub => 'Applies to the workout screen only';

  @override
  String get sectionCalories => 'Calories';

  @override
  String get bodyWeight => 'Body weight';

  @override
  String get bodyWeightSub => 'Used only to estimate calories burned';

  @override
  String get sectionData => 'Data';

  @override
  String get restorePresets => 'Restore default routines';

  @override
  String get restorePresetsSub => 'Adds back default routines you deleted';

  @override
  String get presetsAllThere => 'All default routines are already there';

  @override
  String presetsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored $count default routines',
      one: 'Restored 1 default routine',
    );
    return '$_temp0';
  }

  @override
  String get clearHistory => 'Clear workout history';

  @override
  String get clearHistoryTitle => 'Delete all records?';

  @override
  String get clearHistoryMessage => 'Deleted records can\'t be recovered.';

  @override
  String get voiceAuto => 'Auto (recommended)';

  @override
  String get voiceAutoSub => 'The most natural English voice on this device';

  @override
  String get noVoices =>
      'No English voice found. Install English text-to-speech in your device settings.';

  @override
  String get voiceTipIos =>
      'For a more natural voice, download an Enhanced or Premium English voice in Settings › Accessibility › Spoken Content › Voices › English.';

  @override
  String get voiceTipAndroid =>
      'For a more natural voice, install English voice data for the Google speech engine in your device\'s text-to-speech settings. (Samsung TTS isn\'t available to other apps.)';

  @override
  String get previewVoice => 'Preview';

  @override
  String voiceNumber(int number) {
    return 'Voice $number';
  }

  @override
  String voiceOnline(String name) {
    return '$name (online)';
  }

  @override
  String get qualityPremium => 'Premium';

  @override
  String get qualityEnhanced => 'Enhanced';

  @override
  String get qualityVeryHigh => 'Highest quality';

  @override
  String get qualityHigh => 'High quality';

  @override
  String get qualityDefault => 'Standard';

  @override
  String get startingSoon => 'Starting soon';

  @override
  String noticeRound(int round, int total) {
    return 'Round $round/$total';
  }

  @override
  String noticeSet(int set, int total) {
    return 'Set $set/$total';
  }

  @override
  String noticeRoundsDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds done',
      one: '1 round done',
    );
    return '$_temp0';
  }

  @override
  String noticeNext(String what) {
    return 'Next $what';
  }

  @override
  String get noticeLast => 'Last interval';

  @override
  String get paused => 'Paused';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get stopTitle => 'End this workout?';

  @override
  String get stopMessage => 'What you\'ve done so far will be saved.';

  @override
  String get stopConfirm => 'End';

  @override
  String get restOver => 'Rest over!';

  @override
  String get startNextSet => 'Start your next set';

  @override
  String setOf(int set, int total) {
    return 'Set $set / $total';
  }

  @override
  String firstExercise(String name) {
    return 'First up · $name';
  }

  @override
  String get lastRoundExclaim => 'Last round!';

  @override
  String get asFastAsYouCan => 'As fast as you can';

  @override
  String get keepGoing => 'You\'ve got this!';

  @override
  String nextUp(String name) {
    return 'Next · $name';
  }

  @override
  String get catchBreath => 'Catch your breath';

  @override
  String get warmupSub => 'Loosen up gently';

  @override
  String get cooldownSub => 'Ease off slowly';

  @override
  String get untilStart => 'Until start';

  @override
  String setDone(int set) {
    return 'Set $set done';
  }

  @override
  String get timeLeft => 'Time left';

  @override
  String get restLeft => 'Rest left';

  @override
  String roundOf(int round, int total) {
    return 'Round $round / $total';
  }

  @override
  String get elapsedTime => 'Elapsed';

  @override
  String timeCapAt(String time) {
    return 'Time cap $time';
  }

  @override
  String roundN(int round) {
    return 'Round $round';
  }

  @override
  String get restAgain => 'Rest again';

  @override
  String get startNow => 'Start now';

  @override
  String get lap => 'Lap';

  @override
  String lapN(int number) {
    return 'Lap $number';
  }

  @override
  String get done => 'Done';

  @override
  String get lastOneFinishStrong => 'Last one. Finish strong!';

  @override
  String nextPill(String what) {
    return 'Next  ·  $what';
  }

  @override
  String elapsedShort(String time) {
    return 'Elapsed $time';
  }

  @override
  String remainingShort(String time) {
    return 'Left $time';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get unmute => 'Sound on';

  @override
  String get mute => 'Sound off';

  @override
  String get undoRound => 'Undo round';

  @override
  String get roundsCounter => 'Rounds';

  @override
  String get workoutComplete => 'Workout complete!';

  @override
  String get stoppedHere => 'Here\'s what you did';

  @override
  String get finishTime => 'Finish time';

  @override
  String get workoutTime => 'Workout time';

  @override
  String get kcalEstimated => 'kcal (est.)';

  @override
  String get howHard => 'How hard was it today?';

  @override
  String get logIt => 'Save';

  @override
  String get voiceGetReady => 'Get ready';

  @override
  String voiceGetReadyFirst(String name) {
    return 'Get ready. First up, $name';
  }

  @override
  String get voiceWarmup => 'Warm up';

  @override
  String get voiceCooldown => 'Cool down. Great work';

  @override
  String get voiceSetRest => 'Set rest';

  @override
  String voiceSetRestNext(int set) {
    return 'Set rest. Next, set $set';
  }

  @override
  String get voiceRestStart => 'Rest begins';

  @override
  String get voiceRest => 'Rest';

  @override
  String voiceRestNext(String name) {
    return 'Rest. Next up, $name';
  }

  @override
  String get voiceGo => 'Go';

  @override
  String voiceNameGo(String name) {
    return '$name, go';
  }

  @override
  String voiceRound(int round) {
    return 'Round $round';
  }

  @override
  String voiceRoundGo(int round) {
    return 'Round $round, go';
  }

  @override
  String get voiceLastRound => 'Last round';

  @override
  String get voiceLastRoundGo => 'Last round, go';

  @override
  String voiceLastRoundThen(String go) {
    return 'Last round! $go';
  }

  @override
  String voiceSetThen(int set, String go) {
    return 'Set $set. $go';
  }

  @override
  String get voiceHalfway => 'Halfway there';

  @override
  String get voiceOneMinute => 'One minute left';

  @override
  String get voiceRestOver => 'Rest over. Start your next set';

  @override
  String get voiceFinished => 'Workout complete! Great job';

  @override
  String get voiceSample => 'Go! Rest. Next up, burpees';

  @override
  String get channelName => 'Workout progress';

  @override
  String get channelDescription => 'Keeps the timer running while you\'re away from the screen';

  @override
  String get presetClassic => 'Classic Tabata';

  @override
  String get presetHome => 'Home Tabata';

  @override
  String get presetBeginner => 'Beginner Tabata';

  @override
  String get presetDouble => 'Double Tabata';

  @override
  String get presetHiit3030 => 'HIIT 30/30';

  @override
  String get presetCircuit => 'Full-body circuit';

  @override
  String get presetEmom10 => 'EMOM 10 min';

  @override
  String get presetAmrap12 => 'AMRAP 12 min';

  @override
  String get presetForTime20 => 'For Time · 20 min cap';

  @override
  String get exSquat => 'Squats';

  @override
  String get exPushUp => 'Push-ups';

  @override
  String get exBurpee => 'Burpees';

  @override
  String get exJumpingJack => 'Jumping jacks';

  @override
  String get exLunge => 'Lunges';

  @override
  String get exMountainClimber => 'Mountain climbers';

  @override
  String get exPlank => 'Plank';
}
