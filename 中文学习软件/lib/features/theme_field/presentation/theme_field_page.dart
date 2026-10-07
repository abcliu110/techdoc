import 'package:flutter/material.dart' hide Theme;
import 'package:flutter/material.dart' as material show Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_field_provider.dart';
import '../models/theme_model.dart';
import '../widgets/theme_card.dart';
import 'theme_detail_page.dart';

/// 主题词场首页
class ThemeFieldPage extends ConsumerStatefulWidget {
  const ThemeFieldPage({super.key});

  @override
  ConsumerState<ThemeFieldPage> createState() => _ThemeFieldPageState();
}

class _ThemeFieldPageState extends ConsumerState<ThemeFieldPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化预设主题数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initThemeDataProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedThemeCategoryProvider);
    final themesAsync = selectedCategory == null
        ? ref.watch(allThemesProvider)
        : ref.watch(filteredThemesProvider);
    final searchQuery = ref.watch(themeSearchQueryProvider);
    final searchResults = ref.watch(themeSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题词场'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏（如果有搜索关键词）
          if (searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Text('搜索: "$searchQuery"'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(themeSearchQueryProvider.notifier).state = '';
                      _searchController.clear();
                    },
                    child: const Text('清除'),
                  ),
                ],
              ),
            ),

          // 分类筛选
          _buildCategoryFilter(selectedCategory),

          // 主题列表
          Expanded(
            child: searchQuery.isNotEmpty
                ? _buildSearchResults(searchResults)
                : _buildThemeList(themesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeCategory? selectedCategory) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _CategoryChip(
            label: '全部',
            isSelected: selectedCategory == null,
            onTap: () {
              ref.read(selectedThemeCategoryProvider.notifier).state = null;
            },
          ),
          ...ThemeCategory.values.map((category) {
            return _CategoryChip(
              label: category.label,
              isSelected: selectedCategory == category,
              onTap: () {
                ref.read(selectedThemeCategoryProvider.notifier).state = category;
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThemeList(AsyncValue<List<Theme>> themesAsync) {
    return themesAsync.when(
      data: (themes) {
        if (themes.isEmpty) {
          return const Center(
            child: Text('暂无主题数据'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allThemesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ThemeCard(
                  theme: theme,
                  onTap: () => _navigateToDetail(theme),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allThemesProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Theme>> searchResults) {
    return searchResults.when(
      data: (themes) {
        if (themes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('未找到匹配的主题'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(themeSearchQueryProvider.notifier).state = '';
                    _searchController.clear();
                  },
                  child: const Text('清除搜索'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ThemeCard(
                theme: theme,
                onTap: () => _navigateToDetail(theme),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('搜索失败: $error'),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('搜索主题'),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入主题名称或描述...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              ref.read(themeSearchQueryProvider.notifier).state = value;
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(themeSearchQueryProvider.notifier).state =
                    _searchController.text;
                Navigator.pop(context);
              },
              child: const Text('搜索'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetail(Theme theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThemeDetailPage(themeId: theme.id, theme: theme),
      ),
    );
  }
}

/// 分类筛选标签
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: material.Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: material.Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected
              ? material.Theme.of(context).primaryColor
              : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
