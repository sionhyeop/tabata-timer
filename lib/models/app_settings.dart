class AppSettings {
  const AppSettings({
    this.soundOn = true,
    this.voiceOn = true,
    this.vibrationOn = true,
    this.countdownBeeps = 3,
    this.halfwayAlert = true,
    this.prepareSec = 10,
    this.keepScreenOn = true,
    this.weightKg = 65,
  });

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

  AppSettings copyWith({
    bool? soundOn,
    bool? voiceOn,
    bool? vibrationOn,
    int? countdownBeeps,
    bool? halfwayAlert,
    int? prepareSec,
    bool? keepScreenOn,
    int? weightKg,
  }) => AppSettings(
    soundOn: soundOn ?? this.soundOn,
    voiceOn: voiceOn ?? this.voiceOn,
    vibrationOn: vibrationOn ?? this.vibrationOn,
    countdownBeeps: countdownBeeps ?? this.countdownBeeps,
    halfwayAlert: halfwayAlert ?? this.halfwayAlert,
    prepareSec: prepareSec ?? this.prepareSec,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    weightKg: weightKg ?? this.weightKg,
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
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const d = AppSettings();
    return AppSettings(
      soundOn: json['soundOn'] as bool? ?? d.soundOn,
      voiceOn: json['voiceOn'] as bool? ?? d.voiceOn,
      vibrationOn: json['vibrationOn'] as bool? ?? d.vibrationOn,
      countdownBeeps: json['countdownBeeps'] as int? ?? d.countdownBeeps,
      halfwayAlert: json['halfwayAlert'] as bool? ?? d.halfwayAlert,
      prepareSec: json['prepareSec'] as int? ?? d.prepareSec,
      keepScreenOn: json['keepScreenOn'] as bool? ?? d.keepScreenOn,
      weightKg: json['weightKg'] as int? ?? d.weightKg,
    );
  }
}
