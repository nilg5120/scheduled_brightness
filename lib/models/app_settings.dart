// アプリ設定のデータモデル
class AppSettings {
  // 自動明るさモードが有効かどうか
  bool isAutoModeEnabled;
  
  // 黒オーバーレイモードを使用するかどうか
  bool useOverlayMode;
  
  // WRITE_SETTINGS権限が許可されているかどうか
  bool hasWriteSettingsPermission;
  
  // オーバーレイの不透明度（0.0～1.0、0%～100%に対応）
  double overlayOpacity;
  
  // オーバーレイが現在アクティブかどうか
  bool isOverlayActive;

  // コンストラクタ
  AppSettings({
    this.isAutoModeEnabled = false,
    this.useOverlayMode = false,
    this.hasWriteSettingsPermission = false,
    this.overlayOpacity = 0.5,
    this.isOverlayActive = false,
  });

  // JSONからオブジェクトを生成するファクトリコンストラクタ
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isAutoModeEnabled: json['isAutoModeEnabled'] ?? false,
      useOverlayMode: json['useOverlayMode'] ?? false,
      hasWriteSettingsPermission: json['hasWriteSettingsPermission'] ?? false,
      overlayOpacity: json['overlayOpacity'] ?? 0.5,
      isOverlayActive: json['isOverlayActive'] ?? false,
    );
  }

  // オブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'isAutoModeEnabled': isAutoModeEnabled,
      'useOverlayMode': useOverlayMode,
      'hasWriteSettingsPermission': hasWriteSettingsPermission,
      'overlayOpacity': overlayOpacity,
      'isOverlayActive': isOverlayActive,
    };
  }

  // 設定のコピーを作成するメソッド
  AppSettings copyWith({
    bool? isAutoModeEnabled,
    bool? useOverlayMode,
    bool? hasWriteSettingsPermission,
    double? overlayOpacity,
    bool? isOverlayActive,
  }) {
    return AppSettings(
      isAutoModeEnabled: isAutoModeEnabled ?? this.isAutoModeEnabled,
      useOverlayMode: useOverlayMode ?? this.useOverlayMode,
      hasWriteSettingsPermission: hasWriteSettingsPermission ?? this.hasWriteSettingsPermission,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      isOverlayActive: isOverlayActive ?? this.isOverlayActive,
    );
  }
}
