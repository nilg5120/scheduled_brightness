import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:permission_handler/permission_handler.dart';

// 明るさ制御を担当するサービスクラス
class BrightnessService {
  // MethodChannelの定義
  static const platform = MethodChannel('com.example.scheduled_brightness/brightness');
  
  // 画面の明るさを取得するメソッド
  Future<double> getCurrentBrightness() async {
    try {
      return await ScreenBrightness().current;
    } catch (e) {
      print('明るさ取得エラー: $e');
      return 0.5; // デフォルト値
    }
  }

  // 画面の明るさを設定するメソッド
  Future<bool> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
      return true;
    } catch (e) {
      print('明るさ設定エラー: $e');
      return false;
    }
  }

  // 自動明るさモードの状態を取得するメソッド
  Future<bool> isAutoBrightnessEnabled() async {
    try {
      final result = await platform.invokeMethod<bool>('isAutoBrightnessEnabled');
      return result ?? false;
    } catch (e) {
      print('自動明るさモード取得エラー: $e');
      return false;
    }
  }

  // 自動明るさモードを設定するメソッド
  Future<bool> setAutoBrightnessMode(bool enabled) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'setAutoBrightnessMode',
        {'enabled': enabled},
      );
      return result ?? false;
    } catch (e) {
      print('自動明るさモード設定エラー: $e');
      return false;
    }
  }

  // WRITE_SETTINGS権限があるかどうかを確認するメソッド
  Future<bool> hasWriteSettingsPermission() async {
    try {
      final status = await Permission.systemAlertWindow.status;
      if (status.isGranted) {
        return true;
      }
      
      final result = await platform.invokeMethod<bool>('checkWriteSettingsPermission');
      return result ?? false;
    } catch (e) {
      print('権限確認エラー: $e');
      return false;
    }
  }

  // WRITE_SETTINGS権限を要求するメソッド（設定画面に遷移）
  Future<void> requestWriteSettingsPermission() async {
    try {
      await platform.invokeMethod('openWriteSettingsPermissionPage');
    } catch (e) {
      print('権限リクエストエラー: $e');
    }
  }

  // 黒オーバーレイを表示するメソッド（明るさ変更の代替手段）
  Future<bool> showOverlay(double opacity) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'showOverlay',
        {'opacity': opacity},
      );
      return result ?? false;
    } catch (e) {
      print('オーバーレイ表示エラー: $e');
      return false;
    }
  }

  // 黒オーバーレイを非表示にするメソッド
  Future<bool> hideOverlay() async {
    try {
      final result = await platform.invokeMethod<bool>('hideOverlay');
      return result ?? false;
    } catch (e) {
      print('オーバーレイ非表示エラー: $e');
      return false;
    }
  }
}
