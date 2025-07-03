package com.example.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import android.media.MediaPlayer
import android.app.AlarmManager
import android.os.SystemClock

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_SNOOZE = "com.example.alarm.ACTION_SNOOZE"
        const val ACTION_STOP = "com.example.alarm.ACTION_STOP"
        private var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_SNOOZE -> {
                // Snooze for 1 minute
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val snoozeIntent = Intent(context, AlarmReceiver::class.java)
                val pendingIntent = PendingIntent.getBroadcast(
                    context, 0, snoozeIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val triggerAtMillis = System.currentTimeMillis() + 1 * 60 * 1000 // 1 minute
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
                Toast.makeText(context, "Snoozed for 1 minute", Toast.LENGTH_SHORT).show()
                stopRingtone()
                return
            }
            ACTION_STOP -> {
                stopRingtone()
                Toast.makeText(context, "Alarm stopped", Toast.LENGTH_SHORT).show()
                return
            }
            else -> {
                Log.d("AlarmReceiver", "Alarm received!")
                Toast.makeText(context, "Alarm triggered!", Toast.LENGTH_LONG).show()
                // Play custom ringtone from res/raw/old_alarm.mp3
                try {
                    stopRingtone() // Stop any previous instance
                    mediaPlayer = MediaPlayer.create(context, R.raw.old_alarm)
                    mediaPlayer?.isLooping = true
                    mediaPlayer?.start()
                } catch (e: Exception) {
                    Log.e("AlarmReceiver", "Failed to play alarm sound", e)
                }
            }
        }

        val channelId = "alarm_channel_id"
        val channelName = "Alarm Channel"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel for Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, channelName, NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(channel)
        }

        val notificationIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Snooze action
        val snoozeIntent = Intent(context, AlarmReceiver::class.java).apply { action = ACTION_SNOOZE }
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context, 1, snoozeIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val snoozeAction = NotificationCompat.Action.Builder(
            android.R.drawable.ic_media_pause, "Snooze", snoozePendingIntent
        ).build()

        // Stop action
        val stopIntent = Intent(context, AlarmReceiver::class.java).apply { action = ACTION_STOP }
        val stopPendingIntent = PendingIntent.getBroadcast(
            context, 2, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val stopAction = NotificationCompat.Action.Builder(
            android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPendingIntent
        ).build()

        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle("Alarm")
            .setContentText("Your alarm is ringing!")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .addAction(snoozeAction)
            .addAction(stopAction)
            .build()

        notificationManager.notify(1, notification)
    }

    private fun stopRingtone() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "Failed to stop alarm sound", e)
        }
    }
}
