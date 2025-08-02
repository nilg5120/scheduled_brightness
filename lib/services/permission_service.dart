import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

// 権限管理を担当するサービスクラス
class PermissionService {
  // Loggerのインスタンス
  static final Logger _logger = Logger();
  
  // MethodChannelの定義
  static const platform = MethodChannel('com.example.scheduled_brightness/permission');

  // WRITE_SETTINGS権限があるかどうかを確認するメソッド
  Future<bool> hasWriteSettingsPermission() async {
    try {
      // permission_handlerを使用して確認
      var status = await Permission.systemAlertWindow.status;
      if (status.isGranted) {
        return true;
      }
      
      // ネイティブコードを使用して確認
      final result = await platform.invokeMethod<bool>('checkWriteSettingsPermission');
      return result ?? false;
    } catch (e) {
      _logger.e('権限確認エラー: $e');
      return false;
    }
  }

  // WRITE_SETTINGS権限を要求するメソッド（設定画面に遷移）
  Future<void> requestWriteSettingsPermission() async {
    try {
      await platform.invokeMethod('openWriteSettingsPermissionPage');
    } catch (e) {
      _logger.e('権限リクエストエラー: $e');
    }
  }

  // 権限の状態を監視するメソッド
  Stream<bool> get writeSettingsPermissionStatus {
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => hasWriteSettingsPermission());
  }
}
