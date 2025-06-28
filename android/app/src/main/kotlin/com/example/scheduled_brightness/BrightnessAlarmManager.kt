package com.example.scheduled_brightness

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.Calendar

/**
 * 明るさ変更のアラームを管理するクラス
 */
class BrightnessAlarmManager(private val context: Context) {
    private val alarmManager: AlarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    
    companion object {
        private const val TAG = "BrightnessAlarmManager"
        private const val ACTION_BRIGHTNESS_ALARM = "com.example.scheduled_brightness.BRIGHTNESS_ALARM"
        private const val EXTRA_ID = "id"
        private const val EXTRA_BRIGHTNESS = "brightness"
        private const val EXTRA_AUTO_MODE = "auto_mode"
    }
    
    /**
     * アラームをスケジュールするメソッド
     *
     * @param id アラームの一意のID
     * @param hour 時刻（時）
     * @param minute 時刻（分）
     * @param brightness 明るさの値（0.0〜1.0）
     * @param isAutoMode 自動明るさモードを使用するかどうか
     * @return アラームの設定に成功したかどうか
     */
    fun scheduleAlarm(id: String, hour: Int, minute: Int, brightness: Double, isAutoMode: Boolean): Boolean {
        try {
            // アラームの時刻を設定
            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                
                // 現在時刻より前の場合は翌日に設定
                if (timeInMillis <= System.currentTimeMillis()) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }
            
            // アラーム用のIntentを作成
            val intent = Intent(context, BrightnessAlarmReceiver::class.java).apply {
                action = ACTION_BRIGHTNESS_ALARM
                putExtra(EXTRA_ID, id)
                putExtra(EXTRA_BRIGHTNESS, brightness)
                putExtra(EXTRA_AUTO_MODE, isAutoMode)
            }
            
            // PendingIntentを作成
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // アラームを設定
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            
            Log.d(TAG, "Alarm scheduled: id=$id, time=${hour}:${minute}, brightness=$brightness, autoMode=$isAutoMode")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule alarm: ${e.message}")
            return false
        }
    }
    
    /**
     * アラームをキャンセルするメソッド
     *
     * @param id キャンセルするアラームのID
     * @return アラームのキャンセルに成功したかどうか
     */
    fun cancelAlarm(id: String): Boolean {
        try {
            val intent = Intent(context, BrightnessAlarmReceiver::class.java).apply {
                action = ACTION_BRIGHTNESS_ALARM
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
            
            Log.d(TAG, "Alarm canceled: id=$id")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cancel alarm: ${e.message}")
            return false
        }
    }
    
    /**
     * すべてのアラームをキャンセルするメソッド
     * 注意: このメソッドは実際にはすべてのアラームをキャンセルできません。
     * アプリが管理しているアラームのIDのリストを保持し、それらをループでキャンセルする必要があります。
     */
    fun cancelAllAlarms() {
        Log.d(TAG, "All alarms canceled")
        // 実際の実装では、保存されているすべてのアラームIDを取得し、
        // それぞれに対してcancelAlarm()を呼び出す必要があります。
    }
    
    /**
     * テスト用のアラームを設定するメソッド（10秒後に発火）
     *
     * @return テストアラームの設定に成功したかどうか
     */
    fun testAlarm(): Boolean {
        try {
            val testId = "test_alarm"
            val calendar = Calendar.getInstance().apply {
                add(Calendar.SECOND, 10) // 10秒後
            }
            
            val intent = Intent(context, BrightnessAlarmReceiver::class.java).apply {
                action = ACTION_BRIGHTNESS_ALARM
                putExtra(EXTRA_ID, testId)
                putExtra(EXTRA_BRIGHTNESS, 0.5)
                putExtra(EXTRA_AUTO_MODE, false)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                testId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
            
            Log.d(TAG, "Test alarm scheduled for 10 seconds later")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule test alarm: ${e.message}")
            return false
        }
    }
}
