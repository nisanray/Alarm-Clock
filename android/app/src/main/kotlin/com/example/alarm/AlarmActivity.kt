package com.example.alarm

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import android.os.PowerManager
import android.provider.Settings
import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Build
import android.util.Log
import android.os.Vibrator
import android.os.VibrationEffect

class AlarmActivity : Activity() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var vibrator: Vibrator? = null
    private val vibrationPattern = longArrayOf(0, 1000, 1000) // Vibrate 1s, pause 1s, repeat

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Toast.makeText(this, "AlarmActivity launched", Toast.LENGTH_LONG).show()
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        // Acquire a wake lock to keep the screen on
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
            "AlarmApp:AlarmWakeLock"
        )
        wakeLock?.acquire(10*60*1000L /*10 minutes*/)
        setContentView(R.layout.activity_alarm)

        val snoozeButton = findViewById<Button>(R.id.snoozeButton)
        val stopButton = findViewById<Button>(R.id.stopButton)
        val alarmText = findViewById<TextView>(R.id.alarmText)
        alarmText.text = "Alarm is ringing!"

        // Start repeating vibration
        try {
            vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(vibrationPattern, 1)) // 1 = repeat after first vibrate
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(vibrationPattern, 1)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        snoozeButton.setOnClickListener {
            val snoozeIntent = Intent(this, AlarmReceiver::class.java).apply {
                action = AlarmReceiver.ACTION_SNOOZE
            }
            sendBroadcast(snoozeIntent)
            stopVibration()
            finish()
        }
        stopButton.setOnClickListener {
            val stopIntent = Intent(this, AlarmReceiver::class.java).apply {
                action = AlarmReceiver.ACTION_STOP
            }
            sendBroadcast(stopIntent)
            stopVibration()
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        wakeLock?.release()
        stopVibration()
    }

    override fun onBackPressed() {
        // Disable back button to make alarm persistent
    }

    private fun stopVibration() {
        try {
            vibrator?.cancel()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
} 