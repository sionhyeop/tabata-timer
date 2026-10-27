import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_scope.dart';
import 'models/app_settings.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'ui/history/history_tab.dart';
import 'ui/routines/routines_tab.dart';
import 'ui/settings/settings_tab.dart';
import 'ui/timer/timer_tab.dart';
import 'ui/widgets/aurora_background.dart';

class TabataApp extends StatelessWidget {
  const TabataApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: ListenableBuilder(
        listenable: services.settings,
        builder: (context, _) => MaterialApp(
          title: '타바타 타이머',
          debugShowCheckedModeBanner: false,
          theme: appLightTheme,
          darkTheme: appDarkTheme,
          themeMode: switch (services.settings.value.appearance) {
            Appearance.system => ThemeMode.system,
            Appearance.light => ThemeMode.light,
            Appearance.dark => ThemeMode.dark,
          },
          locale: const Locale('ko'),
          supportedLocales: const [Locale('ko'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => AnnotatedRegion(value: _systemBars(context), child: child!),
          home: const HomeShell(),
        ),
      ),
    );
  }

  /// Status and navigation bar icons that read on the current background.
  static SystemUiOverlayStyle _systemBars(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return style.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: palette.navBar,
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _tabs = [
  _TabSpec('타이머', Icons.timer_outlined, Icons.timer),
  _TabSpec('루틴', Icons.view_agenda_outlined, Icons.view_agenda),
  _TabSpec('기록', Icons.insert_chart_outlined, Icons.insert_chart),
  _TabSpec('설정', Icons.settings_outlined, Icons.settings),
];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: IndexedStack(
          index: _index,
          children: const [TimerTab(), RoutinesTab(), HistoryTab(), SettingsTab()],
        ),
      ),
      bottomNavigationBar: _BottomBar(index: _index, onSelect: (i) => setState(() => _index = i)),
    );
  }
}

/// Outline icons; the selected tab turns bright with a short underline,
/// like the reference.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.of(context).navBar,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _BarItem(spec: _tabs[i], selected: i == index, onTap: () => onSelect(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.spec, required this.selected, required this.onTap});

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = selected ? palette.textPrimary : palette.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      label: spec.label,
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? spec.selectedIcon : spec.icon, color: color, size: 26),
              const SizedBox(height: 3),
              Text(
                spec.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 22 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: palette.textPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
