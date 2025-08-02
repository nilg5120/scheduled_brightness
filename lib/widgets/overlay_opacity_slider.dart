import 'package:flutter/material.dart';

// オーバーレイの不透明度を調整するスライダーウィジェット
class OverlayOpacitySlider extends StatelessWidget {
  final double value; // 現在の不透明度（0.0～1.0）
  final ValueChanged<double> onChanged; // 値が変更された時のコールバック
  final bool enabled; // スライダーが有効かどうか

  const OverlayOpacitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 0.0～1.0を0～100に変換
    final percentage = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ラベルと現在値の表示
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'オーバーレイ不透明度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // スライダー
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            valueIndicatorColor: Theme.of(context).primaryColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 100, // 1%刻みで調整可能
            label: '$percentage%',
            onChanged: enabled ? onChanged : null,
          ),
        ),
        
        // 説明テキスト
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '0%で完全に透明、100%で完全に不透明になります',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        
        // プリセットボタン
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPresetButton(context, '軽く', 0.2),
            const SizedBox(width: 8),
            _buildPresetButton(context, '普通', 0.5),
            const SizedBox(width: 8),
            _buildPresetButton(context, '強く', 0.8),
          ],
        ),
      ],
    );
  }

  // プリセットボタンを構築
  Widget _buildPresetButton(BuildContext context, String label, double presetValue) {
    final isSelected = (value - presetValue).abs() < 0.05; // 現在値に近い場合は選択状態
    
    return Expanded(
      child: OutlinedButton(
        onPressed: enabled ? () => onChanged(presetValue) : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected 
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
          side: BorderSide(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
