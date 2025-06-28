// アプリ設定のデータモデル
class AppSettings {
  // 自動明るさモードが有効かどうか
  bool isAutoModeEnabled;
  
  // 黒オーバーレイモードを使用するかどうか
  bool useOverlayMode;
  
  // WRITE_SETTINGS権限が許可されているかどうか
  bool hasWriteSettingsPermission;

  // コンストラクタ
  AppSettings({
    this.isAutoModeEnabled = false,
    this.useOverlayMode = false,
    this.hasWriteSettingsPermission = false,
  });

  // JSONからオブジェクトを生成するファクトリコンストラクタ
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isAutoModeEnabled: json['isAutoModeEnabled'] ?? false,
      useOverlayMode: json['useOverlayMode'] ?? false,
      hasWriteSettingsPermission: json['hasWriteSettingsPermission'] ?? false,
    );
  }

  // オブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'isAutoModeEnabled': isAutoModeEnabled,
      'useOverlayMode': useOverlayMode,
      'hasWriteSettingsPermission': hasWriteSettingsPermission,
    };
  }

  // 設定のコピーを作成するメソッド
  AppSettings copyWith({
    bool? isAutoModeEnabled,
    bool? useOverlayMode,
    bool? hasWriteSettingsPermission,
  }) {
    return AppSettings(
      isAutoModeEnabled: isAutoModeEnabled ?? this.isAutoModeEnabled,
      useOverlayMode: useOverlayMode ?? this.useOverlayMode,
      hasWriteSettingsPermission: hasWriteSettingsPermission ?? this.hasWriteSettingsPermission,
    );
  }
}
