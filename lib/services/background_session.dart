import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'workout_notice.dart';

/// Keeps a workout running on Android while the screen is off or another
/// app (e.g. music) is in front: a foreground service with a wake lock, and
/// an ongoing notification with the workout's progress bar.
///
/// iOS needs no service; CuePlayer holds the audio session instead.
abstract final class BackgroundSession {
  static bool get _supported => !kIsWeb && Platform.isAndroid;

  /// Must match WorkoutNotification.kt: the progress notification reuses
  /// this id to replace the service's own notification.
  static const _serviceId = 120;
  static const _notice = MethodChannel('tabata_timer/workout_notification');

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
      if (!await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.startService(
          serviceId: _serviceId,
          serviceTypes: [ForegroundServiceTypes.mediaPlayback],
          notificationTitle: title,
          notificationText: text,
          notificationIcon: const NotificationIcon(
            metaDataName: 'com.tabatatimer.tabata_timer.WORKOUT_ICON',
          ),
        );
      }
    } catch (e) {
      debugPrint('BackgroundSession: start failed: $e');
    }
  }

  /// Replaces the service notification with the current progress.
  static Future<void> show(WorkoutNotice notice) async {
    if (!_supported) return;
    try {
      await _notice.invokeMethod<void>('show', notice.toMap());
    } catch (e) {
      debugPrint('BackgroundSession: notice failed: $e');
    }
  }

  static Future<void> stop() async {
    if (!_supported) return;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
      // A progress update racing the stop would otherwise linger.
      await _notice.invokeMethod<void>('cancel');
    } catch (e) {
      debugPrint('BackgroundSession: stop failed: $e');
    }
  }
}
