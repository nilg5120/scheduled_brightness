package com.example.scheduled_brightness

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // MethodChannelの名前
    private val BRIGHTNESS_CHANNEL = "com.example.scheduled_brightness/brightness"
    private val ALARM_CHANNEL = "com.example.scheduled_brightness/alarm"
    private val PERMISSION_CHANNEL = "com.example.scheduled_brightness/permission"
    
    // オーバーレイ用のView
    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var isOverlayShowing = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 明るさ関連のMethodChannelを設定
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BRIGHTNESS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAutoBrightnessEnabled" -> {
                    result.success(isAutoBrightnessEnabled())
                }
                "setAutoBrightnessMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(setAutoBrightnessMode(enabled))
                }
                "checkWriteSettingsPermission" -> {
                    result.success(hasWriteSettingsPermission())
                }
                "openWriteSettingsPermissionPage" -> {
                    openWriteSettingsPermissionPage()
                    result.success(null)
                }
                "showOverlay" -> {
                    val opacity = call.argument<Double>("opacity") ?: 0.5
                    result.success(showOverlay(opacity.toFloat()))
                }
                "hideOverlay" -> {
                    result.success(hideOverlay())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // アラーム関連のMethodChannelを設定
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            val alarmManager = BrightnessAlarmManager(this)
            
            when (call.method) {
                "scheduleAlarm" -> {
                    val id = call.argument<String>("id") ?: ""
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val brightness = call.argument<Double>("brightness") ?: 0.5
                    val isAutoMode = call.argument<Boolean>("isAutoMode") ?: false
                    val isEnabled = call.argument<Boolean>("isEnabled") ?: true
                    
                    if (isEnabled) {
                        val success = alarmManager.scheduleAlarm(id, hour, minute, brightness, isAutoMode)
                        result.success(success)
                    } else {
                        // スケジュールが無効な場合はアラームをキャンセル
                        val success = alarmManager.cancelAlarm(id)
                        result.success(success)
                    }
                }
                "cancelAlarm" -> {
                    val id = call.argument<String>("id") ?: ""
                    val success = alarmManager.cancelAlarm(id)
                    result.success(success)
                }
                "cancelAllAlarms" -> {
                    alarmManager.cancelAllAlarms()
                    result.success(true)
                }
                "testAlarm" -> {
                    val success = alarmManager.testAlarm()
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // 権限関連のMethodChannelを設定
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkWriteSettingsPermission" -> {
                    result.success(hasWriteSettingsPermission())
                }
                "openWriteSettingsPermissionPage" -> {
                    openWriteSettingsPermissionPage()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // 自動明るさモードが有効かどうかを確認するメソッド
    private fun isAutoBrightnessEnabled(): Boolean {
        return try {
            val mode = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE)
            mode == Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC
        } catch (e: Exception) {
            false
        }
    }

    // 自動明るさモードを設定するメソッド
    private fun setAutoBrightnessMode(enabled: Boolean): Boolean {
        return try {
            if (hasWriteSettingsPermission()) {
                val mode = if (enabled) {
                    Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC
                } else {
                    Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
                }
                Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, mode)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    // WRITE_SETTINGS権限があるかどうかを確認するメソッド
    private fun hasWriteSettingsPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.System.canWrite(this)
        } else {
            true
        }
    }

    // WRITE_SETTINGS権限を要求するメソッド（設定画面に遷移）
    private fun openWriteSettingsPermissionPage() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        }
    }

    // 黒オーバーレイを表示するメソッド
    private fun showOverlay(opacity: Float): Boolean {
        if (overlayView != null) {
            hideOverlay()
        }

        try {
            windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            
            // オーバーレイのパラメータを設定
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY
                },
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            )
            params.gravity = Gravity.TOP or Gravity.START
            
            // 黒い半透明のViewを作成
            overlayView = FrameLayout(this)
            overlayView?.setBackgroundColor(
                (opacity * 255).toInt() shl 24
            )
            
            // オーバーレイを表示
            windowManager?.addView(overlayView, params)
            isOverlayShowing = true
            
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    // 黒オーバーレイを非表示にするメソッド
    private fun hideOverlay(): Boolean {
        return try {
            if (isOverlayShowing && overlayView != null && windowManager != null) {
                windowManager?.removeView(overlayView)
                overlayView = null
                isOverlayShowing = false
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    override fun onDestroy() {
        hideOverlay()
        super.onDestroy()
    }
}
