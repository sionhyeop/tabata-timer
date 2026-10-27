import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_scope.dart';
import 'services/background_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  BackgroundSession.init();
  final prefs = await SharedPreferences.getInstance();
  final services = AppServices(prefs);
  unawaited(services.cues.init());

  runApp(TabataApp(services: services));
}
