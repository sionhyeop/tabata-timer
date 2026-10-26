class AppSettings {
  const AppSettings({
    this.soundOn = true,
    this.voiceOn = true,
    this.vibrationOn = true,
    this.countdownBeeps = 3,
    this.halfwayAlert = true,
    this.prepareSec = 5,
    this.keepScreenOn = true,
    this.weightKg = 65,
    this.tickOn = true,
    this.voiceName,
    this.voiceLocale,
  });

  /// Bumped when a default changes in a way stored settings should follow.
  static const schemaVersion = 2;

  final bool soundOn;
  final bool voiceOn;
  final bool vibrationOn;

  /// Beeps before a step ends: 0 (off), 3 or 5.
  final int countdownBeeps;
  final bool halfwayAlert;

  /// Get-ready countdown before the first step: 0, 5, 10 or 15.
  final int prepareSec;
  final bool keepScreenOn;

  /// Used only for the calorie estimate.
  final int weightKg;

  /// A soft beep every second while the timer runs.
  final bool tickOn;

  /// Chosen TTS voice; null picks the best Korean voice on the device.
  final String? voiceName;
  final String? voiceLocale;

  AppSettings copyWith({
    bool? soundOn,
    bool? voiceOn,
    bool? vibrationOn,
    int? countdownBeeps,
    bool? halfwayAlert,
    int? prepareSec,
    bool? keepScreenOn,
    int? weightKg,
    bool? tickOn,
    (String, String)? voice,
    bool clearVoice = false,
  }) => AppSettings(
    soundOn: soundOn ?? this.soundOn,
    voiceOn: voiceOn ?? this.voiceOn,
    vibrationOn: vibrationOn ?? this.vibrationOn,
    countdownBeeps: countdownBeeps ?? this.countdownBeeps,
    halfwayAlert: halfwayAlert ?? this.halfwayAlert,
    prepareSec: prepareSec ?? this.prepareSec,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    weightKg: weightKg ?? this.weightKg,
    tickOn: tickOn ?? this.tickOn,
    voiceName: clearVoice ? null : (voice?.$1 ?? voiceName),
    voiceLocale: clearVoice ? null : (voice?.$2 ?? voiceLocale),
  );

  Map<String, dynamic> toJson() => {
    'soundOn': soundOn,
    'voiceOn': voiceOn,
    'vibrationOn': vibrationOn,
    'countdownBeeps': countdownBeeps,
    'halfwayAlert': halfwayAlert,
    'prepareSec': prepareSec,
    'keepScreenOn': keepScreenOn,
    'weightKg': weightKg,
    'tickOn': tickOn,
    'voiceName': voiceName,
    'voiceLocale': voiceLocale,
    'schema': schemaVersion,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const d = AppSettings();
    final schema = json['schema'] as int? ?? 1;
    var prepareSec = json['prepareSec'] as int? ?? d.prepareSec;
    // v1 defaulted to 10s, which proved too long; move untouched values.
    if (schema < 2 && prepareSec == 10) prepareSec = d.prepareSec;
    return AppSettings(
      soundOn: json['soundOn'] as bool? ?? d.soundOn,
      voiceOn: json['voiceOn'] as bool? ?? d.voiceOn,
      vibrationOn: json['vibrationOn'] as bool? ?? d.vibrationOn,
      countdownBeeps: json['countdownBeeps'] as int? ?? d.countdownBeeps,
      halfwayAlert: json['halfwayAlert'] as bool? ?? d.halfwayAlert,
      prepareSec: prepareSec,
      keepScreenOn: json['keepScreenOn'] as bool? ?? d.keepScreenOn,
      weightKg: json['weightKg'] as int? ?? d.weightKg,
      tickOn: json['tickOn'] as bool? ?? d.tickOn,
      voiceName: json['voiceName'] as String?,
      voiceLocale: json['voiceLocale'] as String?,
    );
  }
}
