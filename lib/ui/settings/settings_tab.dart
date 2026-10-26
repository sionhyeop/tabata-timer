import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/default_routines.dart';
import '../../models/app_settings.dart';
import '../../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/value_tile.dart';
import 'voice_sheet.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final store = services.settings;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final s = store.value;
          void set(AppSettings Function(AppSettings) change) => store.update(change);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              const ScreenHeader(title: '설정'),
              const SectionLabel('소리와 진동'),
              _Group(
                children: [
                  _SwitchRow(
                    title: '효과음',
                    subtitle: '카운트다운 비프와 전환음',
                    value: s.soundOn,
                    onChanged: (v) => set((s) => s.copyWith(soundOn: v)),
                  ),
                  _SwitchRow(
                    title: '음성 안내',
                    subtitle: '“운동”, “휴식, 다음은 버피”처럼 말해줘요',
                    value: s.voiceOn,
                    onChanged: (v) => set((s) => s.copyWith(voiceOn: v)),
                  ),
                  _SwitchRow(
                    title: '매초 신호음',
                    subtitle: '타이머가 도는 동안 1초마다 짧게 삐-',
                    value: s.tickOn,
                    onChanged: (v) => set((s) => s.copyWith(tickOn: v)),
                  ),
                  _TapRow(
                    title: '목소리',
                    subtitle: s.voiceName ?? '자동 · 가장 자연스러운 한국어 목소리',
                    onTap: () => showVoiceSheet(context),
                  ),
                  _SwitchRow(
                    title: '진동',
                    value: s.vibrationOn,
                    onChanged: (v) => set((s) => s.copyWith(vibrationOn: v)),
                  ),
                  _TapRow(
                    title: '소리 테스트',
                    trailing: const Icon(Icons.volume_up_rounded, color: AppColors.textSecondary),
                    onTap: services.cues.preview,
                  ),
                ],
              ),
              const SectionLabel('타이머'),
              _Group(
                children: [
                  _ChoiceRow(
                    title: '카운트다운 비프',
                    subtitle: '단계가 끝나기 전 짧은 비프',
                    child: SegmentedPills<int>(
                      options: const [0, 3, 5],
                      selected: s.countdownBeeps,
                      labelOf: (v) => v == 0 ? '끄기' : '$v초',
                      onChanged: (v) => set((s) => s.copyWith(countdownBeeps: v)),
                    ),
                  ),
                  _ChoiceRow(
                    title: '준비 시간',
                    subtitle: '시작 버튼을 누른 뒤 자세를 잡는 시간',
                    child: SegmentedPills<int>(
                      options: const [0, 5, 10, 15],
                      selected: s.prepareSec,
                      labelOf: (v) => v == 0 ? '없음' : '$v초',
                      onChanged: (v) => set((s) => s.copyWith(prepareSec: v)),
                    ),
                  ),
                  _SwitchRow(
                    title: '절반 알림',
                    subtitle: '30초 이상 운동에서 절반 지점을 알려줘요',
                    value: s.halfwayAlert,
                    onChanged: (v) => set((s) => s.copyWith(halfwayAlert: v)),
                  ),
                ],
              ),
              const SectionLabel('화면'),
              _Group(
                children: [
                  _SwitchRow(
                    title: '운동 중 화면 켜짐 유지',
                    subtitle: '운동 화면에서만 적용돼요',
                    value: s.keepScreenOn,
                    onChanged: (v) => set((s) => s.copyWith(keepScreenOn: v)),
                  ),
                ],
              ),
              const SectionLabel('칼로리'),
              _Group(
                children: [
                  _TapRow(
                    title: '체중',
                    subtitle: '소모 칼로리 추정에만 사용해요',
                    trailing: Text(
                      '${s.weightKg}kg',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    onTap: () async {
                      final kg = await showValuePicker(
                        context,
                        ConfigField(
                          label: '체중',
                          kind: ValueKind.count,
                          value: s.weightKg,
                          min: 30,
                          max: 200,
                          unit: 'kg',
                          onChanged: (_) {},
                        ),
                      );
                      if (kg != null) set((s) => s.copyWith(weightKg: kg));
                    },
                  ),
                ],
              ),
              const SectionLabel('데이터'),
              _Group(
                children: [
                  _TapRow(
                    title: '기본 루틴 복원',
                    subtitle: '삭제한 기본 루틴을 다시 추가해요',
                    onTap: () {
                      final routines = services.routines;
                      var added = 0;
                      for (final preset in defaultRoutines.reversed) {
                        if (routines.byId(preset.id) == null) {
                          routines.save(preset);
                          added++;
                        }
                      }
                      showToast(context, added == 0 ? '모든 기본 루틴이 이미 있어요' : '기본 루틴 $added개를 복원했어요');
                    },
                  ),
                  _TapRow(
                    title: '운동 기록 초기화',
                    titleColor: AppColors.accent,
                    onTap: () async {
                      final ok = await showConfirmDialog(
                        context,
                        title: '모든 기록을 삭제할까요?',
                        message: '삭제한 기록은 되돌릴 수 없어요.',
                        confirmLabel: '삭제',
                      );
                      if (ok) services.history.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  '타바타 타이머 1.3.3',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 18, endIndent: 18),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  const _RowText({required this.title, this.subtitle, this.titleColor});

  final String title;
  final String? subtitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: _RowText(title: title, subtitle: subtitle),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          children: [
            Expanded(
              child: _RowText(title: title, subtitle: subtitle, titleColor: titleColor),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowText(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
