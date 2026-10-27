import 'package:flutter/widgets.dart';

import '../data/settings_store.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';

/// The locale for [language] given the device's preferred [deviceLocales]:
/// the first one the app speaks, else English.
Locale resolveAppLocale(AppLanguage language, List<Locale> deviceLocales) {
  switch (language) {
    case AppLanguage.ko:
      return const Locale('ko');
    case AppLanguage.en:
      return const Locale('en');
    case AppLanguage.system:
      for (final device in deviceLocales) {
        for (final supported in AppLocalizations.supportedLocales) {
          if (supported.languageCode == device.languageCode) return supported;
        }
      }
      return const Locale('en');
  }
}

/// The app's current language, from the setting and the device. Widgets read
/// strings through [AppLocalizations.of]; code without a context (voice,
/// notification, preset routines) uses [strings].
class AppLanguageController extends ChangeNotifier with WidgetsBindingObserver {
  AppLanguageController(this._settings) {
    _locale = _resolve();
    _settings.addListener(_update);
    WidgetsBinding.instance.addObserver(this);
  }

  final SettingsStore _settings;
  late Locale _locale;

  Locale get locale => _locale;
  AppLocalizations get strings => lookupAppLocalizations(_locale);

  @override
  void didChangeLocales(List<Locale>? locales) => _update();

  void _update() {
    final next = _resolve();
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
  }

  Locale _resolve() => resolveAppLocale(
    _settings.value.language,
    WidgetsBinding.instance.platformDispatcher.locales,
  );
}
