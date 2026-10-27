import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/default_routines.dart';
import '../../l10n/l10n.dart';
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
    final palette = AppPalette.of(context);
    final l10n = context.l10n;
    String seconds(int v) => l10n.durationSec(v);
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
              ScreenHeader(title: l10n.tabSettings),
              SectionLabel(l10n.sectionSound),
              _Group(
                children: [
                  _SwitchRow(
                    title: l10n.soundEffects,
                    subtitle: l10n.soundEffectsSub,
                    value: s.soundOn,
                    onChanged: (v) => set((s) => s.copyWith(soundOn: v)),
                  ),
                  _SwitchRow(
                    title: l10n.voiceGuide,
                    subtitle: l10n.voiceGuideSub,
                    value: s.voiceOn,
                    onChanged: (v) => set((s) => s.copyWith(voiceOn: v)),
                  ),
                  _SwitchRow(
                    title: l10n.tickBeep,
                    subtitle: l10n.tickBeepSub,
                    value: s.tickOn,
                    onChanged: (v) => set((s) => s.copyWith(tickOn: v)),
                  ),
                  _TapRow(
                    title: l10n.voice,
                    subtitle:
                        s.voiceFor(services.language.locale.languageCode)?.name ??
                        l10n.voiceAutoSummary,
                    onTap: () => showVoiceSheet(context),
                  ),
                  _SwitchRow(
                    title: l10n.vibration,
                    value: s.vibrationOn,
                    onChanged: (v) => set((s) => s.copyWith(vibrationOn: v)),
                  ),
                  _TapRow(
                    title: l10n.soundTest,
                    trailing: Icon(Icons.volume_up_rounded, color: palette.textSecondary),
                    onTap: services.cues.preview,
                  ),
                ],
              ),
              SectionLabel(l10n.tabTimer),
              _Group(
                children: [
                  _ChoiceRow(
                    title: l10n.countdownBeeps,
                    subtitle: l10n.countdownBeepsSub,
                    child: SegmentedPills<int>(
                      options: const [0, 3, 5],
                      selected: s.countdownBeeps,
                      labelOf: (v) => v == 0 ? l10n.off : seconds(v),
                      onChanged: (v) => set((s) => s.copyWith(countdownBeeps: v)),
                    ),
                  ),
                  _ChoiceRow(
                    title: l10n.prepareTime,
                    subtitle: l10n.prepareTimeSub,
                    child: SegmentedPills<int>(
                      options: const [0, 5, 10, 15],
                      selected: s.prepareSec,
                      labelOf: (v) => v == 0 ? l10n.none : seconds(v),
                      onChanged: (v) => set((s) => s.copyWith(prepareSec: v)),
                    ),
                  ),
                  _SwitchRow(
                    title: l10n.halfwayAlert,
                    subtitle: l10n.halfwayAlertSub,
                    value: s.halfwayAlert,
                    onChanged: (v) => set((s) => s.copyWith(halfwayAlert: v)),
                  ),
                ],
              ),
              SectionLabel(l10n.sectionDisplay),
              _Group(
                children: [
                  _ChoiceRow(
                    title: l10n.theme,
                    subtitle: l10n.themeSub,
                    child: SegmentedPills<Appearance>(
                      options: Appearance.values,
                      selected: s.appearance,
                      labelOf: (a) => a.label(l10n),
                      onChanged: (a) => set((s) => s.copyWith(appearance: a)),
                    ),
                  ),
                  _ChoiceRow(
                    title: l10n.language,
                    subtitle: l10n.languageSub,
                    child: SegmentedPills<AppLanguage>(
                      options: AppLanguage.values,
                      selected: s.language,
                      labelOf: (a) => a.label(l10n),
                      onChanged: (a) => set((s) => s.copyWith(language: a)),
                    ),
                  ),
                  _SwitchRow(
                    title: l10n.keepScreenOn,
                    subtitle: l10n.keepScreenOnSub,
                    value: s.keepScreenOn,
                    onChanged: (v) => set((s) => s.copyWith(keepScreenOn: v)),
                  ),
                ],
              ),
              SectionLabel(l10n.sectionCalories),
              _Group(
                children: [
                  _TapRow(
                    title: l10n.bodyWeight,
                    subtitle: l10n.bodyWeightSub,
                    trailing: Text(
                      '${s.weightKg}kg',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    onTap: () async {
                      final kg = await showValuePicker(
                        context,
                        ConfigField(
                          label: l10n.bodyWeight,
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
              SectionLabel(l10n.sectionData),
              _Group(
                children: [
                  _TapRow(
                    title: l10n.restorePresets,
                    subtitle: l10n.restorePresetsSub,
                    onTap: () {
                      final routines = services.routines;
                      var added = 0;
                      for (final preset in defaultRoutines(l10n).reversed) {
                        if (routines.byId(preset.id) == null) {
                          routines.save(preset);
                          added++;
                        }
                      }
                      showToast(
                        context,
                        added == 0 ? l10n.presetsAllThere : l10n.presetsRestored(added),
                      );
                    },
                  ),
                  _TapRow(
                    title: l10n.clearHistory,
                    titleColor: AppColors.accent,
                    onTap: () async {
                      final ok = await showConfirmDialog(
                        context,
                        title: l10n.clearHistoryTitle,
                        message: l10n.clearHistoryMessage,
                        confirmLabel: l10n.delete,
                      );
                      if (ok) services.history.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  '${l10n.appTitle} 1.5.0',
                  style: TextStyle(color: palette.textTertiary, fontSize: 12),
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
          Text(
            subtitle!,
            style: TextStyle(color: AppPalette.of(context).textSecondary, fontSize: 13),
          ),
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
            trailing ?? Icon(Icons.chevron_right, color: AppPalette.of(context).textTertiary),
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
