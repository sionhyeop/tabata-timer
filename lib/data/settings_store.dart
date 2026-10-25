import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._prefs) : _value = _load(_prefs);

  static const _key = 'settings';

  final SharedPreferences _prefs;
  AppSettings _value;

  AppSettings get value => _value;

  void update(AppSettings Function(AppSettings current) change) {
    _value = change(_value);
    _prefs.setString(_key, jsonEncode(_value.toJson()));
    notifyListeners();
  }

  static AppSettings _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
