import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Keeps a workout running on Android while the screen is off or another
/// app (e.g. music) is in front: a foreground service with a wake lock and
/// an ongoing notification showing the current interval.
///
/// iOS needs no service; CuePlayer holds the audio session instead.
abstract final class BackgroundSession {
  static bool get _supported => !kIsWeb && Platform.isAndroid;

  static void init() {
    if (!_supported) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout',
        channelName: '운동 진행',
        channelDescription: '운동 중 타이머가 화면 밖에서도 계속 동작해요',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(showNotification: false),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowAutoRestart: false,
      ),
    );
  }

  /// Asks once (Android 13+) so the running timer can show in the shade.
  /// The service works without it; only the notification is hidden.
  static Future<void> ensureNotificationPermission() async {
    if (!_supported) return;
    try {
      final status = await FlutterForegroundTask.checkNotificationPermission();
      if (status == NotificationPermission.denied) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('BackgroundSession: permission failed: $e');
    }
  }

  static Future<void> start({required String title, required String text}) async {
    if (!_supported) return;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(notificationTitle: title, notificationText: text);
      } else {
        await FlutterForegroundTask.startService(
          serviceId: 120,
          serviceTypes: [ForegroundServiceTypes.mediaPlayback],
          notificationTitle: title,
          notificationText: text,
        );
      }
    } catch (e) {
      debugPrint('BackgroundSession: start failed: $e');
    }
  }

  static Future<void> update(String text) async {
    if (!_supported) return;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(notificationText: text);
      }
    } catch (e) {
      debugPrint('BackgroundSession: update failed: $e');
    }
  }

  static Future<void> stop() async {
    if (!_supported) return;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      debugPrint('BackgroundSession: stop failed: $e');
    }
  }
}
