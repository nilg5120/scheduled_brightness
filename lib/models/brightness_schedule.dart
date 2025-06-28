// 明るさスケジュールのデータモデル
class BrightnessSchedule {
  // スケジュールの一意のID
  final String id;
  
  // スケジュールの時刻（時）
  final int hour;
  
  // スケジュールの時刻（分）
  final int minute;
  
  // 明るさの値（0.0〜1.0）
  final double brightness;
  
  // 自動明るさモードを使用するかどうか
  final bool isAutoMode;
  
  // スケジュールが有効かどうか
  bool isEnabled;

  // コンストラクタ
  BrightnessSchedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.brightness,
    required this.isAutoMode,
    this.isEnabled = true,
  });

  // JSONからオブジェクトを生成するファクトリコンストラクタ
  factory BrightnessSchedule.fromJson(Map<String, dynamic> json) {
    return BrightnessSchedule(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      brightness: json['brightness'],
      isAutoMode: json['isAutoMode'],
      isEnabled: json['isEnabled'],
    );
  }

  // オブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'brightness': brightness,
      'isAutoMode': isAutoMode,
      'isEnabled': isEnabled,
    };
  }

  // 時刻を文字列で取得するメソッド（例：07:30）
  String getTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // 明るさを百分率で取得するメソッド（例：75%）
  String getBrightnessPercentage() {
    return '${(brightness * 100).round()}%';
  }

  // スケジュールのコピーを作成するメソッド
  BrightnessSchedule copyWith({
    String? id,
    int? hour,
    int? minute,
    double? brightness,
    bool? isAutoMode,
    bool? isEnabled,
  }) {
    return BrightnessSchedule(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      brightness: brightness ?? this.brightness,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
