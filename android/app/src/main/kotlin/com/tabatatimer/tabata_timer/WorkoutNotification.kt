package com.tabatatimer.tabata_timer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.os.Build
import android.widget.RemoteViews

/**
 * The running workout in the notification shade.
 *
 * Uses its own layouts so the progress bar shows even when the notification
 * is collapsed: phase and round, time left, and the workout drawn as the
 * app's segmented gradient bar with a "you are here" marker.
 *
 * Posted under the foreground service's notification id, so it replaces
 * that notification rather than adding a second one.
 */
object WorkoutNotification {
    private const val ID = 120 // BackgroundSession's serviceId
    private const val CHANNEL = "workout"

    fun show(context: Context, args: Map<*, *>) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        ensureChannel(manager)

        val title = args["title"] as? String ?: return
        val text = args["text"] as? String ?: ""
        val time = args["time"] as? String ?: ""
        val color = (args["color"] as? Number)?.toInt() ?: Color.WHITE
        val position = (args["position"] as? Number)?.toInt() ?: 0
        val segments =
            (args["segments"] as? List<*>).orEmpty().mapNotNull { it as? Map<*, *> }.map {
                Segment((it["length"] as? Number)?.toInt() ?: 0, (it["color"] as? Number)?.toInt() ?: color)
            }

        val small =
            RemoteViews(context.packageName, R.layout.notification_workout_small).apply {
                setTextViewText(R.id.title, title)
                setTextViewText(R.id.time, time)
                setImageViewBitmap(R.id.bar, drawBar(context, segments, position, color, heightDp = 12))
            }
        val big =
            RemoteViews(context.packageName, R.layout.notification_workout_big).apply {
                setTextViewText(R.id.title, title)
                setTextViewText(R.id.time, time)
                setTextViewText(R.id.text, text)
                setImageViewBitmap(R.id.bar, drawBar(context, segments, position, color, heightDp = 14))
            }

        val builder =
            if (Build.VERSION.SDK_INT >= 26) {
                Notification.Builder(context, CHANNEL)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context)
            }
        builder
            .setSmallIcon(R.drawable.ic_stat_workout)
            .setContentTitle(title) // also the plain fallback, e.g. on the lock screen
            .setContentText(listOf(time, text).filter { it.isNotEmpty() }.joinToString(" · "))
            .setColor(color)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(openApp(context))
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(small)
            .setCustomBigContentView(big)

        try {
            manager.notify(ID, builder.build())
        } catch (_: SecurityException) {
            // Notifications not allowed; the service keeps running regardless.
        }
    }

    fun cancel(context: Context) {
        context.getSystemService(NotificationManager::class.java)?.cancel(ID)
    }

    private class Segment(val length: Int, val color: Int)

    /**
     * The workout as rounded segments (done parts in their phase gradient,
     * the rest faded) with a slim white marker at [position], the same marker
     * as the app's ratio bar. Drawn close to the width the shade gives the
     * view (screen minus icon, margins and expand button) to limit stretching.
     */
    private fun drawBar(
        context: Context,
        segments: List<Segment>,
        position: Int,
        color: Int,
        heightDp: Int,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val width = (context.resources.displayMetrics.widthPixels - 150 * density).toInt().coerceAtLeast(240)
        val height = (heightDp * density).toInt()
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        val markerWidth = 4 * density
        val trackHeight = height * 0.6f
        val top = (height - trackHeight) / 2
        val radius = trackHeight / 2
        val left = markerWidth // keep the marker inside the bitmap at either end
        val right = width - markerWidth

        val parts = segments.filter { it.length > 0 }
        if (parts.isEmpty()) {
            // Open-ended: a calm full bar.
            paint.shader = LinearGradient(left, 0f, right, 0f, lighten(color), color, Shader.TileMode.CLAMP)
            canvas.drawRoundRect(RectF(left, top, right, top + trackHeight), radius, radius, paint)
            return bitmap
        }

        val gap = 3 * density
        val total = parts.sumOf { it.length }
        val usable = (right - left) - gap * (parts.size - 1)
        var x = left
        var markerX = left
        var before = 0
        for (segment in parts) {
            val w = usable * segment.length / total
            val rect = RectF(x, top, x + w, top + trackHeight)
            paint.shader = null
            paint.color = withAlpha(segment.color, 60)
            canvas.drawRoundRect(rect, radius, radius, paint)

            val done = ((position - before).coerceIn(0, segment.length)).toFloat() / segment.length
            if (done > 0f) {
                val filled = RectF(x, top, x + w * done, top + trackHeight)
                paint.color = Color.WHITE // the paint's alpha would otherwise dim the gradient
                paint.shader =
                    LinearGradient(x, 0f, x + w, 0f, lighten(segment.color), segment.color, Shader.TileMode.CLAMP)
                canvas.drawRoundRect(filled, radius, radius, paint)
            }
            if (position in before..(before + segment.length)) markerX = x + w * done
            before += segment.length
            x += w + gap
        }

        paint.shader = null
        paint.color = Color.WHITE
        paint.setShadowLayer(3 * density, 0f, 0f, color)
        canvas.drawRoundRect(
            RectF(markerX - markerWidth / 2, 0f, markerX + markerWidth / 2, height.toFloat()),
            markerWidth / 2,
            markerWidth / 2,
            paint,
        )
        return bitmap
    }

    private fun withAlpha(color: Int, alpha: Int) = Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))

    private fun lighten(color: Int): Int {
        fun mix(c: Int) = c + ((255 - c) * 0.25f).toInt()
        return Color.argb(255, mix(Color.red(color)), mix(Color.green(color)), mix(Color.blue(color)))
    }

    private fun ensureChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT < 26 || manager.getNotificationChannel(CHANNEL) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, "운동 진행", NotificationManager.IMPORTANCE_LOW).apply {
                description = "운동 중 타이머가 화면 밖에서도 계속 동작해요"
                setShowBadge(false)
            },
        )
    }

    private fun openApp(context: Context): PendingIntent {
        val intent =
            Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
