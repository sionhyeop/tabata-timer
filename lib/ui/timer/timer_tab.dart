import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/routine_store.dart';
import '../../engine/intensity.dart';
import '../../engine/workout_plan.dart';
import '../../models/timer_mode.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/intensity_meter.dart';
import '../widgets/mode_chips.dart';
import '../widgets/work_rest_card.dart';
import '../workout/launch.dart';

/// Home: pick a mode, adjust a few numbers, press start.
class TimerTab extends StatelessWidget {
  const TimerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final setup = services.setup;
    final palette = AppPalette.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([setup, services.routines]),
      builder: (context, _) {
        final config = setup.config;
        final recent = services.routines.lastUsed;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ScreenHeader(
                        subtitle: '오늘도 힘내요',
                        title: config.mode.label,
                        trailing: IconButton(
                          tooltip: '루틴으로 저장',
                          onPressed: () => _saveAsRoutine(context, config),
                          icon: const Icon(Icons.bookmark_add_outlined),
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    if (recent != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: GradientBanner(
                          icon: Icons.replay_rounded,
                          label: '최근 루틴 · ${recent.name}',
                          onTap: () => launchWorkout(context, recent, isRoutine: true),
                        ),
                      ),
                    ModeChips(selected: config.mode, onChanged: setup.selectMode),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                      child: Text(
                        config.mode.description,
                        style: TextStyle(color: palette.textSecondary, fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ConfigPanel(config: config, onChanged: setup.update),
                    ),
                    if (config.mode == TimerMode.rest)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: SegmentedPills<int>(
                          options: const [30, 60, 90, 120, 180],
                          selected: config.workSec,
                          labelOf: (s) => s < 60
                              ? '$s초'
                              : (s % 60 == 0 ? '${s ~/ 60}분' : '${s ~/ 60}분 ${s % 60}초'),
                          onChanged: (s) => setup.update(config.copyWith(workSec: s)),
                        ),
                      ),
                    _SummaryCard(config: config),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: PrimaryButton(
                  label: '시작',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => launchWorkout(context, config),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAsRoutine(BuildContext context, WorkoutConfig config) async {
    final routines = AppScope.of(context).routines;
    final name = await showNameSheet(context, initial: '나의 ${config.mode.label}');
    if (name == null || !context.mounted) return;
    routines.save(config.copyWith(id: RoutineStore.newId(), name: name));
    showToast(context, '루틴에 저장했어요');
  }
}

/// Total time next to the expected effort, so the cost of a change to
/// any tile is visible right away.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.config});

  final WorkoutConfig config;

  @override
  Widget build(BuildContext context) {
    final total = workoutDurationSec(config);
    final (label, value) = switch (config.mode) {
      TimerMode.forTime when total == null => ('스톱워치', '제한 없음'),
      TimerMode.forTime => ('최대', formatClock(total!)),
      TimerMode.rest => ('휴식', formatClock(total!)),
      _ => ('총 운동 시간', formatClock(total!)),
    };
    final intensity = estimateIntensity(config);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _Labeled(
                label: label,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ),
            if (intensity != null) ...[
              Container(width: 1, height: 40, color: AppPalette.of(context).border),
              const SizedBox(width: 16),
              Expanded(
                child: _Labeled(
                  label: '예상 강도',
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: IntensityMeter(level: intensity),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppPalette.of(context).textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ],
    );
  }
}

/// Bottom sheet with a single text field. Returns the trimmed name.
Future<String?> showNameSheet(BuildContext context, {required String initial}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _NameSheet(initial: initial),
  );
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.initial});

  final String initial;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '루틴 이름',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 30,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: '예) 아침 타바타', counterText: ''),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: '저장', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
