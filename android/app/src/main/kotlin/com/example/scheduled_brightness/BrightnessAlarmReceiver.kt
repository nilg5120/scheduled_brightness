package com.example.scheduled_brightness

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.content.ContentResolver
import android.net.Uri
import java.util.Calendar

/**
 * 明るさ変更のアラームを受信するBroadcastReceiver
 */
class BrightnessAlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BrightnessAlarmReceiver"
        private const val ACTION_BRIGHTNESS_ALARM = "com.example.scheduled_brightness.BRIGHTNESS_ALARM"
        private const val EXTRA_ID = "id"
        private const val EXTRA_BRIGHTNESS = "brightness"
        private const val EXTRA_AUTO_MODE = "auto_mode"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_BRIGHTNESS_ALARM) {
            val id = intent.getStringExtra(EXTRA_ID) ?: return
            val brightness = intent.getDoubleExtra(EXTRA_BRIGHTNESS, 0.5)
            val isAutoMode = intent.getBooleanExtra(EXTRA_AUTO_MODE, false)
            
            Log.d(TAG, "Alarm received: id=$id, brightness=$brightness, autoMode=$isAutoMode")
            
            // 明るさを変更
            changeBrightness(context, brightness, isAutoMode)
            
            // 次の日のアラームを設定（毎日繰り返し）
            rescheduleAlarm(context, id, brightness, isAutoMode)
        }
    }
    
    /**
     * 明るさを変更するメソッド
     *
     * @param context コンテキスト
     * @param brightness 明るさの値（0.0〜1.0）
     * @param isAutoMode 自動明るさモードを使用するかどうか
     */
    private fun changeBrightness(context: Context, brightness: Double, isAutoMode: Boolean) {
        try {
            // WRITE_SETTINGS権限があるか確認
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!Settings.System.canWrite(context)) {
                    Log.e(TAG, "No WRITE_SETTINGS permission")
                    return
                }
            }
            
            val contentResolver = context.contentResolver
            
            // 自動明るさモードの設定
            if (isAutoMode) {
                // 自動明るさモードを有効にする
                Settings.System.putInt(
                    contentResolver,
                    Settings.System.SCREEN_BRIGHTNESS_MODE,
                    Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC
                )
                Log.d(TAG, "Auto brightness mode enabled")
            } else {
                // 自動明るさモードを無効にする
                Settings.System.putInt(
                    contentResolver,
                    Settings.System.SCREEN_BRIGHTNESS_MODE,
                    Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
                )
                
                // 明るさを設定（0-255の範囲に変換）
                val brightnessValue = (brightness * 255).toInt()
                Settings.System.putInt(
                    contentResolver,
                    Settings.System.SCREEN_BRIGHTNESS,
                    brightnessValue
                )
                Log.d(TAG, "Brightness set to $brightnessValue (${brightness * 100}%)")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to change brightness: ${e.message}")
        }
    }
    
    /**
     * 次の日のアラームを再設定するメソッド
     *
     * @param context コンテキスト
     * @param id アラームのID
     * @param brightness 明るさの値
     * @param isAutoMode 自動明るさモードを使用するかどうか
     */
    private fun rescheduleAlarm(context: Context, id: String, brightness: Double, isAutoMode: Boolean) {
        try {
            // アラーム情報からスケジュール時刻を抽出
            val parts = id.split("_")
            if (parts.size >= 3) {
                val hour = parts[1].toIntOrNull() ?: 0
                val minute = parts[2].toIntOrNull() ?: 0
                
                // 翌日の同じ時刻にアラームを設定
                val brightnessAlarmManager = BrightnessAlarmManager(context)
                brightnessAlarmManager.scheduleAlarm(id, hour, minute, brightness, isAutoMode)
                
                Log.d(TAG, "Alarm rescheduled for tomorrow: id=$id, time=$hour:$minute")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to reschedule alarm: ${e.message}")
        }
    }
}
