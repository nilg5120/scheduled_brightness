import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduled_brightness/services/brightness_service.dart';

void main() {
  group('BrightnessService', () {
    late BrightnessService brightnessService;
    late List<MethodCall> methodCalls;

    setUp(() {
      // テストバインディングを初期化
      TestWidgetsFlutterBinding.ensureInitialized();
      
      brightnessService = BrightnessService();
      methodCalls = [];
      
      // MethodChannelをモック
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.scheduled_brightness/brightness'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'showOverlay':
              return true;
            case 'hideOverlay':
              return true;
            case 'setOverlayOpacity':
              return true;
            case 'isOverlayVisible':
              return false;
            case 'isAutoBrightnessEnabled':
              return false;
            case 'setAutoBrightnessMode':
              return true;
            case 'checkWriteSettingsPermission':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.scheduled_brightness/brightness'),
        null,
      );
    });

    group('オーバーレイ機能', () {
      test('showOverlayが正しいパラメータでMethodChannelを呼び出す', () async {
        const opacity = 0.7;
        
        final result = await brightnessService.showOverlay(opacity);
        
        expect(result, true);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'showOverlay');
        expect(methodCalls[0].arguments['opacity'], opacity);
      });

      test('hideOverlayが正しくMethodChannelを呼び出す', () async {
        final result = await brightnessService.hideOverlay();
        
        expect(result, true);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'hideOverlay');
      });

      test('setOverlayOpacityが正しいパラメータでMethodChannelを呼び出す', () async {
        const opacity = 0.3;
        
        final result = await brightnessService.setOverlayOpacity(opacity);
        
        expect(result, true);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'setOverlayOpacity');
        expect(methodCalls[0].arguments['opacity'], opacity);
      });

      test('isOverlayVisibleが正しくMethodChannelを呼び出す', () async {
        final result = await brightnessService.isOverlayVisible();
        
        expect(result, false);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'isOverlayVisible');
      });

      test('オーバーレイ不透明度の境界値テスト', () async {
        // 0.0の場合
        await brightnessService.setOverlayOpacity(0.0);
        expect(methodCalls.last.arguments['opacity'], 0.0);
        
        // 1.0の場合
        await brightnessService.setOverlayOpacity(1.0);
        expect(methodCalls.last.arguments['opacity'], 1.0);
        
        // 中間値の場合
        await brightnessService.setOverlayOpacity(0.5);
        expect(methodCalls.last.arguments['opacity'], 0.5);
      });
    });

    group('エラーハンドリング', () {
      test('MethodChannelでエラーが発生した場合、falseを返す', () async {
        // エラーを発生させるモックを設定
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.example.scheduled_brightness/brightness'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Test error',
            );
          },
        );

        final result1 = await brightnessService.showOverlay(0.5);
        final result2 = await brightnessService.hideOverlay();
        final result3 = await brightnessService.setOverlayOpacity(0.5);
        final result4 = await brightnessService.isOverlayVisible();

        expect(result1, false);
        expect(result2, false);
        expect(result3, false);
        expect(result4, false);
      });

      test('MethodChannelがnullを返した場合、デフォルト値を返す', () async {
        // nullを返すモックを設定
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.example.scheduled_brightness/brightness'),
          (MethodCall methodCall) async {
            return null;
          },
        );

        final result1 = await brightnessService.showOverlay(0.5);
        final result2 = await brightnessService.hideOverlay();
        final result3 = await brightnessService.setOverlayOpacity(0.5);
        final result4 = await brightnessService.isOverlayVisible();

        expect(result1, false);
        expect(result2, false);
        expect(result3, false);
        expect(result4, false);
      });
    });

    group('自動明るさモード', () {
      test('isAutoBrightnessEnabledが正しくMethodChannelを呼び出す', () async {
        final result = await brightnessService.isAutoBrightnessEnabled();
        
        expect(result, false);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'isAutoBrightnessEnabled');
      });

      test('setAutoBrightnessModeが正しいパラメータでMethodChannelを呼び出す', () async {
        const enabled = true;
        
        final result = await brightnessService.setAutoBrightnessMode(enabled);
        
        expect(result, true);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'setAutoBrightnessMode');
        expect(methodCalls[0].arguments['enabled'], enabled);
      });
    });

    group('権限チェック', () {
      test('hasWriteSettingsPermissionが正しくMethodChannelを呼び出す', () async {
        final result = await brightnessService.hasWriteSettingsPermission();
        
        expect(result, true);
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'checkWriteSettingsPermission');
      });

      test('requestWriteSettingsPermissionが正しくMethodChannelを呼び出す', () async {
        await brightnessService.requestWriteSettingsPermission();
        
        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'openWriteSettingsPermissionPage');
      });
    });
  });
}
