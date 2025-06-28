import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
              
              // 明るさ設定セクション
              _buildBrightnessSettingsSection(settingsProvider),
              
              const Divider(),
              
              // その他の設定セクション
              _buildOtherSettingsSection(settingsProvider),
              
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

  // 明るさ設定セクションを構築
  Widget _buildBrightnessSettingsSection(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            '明るさ設定',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('自動明るさモード'),
          subtitle: const Text('周囲の環境に応じて明るさを自動調整します'),
          value: settingsProvider.isAutoModeEnabled,
          onChanged: settingsProvider.hasWriteSettingsPermission
              ? (value) async {
                  await settingsProvider.toggleAutoMode();
                }
              : null,
          secondary: const Icon(Icons.brightness_auto),
        ),
      ],
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
