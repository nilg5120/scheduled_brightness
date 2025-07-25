import 'package:flutter_test/flutter_test.dart';
import 'package:scheduled_brightness/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('デフォルト値が正しく設定されている', () {
      final settings = AppSettings();
      
      expect(settings.isAutoModeEnabled, false);
      expect(settings.hasWriteSettingsPermission, false);
      expect(settings.useOverlayMode, false);
      expect(settings.overlayOpacity, 0.5);
      expect(settings.isOverlayActive, false);
    });

    test('copyWithメソッドが正しく動作する', () {
      final original = AppSettings();
      
      final updated = original.copyWith(
        isAutoModeEnabled: true,
        overlayOpacity: 0.8,
        isOverlayActive: true,
      );
      
      expect(updated.isAutoModeEnabled, true);
      expect(updated.overlayOpacity, 0.8);
      expect(updated.isOverlayActive, true);
      // 変更されていない値は元の値を保持
      expect(updated.hasWriteSettingsPermission, false);
      expect(updated.useOverlayMode, false);
    });

    test('toJsonメソッドが正しくJSONに変換する', () {
      final settings = AppSettings(
        isAutoModeEnabled: true,
        hasWriteSettingsPermission: true,
        useOverlayMode: true,
        overlayOpacity: 0.7,
        isOverlayActive: true,
      );
      
      final json = settings.toJson();
      
      expect(json['isAutoModeEnabled'], true);
      expect(json['hasWriteSettingsPermission'], true);
      expect(json['useOverlayMode'], true);
      expect(json['overlayOpacity'], 0.7);
      expect(json['isOverlayActive'], true);
    });

    test('fromJsonメソッドが正しくJSONから復元する', () {
      final json = {
        'isAutoModeEnabled': true,
        'hasWriteSettingsPermission': true,
        'useOverlayMode': true,
        'overlayOpacity': 0.3,
        'isOverlayActive': true,
      };
      
      final settings = AppSettings.fromJson(json);
      
      expect(settings.isAutoModeEnabled, true);
      expect(settings.hasWriteSettingsPermission, true);
      expect(settings.useOverlayMode, true);
      expect(settings.overlayOpacity, 0.3);
      expect(settings.isOverlayActive, true);
    });

    test('不正なJSONでもデフォルト値で復元する', () {
      final json = <String, dynamic>{
        'invalidKey': 'invalidValue',
      };
      
      final settings = AppSettings.fromJson(json);
      
      expect(settings.isAutoModeEnabled, false);
      expect(settings.hasWriteSettingsPermission, false);
      expect(settings.useOverlayMode, false);
      expect(settings.overlayOpacity, 0.5);
      expect(settings.isOverlayActive, false);
    });

    test('オーバーレイ不透明度の境界値テスト', () {
      // 0.0の場合
      final settings1 = AppSettings(overlayOpacity: 0.0);
      expect(settings1.overlayOpacity, 0.0);
      
      // 1.0の場合
      final settings2 = AppSettings(overlayOpacity: 1.0);
      expect(settings2.overlayOpacity, 1.0);
      
      // 中間値の場合
      final settings3 = AppSettings(overlayOpacity: 0.5);
      expect(settings3.overlayOpacity, 0.5);
    });

    test('JSON変換の往復テスト', () {
      final original = AppSettings(
        isAutoModeEnabled: true,
        hasWriteSettingsPermission: false,
        useOverlayMode: true,
        overlayOpacity: 0.75,
        isOverlayActive: false,
      );
      
      final json = original.toJson();
      final restored = AppSettings.fromJson(json);
      
      expect(restored.isAutoModeEnabled, original.isAutoModeEnabled);
      expect(restored.hasWriteSettingsPermission, original.hasWriteSettingsPermission);
      expect(restored.useOverlayMode, original.useOverlayMode);
      expect(restored.overlayOpacity, original.overlayOpacity);
      expect(restored.isOverlayActive, original.isOverlayActive);
    });
  });
}
