import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../models/brightness_schedule.dart';

// アラーム（スケジュールされた時刻に明るさを変更するトリガー）を管理するサービスクラス
class AlarmService {
  // ロガーの定義
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  // MethodChannelの定義
  static const platform = MethodChannel('com.example.scheduled_brightness/alarm');

  // スケジュールに基づいてアラームを設定するメソッド
  Future<bool> scheduleAlarm(BrightnessSchedule schedule) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'scheduleAlarm',
        {
          'id': schedule.id,
          'hour': schedule.hour,
          'minute': schedule.minute,
          'brightness': schedule.brightness,
          'isAutoMode': schedule.isAutoMode,
          'isEnabled': schedule.isEnabled,
        },
      );
      return result ?? false;
    } catch (e) {
      _logger.e('アラーム設定エラー: $e');
      return false;
    }
  }

  // スケジュールに基づいてアラームをキャンセルするメソッド
  Future<bool> cancelAlarm(String scheduleId) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'cancelAlarm',
        {'id': scheduleId},
      );
      return result ?? false;
    } catch (e) {
      _logger.e('アラームキャンセルエラー: $e');
      return false;
    }
  }

  // すべてのアラームを再設定するメソッド
  Future<bool> rescheduleAllAlarms(List<BrightnessSchedule> schedules) async {
    try {
      // まず全てのアラームをキャンセル
      await platform.invokeMethod('cancelAllAlarms');
      
      // 有効なスケジュールのみアラームを設定
      bool allSuccess = true;
      for (var schedule in schedules) {
        if (schedule.isEnabled) {
          final success = await scheduleAlarm(schedule);
          if (!success) {
            allSuccess = false;
          }
        }
      }
      
      return allSuccess;
    } catch (e) {
      _logger.e('アラーム再設定エラー: $e');
      return false;
    }
  }

  // アラームが正しく動作するかテストするメソッド
  Future<bool> testAlarm() async {
    try {
      final result = await platform.invokeMethod<bool>('testAlarm');
      return result ?? false;
    } catch (e) {
      _logger.e('アラームテストエラー: $e');
      return false;
    }
  }
}
