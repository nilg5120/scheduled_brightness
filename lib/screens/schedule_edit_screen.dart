import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import '../models/brightness_schedule.dart';
import '../providers/schedule_provider.dart';
import '../widgets/brightness_slider.dart';

// スケジュール追加・編集画面
class ScheduleEditScreen extends StatefulWidget {
  // 編集対象のスケジュール（新規作成の場合はnull）
  final BrightnessSchedule? schedule;

  // コンストラクタ
  const ScheduleEditScreen({super.key, this.schedule});

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  // 時刻（時）
  late int _hour;
  
  // 時刻（分）
  late int _minute;
  
  // 明るさの値（0.0〜1.0）
  late double _brightness;
  
  // 自動明るさモードを使用するかどうか
  late bool _isAutoMode;
  
  // スケジュールが有効かどうか
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    
    // 編集モードの場合は既存のスケジュールの値を設定
    if (widget.schedule != null) {
      _hour = widget.schedule!.hour;
      _minute = widget.schedule!.minute;
      _brightness = widget.schedule!.brightness;
      _isAutoMode = widget.schedule!.isAutoMode;
      _isEnabled = widget.schedule!.isEnabled;
    } else {
      // 新規作成モードの場合はデフォルト値を設定
      final now = DateTime.now();
      _hour = now.hour;
      _minute = now.minute;
      _brightness = 0.5; // デフォルトは50%
      _isAutoMode = false;
      _isEnabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'スケジュール追加' : 'スケジュール編集'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 時刻選択
            _buildTimePickerSection(),
            
            const SizedBox(height: 24),
            
            // 明るさモード選択
            _buildBrightnessModeSection(),
            
            const SizedBox(height: 24),
            
            // 明るさスライダー
            BrightnessSlider(
              value: _brightness,
              onChanged: (value) {
                setState(() {
                  _brightness = value;
                });
              },
              isAutoMode: _isAutoMode,
            ),
            
            const SizedBox(height: 24),
            
            // 有効/無効スイッチ
            _buildEnabledSwitch(),
            
            const SizedBox(height: 32),
            
            // 保存/キャンセルボタン
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // 時刻選択セクション
  Widget _buildTimePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '時刻',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TimePickerSpinner(
            is24HourMode: true,
            normalTextStyle: const TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
            highlightedTextStyle: TextStyle(
              fontSize: 32,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            spacing: 40,
            itemHeight: 60,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                _hour = time.hour;
                _minute = time.minute;
              });
            },
            time: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              _hour,
              _minute,
            ),
          ),
        ),
      ],
    );
  }

  // 明るさモード選択セクション
  Widget _buildBrightnessModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '明るさモード',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Row(
                  children: [
                    Icon(Icons.brightness_auto, size: 20),
                    SizedBox(width: 8),
                    Text('自動'),
                  ],
                ),
                value: true,
                groupValue: _isAutoMode,
                onChanged: (value) {
                  setState(() {
                    _isAutoMode = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Row(
                  children: [
                    Icon(Icons.brightness_6, size: 20),
                    SizedBox(width: 8),
                    Text('手動'),
                  ],
                ),
                value: false,
                groupValue: _isAutoMode,
                onChanged: (value) {
                  setState(() {
                    _isAutoMode = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 有効/無効スイッチ
  Widget _buildEnabledSwitch() {
    return SwitchListTile(
      title: const Text(
        'スケジュールを有効にする',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        _isEnabled ? 'スケジュールは有効です' : 'スケジュールは無効です',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      value: _isEnabled,
      onChanged: (value) {
        setState(() {
          _isEnabled = value;
        });
      },
      activeColor: Theme.of(context).primaryColor,
    );
  }

  // 保存/キャンセルボタン
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // キャンセルボタン
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        const SizedBox(width: 16),
        
        // 保存ボタン
        ElevatedButton(
          onPressed: () => _saveSchedule(context),
          child: const Text('保存'),
        ),
      ],
    );
  }

  // スケジュールを保存する処理
  void _saveSchedule(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    
    if (widget.schedule == null) {
      // 新規作成の場合
      scheduleProvider.addSchedule(
        _hour,
        _minute,
        _brightness,
        _isAutoMode,
      );
    } else {
      // 編集の場合
      scheduleProvider.updateSchedule(
        widget.schedule!.id,
        _hour,
        _minute,
        _brightness,
        _isAutoMode,
        _isEnabled,
      );
    }
    
    Navigator.pop(context);
  }
}
