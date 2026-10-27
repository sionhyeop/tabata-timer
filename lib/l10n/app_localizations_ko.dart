// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Spark Timer';

  @override
  String get tabTimer => '타이머';

  @override
  String get tabRoutines => '루틴';

  @override
  String get tabHistory => '기록';

  @override
  String get tabSettings => '설정';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get close => '닫기';

  @override
  String get edit => '편집';

  @override
  String get duplicate => '복제';

  @override
  String get more => '더보기';

  @override
  String get none => '없음';

  @override
  String get off => '끄기';

  @override
  String get start => '시작';

  @override
  String get systemDefault => '시스템';

  @override
  String get modeTabata => '타바타';

  @override
  String get modeInterval => '인터벌';

  @override
  String get modeEmom => 'EMOM';

  @override
  String get modeAmrap => 'AMRAP';

  @override
  String get modeForTime => 'For Time';

  @override
  String get modeRest => '휴식';

  @override
  String get modeTabataDesc => '20초 고강도 + 10초 휴식 × 8라운드';

  @override
  String get modeIntervalDesc => '웜업·세트·쿨다운까지 자유롭게 구성';

  @override
  String get modeEmomDesc => '매 간격마다 새 라운드를 시작해요';

  @override
  String get modeAmrapDesc => '제한 시간 안에 최대한 많은 라운드';

  @override
  String get modeForTimeDesc => '최대한 빨리 완료하기 · 스톱워치';

  @override
  String get modeRestDesc => '세트 사이 휴식 · 바로 시작';

  @override
  String get phasePrepare => '준비';

  @override
  String get phaseWarmup => '웜업';

  @override
  String get phaseWork => '운동';

  @override
  String get phaseRest => '휴식';

  @override
  String get phaseSetRest => '세트 휴식';

  @override
  String get phaseCooldown => '쿨다운';

  @override
  String get intensityLight => '가볍게';

  @override
  String get intensityModerate => '적당히';

  @override
  String get intensityVigorous => '힘차게';

  @override
  String get intensityHard => '고강도';

  @override
  String get intensityExtreme => '한계 도전';

  @override
  String intensitySemantics(String level, int value) {
    return '예상 강도 $level, 5단계 중 $value단계';
  }

  @override
  String get rpeLight => '가벼워요';

  @override
  String get rpeModerate => '적당해요';

  @override
  String get rpeVigorous => '힘들어요';

  @override
  String get rpeHard => '버거워요';

  @override
  String get rpeExtreme => '한계예요';

  @override
  String get appearanceLight => '라이트';

  @override
  String get appearanceDark => '다크';

  @override
  String get unitMin => '분';

  @override
  String get unitSec => '초';

  @override
  String durationSec(int sec) {
    return '$sec초';
  }

  @override
  String durationMin(int min) {
    return '$min분';
  }

  @override
  String durationMinSec(int min, int sec) {
    return '$min분 $sec초';
  }

  @override
  String durationHour(int hours) {
    return '$hours시간';
  }

  @override
  String durationHourMin(int hours, int min) {
    return '$hours시간 $min분';
  }

  @override
  String kcal(int kcal) {
    return '${kcal}kcal';
  }

  @override
  String rounds(int count) {
    return '$count라운드';
  }

  @override
  String sets(int count) {
    return '$count세트';
  }

  @override
  String laps(int count) {
    return '랩 $count';
  }

  @override
  String everyDuration(String duration) {
    return '$duration마다';
  }

  @override
  String get timeLimit => '제한 시간';

  @override
  String get timeCap => '타임캡';

  @override
  String get noTimeCap => '타임캡 없음';

  @override
  String get fieldRounds => '라운드';

  @override
  String get fieldSets => '세트';

  @override
  String get fieldSetRest => '세트 간 휴식';

  @override
  String get fieldInterval => '간격';

  @override
  String get fieldRestTime => '휴식 시간';

  @override
  String stepDown(String label) {
    return '$label 줄이기';
  }

  @override
  String stepUp(String label) {
    return '$label 늘리기';
  }

  @override
  String valueTapToEdit(String label, String value) {
    return '$label $value, 탭하여 직접 입력';
  }

  @override
  String get noRest => '휴식 없음';

  @override
  String workShare(int percent) {
    return '운동 $percent%';
  }

  @override
  String restShare(int percent) {
    return '휴식 $percent%';
  }

  @override
  String ratioSemantics(int work, int workPercent, int rest, int restPercent, String ratio) {
    return '운동 $work초 $workPercent퍼센트, 휴식 $rest초 $restPercent퍼센트, 비율 $ratio';
  }

  @override
  String get timerGreeting => '오늘도 힘내요';

  @override
  String get saveAsRoutine => '루틴으로 저장';

  @override
  String recentRoutine(String name) {
    return '최근 루틴 · $name';
  }

  @override
  String myRoutineName(String mode) {
    return '나의 $mode';
  }

  @override
  String get savedToRoutines => '루틴에 저장했어요';

  @override
  String get summaryTotal => '총 운동 시간';

  @override
  String get summaryMax => '최대';

  @override
  String get summaryStopwatch => '스톱워치';

  @override
  String get summaryNoLimit => '제한 없음';

  @override
  String get expectedIntensity => '예상 강도';

  @override
  String get routineName => '루틴 이름';

  @override
  String get routineNameExample => '예) 아침 타바타';

  @override
  String routineCount(int count) {
    return '$count개의 루틴';
  }

  @override
  String get myRoutines => '내 루틴';

  @override
  String get noRoutines => '저장된 루틴이 없어요.\n＋ 버튼으로 나만의 루틴을 만들어 보세요.';

  @override
  String get newRoutine => '새 루틴';

  @override
  String get editRoutine => '루틴 편집';

  @override
  String startRoutine(String name) {
    return '$name 시작';
  }

  @override
  String get deleteRoutineTitle => '루틴을 삭제할까요?';

  @override
  String deleteRoutineMessage(String name) {
    return '‘$name’ 루틴이 삭제돼요.';
  }

  @override
  String routineCopyName(String name) {
    return '$name 복사본';
  }

  @override
  String get routineNameHint => '루틴 이름 (예: 아침 타바타)';

  @override
  String get timerType => '타이머 종류';

  @override
  String get noTimeLimit => '시간 제한 없음';

  @override
  String totalDuration(String time) {
    return '총 $time';
  }

  @override
  String get exercisesOptional => '운동 이름 (선택)';

  @override
  String get exercisesHintOpen => '운동 화면에 표시되고 음성으로 안내돼요.';

  @override
  String get exercisesHintRounds => '라운드마다 순서대로 반복돼요. 운동 화면과 음성으로 안내해요.';

  @override
  String get exerciseExample => '예) 버피';

  @override
  String get addExercise => '운동 추가';

  @override
  String get historyTagline => '꾸준함이 실력이에요';

  @override
  String get weekTime => '이번 주 운동 시간';

  @override
  String get recentWorkouts => '최근 운동';

  @override
  String get noHistory => '아직 기록이 없어요.\n첫 운동을 시작해 보세요!';

  @override
  String get today => '오늘';

  @override
  String workoutCount(int count) {
    return '$count회';
  }

  @override
  String streakDays(int count) {
    return '🔥 $count일 연속';
  }

  @override
  String get streakNone => '🔥 0일';

  @override
  String get deleteRecordTitle => '기록을 삭제할까요?';

  @override
  String get stopped => '중단';

  @override
  String finishedIn(String time) {
    return '완료 $time';
  }

  @override
  String rpeTooltip(String label) {
    return '강도 · $label';
  }

  @override
  String weeklyChartSemantics(String summary) {
    return '요일별 운동 시간: $summary';
  }

  @override
  String get sectionSound => '소리와 진동';

  @override
  String get soundEffects => '효과음';

  @override
  String get soundEffectsSub => '카운트다운 비프와 전환음';

  @override
  String get voiceGuide => '음성 안내';

  @override
  String get voiceGuideSub => '“운동”, “휴식, 다음은 버피”처럼 말해줘요';

  @override
  String get tickBeep => '매초 신호음';

  @override
  String get tickBeepSub => '타이머가 도는 동안 1초마다 짧게 삐-';

  @override
  String get voice => '목소리';

  @override
  String get voiceAutoSummary => '자동 · 가장 자연스러운 한국어 목소리';

  @override
  String get vibration => '진동';

  @override
  String get soundTest => '소리 테스트';

  @override
  String get countdownBeeps => '카운트다운 비프';

  @override
  String get countdownBeepsSub => '단계가 끝나기 전 짧은 비프';

  @override
  String get prepareTime => '준비 시간';

  @override
  String get prepareTimeSub => '시작 버튼을 누른 뒤 자세를 잡는 시간';

  @override
  String get halfwayAlert => '절반 알림';

  @override
  String get halfwayAlertSub => '30초 이상 운동에서 절반 지점을 알려줘요';

  @override
  String get sectionDisplay => '화면';

  @override
  String get theme => '테마';

  @override
  String get themeSub => '시스템은 기기의 라이트·다크 설정을 따라가요';

  @override
  String get language => '언어';

  @override
  String get languageSub => '시스템은 기기의 언어 설정을 따라가요';

  @override
  String get keepScreenOn => '운동 중 화면 켜짐 유지';

  @override
  String get keepScreenOnSub => '운동 화면에서만 적용돼요';

  @override
  String get sectionCalories => '칼로리';

  @override
  String get bodyWeight => '체중';

  @override
  String get bodyWeightSub => '소모 칼로리 추정에만 사용해요';

  @override
  String get sectionData => '데이터';

  @override
  String get restorePresets => '기본 루틴 복원';

  @override
  String get restorePresetsSub => '삭제한 기본 루틴을 다시 추가해요';

  @override
  String get presetsAllThere => '모든 기본 루틴이 이미 있어요';

  @override
  String presetsRestored(int count) {
    return '기본 루틴 $count개를 복원했어요';
  }

  @override
  String get clearHistory => '운동 기록 초기화';

  @override
  String get clearHistoryTitle => '모든 기록을 삭제할까요?';

  @override
  String get clearHistoryMessage => '삭제한 기록은 되돌릴 수 없어요.';

  @override
  String get voiceAuto => '자동 (추천)';

  @override
  String get voiceAutoSub => '기기에서 가장 자연스러운 한국어 목소리';

  @override
  String get noVoices => '한국어 음성을 찾지 못했어요. 기기 설정에서 한국어 음성(TTS)을 설치해 주세요.';

  @override
  String get voiceTipIos =>
      '더 자연스러운 목소리가 필요하면 설정 › 손쉬운 사용 › 읽기 및 말하기 › 음성 › 한국어에서 ‘향상됨’ 또는 ‘프리미엄’ 음성을 내려받으세요.';

  @override
  String get voiceTipAndroid =>
      '더 자연스러운 목소리가 필요하면 설정 › 일반 › 글자 읽어주기에서 Google 음성 엔진의 한국어 음성 데이터를 설치하세요. (삼성 TTS는 다른 앱에서 쓸 수 없어요)';

  @override
  String get previewVoice => '미리 듣기';

  @override
  String voiceNumber(int number) {
    return '목소리 $number';
  }

  @override
  String voiceOnline(String name) {
    return '$name (온라인)';
  }

  @override
  String get qualityPremium => '프리미엄';

  @override
  String get qualityEnhanced => '향상됨';

  @override
  String get qualityVeryHigh => '최고 음질';

  @override
  String get qualityHigh => '고음질';

  @override
  String get qualityDefault => '기본';

  @override
  String get startingSoon => '곧 시작해요';

  @override
  String noticeRound(int round, int total) {
    return '라운드 $round/$total';
  }

  @override
  String noticeSet(int set, int total) {
    return '세트 $set/$total';
  }

  @override
  String noticeRoundsDone(int count) {
    return '완료 $count라운드';
  }

  @override
  String noticeNext(String what) {
    return '다음 $what';
  }

  @override
  String get noticeLast => '마지막 구간';

  @override
  String get paused => '일시정지';

  @override
  String get pause => '일시정지';

  @override
  String get resume => '재개';

  @override
  String get stopTitle => '운동을 종료할까요?';

  @override
  String get stopMessage => '지금까지 한 운동은 기록에 남아요.';

  @override
  String get stopConfirm => '종료';

  @override
  String get restOver => '휴식 끝!';

  @override
  String get startNextSet => '다음 세트를 시작하세요';

  @override
  String setOf(int set, int total) {
    return '세트 $set / $total';
  }

  @override
  String firstExercise(String name) {
    return '첫 운동 · $name';
  }

  @override
  String get lastRoundExclaim => '마지막 라운드!';

  @override
  String get asFastAsYouCan => '최대한 빠르게';

  @override
  String get keepGoing => '힘내요!';

  @override
  String nextUp(String name) {
    return '다음 · $name';
  }

  @override
  String get catchBreath => '호흡을 가다듬어요';

  @override
  String get warmupSub => '가볍게 몸을 풀어요';

  @override
  String get cooldownSub => '천천히 정리해요';

  @override
  String get untilStart => '시작까지';

  @override
  String setDone(int set) {
    return '세트 $set 완료';
  }

  @override
  String get timeLeft => '남은 시간';

  @override
  String get restLeft => '남은 휴식';

  @override
  String roundOf(int round, int total) {
    return '라운드 $round / $total';
  }

  @override
  String get elapsedTime => '경과 시간';

  @override
  String timeCapAt(String time) {
    return '타임캡 $time';
  }

  @override
  String roundN(int round) {
    return '$round라운드';
  }

  @override
  String get restAgain => '다시 휴식';

  @override
  String get startNow => '바로 시작';

  @override
  String get lap => '랩';

  @override
  String lapN(int number) {
    return '랩 $number';
  }

  @override
  String get done => '완료';

  @override
  String get lastOneFinishStrong => '마지막이에요. 끝까지!';

  @override
  String nextPill(String what) {
    return '다음  ·  $what';
  }

  @override
  String elapsedShort(String time) {
    return '경과 $time';
  }

  @override
  String remainingShort(String time) {
    return '남은 $time';
  }

  @override
  String get previous => '이전';

  @override
  String get next => '다음';

  @override
  String get unmute => '소리 켜기';

  @override
  String get mute => '소리 끄기';

  @override
  String get undoRound => '라운드 취소';

  @override
  String get roundsCounter => '라운드';

  @override
  String get workoutComplete => '운동 완료!';

  @override
  String get stoppedHere => '여기까지 했어요';

  @override
  String get finishTime => '완료 시간';

  @override
  String get workoutTime => '운동 시간';

  @override
  String get kcalEstimated => 'kcal (추정)';

  @override
  String get howHard => '오늘 강도는 어땠나요?';

  @override
  String get logIt => '기록하기';

  @override
  String get voiceGetReady => '준비하세요';

  @override
  String voiceGetReadyFirst(String name) {
    return '준비하세요. 첫 운동은 $name';
  }

  @override
  String get voiceWarmup => '웜업 시작';

  @override
  String get voiceCooldown => '쿨다운. 수고하셨어요';

  @override
  String get voiceSetRest => '세트 휴식';

  @override
  String voiceSetRestNext(int set) {
    return '세트 휴식. 다음은 $set세트';
  }

  @override
  String get voiceRestStart => '휴식 시작';

  @override
  String get voiceRest => '휴식';

  @override
  String voiceRestNext(String name) {
    return '휴식. 다음은 $name';
  }

  @override
  String get voiceGo => '운동 시작';

  @override
  String voiceNameGo(String name) {
    return '$name 시작';
  }

  @override
  String voiceRound(int round) {
    return '$round라운드';
  }

  @override
  String voiceRoundGo(int round) {
    return '$round라운드 시작';
  }

  @override
  String get voiceLastRound => '마지막 라운드';

  @override
  String get voiceLastRoundGo => '마지막 라운드 시작';

  @override
  String voiceLastRoundThen(String go) {
    return '마지막 라운드! $go';
  }

  @override
  String voiceSetThen(int set, String go) {
    return '$set세트. $go';
  }

  @override
  String get voiceHalfway => '절반 지났어요';

  @override
  String get voiceOneMinute => '1분 남았어요';

  @override
  String get voiceRestOver => '휴식 끝. 다음 세트를 시작하세요';

  @override
  String get voiceFinished => '운동 완료! 수고하셨어요';

  @override
  String get voiceSample => '운동 시작! 휴식. 다음은 버피';

  @override
  String get channelName => '운동 진행';

  @override
  String get channelDescription => '운동 중 타이머가 화면 밖에서도 계속 동작해요';

  @override
  String get presetClassic => '클래식 타바타';

  @override
  String get presetHome => '홈트 타바타';

  @override
  String get presetBeginner => '초보자 타바타';

  @override
  String get presetDouble => '더블 타바타';

  @override
  String get presetHiit3030 => 'HIIT 30/30';

  @override
  String get presetCircuit => '전신 서킷';

  @override
  String get presetEmom10 => 'EMOM 10분';

  @override
  String get presetAmrap12 => 'AMRAP 12분';

  @override
  String get presetForTime20 => 'For Time 20분 캡';

  @override
  String get exSquat => '스쿼트';

  @override
  String get exPushUp => '푸시업';

  @override
  String get exBurpee => '버피';

  @override
  String get exJumpingJack => '점핑잭';

  @override
  String get exLunge => '런지';

  @override
  String get exMountainClimber => '마운틴 클라이머';

  @override
  String get exPlank => '플랭크';
}
