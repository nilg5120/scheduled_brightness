import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/overlay_opacity_slider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // アプリのバージョン情報
  String _version = '';
  
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  // アプリのバージョン情報を読み込む
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            children: [
              // 権限セクション
              _buildPermissionSection(context, settingsProvider),
              
              const Divider(),
              
              // その他の設定セクション
              _buildOtherSettingsSection(settingsProvider),
              
              const Divider(),
              
              // オーバーレイ制御セクション
              _buildOverlayControlSection(settingsProvider),
              
              const Divider(),
              
              // アプリ情報セクション
              _buildAppInfoSection(),
            ],
          );
        },
      ),
    );
  }

  // 権限セクションを構築
  Widget _buildPermissionSection(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return ListTile(
      title: const Text(
        'システム設定の変更権限',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        settingsProvider.hasWriteSettingsPermission
            ? '権限が許可されています'
            : '明るさを変更するには権限が必要です',
      ),
      leading: Icon(
        settingsProvider.hasWriteSettingsPermission
            ? Icons.check_circle
            : Icons.warning,
        color: settingsProvider.hasWriteSettingsPermission
            ? Colors.green
            : Colors.orange,
      ),
      trailing: settingsProvider.hasWriteSettingsPermission
          ? null
          : ElevatedButton(
              onPressed: () async {
                await settingsProvider.requestWriteSettingsPermission();
                // 権限ダイアログから戻ってきたら状態を更新
                if (mounted) {
                  await settingsProvider.updatePermissionStatus();
                }
              },
              child: const Text('許可する'),
            ),
    );
  }

  // その他の設定セクションを構築
  Widget _buildOtherSettingsSection(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'その他の設定',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('黒オーバーレイモード'),
          subtitle: const Text('明るさ変更が制限されている端末で代替手段として使用します'),
          value: settingsProvider.useOverlayMode,
          onChanged: (value) async {
            await settingsProvider.toggleOverlayMode();
          },
          secondary: const Icon(Icons.layers),
        ),
      ],
    );
  }

  // オーバーレイ制御セクションを構築
  Widget _buildOverlayControlSection(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'オーバーレイ制御',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        
        // オーバーレイON/OFFスイッチ
        SwitchListTile(
          title: const Text('オーバーレイを表示'),
          subtitle: Text(
            settingsProvider.isOverlayActive
                ? 'オーバーレイが表示されています'
                : 'オーバーレイは非表示です',
          ),
          value: settingsProvider.isOverlayActive,
          onChanged: (value) async {
            // オーバーレイ権限をチェック・要求
            final granted = await Permission.systemAlertWindow.isGranted ||
                await Permission.systemAlertWindow.request().isGranted;

            if (!granted) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('オーバーレイの権限が必要です。設定から許可してください。'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              return;
            }

            // 権限がある場合のみ切り替え
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
          secondary: Icon(
            settingsProvider.isOverlayActive ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        
        // 不透明度調整スライダー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OverlayOpacitySlider(
            value: settingsProvider.overlayOpacity,
            onChanged: (value) async {
              await settingsProvider.setOverlayOpacity(value);
            },
            enabled: true,
          ),
        ),
        
        // 説明テキスト
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'オーバーレイ機能を使用すると、通常の明度調整の限界を超えて画面をより暗くできます。',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  // アプリ情報セクションを構築
  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'アプリ情報',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          title: const Text('バージョン'),
          subtitle: Text(_version),
          leading: const Icon(Icons.info_outline),
        ),
        const ListTile(
          title: Text('開発者'),
          subtitle: Text('Scheduled Brightness Team'),
          leading: Icon(Icons.person),
        ),
      ],
    );
  }
}
