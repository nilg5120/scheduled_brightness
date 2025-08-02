import 'package:flutter/material.dart';

// 明るさスライダーのウィジェット
class BrightnessSlider extends StatelessWidget {
  // 現在の明るさ値（0.0〜1.0）
  final double value;
  
  // 値が変更されたときのコールバック
  final Function(double) onChanged;
  
  // 自動モードが有効かどうか
  final bool isAutoMode;

  // コンストラクタ
  const BrightnessSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.isAutoMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ラベルと現在の値（パーセント表示）
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '明るさ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isAutoMode ? Colors.grey : Colors.black,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isAutoMode ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
        ),
        
        // スライダー
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isAutoMode ? Colors.grey : null,
            inactiveTrackColor: isAutoMode ? Colors.grey.withOpacity(0.3) : null,
            thumbColor: isAutoMode ? Colors.grey : null,
            overlayColor: isAutoMode
                ? Colors.grey.withOpacity(0.2)
                : Theme.of(context).primaryColor.withOpacity(0.2),
            valueIndicatorColor: isAutoMode ? Colors.grey : null,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            label: '${(value * 100).round()}%',
            onChanged: isAutoMode ? null : onChanged,
          ),
        ),
        
        // 明るさアイコン表示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.brightness_low,
                size: 20,
                color: isAutoMode ? Colors.grey : Colors.black54,
              ),
              Icon(
                Icons.brightness_high,
                size: 20,
                color: isAutoMode ? Colors.grey : Colors.black54,
              ),
            ],
          ),
        ),
        
        // 自動モードの場合の注意表示
        if (isAutoMode)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '自動モードが有効なため、明るさは自動調整されます',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
