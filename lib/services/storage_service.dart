import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/brightness_schedule.dart';
import '../models/app_settings.dart';

// データの永続化を担当するサービスクラス
class StorageService {
  // ログ出力用のインスタンス
  static final Logger _logger = Logger();
  
  // SharedPreferencesのキー
  static const String _schedulesKey = 'brightness_schedules';
  static const String _settingsKey = 'app_settings';

  // スケジュールを保存するメソッド
  Future<void> saveSchedules(List<BrightnessSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = schedules.map((schedule) => schedule.toJson()).toList();
    await prefs.setString(_schedulesKey, jsonEncode(schedulesJson));
  }

  // スケジュールを読み込むメソッド
  Future<List<BrightnessSchedule>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesString = prefs.getString(_schedulesKey);
    
    if (schedulesString == null) {
      return [];
    }
    
    try {
      final schedulesJson = jsonDecode(schedulesString) as List;
      return schedulesJson
          .map((scheduleJson) => BrightnessSchedule.fromJson(scheduleJson))
          .toList();
    } catch (e) {
      _logger.e('スケジュールの読み込みエラー', error: e);
      return [];
    }
  }

  // アプリ設定を保存するメソッド
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // アプリ設定を読み込むメソッド
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey);
    
    if (settingsString == null) {
      return AppSettings();
    }
    
    try {
      final settingsJson = jsonDecode(settingsString);
      return AppSettings.fromJson(settingsJson);
    } catch (e) {
      _logger.e('設定の読み込みエラー', error: e);
      return AppSettings();
    }
  }
}
