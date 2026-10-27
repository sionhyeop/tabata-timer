import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ko')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Spark Timer'**
  String get appTitle;

  /// No description provided for @tabTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get tabTimer;

  /// No description provided for @tabRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get tabRoutines;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDefault;

  /// No description provided for @modeTabata.
  ///
  /// In en, this message translates to:
  /// **'Tabata'**
  String get modeTabata;

  /// No description provided for @modeInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get modeInterval;

  /// No description provided for @modeEmom.
  ///
  /// In en, this message translates to:
  /// **'EMOM'**
  String get modeEmom;

  /// No description provided for @modeAmrap.
  ///
  /// In en, this message translates to:
  /// **'AMRAP'**
  String get modeAmrap;

  /// No description provided for @modeForTime.
  ///
  /// In en, this message translates to:
  /// **'For Time'**
  String get modeForTime;

  /// No description provided for @modeRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get modeRest;

  /// No description provided for @modeTabataDesc.
  ///
  /// In en, this message translates to:
  /// **'20s all-out + 10s rest × 8 rounds'**
  String get modeTabataDesc;

  /// No description provided for @modeIntervalDesc.
  ///
  /// In en, this message translates to:
  /// **'Build your own with warm-up, sets and cool-down'**
  String get modeIntervalDesc;

  /// No description provided for @modeEmomDesc.
  ///
  /// In en, this message translates to:
  /// **'Start a new round at the top of every interval'**
  String get modeEmomDesc;

  /// No description provided for @modeAmrapDesc.
  ///
  /// In en, this message translates to:
  /// **'As many rounds as possible within the time limit'**
  String get modeAmrapDesc;

  /// No description provided for @modeForTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Finish as fast as you can · stopwatch'**
  String get modeForTimeDesc;

  /// No description provided for @modeRestDesc.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets · starts right away'**
  String get modeRestDesc;

  /// No description provided for @phasePrepare.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get phasePrepare;

  /// No description provided for @phaseWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get phaseWarmup;

  /// No description provided for @phaseWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get phaseWork;

  /// No description provided for @phaseRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get phaseRest;

  /// No description provided for @phaseSetRest.
  ///
  /// In en, this message translates to:
  /// **'Set rest'**
  String get phaseSetRest;

  /// No description provided for @phaseCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool-down'**
  String get phaseCooldown;

  /// No description provided for @intensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get intensityLight;

  /// No description provided for @intensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get intensityModerate;

  /// No description provided for @intensityVigorous.
  ///
  /// In en, this message translates to:
  /// **'Vigorous'**
  String get intensityVigorous;

  /// No description provided for @intensityHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get intensityHard;

  /// No description provided for @intensityExtreme.
  ///
  /// In en, this message translates to:
  /// **'All-out'**
  String get intensityExtreme;

  /// No description provided for @intensitySemantics.
  ///
  /// In en, this message translates to:
  /// **'Expected intensity {level}, level {value} of 5'**
  String intensitySemantics(String level, int value);

  /// No description provided for @rpeLight.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get rpeLight;

  /// No description provided for @rpeModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get rpeModerate;

  /// No description provided for @rpeVigorous.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get rpeVigorous;

  /// No description provided for @rpeHard.
  ///
  /// In en, this message translates to:
  /// **'Very hard'**
  String get rpeHard;

  /// No description provided for @rpeExtreme.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get rpeExtreme;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @unitMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMin;

  /// No description provided for @unitSec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get unitSec;

  /// No description provided for @durationSec.
  ///
  /// In en, this message translates to:
  /// **'{sec} sec'**
  String durationSec(int sec);

  /// No description provided for @durationMin.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String durationMin(int min);

  /// No description provided for @durationMinSec.
  ///
  /// In en, this message translates to:
  /// **'{min} min {sec} sec'**
  String durationMinSec(int min, int sec);

  /// No description provided for @durationHour.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String durationHour(int hours);

  /// No description provided for @durationHourMin.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {min} min'**
  String durationHourMin(int hours, int min);

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String kcal(int kcal);

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 round} other{{count} rounds}}'**
  String rounds(int count);

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String sets(int count);

  /// No description provided for @laps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lap} other{{count} laps}}'**
  String laps(int count);

  /// No description provided for @everyDuration.
  ///
  /// In en, this message translates to:
  /// **'Every {duration}'**
  String everyDuration(String duration);

  /// No description provided for @timeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time limit'**
  String get timeLimit;

  /// No description provided for @timeCap.
  ///
  /// In en, this message translates to:
  /// **'Time cap'**
  String get timeCap;

  /// No description provided for @noTimeCap.
  ///
  /// In en, this message translates to:
  /// **'No time cap'**
  String get noTimeCap;

  /// No description provided for @fieldRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get fieldRounds;

  /// No description provided for @fieldSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get fieldSets;

  /// No description provided for @fieldSetRest.
  ///
  /// In en, this message translates to:
  /// **'Set rest'**
  String get fieldSetRest;

  /// No description provided for @fieldInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get fieldInterval;

  /// No description provided for @fieldRestTime.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get fieldRestTime;

  /// No description provided for @stepDown.
  ///
  /// In en, this message translates to:
  /// **'Decrease {label}'**
  String stepDown(String label);

  /// No description provided for @stepUp.
  ///
  /// In en, this message translates to:
  /// **'Increase {label}'**
  String stepUp(String label);

  /// No description provided for @valueTapToEdit.
  ///
  /// In en, this message translates to:
  /// **'{label} {value}, tap to type a value'**
  String valueTapToEdit(String label, String value);

  /// No description provided for @noRest.
  ///
  /// In en, this message translates to:
  /// **'No rest'**
  String get noRest;

  /// No description provided for @workShare.
  ///
  /// In en, this message translates to:
  /// **'Work {percent}%'**
  String workShare(int percent);

  /// No description provided for @restShare.
  ///
  /// In en, this message translates to:
  /// **'Rest {percent}%'**
  String restShare(int percent);

  /// No description provided for @ratioSemantics.
  ///
  /// In en, this message translates to:
  /// **'Work {work} seconds, {workPercent} percent. Rest {rest} seconds, {restPercent} percent. Ratio {ratio}'**
  String ratioSemantics(int work, int workPercent, int rest, int restPercent, String ratio);

  /// No description provided for @timerGreeting.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got this'**
  String get timerGreeting;

  /// No description provided for @saveAsRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get saveAsRoutine;

  /// No description provided for @recentRoutine.
  ///
  /// In en, this message translates to:
  /// **'Recent · {name}'**
  String recentRoutine(String name);

  /// No description provided for @myRoutineName.
  ///
  /// In en, this message translates to:
  /// **'My {mode}'**
  String myRoutineName(String mode);

  /// No description provided for @savedToRoutines.
  ///
  /// In en, this message translates to:
  /// **'Saved to routines'**
  String get savedToRoutines;

  /// No description provided for @summaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get summaryTotal;

  /// No description provided for @summaryMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get summaryMax;

  /// No description provided for @summaryStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get summaryStopwatch;

  /// No description provided for @summaryNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get summaryNoLimit;

  /// No description provided for @expectedIntensity.
  ///
  /// In en, this message translates to:
  /// **'Expected intensity'**
  String get expectedIntensity;

  /// No description provided for @routineName.
  ///
  /// In en, this message translates to:
  /// **'Routine name'**
  String get routineName;

  /// No description provided for @routineNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning tabata'**
  String get routineNameExample;

  /// No description provided for @routineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 routine} other{{count} routines}}'**
  String routineCount(int count);

  /// No description provided for @myRoutines.
  ///
  /// In en, this message translates to:
  /// **'My routines'**
  String get myRoutines;

  /// No description provided for @noRoutines.
  ///
  /// In en, this message translates to:
  /// **'No saved routines yet.\nTap + to make your own.'**
  String get noRoutines;

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get newRoutine;

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get editRoutine;

  /// No description provided for @startRoutine.
  ///
  /// In en, this message translates to:
  /// **'Start {name}'**
  String startRoutine(String name);

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this routine?'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'‘{name}’ will be deleted.'**
  String deleteRoutineMessage(String name);

  /// No description provided for @routineCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} copy'**
  String routineCopyName(String name);

  /// No description provided for @routineNameHint.
  ///
  /// In en, this message translates to:
  /// **'Routine name (e.g. Morning tabata)'**
  String get routineNameHint;

  /// No description provided for @timerType.
  ///
  /// In en, this message translates to:
  /// **'Timer type'**
  String get timerType;

  /// No description provided for @noTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'No time limit'**
  String get noTimeLimit;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total {time}'**
  String totalDuration(String time);

  /// No description provided for @exercisesOptional.
  ///
  /// In en, this message translates to:
  /// **'Exercises (optional)'**
  String get exercisesOptional;

  /// No description provided for @exercisesHintOpen.
  ///
  /// In en, this message translates to:
  /// **'Shown on the workout screen and read aloud.'**
  String get exercisesHintOpen;

  /// No description provided for @exercisesHintRounds.
  ///
  /// In en, this message translates to:
  /// **'Repeat in order, one per round. Shown on the workout screen and read aloud.'**
  String get exercisesHintRounds;

  /// No description provided for @exerciseExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Burpees'**
  String get exerciseExample;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @historyTagline.
  ///
  /// In en, this message translates to:
  /// **'Consistency builds strength'**
  String get historyTagline;

  /// No description provided for @weekTime.
  ///
  /// In en, this message translates to:
  /// **'Workout time this week'**
  String get weekTime;

  /// No description provided for @recentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get recentWorkouts;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet.\nStart your first one!'**
  String get noHistory;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @workoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout} other{{count} workouts}}'**
  String workoutCount(int count);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count}-day streak'**
  String streakDays(int count);

  /// No description provided for @streakNone.
  ///
  /// In en, this message translates to:
  /// **'🔥 0 days'**
  String get streakNone;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteRecordTitle;

  /// No description provided for @stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// No description provided for @finishedIn.
  ///
  /// In en, this message translates to:
  /// **'Done in {time}'**
  String finishedIn(String time);

  /// No description provided for @rpeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Effort · {label}'**
  String rpeTooltip(String label);

  /// No description provided for @weeklyChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Workout time by day: {summary}'**
  String weeklyChartSemantics(String summary);

  /// No description provided for @sectionSound.
  ///
  /// In en, this message translates to:
  /// **'Sound & vibration'**
  String get sectionSound;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsSub.
  ///
  /// In en, this message translates to:
  /// **'Countdown beeps and transitions'**
  String get soundEffectsSub;

  /// No description provided for @voiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance'**
  String get voiceGuide;

  /// No description provided for @voiceGuideSub.
  ///
  /// In en, this message translates to:
  /// **'Says things like “Go” and “Rest. Next up, burpees”'**
  String get voiceGuideSub;

  /// No description provided for @tickBeep.
  ///
  /// In en, this message translates to:
  /// **'Beep every second'**
  String get tickBeep;

  /// No description provided for @tickBeepSub.
  ///
  /// In en, this message translates to:
  /// **'A short beep each second while the timer runs'**
  String get tickBeepSub;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @voiceAutoSummary.
  ///
  /// In en, this message translates to:
  /// **'Auto · the most natural English voice'**
  String get voiceAutoSummary;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @soundTest.
  ///
  /// In en, this message translates to:
  /// **'Test sound'**
  String get soundTest;

  /// No description provided for @countdownBeeps.
  ///
  /// In en, this message translates to:
  /// **'Countdown beeps'**
  String get countdownBeeps;

  /// No description provided for @countdownBeepsSub.
  ///
  /// In en, this message translates to:
  /// **'Short beeps before each interval ends'**
  String get countdownBeepsSub;

  /// No description provided for @prepareTime.
  ///
  /// In en, this message translates to:
  /// **'Get-ready time'**
  String get prepareTime;

  /// No description provided for @prepareTimeSub.
  ///
  /// In en, this message translates to:
  /// **'Time to get into position after pressing start'**
  String get prepareTimeSub;

  /// No description provided for @halfwayAlert.
  ///
  /// In en, this message translates to:
  /// **'Halfway alert'**
  String get halfwayAlert;

  /// No description provided for @halfwayAlertSub.
  ///
  /// In en, this message translates to:
  /// **'Calls out the halfway point of intervals 30s or longer'**
  String get halfwayAlertSub;

  /// No description provided for @sectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get sectionDisplay;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSub.
  ///
  /// In en, this message translates to:
  /// **'System follows your device\'s light or dark setting'**
  String get themeSub;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSub.
  ///
  /// In en, this message translates to:
  /// **'System follows your device\'s language'**
  String get languageSub;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on during workouts'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnSub.
  ///
  /// In en, this message translates to:
  /// **'Applies to the workout screen only'**
  String get keepScreenOnSub;

  /// No description provided for @sectionCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get sectionCalories;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get bodyWeight;

  /// No description provided for @bodyWeightSub.
  ///
  /// In en, this message translates to:
  /// **'Used only to estimate calories burned'**
  String get bodyWeightSub;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @restorePresets.
  ///
  /// In en, this message translates to:
  /// **'Restore default routines'**
  String get restorePresets;

  /// No description provided for @restorePresetsSub.
  ///
  /// In en, this message translates to:
  /// **'Adds back default routines you deleted'**
  String get restorePresetsSub;

  /// No description provided for @presetsAllThere.
  ///
  /// In en, this message translates to:
  /// **'All default routines are already there'**
  String get presetsAllThere;

  /// No description provided for @presetsRestored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored 1 default routine} other{Restored {count} default routines}}'**
  String presetsRestored(int count);

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear workout history'**
  String get clearHistory;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all records?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted records can\'t be recovered.'**
  String get clearHistoryMessage;

  /// No description provided for @voiceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (recommended)'**
  String get voiceAuto;

  /// No description provided for @voiceAutoSub.
  ///
  /// In en, this message translates to:
  /// **'The most natural English voice on this device'**
  String get voiceAutoSub;

  /// No description provided for @noVoices.
  ///
  /// In en, this message translates to:
  /// **'No English voice found. Install English text-to-speech in your device settings.'**
  String get noVoices;

  /// No description provided for @voiceTipIos.
  ///
  /// In en, this message translates to:
  /// **'For a more natural voice, download an Enhanced or Premium English voice in Settings › Accessibility › Spoken Content › Voices › English.'**
  String get voiceTipIos;

  /// No description provided for @voiceTipAndroid.
  ///
  /// In en, this message translates to:
  /// **'For a more natural voice, install English voice data for the Google speech engine in your device\'s text-to-speech settings. (Samsung TTS isn\'t available to other apps.)'**
  String get voiceTipAndroid;

  /// No description provided for @previewVoice.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewVoice;

  /// No description provided for @voiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Voice {number}'**
  String voiceNumber(int number);

  /// No description provided for @voiceOnline.
  ///
  /// In en, this message translates to:
  /// **'{name} (online)'**
  String voiceOnline(String name);

  /// No description provided for @qualityPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get qualityPremium;

  /// No description provided for @qualityEnhanced.
  ///
  /// In en, this message translates to:
  /// **'Enhanced'**
  String get qualityEnhanced;

  /// No description provided for @qualityVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Highest quality'**
  String get qualityVeryHigh;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High quality'**
  String get qualityHigh;

  /// No description provided for @qualityDefault.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get qualityDefault;

  /// No description provided for @startingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get startingSoon;

  /// No description provided for @noticeRound.
  ///
  /// In en, this message translates to:
  /// **'Round {round}/{total}'**
  String noticeRound(int round, int total);

  /// No description provided for @noticeSet.
  ///
  /// In en, this message translates to:
  /// **'Set {set}/{total}'**
  String noticeSet(int set, int total);

  /// No description provided for @noticeRoundsDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 round done} other{{count} rounds done}}'**
  String noticeRoundsDone(int count);

  /// No description provided for @noticeNext.
  ///
  /// In en, this message translates to:
  /// **'Next {what}'**
  String noticeNext(String what);

  /// No description provided for @noticeLast.
  ///
  /// In en, this message translates to:
  /// **'Last interval'**
  String get noticeLast;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @stopTitle.
  ///
  /// In en, this message translates to:
  /// **'End this workout?'**
  String get stopTitle;

  /// No description provided for @stopMessage.
  ///
  /// In en, this message translates to:
  /// **'What you\'ve done so far will be saved.'**
  String get stopMessage;

  /// No description provided for @stopConfirm.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get stopConfirm;

  /// No description provided for @restOver.
  ///
  /// In en, this message translates to:
  /// **'Rest over!'**
  String get restOver;

  /// No description provided for @startNextSet.
  ///
  /// In en, this message translates to:
  /// **'Start your next set'**
  String get startNextSet;

  /// No description provided for @setOf.
  ///
  /// In en, this message translates to:
  /// **'Set {set} / {total}'**
  String setOf(int set, int total);

  /// No description provided for @firstExercise.
  ///
  /// In en, this message translates to:
  /// **'First up · {name}'**
  String firstExercise(String name);

  /// No description provided for @lastRoundExclaim.
  ///
  /// In en, this message translates to:
  /// **'Last round!'**
  String get lastRoundExclaim;

  /// No description provided for @asFastAsYouCan.
  ///
  /// In en, this message translates to:
  /// **'As fast as you can'**
  String get asFastAsYouCan;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got this!'**
  String get keepGoing;

  /// No description provided for @nextUp.
  ///
  /// In en, this message translates to:
  /// **'Next · {name}'**
  String nextUp(String name);

  /// No description provided for @catchBreath.
  ///
  /// In en, this message translates to:
  /// **'Catch your breath'**
  String get catchBreath;

  /// No description provided for @warmupSub.
  ///
  /// In en, this message translates to:
  /// **'Loosen up gently'**
  String get warmupSub;

  /// No description provided for @cooldownSub.
  ///
  /// In en, this message translates to:
  /// **'Ease off slowly'**
  String get cooldownSub;

  /// No description provided for @untilStart.
  ///
  /// In en, this message translates to:
  /// **'Until start'**
  String get untilStart;

  /// No description provided for @setDone.
  ///
  /// In en, this message translates to:
  /// **'Set {set} done'**
  String setDone(int set);

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get timeLeft;

  /// No description provided for @restLeft.
  ///
  /// In en, this message translates to:
  /// **'Rest left'**
  String get restLeft;

  /// No description provided for @roundOf.
  ///
  /// In en, this message translates to:
  /// **'Round {round} / {total}'**
  String roundOf(int round, int total);

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get elapsedTime;

  /// No description provided for @timeCapAt.
  ///
  /// In en, this message translates to:
  /// **'Time cap {time}'**
  String timeCapAt(String time);

  /// No description provided for @roundN.
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String roundN(int round);

  /// No description provided for @restAgain.
  ///
  /// In en, this message translates to:
  /// **'Rest again'**
  String get restAgain;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get startNow;

  /// No description provided for @lap.
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get lap;

  /// No description provided for @lapN.
  ///
  /// In en, this message translates to:
  /// **'Lap {number}'**
  String lapN(int number);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @lastOneFinishStrong.
  ///
  /// In en, this message translates to:
  /// **'Last one. Finish strong!'**
  String get lastOneFinishStrong;

  /// No description provided for @nextPill.
  ///
  /// In en, this message translates to:
  /// **'Next  ·  {what}'**
  String nextPill(String what);

  /// No description provided for @elapsedShort.
  ///
  /// In en, this message translates to:
  /// **'Elapsed {time}'**
  String elapsedShort(String time);

  /// No description provided for @remainingShort.
  ///
  /// In en, this message translates to:
  /// **'Left {time}'**
  String remainingShort(String time);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get unmute;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Sound off'**
  String get mute;

  /// No description provided for @undoRound.
  ///
  /// In en, this message translates to:
  /// **'Undo round'**
  String get undoRound;

  /// No description provided for @roundsCounter.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get roundsCounter;

  /// No description provided for @workoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete!'**
  String get workoutComplete;

  /// No description provided for @stoppedHere.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what you did'**
  String get stoppedHere;

  /// No description provided for @finishTime.
  ///
  /// In en, this message translates to:
  /// **'Finish time'**
  String get finishTime;

  /// No description provided for @workoutTime.
  ///
  /// In en, this message translates to:
  /// **'Workout time'**
  String get workoutTime;

  /// No description provided for @kcalEstimated.
  ///
  /// In en, this message translates to:
  /// **'kcal (est.)'**
  String get kcalEstimated;

  /// No description provided for @howHard.
  ///
  /// In en, this message translates to:
  /// **'How hard was it today?'**
  String get howHard;

  /// No description provided for @logIt.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get logIt;

  /// No description provided for @voiceGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get voiceGetReady;

  /// No description provided for @voiceGetReadyFirst.
  ///
  /// In en, this message translates to:
  /// **'Get ready. First up, {name}'**
  String voiceGetReadyFirst(String name);

  /// No description provided for @voiceWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm up'**
  String get voiceWarmup;

  /// No description provided for @voiceCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool down. Great work'**
  String get voiceCooldown;

  /// No description provided for @voiceSetRest.
  ///
  /// In en, this message translates to:
  /// **'Set rest'**
  String get voiceSetRest;

  /// No description provided for @voiceSetRestNext.
  ///
  /// In en, this message translates to:
  /// **'Set rest. Next, set {set}'**
  String voiceSetRestNext(int set);

  /// No description provided for @voiceRestStart.
  ///
  /// In en, this message translates to:
  /// **'Rest begins'**
  String get voiceRestStart;

  /// No description provided for @voiceRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get voiceRest;

  /// No description provided for @voiceRestNext.
  ///
  /// In en, this message translates to:
  /// **'Rest. Next up, {name}'**
  String voiceRestNext(String name);

  /// No description provided for @voiceGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get voiceGo;

  /// No description provided for @voiceNameGo.
  ///
  /// In en, this message translates to:
  /// **'{name}, go'**
  String voiceNameGo(String name);

  /// No description provided for @voiceRound.
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String voiceRound(int round);

  /// No description provided for @voiceRoundGo.
  ///
  /// In en, this message translates to:
  /// **'Round {round}, go'**
  String voiceRoundGo(int round);

  /// No description provided for @voiceLastRound.
  ///
  /// In en, this message translates to:
  /// **'Last round'**
  String get voiceLastRound;

  /// No description provided for @voiceLastRoundGo.
  ///
  /// In en, this message translates to:
  /// **'Last round, go'**
  String get voiceLastRoundGo;

  /// No description provided for @voiceLastRoundThen.
  ///
  /// In en, this message translates to:
  /// **'Last round! {go}'**
  String voiceLastRoundThen(String go);

  /// No description provided for @voiceSetThen.
  ///
  /// In en, this message translates to:
  /// **'Set {set}. {go}'**
  String voiceSetThen(int set, String go);

  /// No description provided for @voiceHalfway.
  ///
  /// In en, this message translates to:
  /// **'Halfway there'**
  String get voiceHalfway;

  /// No description provided for @voiceOneMinute.
  ///
  /// In en, this message translates to:
  /// **'One minute left'**
  String get voiceOneMinute;

  /// No description provided for @voiceRestOver.
  ///
  /// In en, this message translates to:
  /// **'Rest over. Start your next set'**
  String get voiceRestOver;

  /// No description provided for @voiceFinished.
  ///
  /// In en, this message translates to:
  /// **'Workout complete! Great job'**
  String get voiceFinished;

  /// No description provided for @voiceSample.
  ///
  /// In en, this message translates to:
  /// **'Go! Rest. Next up, burpees'**
  String get voiceSample;

  /// No description provided for @channelName.
  ///
  /// In en, this message translates to:
  /// **'Workout progress'**
  String get channelName;

  /// No description provided for @channelDescription.
  ///
  /// In en, this message translates to:
  /// **'Keeps the timer running while you\'re away from the screen'**
  String get channelDescription;

  /// No description provided for @presetClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Tabata'**
  String get presetClassic;

  /// No description provided for @presetHome.
  ///
  /// In en, this message translates to:
  /// **'Home Tabata'**
  String get presetHome;

  /// No description provided for @presetBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner Tabata'**
  String get presetBeginner;

  /// No description provided for @presetDouble.
  ///
  /// In en, this message translates to:
  /// **'Double Tabata'**
  String get presetDouble;

  /// No description provided for @presetHiit3030.
  ///
  /// In en, this message translates to:
  /// **'HIIT 30/30'**
  String get presetHiit3030;

  /// No description provided for @presetCircuit.
  ///
  /// In en, this message translates to:
  /// **'Full-body circuit'**
  String get presetCircuit;

  /// No description provided for @presetEmom10.
  ///
  /// In en, this message translates to:
  /// **'EMOM 10 min'**
  String get presetEmom10;

  /// No description provided for @presetAmrap12.
  ///
  /// In en, this message translates to:
  /// **'AMRAP 12 min'**
  String get presetAmrap12;

  /// No description provided for @presetForTime20.
  ///
  /// In en, this message translates to:
  /// **'For Time · 20 min cap'**
  String get presetForTime20;

  /// No description provided for @exSquat.
  ///
  /// In en, this message translates to:
  /// **'Squats'**
  String get exSquat;

  /// No description provided for @exPushUp.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get exPushUp;

  /// No description provided for @exBurpee.
  ///
  /// In en, this message translates to:
  /// **'Burpees'**
  String get exBurpee;

  /// No description provided for @exJumpingJack.
  ///
  /// In en, this message translates to:
  /// **'Jumping jacks'**
  String get exJumpingJack;

  /// No description provided for @exLunge.
  ///
  /// In en, this message translates to:
  /// **'Lunges'**
  String get exLunge;

  /// No description provided for @exMountainClimber.
  ///
  /// In en, this message translates to:
  /// **'Mountain climbers'**
  String get exMountainClimber;

  /// No description provided for @exPlank.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get exPlank;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
