import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../engine/intensity.dart';
import '../../engine/workout_plan.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/intensity_meter.dart';
import '../workout/launch.dart';
import 'routine_editor_page.dart';

enum _MenuAction { edit, duplicate, delete }

class RoutinesTab extends StatelessWidget {
  const RoutinesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).routines;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        tooltip: '새 루틴',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => openRoutineEditor(context),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final routines = store.routines;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              children: [
                ScreenHeader(subtitle: '${routines.length}개의 루틴', title: '내 루틴'),
                if (routines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      '저장된 루틴이 없어요.\n＋ 버튼으로 나만의 루틴을 만들어 보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppPalette.of(context).textSecondary, height: 1.5),
                    ),
                  ),
                for (final routine in routines) ...[
                  _RoutineCard(routine: routine),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> openRoutineEditor(BuildContext context, [WorkoutConfig? routine]) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => RoutineEditorPage(initial: routine),
    ),
  );
}

/// Mirrors the alarm cards of the reference: small caption, big number,
/// details below, primary action on the right with a ⋮ menu.
class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine});

  final WorkoutConfig routine;

  @override
  Widget build(BuildContext context) {
    final total = workoutDurationSec(routine);
    final intensity = estimateIntensity(routine);
    final palette = AppPalette.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 14),
      onTap: () => openRoutineEditor(context, routine),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: name and expected effort boxed together, total time
          // beside it, the menu at the far end.
          Row(
            children: [
              // Takes everything but the menu; the name gives way first.
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: _TitleBox(name: routine.name, intensity: intensity),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.timer_outlined, size: 14, color: palette.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      total == null ? '∞' : formatClock(total),
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFeatures: tabularFigures,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_MenuAction>(
                tooltip: '더보기',
                icon: Icon(Icons.more_vert, color: palette.textSecondary, size: 20),
                onSelected: (action) => _onMenu(context, action),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _MenuAction.edit, child: Text('편집')),
                  PopupMenuItem(value: _MenuAction.duplicate, child: Text('복제')),
                  PopupMenuItem(
                    value: _MenuAction.delete,
                    child: Text('삭제', style: TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // The plan, large, with the start button beside it.
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BigSummary(parts: routine.summaryParts),
                      if (routine.exercises.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          routine.exercises.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: palette.textTertiary, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: '${routine.name} 시작',
                child: Material(
                  color: AppColors.accent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => launchWorkout(context, routine, isRoutine: true),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onMenu(BuildContext context, _MenuAction action) async {
    final store = AppScope.of(context).routines;
    switch (action) {
      case _MenuAction.edit:
        await openRoutineEditor(context, routine);
      case _MenuAction.duplicate:
        store.duplicate(routine);
      case _MenuAction.delete:
        final ok = await showConfirmDialog(
          context,
          title: '루틴을 삭제할까요?',
          message: '‘${routine.name}’ 루틴이 삭제돼요.',
          confirmLabel: '삭제',
        );
        if (ok) store.delete(routine.id);
    }
  }
}

/// Routine name with its expected effort, boxed so it reads as the title.
class _TitleBox extends StatelessWidget {
  const _TitleBox({required this.name, required this.intensity});

  final String name;
  final IntensityLevel? intensity;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          if (intensity != null) ...[
            const SizedBox(width: 10),
            IntensityMeter(level: intensity!, compact: true, showBars: false),
          ],
        ],
      ),
    );
  }
}

/// "운동 20초  휴식 10초  ×8라운드 ×2세트": durations large, repeat counts
/// small; wraps between items, never inside one.
class _BigSummary extends StatelessWidget {
  const _BigSummary({required this.parts});

  final List<({String label, String value, bool repeat})> parts;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final label = TextStyle(
      color: palette.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    final value = TextStyle(
      color: palette.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      fontFeatures: tabularFigures,
    );
    final repeat = TextStyle(
      // Half opacity: present, not loud.
      color: palette.cardCaption.withValues(alpha: 0.5),
      fontSize: 15,
      fontWeight: FontWeight.w700,
      fontFeatures: tabularFigures,
    );
    // Repeat counts travel together ("×8라운드 ×2세트"), so a wrap never
    // separates them.
    final repeats = [
      for (final p in parts)
        if (p.repeat) '×${p.value}',
    ].join(' ');
    return Wrap(
      spacing: 12,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final p in parts)
          if (!p.repeat)
            Text.rich(
              TextSpan(
                children: [
                  if (p.label.isNotEmpty) TextSpan(text: '${p.label} ', style: label),
                  TextSpan(text: p.value, style: value),
                ],
              ),
              maxLines: 1,
            ),
        if (repeats.isNotEmpty)
          Padding(
            // Sit on roughly the same baseline as the large values.
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(repeats, style: repeat, maxLines: 1),
          ),
      ],
    );
  }
}
