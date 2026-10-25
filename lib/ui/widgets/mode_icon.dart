import 'package:flutter/material.dart';

import '../../models/timer_mode.dart';

IconData modeIcon(TimerMode mode) => switch (mode) {
  TimerMode.tabata => Icons.local_fire_department_rounded,
  TimerMode.interval => Icons.repeat_rounded,
  TimerMode.emom => Icons.av_timer_rounded,
  TimerMode.amrap => Icons.all_inclusive_rounded,
  TimerMode.forTime => Icons.flag_rounded,
  TimerMode.rest => Icons.hourglass_bottom_rounded,
};
