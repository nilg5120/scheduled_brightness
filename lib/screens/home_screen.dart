import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/schedule_list_item.dart';
import '../models/brightness_schedule.dart';
import 'schedule_edit_screen.dart';
import 'settings_screen.dart';

// ホーム画面（スケジュール一覧）
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール一覧'),
        actions: [
          // 設定画面へのボタン
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 現在の明るさ状態表示
          _buildBrightnessStatusCard(context),
          
          // スケジュール一覧
          Expanded(
            child: _buildScheduleList(context),
          ),
        ],
      ),
      // スケジュール追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewSchedule(context),
        child: const Icon(Icons.add),
        tooltip: 'スケジュールを追加',
      ),
    );
  }

  // 現在の明るさ状態を表示するカード
  Widget _buildBrightnessStatusCard(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 上段：明るさ状態とオーバーレイ状態
            Row(
              children: [
                // 明るさアイコン
                Icon(
                  settingsProvider.isAutoModeEnabled
                      ? Icons.brightness_auto
                      : Icons.brightness_6,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                
                // 明るさモード表示
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingsProvider.isAutoModeEnabled ? '自動明るさ' : '手動明るさ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (settingsProvider.isOverlayActive)
                        Text(
                          'オーバーレイ: ${(settingsProvider.overlayOpacity * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // オーバーレイ切り替えボタン
                IconButton(
                  onPressed: () async {
                    final success = await settingsProvider.toggleOverlay();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('オーバーレイの切り替えに失敗しました'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    settingsProvider.isOverlayActive 
                        ? Icons.layers 
                        : Icons.layers_outlined,
                    color: settingsProvider.isOverlayActive 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey,
                  ),
                  tooltip: settingsProvider.isOverlayActive 
                      ? 'オーバーレイを非表示' 
                      : 'オーバーレイを表示',
                ),
                
                // 権限がない場合の警告アイコン
                if (!settingsProvider.hasWriteSettingsPermission)
                  Tooltip(
                    message: '権限が必要です。設定画面で許可してください。',
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber[700],
                    ),
                  ),
              ],
            ),
            
            // オーバーレイがアクティブな場合の詳細情報
            if (settingsProvider.isOverlayActive) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '画面に黒いオーバーレイが適用されています',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // スケジュール一覧を表示するウィジェット
  Widget _buildScheduleList(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final schedules = scheduleProvider.schedules;
    
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          'スケジュールがありません\n＋ボタンから追加してください',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: schedules.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return ScheduleListItem(
          schedule: schedule,
          onEdit: (schedule) => _editSchedule(context, schedule),
          onDelete: (id) => _deleteSchedule(context, id),
          onToggleEnabled: (id) => scheduleProvider.toggleScheduleEnabled(id),
        );
      },
    );
  }

  // 新しいスケジュールを追加する処理
  void _addNewSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleEditScreen(),
      ),
    );
  }

  // スケジュールを編集する処理
  void _editSchedule(BuildContext context, BrightnessSchedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleEditScreen(schedule: schedule),
      ),
    );
  }

  // スケジュールを削除する処理
  void _deleteSchedule(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スケジュールの削除'),
        content: const Text('このスケジュールを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ScheduleProvider>(context, listen: false)
                  .deleteSchedule(id);
              Navigator.pop(context);
            },
            child: const Text('削除'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
