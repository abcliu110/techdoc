import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/radical_provider.dart';
import '../widgets/radical_tab_bar.dart';
import '../widgets/radical_card.dart';
import '../widgets/radical_search_bar.dart';
import '../models/radical_model.dart';
import '../../../core/theme/app_theme.dart';
import 'radical_detail_page.dart';

/// 部首索引页面
class RadicalIndexPage extends ConsumerStatefulWidget {
  const RadicalIndexPage({super.key});

  @override
  ConsumerState<RadicalIndexPage> createState() => _RadicalIndexPageState();
}

class _RadicalIndexPageState extends ConsumerState<RadicalIndexPage> {
  final Map<String, int> _radicalCountCache = {};
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRadicalCounts();
  }

  Future<void> _loadRadicalCounts() async {
    final statsAsync = ref.read(radicalStatsProvider);
    statsAsync.whenData((stats) {
      if (mounted) {
        setState(() {
          for (final stat in stats) {
            _radicalCountCache[stat.radical] = stat.count;
          }
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
    // 更新搜索查询 Provider
    ref.read(radicalSearchQueryProvider.notifier).state = query;
  }

  void _navigateToDetail(Radical radical) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RadicalDetailPage(radical: radical),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(radicalNotifierProvider);
    final selectedIndex = ref.watch(radicalTabIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('部首索引'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索栏
          RadicalSearchBar(
            onChanged: _onSearchChanged,
          ),

          // 分类Tab
          if (!_isSearching) const RadicalTabBar(),

          // 内容区
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildRadicalGrid(groups, selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '输入部首名称或字符搜索',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // 使用 Provider 进行搜索
    final searchResults = ref.watch(radicalSearchResultsProvider);

    return searchResults.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  '未找到 "$_searchQuery" 相关部首',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final radical = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadicalListTile(
                radical: radical,
                characterCount: _radicalCountCache[radical.character],
                onTap: () => _navigateToDetail(radical),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('搜索出错')),
    );
  }

  Widget _buildRadicalGrid(List<RadicalGroup> groups, int selectedIndex) {
    if (groups.isEmpty || selectedIndex >= groups.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final group = groups[selectedIndex];
    final radicals = group.radicals;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: radicals.length,
      itemBuilder: (context, index) {
        final radical = radicals[index];
        return RadicalGridCard(
          radical: radical,
          characterCount: _radicalCountCache[radical.character],
          onTap: () => _navigateToDetail(radical),
        );
      },
    );
  }
}
