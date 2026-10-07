import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late UserSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await UserRepository().getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });
    await UserRepository().updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  title: '学习设置',
                  children: [
                    _buildDailyTargetSetting(),
                    _buildSoundSetting(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '提醒设置',
                  children: [
                    _buildNotificationSetting(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '家长模式',
                  children: [
                    _buildParentModeSetting(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '数据管理',
                  children: [
                    _buildDataManagement(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: '关于',
                  children: [
                    _buildAbout(),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTargetSetting() {
    return ListTile(
      title: const Text('每日学习目标'),
      subtitle: Text('${_settings.dailyTarget} 个字/天'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDailyTargetDialog(),
    );
  }

  void _showDailyTargetDialog() {
    final targets = [5, 10, 15, 20, 30, 50];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('每日学习目标'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: targets.map((target) {
            return RadioListTile<int>(
              title: Text('$target 个字/天'),
              value: target,
              groupValue: _settings.dailyTarget,
              onChanged: (value) {
                if (value != null) {
                  _updateSettings(_settings.copyWith(dailyTarget: value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSoundSetting() {
    return SwitchListTile(
      title: const Text('发音朗读'),
      subtitle: const Text('学习时播放汉字读音'),
      value: _settings.soundEnabled,
      onChanged: (value) {
        _updateSettings(_settings.copyWith(soundEnabled: value));
      },
    );
  }

  Widget _buildNotificationSetting() {
    return SwitchListTile(
      title: const Text('学习提醒'),
      subtitle: const Text('定时提醒复习已学汉字'),
      value: _settings.notificationEnabled,
      onChanged: (value) {
        _updateSettings(_settings.copyWith(notificationEnabled: value));
      },
    );
  }

  Widget _buildParentModeSetting() {
    return SwitchListTile(
      title: const Text('家长模式'),
      subtitle: const Text('开启后显示学习报告和统计'),
      value: _settings.parentModeEnabled,
      onChanged: (value) {
        _updateSettings(_settings.copyWith(parentModeEnabled: value));
      },
    );
  }

  Widget _buildDataManagement() {
    return Column(
      children: [
        ListTile(
          title: const Text('重置学习进度'),
          subtitle: const Text('清除所有学习记录，重新开始'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showResetConfirmDialog(),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('导出学习数据'),
          subtitle: const Text('将学习记录导出为文件'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('导出功能开发中...')),
            );
          },
        ),
      ],
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text(
          '确定要重置所有学习进度吗？\n\n'
          '这将清除：\n'
          '• 所有已学习汉字记录\n'
          '• 复习计划\n'
          '• 每日任务记录\n\n'
          '注意：此操作不可恢复！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    try {
      await UserRepository().resetAllProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('学习进度已重置')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重置失败: $e')),
        );
      }
    }
  }

  Widget _buildAbout() {
    return Column(
      children: [
        ListTile(
          title: const Text('版本信息'),
          subtitle: const Text('v1.0.0'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: '汉字学习',
              applicationVersion: 'v1.0.0',
              applicationLegalese: '© 2026 汉字学习团队',
              children: [
                const SizedBox(height: 16),
                const Text(
                  '帮助 K12 学生高效认识汉字，\n深刻理解汉字构造逻辑与语义演变。',
                ),
              ],
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('使用说明'),
          subtitle: const Text('学习方法和功能介绍'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHelpDialog(),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📚 学习模式',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 首页：查看每日任务和学习进度'),
              Text('• 字卡学习：按照任务学习新汉字'),
              Text('• 自由查询：搜索和查看汉字详情'),
              Text('• 复习巩固：复习已学汉字'),
              Text('• 书写练习：练习汉字书写'),
              SizedBox(height: 16),
              Text(
                '🎯 学习方法',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 形声规律：利用形旁和声旁理解汉字'),
              Text('• 字族学习：以声旁为纽带批量学习'),
              Text('• 间隔重复：根据遗忘曲线安排复习'),
              SizedBox(height: 16),
              Text(
                '💡 小贴士',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 坚持每天学习，效果更佳'),
              Text('• 复习比学习新字更重要'),
              Text('• 书写练习有助于加深记忆'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
