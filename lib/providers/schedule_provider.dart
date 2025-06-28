import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/brightness_schedule.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';

// スケジュール管理のためのプロバイダークラス
class ScheduleProvider with ChangeNotifier {
  List<BrightnessSchedule> _schedules = [];
  final StorageService _storageService = StorageService();
  final AlarmService _alarmService = AlarmService();
  final _uuid = Uuid();

  // スケジュールのリストを取得するゲッター
  List<BrightnessSchedule> get schedules => _schedules;

  // コンストラクタ
  ScheduleProvider() {
    _loadSchedules();
  }

  // スケジュールを読み込むメソッド
  Future<void> _loadSchedules() async {
    _schedules = await _storageService.loadSchedules();
    _schedules.sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour.compareTo(b.hour);
      }
      return a.minute.compareTo(b.minute);
    });
    notifyListeners();
  }

  // スケジュールを保存するメソッド
  Future<void> _saveSchedules() async {
    await _storageService.saveSchedules(_schedules);
    await _alarmService.rescheduleAllAlarms(_schedules);
  }

  // スケジュールを追加するメソッド
  Future<void> addSchedule(int hour, int minute, double brightness, bool isAutoMode) async {
    final newSchedule = BrightnessSchedule(
      id: _uuid.v4(),
      hour: hour,
      minute: minute,
      brightness: brightness,
      isAutoMode: isAutoMode,
      isEnabled: true,
    );
    
    _schedules.add(newSchedule);
    _schedules.sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour.compareTo(b.hour);
      }
      return a.minute.compareTo(b.minute);
    });
    
    notifyListeners();
    await _saveSchedules();
  }

  // スケジュールを更新するメソッド
  Future<void> updateSchedule(
    String id,
    int hour,
    int minute,
    double brightness,
    bool isAutoMode,
    bool isEnabled,
  ) async {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);
    if (index != -1) {
      _schedules[index] = BrightnessSchedule(
        id: id,
        hour: hour,
        minute: minute,
        brightness: brightness,
        isAutoMode: isAutoMode,
        isEnabled: isEnabled,
      );
      
      _schedules.sort((a, b) {
        if (a.hour != b.hour) {
          return a.hour.compareTo(b.hour);
        }
        return a.minute.compareTo(b.minute);
      });
      
      notifyListeners();
      await _saveSchedules();
    }
  }

  // スケジュールを削除するメソッド
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((schedule) => schedule.id == id);
    notifyListeners();
    await _saveSchedules();
  }

  // スケジュールの有効/無効を切り替えるメソッド
  Future<void> toggleScheduleEnabled(String id) async {
    final index = _schedules.indexWhere((schedule) => schedule.id == id);
    if (index != -1) {
      _schedules[index].isEnabled = !_schedules[index].isEnabled;
      notifyListeners();
      await _saveSchedules();
    }
  }

  // すべてのスケジュールを再読み込みするメソッド
  Future<void> reloadSchedules() async {
    await _loadSchedules();
  }
}
