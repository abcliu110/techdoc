import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/presentation/settings_page.dart';
import 'widgets/statistics_card.dart';
import 'widgets/menu_list_tile.dart';
import 'widgets/about_section.dart';

/// 更多功能页面
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更多功能'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 学习数据统计
            const StatisticsCard(),

            const SizedBox(height: 16),

            // 功能菜单
            _buildMenuSection(context),

            const SizedBox(height: 16),

            // 关于与帮助
            AboutSection(
              onHelpTap: () => _showHelpDialog(context),
              onAboutTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建菜单区域
  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '设置与工具',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                MenuListTile(
                  icon: Icons.track_changes,
                  title: '学习设置',
                  subtitle: '每日目标、提醒时间',
                  onTap: () => _navigateToSettings(context, tabIndex: 0),
                ),
                const Divider(height: 1),
                MenuListTile(
                  icon: Icons.notifications_outlined,
                  title: '提醒设置',
                  subtitle: '学习提醒开关与时间',
                  onTap: () => _navigateToSettings(context, tabIndex: 1),
                ),
                const Divider(height: 1),
                MenuListTile(
                  icon: Icons.analytics_outlined,
                  title: '数据管理',
                  subtitle: '导出、重置学习数据',
                  onTap: () => _navigateToSettings(context, tabIndex: 3),
                ),
                const Divider(height: 1),
                MenuListTile(
                  icon: Icons.family_restroom,
                  title: '家长模式',
                  subtitle: '开启学习报告和家长控制',
                  onTap: () => _navigateToSettings(context, tabIndex: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 导航到设置页面指定标签
  void _navigateToSettings(BuildContext context, {int tabIndex = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsPage(),
      ),
    );
  }

  /// 显示帮助对话框
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('使用帮助'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpSection(
                icon: Icons.auto_stories,
                title: '学习模式',
                items: [
                  '六书字典：按造字法学习汉字',
                  '字族图谱：以声旁为纽带批量学习',
                  '部首索引：通过部首查找汉字',
                  '主题词场：按主题分类学习词汇',
                ],
              ),
              SizedBox(height: 16),
              _HelpSection(
                icon: Icons.history,
                title: '复习方法',
                items: [
                  '间隔重复：根据遗忘曲线安排复习',
                  '每日任务：系统自动规划学习内容',
                  '形近对比：区分易混淆汉字',
                ],
              ),
              SizedBox(height: 16),
              _HelpSection(
                icon: Icons.lightbulb_outline,
                title: '学习技巧',
                items: [
                  '坚持每天学习，效果更佳',
                  '复习比学习新字更重要',
                  '书写练习有助于加深记忆',
                  '利用字族批量学习效率更高',
                ],
              ),
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

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: '汉字学习',
        applicationVersion: 'v1.0.0',
        applicationIcon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.chinese_restaurant,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ),
        applicationLegalese: '© 2026 汉字学习团队\n帮助 K12 学生高效认识汉字',
        children: const [
          SizedBox(height: 16),
          Text(
            '本应用基于汉字构造原理，结合现代教育心理学，'
            '帮助学生深刻理解汉字的构造逻辑与语义演变。',
          ),
        ],
      ),
    );
  }
}

/// 帮助章节组件
class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 26, bottom: 4),
              child: Text(
                '• $item',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            )),
      ],
    );
  }
}
