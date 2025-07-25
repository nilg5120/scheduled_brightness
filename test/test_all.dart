import 'package:flutter_test/flutter_test.dart';

// モデルテスト
import 'models/app_settings_test.dart' as app_settings_test;

// サービステスト
import 'services/brightness_service_test.dart' as brightness_service_test;

// プロバイダーテスト
import 'providers/settings_provider_test.dart' as settings_provider_test;

// ウィジェットテスト
import 'widgets/overlay_opacity_slider_test.dart' as overlay_opacity_slider_test;

// 統合テスト
import 'integration/overlay_integration_test.dart' as overlay_integration_test;

void main() {
  group('黒オーバーレイ機能テストスイート', () {
    group('モデルテスト', () {
      app_settings_test.main();
    });

    group('サービステスト', () {
      brightness_service_test.main();
    });

    group('プロバイダーテスト', () {
      settings_provider_test.main();
    });

    group('ウィジェットテスト', () {
      overlay_opacity_slider_test.main();
    });

    group('統合テスト', () {
      overlay_integration_test.main();
    });
  });
}
