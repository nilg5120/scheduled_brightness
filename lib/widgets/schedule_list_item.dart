import 'package:flutter/material.dart';
import '../models/brightness_schedule.dart';

// スケジュールリストアイテムのウィジェット
class ScheduleListItem extends StatelessWidget {
  // スケジュールデータ
  final BrightnessSchedule schedule;
  
  // 編集ボタンが押されたときのコールバック
  final Function(BrightnessSchedule) onEdit;
  
  // 削除ボタンが押されたときのコールバック
  final Function(String) onDelete;
  
  // 有効/無効スイッチが切り替えられたときのコールバック
  final Function(String) onToggleEnabled;

  // コンストラクタ
  const ScheduleListItem({
    super.key,
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 時刻表示
            Expanded(
              flex: 2,
              child: Text(
                schedule.getTimeString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // 明るさモードと値の表示
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // モード表示（自動/手動）
                  Row(
                    children: [
                      Icon(
                        schedule.isAutoMode
                            ? Icons.brightness_auto
                            : Icons.brightness_6,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.isAutoMode ? '自動モード' : '手動モード',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  // 明るさ値の表示（手動モードの場合）
                  if (!schedule.isAutoMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '明るさ: ${schedule.getBrightnessPercentage()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 有効/無効スイッチ
            Switch(
              value: schedule.isEnabled,
              onChanged: (_) => onToggleEnabled(schedule.id),
              activeColor: Theme.of(context).primaryColor,
            ),
            
            // 編集ボタン
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => onEdit(schedule),
              color: Colors.blue,
              splashRadius: 24,
            ),
            
            // 削除ボタン
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => onDelete(schedule.id),
              color: Colors.red,
              splashRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
}
