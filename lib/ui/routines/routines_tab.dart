import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../engine/workout_plan.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
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
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Text(
                      '저장된 루틴이 없어요.\n＋ 버튼으로 나만의 루틴을 만들어 보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      onTap: () => openRoutineEditor(context, routine),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFC9CBD1),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      total == null ? '∞' : formatClock(total),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        fontFeatures: tabularFigures,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      routine.mode.label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  routine.summary,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                if (routine.exercises.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    routine.exercises.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
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
              const SizedBox(height: 6),
              PopupMenuButton<_MenuAction>(
                tooltip: '더보기',
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
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
