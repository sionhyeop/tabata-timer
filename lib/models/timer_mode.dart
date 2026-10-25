enum TimerMode {
  tabata('타바타', 'TABATA'),
  interval('인터벌', 'HIIT'),
  emom('EMOM', 'EMOM'),
  amrap('AMRAP', 'AMRAP'),
  forTime('For Time', 'FOR TIME'),
  rest('휴식', 'REST');

  const TimerMode(this.label, this.badge);

  final String label;
  final String badge;

  /// Short explanation shown under the mode chips.
  String get description => switch (this) {
    tabata => '20초 고강도 + 10초 휴식 × 8라운드',
    interval => '웜업·세트·쿨다운까지 자유롭게 구성',
    emom => '매 간격마다 새 라운드를 시작해요',
    amrap => '제한 시간 안에 최대한 많은 라운드',
    forTime => '최대한 빨리 완료하기 · 스톱워치',
    rest => '세트 사이 휴식 · 바로 시작',
  };

  static TimerMode fromName(String? name) =>
      TimerMode.values.firstWhere((m) => m.name == name, orElse: () => TimerMode.tabata);
}
