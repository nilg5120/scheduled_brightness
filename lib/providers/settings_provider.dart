import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/brightness_service.dart';
import '../services/permission_service.dart';

// 設定管理のためのプロバイダークラス
class SettingsProvider with ChangeNotifier {
  AppSettings _settings = AppSettings();
  final StorageService _storageService = StorageService();
  final BrightnessService _brightnessService = BrightnessService();
  final PermissionService _permissionService = PermissionService();

  // 設定を取得するゲッター
  AppSettings get settings => _settings;

  // 自動明るさモードが有効かどうかを取得するゲッター
  bool get isAutoModeEnabled => _settings.isAutoModeEnabled;

  // 黒オーバーレイモードを使用するかどうかを取得するゲッター
  bool get useOverlayMode => _settings.useOverlayMode;

  // WRITE_SETTINGS権限があるかどうかを取得するゲッター
  bool get hasWriteSettingsPermission => _settings.hasWriteSettingsPermission;

  // オーバーレイの不透明度を取得するゲッター
  double get overlayOpacity => _settings.overlayOpacity;

  // オーバーレイがアクティブかどうかを取得するゲッター
  bool get isOverlayActive => _settings.isOverlayActive;

  // コンストラクタ
  SettingsProvider() {
    _loadSettings();
    _checkPermission();
  }

  // 設定を読み込むメソッド
  Future<void> _loadSettings() async {
    _settings = await _storageService.loadSettings();
    notifyListeners();
  }

  // 設定を保存するメソッド
  Future<void> _saveSettings() async {
    await _storageService.saveSettings(_settings);
  }

  // 権限を確認するメソッド
  Future<void> _checkPermission() async {
    final hasPermission = await _permissionService.hasWriteSettingsPermission();
    if (_settings.hasWriteSettingsPermission != hasPermission) {
      _settings.hasWriteSettingsPermission = hasPermission;
      notifyListeners();
      await _saveSettings();
    }
  }

  // 自動明るさモードを切り替えるメソッド
  Future<bool> toggleAutoMode() async {
    if (!_settings.hasWriteSettingsPermission) {
      return false;
    }

    final newValue = !_settings.isAutoModeEnabled;
    final success = await _brightnessService.setAutoBrightnessMode(newValue);
    
    if (success) {
      _settings.isAutoModeEnabled = newValue;
      notifyListeners();
      await _saveSettings();
    }
    
    return success;
  }

  // 黒オーバーレイモードを切り替えるメソッド
  Future<void> toggleOverlayMode() async {
    _settings.useOverlayMode = !_settings.useOverlayMode;
    notifyListeners();
    await _saveSettings();
  }

  // WRITE_SETTINGS権限を要求するメソッド
  Future<void> requestWriteSettingsPermission() async {
    await _permissionService.requestWriteSettingsPermission();
  }

  // 権限の状態を更新するメソッド
  Future<void> updatePermissionStatus() async {
    await _checkPermission();
  }

  // 設定を再読み込みするメソッド
  Future<void> reloadSettings() async {
    await _loadSettings();
  }

  // オーバーレイの不透明度を設定するメソッド
  Future<void> setOverlayOpacity(double opacity) async {
    // 0.0～1.0の範囲に制限
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    
    _settings.overlayOpacity = clampedOpacity;
    notifyListeners();
    await _saveSettings();

    // オーバーレイがアクティブな場合は即座に反映
    if (_settings.isOverlayActive) {
      await _brightnessService.setOverlayOpacity(clampedOpacity);
    }
  }

  // オーバーレイを切り替えるメソッド
  Future<bool> toggleOverlay() async {
    if (_settings.isOverlayActive) {
      // オーバーレイを非表示にする
      final success = await _brightnessService.hideOverlay();
      if (success) {
        _settings.isOverlayActive = false;
        notifyListeners();
        await _saveSettings();
      }
      return success;
    } else {
      // オーバーレイを表示する
      final success = await _brightnessService.showOverlay(_settings.overlayOpacity);
      if (success) {
        _settings.isOverlayActive = true;
        notifyListeners();
        await _saveSettings();
      }
      return success;
    }
  }

  // オーバーレイを表示するメソッド
  Future<bool> showOverlay() async {
    final success = await _brightnessService.showOverlay(_settings.overlayOpacity);
    if (success) {
      _settings.isOverlayActive = true;
      notifyListeners();
      await _saveSettings();
    }
    return success;
  }

  // オーバーレイを非表示にするメソッド
  Future<bool> hideOverlay() async {
    final success = await _brightnessService.hideOverlay();
    if (success) {
      _settings.isOverlayActive = false;
      notifyListeners();
      await _saveSettings();
    }
    return success;
  }

  // オーバーレイの状態を同期するメソッド
  Future<void> syncOverlayStatus() async {
    final isVisible = await _brightnessService.isOverlayVisible();
    if (_settings.isOverlayActive != isVisible) {
      _settings.isOverlayActive = isVisible;
      notifyListeners();
      await _saveSettings();
    }
  }
}
