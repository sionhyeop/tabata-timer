import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/settings_store.dart';
import '../engine/workout_cue.dart';
import '../l10n/app_localizations.dart';
import '../models/interval_step.dart';
import '../models/timer_mode.dart';
import 'app_language.dart';

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
    final home = const {'ko-kr', 'en-us'}.contains(locale.toLowerCase().replaceAll('_', '-'));
    return q - (networkRequired ? 30 : 0) + (home ? 1 : 0);
  }

  String qualityLabel(AppLocalizations s) => switch (quality) {
    'premium' => s.qualityPremium,
    'enhanced' => s.qualityEnhanced,
    'very high' => s.qualityVeryHigh,
    'high' => s.qualityHigh,
    _ => s.qualityDefault,
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
/// The voice speaks the app's language.
class CuePlayer {
  CuePlayer(this._settings, this._language, {this.silent = false});

  final SettingsStore _settings;
  final AppLanguageController _language;

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
      await tts.setLanguage(_ttsLanguage);
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
      _language.addListener(_onLanguageChanged);
    } catch (e) {
      debugPrint('CuePlayer: TTS init failed: $e');
    }
  }

  // --- Voices ----------------------------------------------------------------

  String get _languageCode => _language.locale.languageCode;

  String get _ttsLanguage => _languageCode == 'ko' ? 'ko-KR' : 'en-US';

  Future<void> _onLanguageChanged() async {
    try {
      await _tts?.setLanguage(_ttsLanguage);
    } catch (e) {
      debugPrint('CuePlayer: setLanguage failed: $e');
    }
    await _applyVoice();
  }

  /// Voices for the app's language on this device, most natural first.
  Future<List<TtsVoice>> voices() async {
    final tts = _tts;
    if (tts == null) return const [];
    try {
      final raw = await tts.getVoices;
      final voices = [
        for (final v in (raw as List? ?? const []))
          if (TtsVoice.fromMap(v) case final voice?)
            if (voice.locale.toLowerCase().startsWith(_languageCode)) voice,
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
    final chosen = _settings.value.voiceFor(_languageCode);
    final key = '$_languageCode|${chosen == null ? 'auto' : '${chosen.name}|${chosen.locale}'}';
    if (key == _appliedVoiceKey) return;
    _appliedVoiceKey = key;
    var name = chosen?.name;
    var locale = chosen?.locale;
    if (name == null || locale == null) {
      final best = (await voices()).firstOrNull;
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
      await tts.speak(_language.strings.voiceSample);
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
    final words = _language.strings;
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
          _speak(
            stepAnnouncement(step, cue.next, mode, words),
            afterBeep: s.soundOn && sound != null,
          );
        }
      case CueType.halfway:
        if (s.voiceOn) _speak(words.voiceHalfway);
      case CueType.oneMinuteLeft:
        if (s.voiceOn) _speak(words.voiceOneMinute);
      case CueType.finished:
        if (s.soundOn) _play(_Sound.finish);
        if (s.vibrationOn) HapticFeedback.heavyImpact();
        if (s.voiceOn) {
          _speak(
            mode == TimerMode.rest ? words.voiceRestOver : words.voiceFinished,
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
    if (s.voiceOn) _speak(_language.strings.voiceGo, afterBeep: s.soundOn);
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
String stepAnnouncement(IntervalStep step, IntervalStep? next, TimerMode mode, AppLocalizations s) {
  switch (step.phase) {
    case Phase.prepare:
      final first = next?.label;
      return first == null ? s.voiceGetReady : s.voiceGetReadyFirst(first);
    case Phase.warmup:
      return s.voiceWarmup;
    case Phase.cooldown:
      return s.voiceCooldown;
    case Phase.setRest:
      return next != null && next.set > 0 ? s.voiceSetRestNext(next.set) : s.voiceSetRest;
    case Phase.rest:
      if (mode == TimerMode.rest) return s.voiceRestStart;
      final upcoming = next?.phase == Phase.work ? next?.label : null;
      return upcoming == null ? s.voiceRest : s.voiceRestNext(upcoming);
    case Phase.work:
      final name = step.label;
      final go = name == null ? s.voiceGo : s.voiceNameGo(name);
      switch (mode) {
        case TimerMode.amrap:
        case TimerMode.forTime:
          return go;
        case TimerMode.emom:
          if (name == null) {
            return step.isLastRound ? s.voiceLastRoundGo : s.voiceRoundGo(step.round);
          }
          final head = step.isLastRound ? s.voiceLastRound : s.voiceRound(step.round);
          return '$head. $name';
        case TimerMode.tabata:
        case TimerMode.interval:
        case TimerMode.rest:
          if (step.isLastRound) return s.voiceLastRoundThen(go);
          if (step.round == 1 && step.set > 1) return s.voiceSetThen(step.set, go);
          return go;
      }
  }
}
