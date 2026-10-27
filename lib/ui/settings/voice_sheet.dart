import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../services/cue_player.dart';
import '../../theme/app_colors.dart';

/// Lists the device's Korean TTS voices, most natural first, with a play
/// button to compare them.
Future<void> showVoiceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _VoiceSheet(),
  );
}

/// "목소리 2 · 최고 음질" style label; Android voice names are codes.
String voiceLabel(TtsVoice voice, int index) {
  final base = Platform.isIOS ? voice.name : '목소리 ${index + 1}';
  return voice.networkRequired ? '$base (온라인)' : base;
}

class _VoiceSheet extends StatefulWidget {
  const _VoiceSheet();

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> {
  late final Future<List<TtsVoice>> _voices = AppScope.of(context).cues.koreanVoices();

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final settings = services.settings;
    final palette = AppPalette.of(context);
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
                  final s = settings.value;
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '목소리',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      _VoiceRow(
                        title: '자동 (추천)',
                        subtitle: '기기에서 가장 자연스러운 한국어 목소리',
                        selected: s.voiceName == null,
                        onTap: () => settings.update((s) => s.copyWith(clearVoice: true)),
                      ),
                      if (voices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '한국어 음성을 찾지 못했어요. 기기 설정에서 한국어 음성(TTS)을 설치해 주세요.',
                            style: TextStyle(color: palette.textSecondary, height: 1.5),
                          ),
                        ),
                      for (var i = 0; i < voices.length; i++)
                        _VoiceRow(
                          title: voiceLabel(voices[i], i),
                          subtitle: '${voices[i].qualityLabel} · ${voices[i].name}',
                          selected:
                              s.voiceName == voices[i].name && s.voiceLocale == voices[i].locale,
                          onTap: () => settings.update(
                            (s) => s.copyWith(voice: (voices[i].name, voices[i].locale)),
                          ),
                          onPreview: () => services.cues.previewVoice(voices[i]),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          Platform.isIOS
                              ? '더 자연스러운 목소리가 필요하면 설정 › 손쉬운 사용 › 읽기 및 말하기 › 음성 › 한국어에서 ‘향상됨’ 또는 ‘프리미엄’ 음성을 내려받으세요.'
                              : '더 자연스러운 목소리가 필요하면 설정 › 일반 › 글자 읽어주기에서 Google 음성 엔진의 한국어 음성 데이터를 설치하세요. (삼성 TTS는 다른 앱에서 쓸 수 없어요)',
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
                  tooltip: '미리 듣기',
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
