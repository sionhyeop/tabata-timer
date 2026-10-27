import 'package:intl/intl.dart';

/// `m:ss`, or `h:mm:ss` from one hour.
String formatClock(int totalSec) {
  if (totalSec < 0) totalSec = 0;
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  final s = totalSec % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

/// Remaining time rounds up so a 20s step shows 20 → 1, never 0.
String formatRemainingMs(int ms) => formatClock((ms / 1000).ceil());

String formatElapsedMs(int ms) => formatClock(ms ~/ 1000);

/// `m:ss.d` for lap splits.
String formatLapMs(int ms) => '${formatClock(ms ~/ 1000)}.${(ms % 1000) ~/ 100}';

/// Short weekday for chart columns: "월" / "Mon".
String weekdayLabel(DateTime d, String locale) => DateFormat.E(locale).format(d);

/// "10월 25일 (토)" / "Sat, Oct 25".
String formatDateLabel(DateTime d, String locale) => DateFormat.MMMEd(locale).format(d);

/// "오후 9:30" / "9:30 PM".
String formatTimeOfDay(DateTime d, String locale) => DateFormat.jm(locale).format(d);

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
