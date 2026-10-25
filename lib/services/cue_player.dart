import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/settings_store.dart';
import '../engine/workout_cue.dart';
import '../models/interval_step.dart';
import '../models/timer_mode.dart';

enum _Sound { countdown, work, rest, finish }

/// Turns [WorkoutCue]s into beeps, voice and haptics, honoring settings.
/// Audio mixes with other apps so the user's music keeps playing.
class CuePlayer {
  CuePlayer(this._settings, {this.silent = false});

  final SettingsStore _settings;

  /// No platform audio at all (tests).
  final bool silent;

  final Map<_Sound, AudioPool> _pools = {};
  FlutterTts? _tts;

  Future<void> init() async {
    if (silent) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
      for (final sound in _Sound.values) {
        _pools[sound] = await AudioPool.createFromAsset(
          path: 'sounds/${sound.name}.wav',
          maxPlayers: 3,
        );
      }
    } catch (e) {
      debugPrint('CuePlayer: sound init failed: $e');
    }
    try {
      final tts = FlutterTts();
      await tts.setLanguage('ko-KR');
      await tts.setSpeechRate(0.55);
      await tts.setVolume(1.0);
      if (Platform.isIOS) {
        await tts.setSharedInstance(true);
        await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ]);
      }
      _tts = tts;
    } catch (e) {
      debugPrint('CuePlayer: TTS init failed: $e');
    }
  }

  /// [muted] silences sound and voice for this workout only; haptics stay.
  void handle(WorkoutCue cue, {required TimerMode mode, bool muted = false}) {
    final settings = _settings.value;
    final s = muted ? settings.copyWith(soundOn: false, voiceOn: false) : settings;
    switch (cue.type) {
      case CueType.countdown:
        if (s.soundOn) _play(_Sound.countdown);
        if (s.vibrationOn) HapticFeedback.selectionClick();
      case CueType.stepStart:
        final step = cue.step!;
        final sound = switch (step.phase) {
          Phase.prepare => null,
          Phase.work => _Sound.work,
          _ => _Sound.rest,
        };
        if (s.soundOn && sound != null) _play(sound);
        if (s.vibrationOn && step.phase != Phase.prepare) {
          HapticFeedback.heavyImpact();
        }
        if (s.voiceOn) {
          _speak(stepAnnouncement(step, cue.next, mode), afterBeep: sound != null);
        }
      case CueType.halfway:
        if (s.voiceOn) _speak('절반 지났어요');
      case CueType.oneMinuteLeft:
        if (s.voiceOn) _speak('1분 남았어요');
      case CueType.finished:
        if (s.soundOn) _play(_Sound.finish);
        if (s.vibrationOn) HapticFeedback.heavyImpact();
        if (s.voiceOn) {
          _speak(mode == TimerMode.rest ? '휴식 끝! 다음 세트를 시작하세요' : '운동 완료! 수고하셨어요', afterBeep: true);
        }
    }
  }

  /// Settings screen "test" button.
  void preview() {
    final s = _settings.value;
    if (s.soundOn) _play(_Sound.work);
    if (s.vibrationOn) HapticFeedback.heavyImpact();
    if (s.voiceOn) _speak('운동 시작', afterBeep: s.soundOn);
  }

  void stopVoice() => _tts?.stop().catchError((_) => null);

  void _play(_Sound sound) {
    final pool = _pools[sound];
    if (pool == null) return;
    unawaited(
      pool.start().then(
        (_) {},
        onError: (Object e) {
          debugPrint('CuePlayer: play failed: $e');
        },
      ),
    );
  }

  void _speak(String text, {bool afterBeep = false}) {
    final tts = _tts;
    if (tts == null) return;
    // Let the start beep ring out before the voice comes in.
    Future.delayed(Duration(milliseconds: afterBeep ? 450 : 0), () async {
      try {
        await tts.speak(text);
      } catch (e) {
        debugPrint('CuePlayer: speak failed: $e');
      }
    });
  }
}

@visibleForTesting
String stepAnnouncement(IntervalStep step, IntervalStep? next, TimerMode mode) {
  switch (step.phase) {
    case Phase.prepare:
      final first = next?.label;
      return first == null ? '준비하세요' : '준비하세요. 첫 운동은 $first';
    case Phase.warmup:
      return '웜업';
    case Phase.cooldown:
      return '쿨다운. 수고하셨어요';
    case Phase.setRest:
      return next != null && next.set > 0 ? '세트 휴식. 다음은 ${next.set}세트' : '세트 휴식';
    case Phase.rest:
      if (mode == TimerMode.rest) return '휴식 시작';
      final upcoming = next?.phase == Phase.work ? next?.label : null;
      return upcoming == null ? '휴식' : '휴식. 다음은 $upcoming';
    case Phase.work:
      final name = step.label;
      switch (mode) {
        case TimerMode.amrap:
        case TimerMode.forTime:
          return name == null ? '시작' : '시작. $name';
        case TimerMode.emom:
          final head = step.isLastRound ? '마지막 라운드' : '${step.round}라운드';
          return name == null ? head : '$head. $name';
        case TimerMode.tabata:
        case TimerMode.interval:
        case TimerMode.rest:
          final what = name ?? '운동';
          if (step.isLastRound) return '마지막 라운드. $what';
          if (step.round == 1 && step.set > 1) return '${step.set}세트 시작. $what';
          return what;
      }
  }
}
