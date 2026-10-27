import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../l10n/l10n.dart';
import '../../services/cue_player.dart';
import '../../theme/app_colors.dart';

/// Lists the device's TTS voices for the app language, most natural first,
/// with a play button to compare them.
Future<void> showVoiceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _VoiceSheet(),
  );
}

/// "목소리 2 · 최고 음질" style label; Android voice names are codes.
String voiceLabel(AppLocalizations s, TtsVoice voice, int index) {
  final base = Platform.isIOS ? voice.name : s.voiceNumber(index + 1);
  return voice.networkRequired ? s.voiceOnline(base) : base;
}

class _VoiceSheet extends StatefulWidget {
  const _VoiceSheet();

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> {
  late final Future<List<TtsVoice>> _voices = AppScope.of(context).cues.voices();

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final settings = services.settings;
    final palette = AppPalette.of(context);
    final l10n = context.l10n;
    final language = services.language.locale.languageCode;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: FutureBuilder<List<TtsVoice>>(
            future: _voices,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                );
              }
              final voices = snapshot.data!;
              return ListenableBuilder(
                listenable: settings,
                builder: (context, _) {
                  final chosen = settings.value.voiceFor(language);
                  bool isChosen(TtsVoice v) => chosen?.name == v.name && chosen?.locale == v.locale;
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.voice,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      _VoiceRow(
                        title: l10n.voiceAuto,
                        subtitle: l10n.voiceAutoSub,
                        selected: !voices.any(isChosen),
                        onTap: () => settings.update((s) => s.copyWith(clearVoice: true)),
                      ),
                      if (voices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.noVoices,
                            style: TextStyle(color: palette.textSecondary, height: 1.5),
                          ),
                        ),
                      for (var i = 0; i < voices.length; i++)
                        _VoiceRow(
                          title: voiceLabel(l10n, voices[i], i),
                          subtitle: '${voices[i].qualityLabel(l10n)} · ${voices[i].name}',
                          selected: isChosen(voices[i]),
                          onTap: () => settings.update(
                            (s) => s.copyWith(voice: (voices[i].name, voices[i].locale)),
                          ),
                          onPreview: () => services.cues.previewVoice(voices[i]),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          Platform.isIOS ? l10n.voiceTipIos : l10n.voiceTipAndroid,
                          style: TextStyle(color: palette.textTertiary, fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  const _VoiceRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.onPreview,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Material(
      color: selected ? palette.surfaceHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.accent : palette.textTertiary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: palette.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (onPreview != null)
                IconButton(
                  tooltip: context.l10n.previewVoice,
                  onPressed: onPreview,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  color: palette.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
