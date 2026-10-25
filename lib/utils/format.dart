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

/// Human duration like "1시간 5분", "12분", "40초".
String formatMinutesLabel(int totalSec) {
  if (totalSec < 60) return '$totalSec초';
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  if (h == 0) return '$m분';
  return m == 0 ? '$h시간' : '$h시간 $m분';
}

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String weekdayLabel(DateTime d) => _weekdays[d.weekday - 1];

/// "10월 25일 (토)"
String formatDateLabel(DateTime d) => '${d.month}월 ${d.day}일 (${weekdayLabel(d)})';

/// "오후 9:30"
String formatTimeOfDay(DateTime d) {
  final pm = d.hour >= 12;
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${pm ? '오후' : '오전'} $h12:${d.minute.toString().padLeft(2, '0')}';
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
