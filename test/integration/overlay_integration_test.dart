import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:scheduled_brightness/providers/settings_provider.dart';
import 'package:scheduled_brightness/widgets/overlay_opacity_slider.dart';

void main() {
  group('オーバーレイ機能統合テスト', () {
    late List<MethodCall> methodCalls;

    setUp(() {
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

    testWidgets('オーバーレイ不透明度スライダーとプロバイダーの統合テスト', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: settingsProvider,
            child: Scaffold(
              body: Consumer<SettingsProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // オーバーレイ表示/非表示ボタン
                      ElevatedButton(
                        onPressed: () async {
                          await provider.toggleOverlay();
                        },
                        child: Text(provider.isOverlayActive ? 'オーバーレイを非表示' : 'オーバーレイを表示'),
                      ),
                      
                      // 不透明度スライダー
                      OverlayOpacitySlider(
                        value: provider.overlayOpacity,
                        onChanged: (value) async {
                          await provider.setOverlayOpacity(value);
                        },
                        enabled: provider.isOverlayActive,
                      ),
                      
                      // 現在の状態表示
                      Text('オーバーレイ状態: ${provider.isOverlayActive ? "表示中" : "非表示"}'),
                      Text('不透明度: ${(provider.overlayOpacity * 100).round()}%'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 初期状態の確認
      expect(find.text('オーバーレイを表示'), findsOneWidget);
      expect(find.text('オーバーレイ状態: 非表示'), findsOneWidget);
      expect(find.text('不透明度: 50%'), findsOneWidget);

      // オーバーレイを表示
      await tester.tap(find.text('オーバーレイを表示'));
      await tester.pumpAndSettle();

      // 状態の変更を確認
      expect(find.text('オーバーレイを非表示'), findsOneWidget);
      expect(find.text('オーバーレイ状態: 表示中'), findsOneWidget);
      
      // showOverlayが呼ばれたことを確認
      expect(methodCalls.any((call) => call.method == 'showOverlay'), true);

      // スライダーが有効になったことを確認
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNotNull);

      // プリセットボタンをテスト
      methodCalls.clear();
      await tester.tap(find.text('強く'));
      await tester.pumpAndSettle();

      // 不透明度が変更されたことを確認
      expect(find.text('不透明度: 80%'), findsOneWidget);
      
      // setOverlayOpacityが呼ばれたことを確認
      expect(methodCalls.any((call) => call.method == 'setOverlayOpacity'), true);
      final opacityCall = methodCalls.firstWhere((call) => call.method == 'setOverlayOpacity');
      expect(opacityCall.arguments['opacity'], 0.8);

      // オーバーレイを非表示
      methodCalls.clear();
      await tester.tap(find.text('オーバーレイを非表示'));
      await tester.pumpAndSettle();

      // 状態の変更を確認
      expect(find.text('オーバーレイを表示'), findsOneWidget);
      expect(find.text('オーバーレイ状態: 非表示'), findsOneWidget);
      
      // hideOverlayが呼ばれたことを確認
      expect(methodCalls.any((call) => call.method == 'hideOverlay'), true);

      // スライダーが無効になったことを確認
      final disabledSlider = tester.widget<Slider>(find.byType(Slider));
      expect(disabledSlider.onChanged, isNull);
    });

    testWidgets('エラー処理の統合テスト', (WidgetTester tester) async {
      // エラーを発生させるモックを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.example.scheduled_brightness/brightness'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'showOverlay') {
            throw PlatformException(
              code: 'PERMISSION_DENIED',
              message: 'SYSTEM_ALERT_WINDOW permission not granted',
            );
          }
          return null;
        },
      );

      final settingsProvider = SettingsProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: settingsProvider,
            child: Scaffold(
              body: Consumer<SettingsProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final success = await provider.showOverlay();
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('オーバーレイの表示に失敗しました')),
                            );
                          }
                        },
                        child: const Text('オーバーレイを表示'),
                      ),
                      Text('オーバーレイ状態: ${provider.isOverlayActive ? "表示中" : "非表示"}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // オーバーレイ表示を試行（エラーが発生する）
      await tester.tap(find.text('オーバーレイを表示'));
      await tester.pumpAndSettle();

      // エラーメッセージが表示されることを確認
      expect(find.text('オーバーレイの表示に失敗しました'), findsOneWidget);
      
      // 状態が変更されていないことを確認
      expect(find.text('オーバーレイ状態: 非表示'), findsOneWidget);
    });

    testWidgets('複数の不透明度変更の連続テスト', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: settingsProvider,
            child: Scaffold(
              body: Consumer<SettingsProvider>(
                builder: (context, provider, child) {
                  return OverlayOpacitySlider(
                    value: provider.overlayOpacity,
                    onChanged: (value) async {
                      await provider.setOverlayOpacity(value);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // オーバーレイを表示状態にする
      await settingsProvider.showOverlay();
      await tester.pumpAndSettle();
      methodCalls.clear();

      // 複数のプリセットボタンを連続でタップ
      await tester.tap(find.text('軽く'));
      await tester.pumpAndSettle();
      expect(find.text('20%'), findsOneWidget);

      await tester.tap(find.text('普通'));
      await tester.pumpAndSettle();
      expect(find.text('50%'), findsOneWidget);

      await tester.tap(find.text('強く'));
      await tester.pumpAndSettle();
      expect(find.text('80%'), findsOneWidget);

      // 各変更でsetOverlayOpacityが呼ばれたことを確認
      final opacityCalls = methodCalls.where((call) => call.method == 'setOverlayOpacity').toList();
      expect(opacityCalls.length, 3);
      expect(opacityCalls[0].arguments['opacity'], 0.2);
      expect(opacityCalls[1].arguments['opacity'], 0.5);
      expect(opacityCalls[2].arguments['opacity'], 0.8);
    });

    testWidgets('境界値での動作テスト', (WidgetTester tester) async {
      final settingsProvider = SettingsProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: settingsProvider,
            child: Scaffold(
              body: Consumer<SettingsProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await provider.setOverlayOpacity(0.0);
                        },
                        child: const Text('0%に設定'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await provider.setOverlayOpacity(1.0);
                        },
                        child: const Text('100%に設定'),
                      ),
                      Text('不透明度: ${(provider.overlayOpacity * 100).round()}%'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 0%に設定
      await tester.tap(find.text('0%に設定'));
      await tester.pumpAndSettle();
      expect(find.text('不透明度: 0%'), findsOneWidget);

      // 100%に設定
      await tester.tap(find.text('100%に設定'));
      await tester.pumpAndSettle();
      expect(find.text('不透明度: 100%'), findsOneWidget);
    });
  });
}
