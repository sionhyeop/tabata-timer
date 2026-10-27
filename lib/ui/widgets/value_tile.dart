import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'common.dart';

enum ValueKind { duration, count }

/// One adjustable number on the setup screens.
class ConfigField {
  const ConfigField({
    required this.label,
    required this.kind,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.dot,
    this.zeroLabel,
    this.unit,
  });

  final String label;
  final ValueKind kind;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  /// Phase color shown next to the label.
  final Color? dot;

  /// Shown instead of 0:00, e.g. "없음".
  final String? zeroLabel;

  /// Suffix for counts, e.g. "kg".
  final String? unit;

  /// "20초", "1분 30초", "8", "65kg" — or [zeroLabel].
  String get display {
    if (value == 0 && zeroLabel != null) return zeroLabel!;
    return kind == ValueKind.duration ? formatDurationKo(value) : '$value${unit ?? ''}';
  }

  /// [display] with numbers in [numberStyle] and units smaller and in
  /// [unitColor], so "20초" reads as a big 20 with its unit beside it.
  InlineSpan styledDisplay(TextStyle numberStyle, Color unitColor) {
    final unitStyle = numberStyle.copyWith(
      fontSize: (numberStyle.fontSize ?? 30) * 0.46,
      fontWeight: FontWeight.w700,
      color: unitColor,
    );
    if (value == 0 && zeroLabel != null) return TextSpan(text: zeroLabel, style: numberStyle);
    final parts = kind == ValueKind.duration
        ? durationParts(value)
        : [(text: '$value', isUnit: false), if (unit != null) (text: '\u2009$unit', isUnit: true)];
    return TextSpan(
      children: [
        for (final p in parts) TextSpan(text: p.text, style: p.isUnit ? unitStyle : numberStyle),
      ],
    );
  }

  int get _up {
    if (kind == ValueKind.count) return value + 1;
    final s = _durationStep(value);
    return (value ~/ s + 1) * s;
  }

  int get _down {
    if (kind == ValueKind.count) return value - 1;
    if (value <= 0) return 0;
    final s = _durationStep(value - 1);
    return ((value - 1) ~/ s) * s;
  }

  /// 5s steps under a minute, 15s under ten minutes, then whole minutes.
  static int _durationStep(int sec) => sec < 60 ? 5 : (sec < 600 ? 15 : 60);

  void increment() => _set(_up);
  void decrement() => _set(_down);

  void _set(int v) {
    final clamped = v.clamp(min, max);
    if (clamped != value) onChanged(clamped);
  }
}

/// Lays fields out two per row as compact [− value +] tiles; a lone field
/// gets the full width and a bigger number.
class ConfigGrid extends StatelessWidget {
  const ConfigGrid({super.key, required this.fields});

  final List<ConfigField> fields;

  @override
  Widget build(BuildContext context) {
    if (fields.length == 1) return ValueTile(field: fields.single, large: true);
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i += 2) {
      final hasPair = i + 1 < fields.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ValueTile(field: fields[i], compact: true)),
              const SizedBox(width: 10),
              Expanded(
                child: hasPair ? ValueTile(field: fields[i + 1], compact: true) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
      if (hasPair && i + 2 < fields.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

class ValueTile extends StatelessWidget {
  const ValueTile({
    super.key,
    required this.field,
    this.large = false,
    this.bare = false,
    this.compact = false,
  });

  final ConfigField field;
  final bool large;

  /// Value between the − and + buttons on one line, for secondary fields.
  final bool compact;

  /// Content only, for tiles that sit inside a shared card.
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final content = _content(context);
    if (bare) return content;
    return AppCard(padding: EdgeInsets.fromLTRB(16, 14, 16, large ? 18 : 14), child: content);
  }

  Widget _content(BuildContext context) {
    final f = field;
    final palette = AppPalette.of(context);
    final label = Row(
      children: [
        if (f.dot != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: f.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          f.label,
          style: TextStyle(color: palette.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
    final minus = _StepButton(
      icon: Icons.remove,
      label: '${f.label} 줄이기',
      enabled: f.value > f.min,
      onStep: f.decrement,
    );
    final plus = _StepButton(
      icon: Icons.add,
      label: '${f.label} 늘리기',
      enabled: f.value < f.max,
      onStep: f.increment,
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 8),
          Row(
            children: [
              minus,
              Expanded(
                child: Semantics(
                  button: true,
                  label: '${f.label} ${f.display}, 탭하여 직접 입력',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openPicker(context),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text.rich(
                          f.styledDisplay(
                            TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              fontFeatures: tabularFigures,
                              color: palette.textPrimary,
                            ),
                            palette.textSecondary,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              plus,
            ],
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: '${f.label} ${f.display}, 탭하여 직접 입력',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openPicker(context),
            child: SizedBox(
              width: double.infinity,
              // Long values ("10분 30초") shrink rather than wrap.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: large ? Alignment.center : Alignment.centerLeft,
                child: Text.rich(
                  f.styledDisplay(
                    TextStyle(
                      fontSize: large ? 56 : 36,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      fontFeatures: tabularFigures,
                      color: palette.textPrimary,
                    ),
                    palette.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: large ? 14 : 10),
        Row(
          mainAxisAlignment: large ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [minus, if (large) const SizedBox(width: 40), plus],
        ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showValuePicker(context, field);
    if (result != null) field._set(result);
  }
}

/// Round −/+ button; holding it repeats.
class _StepButton extends StatefulWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onStep,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onStep;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  Timer? _repeat;

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  void didUpdateWidget(_StepButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _stopRepeat();
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final palette = AppPalette.of(context);
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onLongPressStart: enabled
            ? (_) {
                HapticFeedback.selectionClick();
                _repeat = Timer.periodic(const Duration(milliseconds: 110), (_) {
                  // Read the latest widget each time; its value changes.
                  if (widget.enabled) widget.onStep();
                });
              }
            : null,
        onLongPressEnd: (_) => _stopRepeat(),
        onLongPressCancel: _stopRepeat,
        child: Material(
          color: palette.surfaceHigh,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    widget.onStep();
                  }
                : null,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                widget.icon,
                size: 22,
                color: enabled ? palette.textPrimary : palette.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wheel picker bottom sheet for typing a value in directly.
Future<int?> showValuePicker(BuildContext context, ConfigField field) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (context) => _PickerSheet(field: field),
  );
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.field});

  final ConfigField field;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late int _minutes = widget.field.value ~/ 60;
  late int _seconds = widget.field.value % 60;
  late int _count = widget.field.value;

  int get _result => widget.field.kind == ValueKind.duration ? _minutes * 60 + _seconds : _count;

  @override
  Widget build(BuildContext context) {
    final f = widget.field;
    final isDuration = f.kind == ValueKind.duration;
    final maxMinutes = f.max ~/ 60;
    final palette = AppPalette.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(f.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                  textTheme: CupertinoTextThemeData(
                    pickerTextStyle: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                child: isDuration
                    ? Row(
                        children: [
                          Expanded(
                            child: _wheel(
                              count: maxMinutes + 1,
                              initial: _minutes,
                              label: (i) => '$i분',
                              onChanged: (i) => _minutes = i,
                            ),
                          ),
                          Expanded(
                            child: _wheel(
                              count: 60,
                              initial: _seconds,
                              label: (i) => '$i초',
                              onChanged: (i) => _seconds = i,
                            ),
                          ),
                        ],
                      )
                    : _wheel(
                        count: f.max - f.min + 1,
                        initial: _count - f.min,
                        label: (i) => '${i + f.min}${f.unit ?? ''}',
                        onChanged: (i) => _count = i + f.min,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(label: '취소', onPressed: () => Navigator.pop(context)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: '확인',
                    onPressed: () => Navigator.pop(context, _result.clamp(f.min, f.max)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wheel({
    required int count,
    required int initial,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: initial.clamp(0, count - 1)),
      itemExtent: 44,
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: AppPalette.of(context).textPrimary.withValues(alpha: 0.13),
      ),
      onSelectedItemChanged: (i) {
        HapticFeedback.selectionClick();
        onChanged(i);
      },
      children: [for (var i = 0; i < count; i++) Center(child: Text(label(i)))],
    );
  }
}
