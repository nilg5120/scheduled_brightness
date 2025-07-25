# 黒オーバーレイ機能テストスイート

このディレクトリには、黒オーバーレイ機能（限界を超えて画面を暗くする機能）の包括的なテストが含まれています。

## テスト構成

### 1. モデルテスト (`models/`)
- **app_settings_test.dart**: AppSettingsモデルのテスト
  - デフォルト値の検証
  - JSON変換の往復テスト
  - copyWithメソッドの動作確認
  - 境界値テスト

### 2. サービステスト (`services/`)
- **brightness_service_test.dart**: BrightnessServiceのテスト
  - MethodChannelのモック
  - オーバーレイ表示/非表示機能
  - 不透明度設定機能
  - エラーハンドリング
  - 権限チェック機能

### 3. プロバイダーテスト (`providers/`)
- **settings_provider_test.dart**: SettingsProviderのテスト
  - 状態管理の検証
  - オーバーレイ制御機能
  - 不透明度設定とリアルタイム反映
  - エラーハンドリング
  - 通知機能（notifyListeners）

### 4. ウィジェットテスト (`widgets/`)
- **overlay_opacity_slider_test.dart**: OverlayOpacitySliderのテスト
  - UI表示の検証
  - スライダー操作
  - プリセットボタン機能
  - 有効/無効状態の切り替え
  - 境界値表示

### 5. 統合テスト (`integration/`)
- **overlay_integration_test.dart**: 機能全体の統合テスト
  - プロバイダーとウィジェットの連携
  - エラー処理の統合テスト
  - 複数操作の連続実行
  - 境界値での動作確認

## テスト実行方法

### 全テスト実行
```bash
flutter test
```

### 特定のテストファイル実行
```bash
flutter test test/models/app_settings_test.dart
flutter test test/services/brightness_service_test.dart
flutter test test/providers/settings_provider_test.dart
flutter test test/widgets/overlay_opacity_slider_test.dart
flutter test test/integration/overlay_integration_test.dart
```

### テストスイート全体実行
```bash
flutter test test/test_all.dart
```

## テスト対象機能

### 黒オーバーレイ機能
1. **オーバーレイ表示/非表示**
   - `showOverlay()`: 指定した不透明度でオーバーレイを表示
   - `hideOverlay()`: オーバーレイを非表示
   - `toggleOverlay()`: オーバーレイの表示/非表示を切り替え

2. **不透明度制御**
   - 0.0～1.0の範囲で不透明度を設定
   - リアルタイムでの不透明度変更
   - プリセット値（軽く20%、普通50%、強く80%）

3. **状態管理**
   - オーバーレイの表示状態追跡
   - 設定の永続化
   - 状態変更の通知

4. **エラーハンドリング**
   - 権限不足時の適切な処理
   - Android側エラーの処理
   - ユーザーへのフィードバック

## テスト結果の確認

### 成功例
```
00:01 +7: All tests passed!
```

### 失敗例
```
00:01 +9 -1: Some tests failed.
```

## 注意事項

1. **権限テスト**: 一部の権限関連テストは、実際のデバイスでのみ正常に動作する場合があります。

2. **MethodChannelモック**: Android側の実装をモックしているため、実際のオーバーレイ表示は行われません。

3. **非同期処理**: 多くのテストで非同期処理を扱うため、`await`キーワードの適切な使用が重要です。

## カバレッジ

このテストスイートは以下の項目をカバーしています：

- ✅ モデルのデータ変換
- ✅ サービスのMethodChannel通信
- ✅ プロバイダーの状態管理
- ✅ ウィジェットのUI動作
- ✅ 統合的な機能動作
- ✅ エラーハンドリング
- ✅ 境界値処理

## 今後の改善点

1. **カバレッジレポート**: テストカバレッジの可視化
2. **パフォーマンステスト**: 大量の不透明度変更時の性能テスト
3. **アクセシビリティテスト**: 視覚障害者向けの機能テスト
4. **実機テスト**: 実際のAndroidデバイスでの動作確認
