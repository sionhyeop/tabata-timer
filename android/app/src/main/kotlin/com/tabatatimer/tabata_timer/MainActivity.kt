package com.tabatatimer.tabata_timer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tabata_timer/workout_notification")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "show" -> {
                        (call.arguments as? Map<*, *>)?.let { WorkoutNotification.show(applicationContext, it) }
                        result.success(null)
                    }
                    "cancel" -> {
                        WorkoutNotification.cancel(applicationContext)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
