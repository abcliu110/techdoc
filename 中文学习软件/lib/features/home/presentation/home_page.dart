import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../six_book/presentation/six_book_page.dart';
import '../../family/presentation/family_page.dart';
import '../../search/presentation/search_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../radical/presentation/radical_index_page.dart';
import '../../theme_field/presentation/theme_field_page.dart';
import '../../origin_explore/presentation/origin_explore_page.dart';
import '../../similar_char/presentation/similar_char_list_page.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../../more/presentation/more_page.dart';

/// 首页 - 工具型应用
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汉字工具箱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索栏
            _buildSearchBar(context),
            const SizedBox(height: 24),

            // 核心功能区 - P0
            _buildSectionTitle('核心功能'),
            const SizedBox(height: 12),
            _buildCoreFeatures(context),
            const SizedBox(height: 24),

            // 特色功能区 - P1
            _buildSectionTitle('特色功能'),
            const SizedBox(height: 12),
            _buildSpecialFeatures(context),
            const SizedBox(height: 24),

            // 数据统计
            _buildStats(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              '快速查询汉字、拼音、部首...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCoreFeatures(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _FeatureCard(
          icon: Icons.auto_stories,
          title: '六书字典',
          subtitle: '象形/指事/会意/形声',
          color: AppTheme.accent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SixBookPage()),
            );
          },
        ),
        _FeatureCard(
          icon: Icons.account_tree,
          title: '字族图谱',
          subtitle: '声旁归类，批量学习',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FamilyPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialFeatures(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        _FeatureCard(
          icon: Icons.dashboard,
          title: '部首索引',
          subtitle: '',
          color: Colors.green,
          small: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RadicalIndexPage()),
            );
          },
        ),
        _FeatureCard(
          icon: Icons.category,
          title: '主题词场',
          subtitle: '',
          color: Colors.purple,
          small: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeFieldPage()),
            );
          },
        ),
        _FeatureCard(
          icon: Icons.history_edu,
          title: '字源探索',
          subtitle: '',
          color: Colors.orange,
          small: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OriginExplorePage()),
            );
          },
        ),
        _FeatureCard(
          icon: Icons.compare_arrows,
          title: '形近对比',
          subtitle: '',
          color: Colors.red,
          small: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SimilarCharListPage()),
            );
          },
        ),
        _FeatureCard(
          icon: Icons.bookmark,
          title: '我的收藏',
          subtitle: '',
          color: Colors.teal,
          small: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            );
          },
        ),
        _FeatureCard(
          icon: Icons.more_horiz,
          title: '更多功能',
          subtitle: '',
          color: Colors.grey,
          small: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MorePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数据概览',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: '汉字总数', value: '100', icon: Icons.text_fields),
                _StatItem(label: '字族数量', value: '12', icon: Icons.account_tree),
                _StatItem(label: '例词数量', value: '200+', icon: Icons.library_books),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 功能卡片
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool small;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.small = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (small) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 统计项
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accent, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
