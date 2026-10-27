import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/routine_store.dart';
import '../../engine/workout_plan.dart';
import '../../l10n/l10n.dart';
import '../../models/timer_mode.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/mode_chips.dart';
import '../widgets/work_rest_card.dart';

/// Create or edit a routine. Uses the same tiles as the Timer tab.
class RoutineEditorPage extends StatefulWidget {
  const RoutineEditorPage({super.key, this.initial});

  final WorkoutConfig? initial;

  @override
  State<RoutineEditorPage> createState() => _RoutineEditorPageState();
}

class _RoutineEditorPageState extends State<RoutineEditorPage> {
  late WorkoutConfig _config =
      widget.initial ??
      WorkoutConfig.defaults(TimerMode.tabata).copyWith(id: RoutineStore.newId(), name: '');
  late final _nameController = TextEditingController(text: _config.name);
  final _exerciseController = TextEditingController();

  bool get _isNew => widget.initial == null;
  bool get _supportsExercises => _config.mode != TimerMode.rest;

  @override
  void dispose() {
    _nameController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  void _changeMode(TimerMode mode) {
    if (mode == _config.mode) return;
    // Take the new mode's defaults but keep identity and exercise names.
    setState(() {
      _config = WorkoutConfig.defaults(mode)
          .copyWith(id: _config.id, name: _config.name, exercises: _config.exercises);
    });
  }

  void _addExercise() {
    final name = _exerciseController.text.trim();
    if (name.isEmpty) return;
    setState(() => _config = _config.copyWith(exercises: [..._config.exercises, name]));
    _exerciseController.clear();
  }

  void _removeExercise(int index) {
    final list = [..._config.exercises]..removeAt(index);
    setState(() => _config = _config.copyWith(exercises: list));
  }

  void _reorder(int oldIndex, int newIndex) {
    final list = [..._config.exercises];
    list.insert(newIndex, list.removeAt(oldIndex));
    setState(() => _config = _config.copyWith(exercises: list));
  }

  void _save() {
    final name = _nameController.text.trim();
    final s = context.l10n;
    final routine = _config.copyWith(
      name: name.isEmpty ? s.myRoutineName(_config.mode.label(s)) : name,
      exercises: _supportsExercises ? _config.exercises : const [],
    );
    AppScope.of(context).routines.save(routine);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final s = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: s.deleteRoutineTitle,
      confirmLabel: s.delete,
    );
    if (!ok || !mounted) return;
    AppScope.of(context).routines.delete(_config.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final total = workoutDurationSec(_config);
    final palette = AppPalette.of(context);
    final s = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: s.close,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isNew ? s.newRoutine : s.editRoutine),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: s.delete,
              icon: Icon(Icons.delete_outline_rounded, color: palette.textSecondary),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: TextField(
                      controller: _nameController,
                      maxLength: 30,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: s.routineNameHint,
                        counterText: '',
                        prefixIcon: Icon(Icons.edit_outlined, color: palette.textTertiary),
                        fillColor: palette.surface,
                        hintStyle: TextStyle(
                          color: palette.textTertiary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionLabel(s.timerType),
                  ),
                  ModeChips(selected: _config.mode, onChanged: _changeMode),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
                    child: Text(
                      _config.mode.description(s),
                      style: TextStyle(color: palette.textSecondary, fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ConfigPanel(
                      config: _config,
                      onChanged: (c) => setState(() => _config = c),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        total == null ? s.noTimeLimit : s.totalDuration(formatClock(total)),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  if (_supportsExercises) ..._buildExercises(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: PrimaryButton(label: s.save, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExercises() {
    final exercises = _config.exercises;
    final palette = AppPalette.of(context);
    final s = context.l10n;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SectionLabel(s.exercisesOptional),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 8, 6),
                child: Text(
                  _config.mode == TimerMode.amrap || _config.mode == TimerMode.forTime
                      ? s.exercisesHintOpen
                      : s.exercisesHintRounds,
                  style: TextStyle(color: palette.textTertiary, fontSize: 13),
                ),
              ),
              if (exercises.isNotEmpty)
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorderItem: _reorder,
                  children: [
                    for (var i = 0; i < exercises.length; i++)
                      Row(
                        key: ValueKey('ex-$i-${exercises[i]}'),
                        children: [
                          ReorderableDragStartListener(
                            index: i,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.drag_indicator, color: palette.textTertiary),
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            child: Text('${i + 1}', style: TextStyle(color: palette.textSecondary)),
                          ),
                          Expanded(child: Text(exercises[i], style: const TextStyle(fontSize: 16))),
                          IconButton(
                            tooltip: s.delete,
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: palette.textSecondary,
                            onPressed: () => _removeExercise(i),
                          ),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _exerciseController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addExercise(),
                      decoration: InputDecoration(hintText: s.exerciseExample, isDense: true),
                    ),
                  ),
                  IconButton(
                    tooltip: s.addExercise,
                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.accent, size: 32),
                    onPressed: _addExercise,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
