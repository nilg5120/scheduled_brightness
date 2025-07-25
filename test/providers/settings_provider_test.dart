import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduled_brightness/providers/settings_provider.dart';
import 'package:scheduled_brightness/models/app_settings.dart';

void main() {
  group('SettingsProvider', () {
    late SettingsProvider settingsProvider;
    late List<MethodCall> methodCalls;

    setUp(() {
      // テストバインディングを初期化
      TestWidgetsFlutterBinding.ensureInitialized();
      
      methodCalls = [];
      
      // BrightnessServiceのMethodChannelをモック
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
            case 'checkWriteSettingsPermission':
              return true;
            case 'setAutoBrightnessMode':
              return true;
            default:
              return null;
          }
        },
      );
      
      // shared_preferencesのMethodChannelをモック
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getAll':
              return <String, Object>{}; // 空の設定を返す
            case 'setString':
            case 'setBool':
            case 'setInt':
            case 'setDouble':
              return true;
            default:
              return null;
          }
        },
      );
      
      // permission_handlerのMethodChannelをモック
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkPermissionStatus':
              return 0; // PermissionStatus.denied
            case 'requestPermissions':
              return {0: 1}; // Permission.systemAlertWindow: PermissionStatus.granted
            default:
              return null;
          }
        },
      );
      
      // PermissionServiceのMethodChannelをモック
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.scheduled_brightness/permission'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkWriteSettingsPermission':
              return true;
            case 'openWriteSettingsPermissionPage':
              return null;
            default:
              return null;
          }
        },
      );

      settingsProvider = SettingsProvider();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.scheduled_brightness/brightness'),
        null,
      );
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        null,
      );
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        null,
      );
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.scheduled_brightness/permission'),
        null,
      );
    });

    group('初期化', () {
      test('初期値が正しく設定される', () {
        expect(settingsProvider.settings, isA<AppSettings>());
        expect(settingsProvider.isAutoModeEnabled, false);
        expect(settingsProvider.useOverlayMode, false);
        expect(settingsProvider.overlayOpacity, 0.5);
        expect(settingsProvider.isOverlayActive, false);
      });
    });

    group('オーバーレイ不透明度の設定', () {
      test('setOverlayOpacityが正しく動作する', () async {
        const newOpacity = 0.7;
        
        await settingsProvider.setOverlayOpacity(newOpacity);
        
        expect(settingsProvider.overlayOpacity, newOpacity);
      });

      test('不透明度が0.0～1.0の範囲に制限される', () async {
        // 範囲外の値をテスト
        await settingsProvider.setOverlayOpacity(-0.1);
        expect(settingsProvider.overlayOpacity, 0.0);
        
        await settingsProvider.setOverlayOpacity(1.5);
        expect(settingsProvider.overlayOpacity, 1.0);
        
        // 正常な値をテスト
        await settingsProvider.setOverlayOpacity(0.5);
        expect(settingsProvider.overlayOpacity, 0.5);
      });

      test('オーバーレイがアクティブな場合、即座に反映される', () async {
        // オーバーレイを表示状態にする
        await settingsProvider.showOverlay();
        methodCalls.clear(); // 前のメソッドコールをクリア
        
        const newOpacity = 0.8;
        await settingsProvider.setOverlayOpacity(newOpacity);
        
        // setOverlayOpacityが呼ばれたことを確認
        expect(methodCalls.any((call) => call.method == 'setOverlayOpacity'), true);
        final opacityCall = methodCalls.firstWhere((call) => call.method == 'setOverlayOpacity');
        expect(opacityCall.arguments['opacity'], newOpacity);
      });
    });

    group('オーバーレイの表示/非表示', () {
      test('showOverlayが正しく動作する', () async {
        final result = await settingsProvider.showOverlay();
        
        expect(result, true);
        expect(settingsProvider.isOverlayActive, true);
        expect(methodCalls.any((call) => call.method == 'showOverlay'), true);
      });

      test('hideOverlayが正しく動作する', () async {
        // まずオーバーレイを表示
        await settingsProvider.showOverlay();
        methodCalls.clear();
        
        final result = await settingsProvider.hideOverlay();
        
        expect(result, true);
        expect(settingsProvider.isOverlayActive, false);
        expect(methodCalls.any((call) => call.method == 'hideOverlay'), true);
      });

      test('toggleOverlayが正しく動作する', () async {
        // 初期状態（非表示）からの切り替え
        expect(settingsProvider.isOverlayActive, false);
        
        final result1 = await settingsProvider.toggleOverlay();
        expect(result1, true);
        expect(settingsProvider.isOverlayActive, true);
        
        // 表示状態からの切り替え
        methodCalls.clear();
        final result2 = await settingsProvider.toggleOverlay();
        expect(result2, true);
        expect(settingsProvider.isOverlayActive, false);
      });
    });

    group('オーバーレイモードの切り替え', () {
      test('toggleOverlayModeが正しく動作する', () async {
        expect(settingsProvider.useOverlayMode, false);
        
        await settingsProvider.toggleOverlayMode();
        expect(settingsProvider.useOverlayMode, true);
        
        await settingsProvider.toggleOverlayMode();
        expect(settingsProvider.useOverlayMode, false);
      });
    });

    group('自動明るさモードの切り替え', () {
      test('toggleAutoModeが権限がある場合に正しく動作する', () async {
        final result = await settingsProvider.toggleAutoMode();
        
        expect(result, true);
        expect(settingsProvider.isAutoModeEnabled, true);
        expect(methodCalls.any((call) => call.method == 'setAutoBrightnessMode'), true);
      });

      test('toggleAutoModeが権限がない場合にfalseを返す', () async {
        // 権限なしのモックを設定
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.example.scheduled_brightness/brightness'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'checkWriteSettingsPermission') {
              return false;
            }
            return null;
          },
        );

        // 新しいプロバイダーを作成（権限なし状態で）
        final provider = SettingsProvider();
        await Future.delayed(const Duration(milliseconds: 100)); // 初期化待ち
        
        final result = await provider.toggleAutoMode();
        expect(result, false);
      });
    });

    group('エラーハンドリング', () {
      test('BrightnessServiceでエラーが発生した場合の処理', () async {
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

        final result1 = await settingsProvider.showOverlay();
        final result2 = await settingsProvider.hideOverlay();
        final result3 = await settingsProvider.toggleOverlay();

        expect(result1, false);
        expect(result2, false);
        expect(result3, false);
        
        // 状態は変更されない
        expect(settingsProvider.isOverlayActive, false);
      });
    });

    group('状態同期', () {
      test('syncOverlayStatusが正しく動作する', () async {
        // オーバーレイが表示されている状態をモック
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.example.scheduled_brightness/brightness'),
          (MethodCall methodCall) async {
            methodCalls.add(methodCall); // methodCallsに追加
            if (methodCall.method == 'isOverlayVisible') {
              return true;
            }
            return null;
          },
        );

        await settingsProvider.syncOverlayStatus();
        
        expect(settingsProvider.isOverlayActive, true);
        expect(methodCalls.any((call) => call.method == 'isOverlayVisible'), true);
      });
    });

    group('通知機能', () {
      test('設定変更時にnotifyListenersが呼ばれる', () async {
        bool notified = false;
        
        settingsProvider.addListener(() {
          notified = true;
        });

        await settingsProvider.setOverlayOpacity(0.8);
        expect(notified, true);

        notified = false;
        await settingsProvider.toggleOverlayMode();
        expect(notified, true);

        notified = false;
        await settingsProvider.showOverlay();
        expect(notified, true);
      });
    });

    group('境界値テスト', () {
      test('不透明度の境界値が正しく処理される', () async {
        // 最小値
        await settingsProvider.setOverlayOpacity(0.0);
        expect(settingsProvider.overlayOpacity, 0.0);

        // 最大値
        await settingsProvider.setOverlayOpacity(1.0);
        expect(settingsProvider.overlayOpacity, 1.0);

        // 範囲外の値（負の値）
        await settingsProvider.setOverlayOpacity(-1.0);
        expect(settingsProvider.overlayOpacity, 0.0);

        // 範囲外の値（1を超える値）
        await settingsProvider.setOverlayOpacity(2.0);
        expect(settingsProvider.overlayOpacity, 1.0);
      });
    });
  });
}
