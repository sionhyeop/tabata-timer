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

enum _Sound { tick, countdown, work, rest, finish }

/// A text-to-speech voice installed on the device.
class TtsVoice {
  const TtsVoice({
    required this.name,
    required this.locale,
    required this.quality,
    required this.networkRequired,
  });

  final String name;
  final String locale;

  /// Platform quality label: iOS default/enhanced/premium, Android
  /// very low … very high.
  final String quality;
  final bool networkRequired;

  /// Higher is more natural. On-device voices win over network ones so cues
  /// never lag or go silent offline.
  int get score {
    final q = switch (quality) {
      'premium' => 50,
      'very high' => 45,
      'enhanced' || 'high' => 35,
      'normal' || 'default' => 20,
      'low' => 10,
      'very low' => 5,
      _ => 15,
    };
    return q - (networkRequired ? 30 : 0) + (locale.toLowerCase() == 'ko-kr' ? 1 : 0);
  }

  String get qualityLabel => switch (quality) {
    'premium' => '프리미엄',
    'enhanced' => '향상됨',
    'very high' => '최고 음질',
    'high' => '고음질',
    _ => '기본',
  };

  static TtsVoice? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name']?.toString();
    final locale = raw['locale']?.toString();
    if (name == null || locale == null) return null;
    return TtsVoice(
      name: name,
      locale: locale,
      quality: raw['quality']?.toString() ?? 'unknown',
      networkRequired: raw['network_required']?.toString() == '1',
    );
  }
}

/// Turns [WorkoutCue]s into beeps, voice and haptics, honoring settings.
/// All audio mixes with other apps so the user's music keeps playing.
class CuePlayer {
  CuePlayer(this._settings, {this.silent = false});

  final SettingsStore _settings;

  /// No platform audio at all (tests).
  final bool silent;

  final Map<_Sound, AudioPool> _pools = {};
  FlutterTts? _tts;
  AudioPlayer? _keepAlive;

  /// The voice setting last applied to the engine ('auto' for best match).
  String? _appliedVoiceKey;

  Future<void> init() async {
    if (silent) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
      for (final sound in _Sound.values) {
        _pools[sound] = await AudioPool.createFromAsset(
          path: 'sounds/${sound.name}.wav',
          maxPlayers: sound == _Sound.tick ? 2 : 3,
        );
      }
    } catch (e) {
      debugPrint('CuePlayer: sound init failed: $e');
    }
    try {
      final tts = FlutterTts();
      await tts.setLanguage('ko-KR');
      // The platform's own default rate reads most naturally.
      await tts.setSpeechRate(0.5);
      await tts.setPitch(1.0);
      await tts.setVolume(1.0);
      if (Platform.isIOS) {
        await tts.setSharedInstance(true);
        // Keep the session up between phrases so background audio survives.
        await tts.autoStopSharedSession(false);
        await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ]);
      }
      _tts = tts;
      await _applyVoice();
      _settings.addListener(_applyVoice);
    } catch (e) {
      debugPrint('CuePlayer: TTS init failed: $e');
    }
  }

  // --- Voices ----------------------------------------------------------------

  /// Korean voices on this device, most natural first.
  Future<List<TtsVoice>> koreanVoices() async {
    final tts = _tts;
    if (tts == null) return const [];
    try {
      final raw = await tts.getVoices;
      final voices = [
        for (final v in (raw as List? ?? const []))
          if (TtsVoice.fromMap(v) case final voice?)
            if (voice.locale.toLowerCase().startsWith('ko')) voice,
      ];
      voices.sort((a, b) => b.score.compareTo(a.score));
      return voices;
    } catch (e) {
      debugPrint('CuePlayer: listing voices failed: $e');
      return const [];
    }
  }

  Future<void> _applyVoice() async {
    final tts = _tts;
    if (tts == null) return;
    final s = _settings.value;
    final key = s.voiceName == null ? 'auto' : '${s.voiceName}|${s.voiceLocale}';
    if (key == _appliedVoiceKey) return;
    _appliedVoiceKey = key;
    var name = s.voiceName;
    var locale = s.voiceLocale;
    if (name == null || locale == null) {
      final best = (await koreanVoices()).firstOrNull;
      if (best == null) return;
      name = best.name;
      locale = best.locale;
    }
    try {
      await tts.setVoice({'name': name, 'locale': locale});
    } catch (e) {
      debugPrint('CuePlayer: setVoice failed: $e');
    }
  }

  /// Speaks a sample with [voice] without changing the setting.
  Future<void> previewVoice(TtsVoice voice) async {
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.stop();
      await tts.setVoice({'name': voice.name, 'locale': voice.locale});
      _appliedVoiceKey = null; // restore the chosen voice on next apply
      await tts.speak('운동 시작! 휴식. 다음은 버피');
    } catch (e) {
      debugPrint('CuePlayer: preview failed: $e');
    }
  }

  // --- Workout session ---------------------------------------------------------

  /// iOS keeps a backgrounded app running only while it plays audio, so a
  /// silent loop holds the session between cues. Android uses a foreground
  /// service instead (see BackgroundSession).
  Future<void> beginWorkout() async {
    await _applyVoice();
    if (silent || !Platform.isIOS) return;
    try {
      final player = _keepAlive ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('sounds/silence.wav'));
    } catch (e) {
      debugPrint('CuePlayer: keep-alive failed: $e');
    }
  }

  Future<void> endWorkout() async {
    try {
      await _keepAlive?.stop();
    } catch (_) {}
  }

  // --- Cues --------------------------------------------------------------------

  /// [muted] silences sound and voice for this workout only; haptics stay.
  void handle(WorkoutCue cue, {required TimerMode mode, bool muted = false}) {
    final settings = _settings.value;
    final s = muted ? settings.copyWith(soundOn: false, voiceOn: false) : settings;
    switch (cue.type) {
      case CueType.tick:
        if (s.soundOn && s.tickOn) _play(_Sound.tick);
      case CueType.countdown:
        if (s.soundOn) _play(_Sound.countdown);
        if (s.vibrationOn) HapticFeedback.selectionClick();
      case CueType.stepStart:
        final step = cue.step!;
        // The interval that just ended closes with a long beep; the voice
        // then says what comes next.
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
          _speak(stepAnnouncement(step, cue.next, mode), afterBeep: s.soundOn && sound != null);
        }
      case CueType.halfway:
        if (s.voiceOn) _speak('절반 지났어요');
      case CueType.oneMinuteLeft:
        if (s.voiceOn) _speak('1분 남았어요');
      case CueType.finished:
        if (s.soundOn) _play(_Sound.finish);
        if (s.vibrationOn) HapticFeedback.heavyImpact();
        if (s.voiceOn) {
          _speak(
            mode == TimerMode.rest ? '휴식 끝. 다음 세트를 시작하세요' : '운동 완료! 수고하셨어요',
            afterBeep: s.soundOn,
          );
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
    // Come in as the long beep fades rather than talking over it.
    Future.delayed(Duration(milliseconds: afterBeep ? 500 : 0), () async {
      try {
        await tts.speak(text);
      } catch (e) {
        debugPrint('CuePlayer: speak failed: $e');
      }
    });
  }
}

/// What the voice says when [step] begins. Short, spoken-style phrases read
/// most naturally with on-device TTS.
@visibleForTesting
String stepAnnouncement(IntervalStep step, IntervalStep? next, TimerMode mode) {
  switch (step.phase) {
    case Phase.prepare:
      final first = next?.label;
      return first == null ? '준비하세요' : '준비하세요. 첫 운동은 $first';
    case Phase.warmup:
      return '웜업 시작';
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
      final go = name == null ? '운동 시작' : '$name 시작';
      switch (mode) {
        case TimerMode.amrap:
        case TimerMode.forTime:
          return go;
        case TimerMode.emom:
          final head = step.isLastRound ? '마지막 라운드' : '${step.round}라운드';
          return name == null ? '$head 시작' : '$head. $name';
        case TimerMode.tabata:
        case TimerMode.interval:
        case TimerMode.rest:
          if (step.isLastRound) return '마지막 라운드! $go';
          if (step.round == 1 && step.set > 1) return '${step.set}세트. $go';
          return go;
      }
  }
}
