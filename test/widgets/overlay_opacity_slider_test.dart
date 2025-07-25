import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduled_brightness/widgets/overlay_opacity_slider.dart';

void main() {
  group('OverlayOpacitySlider', () {
    testWidgets('初期値が正しく表示される', (WidgetTester tester) async {
      double currentValue = 0.5;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: currentValue,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // パーセンテージ表示をチェック
      expect(find.text('50%'), findsOneWidget);
      
      // ラベルをチェック
      expect(find.text('オーバーレイ不透明度'), findsOneWidget);
      
      // 説明テキストをチェック
      expect(find.text('0%で完全に透明、100%で完全に不透明になります'), findsOneWidget);
      
      // プリセットボタンをチェック
      expect(find.text('軽く'), findsOneWidget);
      expect(find.text('普通'), findsOneWidget);
      expect(find.text('強く'), findsOneWidget);
    });

    testWidgets('スライダーの値変更が正しく動作する', (WidgetTester tester) async {
      double currentValue = 0.5;
      double? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: currentValue,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // スライダーを見つける
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // スライダーの値を変更
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // コールバックが呼ばれたことを確認
      expect(changedValue, isNotNull);
      expect(changedValue! > currentValue, true);
    });

    testWidgets('プリセットボタンが正しく動作する', (WidgetTester tester) async {
      double currentValue = 0.5;
      double? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: currentValue,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // 「軽く」ボタンをタップ
      await tester.tap(find.text('軽く'));
      await tester.pumpAndSettle();
      
      expect(changedValue, 0.2);

      // 「普通」ボタンをタップ
      await tester.tap(find.text('普通'));
      await tester.pumpAndSettle();
      
      expect(changedValue, 0.5);

      // 「強く」ボタンをタップ
      await tester.tap(find.text('強く'));
      await tester.pumpAndSettle();
      
      expect(changedValue, 0.8);
    });

    testWidgets('プリセットボタンの選択状態が正しく表示される', (WidgetTester tester) async {
      // 「軽く」(0.2)に近い値でテスト
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 0.19, // 0.2に近い値
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // 「軽く」ボタンが選択状態になっているかチェック
      final lightButton = find.ancestor(
        of: find.text('軽く'),
        matching: find.byType(OutlinedButton),
      );
      expect(lightButton, findsOneWidget);
    });

    testWidgets('無効状態でスライダーとボタンが無効になる', (WidgetTester tester) async {
      double currentValue = 0.5;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: currentValue,
              onChanged: (value) {},
              enabled: false,
            ),
          ),
        ),
      );

      // スライダーが無効になっているかチェック
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNull);

      // プリセットボタンが無効になっているかチェック
      final buttons = tester.widgetList<OutlinedButton>(find.byType(OutlinedButton));
      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('境界値の表示が正しい', (WidgetTester tester) async {
      // 0%のテスト
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 0.0,
              onChanged: (value) {},
            ),
          ),
        ),
      );
      
      expect(find.text('0%'), findsOneWidget);

      // 100%のテスト
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 1.0,
              onChanged: (value) {},
            ),
          ),
        ),
      );
      
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('中間値の表示が正しい', (WidgetTester tester) async {
      // 75%のテスト
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 0.75,
              onChanged: (value) {},
            ),
          ),
        ),
      );
      
      expect(find.text('75%'), findsOneWidget);

      // 33%のテスト（0.33 → 33%）
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 0.33,
              onChanged: (value) {},
            ),
          ),
        ),
      );
      
      expect(find.text('33%'), findsOneWidget);
    });

    testWidgets('スライダーの分割数が正しい', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 0.5,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.divisions, 100); // 1%刻みで100分割
      expect(slider.min, 0.0);
      expect(slider.max, 1.0);
    });

    testWidgets('テーマカラーが正しく適用される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            body: OverlayOpacitySlider(
              value: 0.5,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // テーマから実際のプライマリカラーを取得
      final BuildContext context = tester.element(find.byType(OverlayOpacitySlider));
      final expectedColor = Theme.of(context).primaryColor.withOpacity(0.1);

      // パーセンテージ表示のコンテナの背景色をチェック
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('50%'),
          matching: find.byType(Container),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, expectedColor);
    });
  });
}
