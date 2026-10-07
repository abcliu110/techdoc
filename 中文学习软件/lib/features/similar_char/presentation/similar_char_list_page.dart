import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/similar_char_model.dart';
import '../providers/similar_char_provider.dart';
import 'similar_char_detail_page.dart';

/// 形近字对比列表页
class SimilarCharListPage extends ConsumerStatefulWidget {
  const SimilarCharListPage({super.key});

  @override
  ConsumerState<SimilarCharListPage> createState() => _SimilarCharListPageState();
}

class _SimilarCharListPageState extends ConsumerState<SimilarCharListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(similarCharListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('形近字对比'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: '筛选',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 筛选区
          if (_showFilters) _buildFilterSection(state),
          // 分组列表
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredGroups.isEmpty
                    ? _buildEmptyState()
                    : _buildGroupList(state.filteredGroups),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索形近字组...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(similarCharListProvider.notifier).search('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.background,
        ),
        onChanged: (value) {
          ref.read(similarCharListProvider.notifier).search(value);
        },
      ),
    );
  }

  /// 构建筛选区
  Widget _buildFilterSection(SimilarCharListState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 难度筛选
          const Text(
            '难度',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: '全部',
                isSelected: state.difficultyFilter == null,
                onTap: () => ref.read(similarCharListProvider.notifier).filterByDifficulty(null),
              ),
              ...DifficultyLevel.values.map((level) {
                return _buildFilterChip(
                  label: '${level.emoji} ${level.label}',
                  isSelected: state.difficultyFilter == level.code,
                  onTap: () => ref.read(similarCharListProvider.notifier).filterByDifficulty(level.code),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          // 分类筛选
          const Text(
            '分类',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: '全部',
                isSelected: state.categoryFilter == null,
                onTap: () => ref.read(similarCharListProvider.notifier).filterByCategory(null),
              ),
              ...SimilarCategory.values.map((cat) {
                return _buildFilterChip(
                  label: cat.label,
                  isSelected: state.categoryFilter == cat.label,
                  onTap: () => ref.read(similarCharListProvider.notifier).filterByCategory(cat.label),
                );
              }),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  /// 构建分组列表
  Widget _buildGroupList(List<SimilarCharGroup> groups) {
    // 按难度分组
    final easyGroups = groups.where((g) => g.difficultyLevel == 'easy').toList();
    final mediumGroups = groups.where((g) => g.difficultyLevel == 'medium').toList();
    final hardGroups = groups.where((g) => g.difficultyLevel == 'hard').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (easyGroups.isNotEmpty) ...[
          _buildSectionHeader('高频易混', Colors.green),
          ...easyGroups.map((g) => _buildGroupCard(g)),
          const SizedBox(height: 24),
        ],
        if (mediumGroups.isNotEmpty) ...[
          _buildSectionHeader('部件混淆', Colors.orange),
          ...mediumGroups.map((g) => _buildGroupCard(g)),
          const SizedBox(height: 24),
        ],
        if (hardGroups.isNotEmpty) ...[
          _buildSectionHeader('相似笔画', Colors.red),
          ...hardGroups.map((g) => _buildGroupCard(g)),
        ],
      ],
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个分组卡片
  Widget _buildGroupCard(SimilarCharGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 汉字展示行
              Row(
                children: [
                  // 字符展示
                  Expanded(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: group.chars.map((char) {
                        return Column(
                          children: [
                            Text(
                              char.character,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              char.pinyin,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  // 收藏图标
                  if (group.isFavorite)
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                  // 难度指示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(group.difficultyLevel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DifficultyLevel.fromCode(group.difficultyLevel).label,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getDifficultyColor(group.difficultyLevel),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 描述
              Text(
                group.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // 标签行
              Row(
                children: [
                  _buildTag(group.category),
                  if (group.memoryTip.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildTag(group.memoryTip, isMemorTip: true),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取难度对应的颜色
  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 构建标签
  Widget _buildTag(String text, {bool isMemorTip = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMemorTip ? Colors.amber.shade50 : AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMemorTip) ...[
            const Icon(Icons.lightbulb_outline, size: 12, color: Colors.amber),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMemorTip ? Colors.amber.shade700 : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            '没有找到匹配的形近字组',
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(similarCharListProvider.notifier).clearFilters();
            },
            child: const Text('清除筛选'),
          ),
        ],
      ),
    );
  }

  /// 导航到详情页
  void _navigateToDetail(SimilarCharGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimilarCharDetailPage(group: group),
      ),
    );
  }
}
