import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../detail/presentation/character_detail_page.dart';
import '../providers/favorite_provider.dart';

/// 收藏列表页面
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // 初始化加载
    Future.microtask(() {
      ref.read(favoriteListProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoriteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计卡片
          _buildStatsCard(state.stats),

          // 筛选标签栏
          _buildFilterBar(state.filter),

          // 收藏列表
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.characters.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoriteGrid(state.characters),
          ),
        ],
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatsCard(FavoriteStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 总数
          Expanded(
            child: Column(
              children: [
                Text(
                  '${stats.totalCount}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Text(
                  '收藏总数',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade300),
          // 学习进度
          Expanded(
            child: Column(
              children: [
                Text(
                  '${(stats.masteryRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                const Text(
                  '掌握进度',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade300),
          // 待复习
          Expanded(
            child: InkWell(
              onTap: () {
                // 跳转到收藏复习
              },
              child: Column(
                children: [
                  Text(
                    '${stats.learningCount}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text(
                    '学习中',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 筛选标签栏
  Widget _buildFilterBar(FavoriteFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 排序选择
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip(filter.sortOrder),
                  if (filter.levels.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ...filter.levels.map((level) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Lv.$level'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              final newLevels =
                                  List<int>.from(filter.levels)..remove(level);
                              ref.read(favoriteListProvider.notifier)
                                  .filterByLevels(newLevels);
                            },
                          ),
                        )),
                  ],
                  if (filter.statuses.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ...filter.statuses.map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(_getStatusLabel(status)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              final newStatuses =
                                  List<String>.from(filter.statuses)
                                    ..remove(status);
                              ref.read(favoriteListProvider.notifier)
                                  .filterByStatuses(newStatuses);
                            },
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
          // 重置按钮
          if (filter.hasActiveFilter)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(favoriteListProvider.notifier).resetFilter();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip(FavoriteSortOrder sortOrder) {
    return ActionChip(
      avatar: const Icon(Icons.sort, size: 16),
      label: Text(sortOrder.label),
      onPressed: () => _showSortSheet(sortOrder),
    );
  }

  /// 排序选择底部弹窗
  void _showSortSheet(FavoriteSortOrder current) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '排序方式',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...FavoriteSortOrder.values.map((order) => ListTile(
                  leading: Radio<FavoriteSortOrder>(
                    value: order,
                    groupValue: current,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(favoriteListProvider.notifier)
                            .updateSortOrder(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(order.label),
                  onTap: () {
                    ref.read(favoriteListProvider.notifier)
                        .updateSortOrder(order);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无收藏',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击汉字旁边的 ♥ 按钮添加收藏',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 收藏网格
  Widget _buildFavoriteGrid(List<Character> characters) {
    return RefreshIndicator(
      onRefresh: () => ref.read(favoriteListProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final char = characters[index];
          return _FavoriteCharCard(
            character: char,
            onRemove: () {
              _removeFavorite(char.id);
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterDetailPage(character: char),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 移除收藏
  void _removeFavorite(int characterId) async {
    final repository = FavoriteRepository();
    await repository.removeFavorite(characterId);
    ref.read(favoriteListProvider.notifier).refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已取消收藏'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 筛选底部弹窗
  void _showFilterSheet(BuildContext context) {
    final filter = ref.read(favoriteListProvider).filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        filter: filter,
        onApply: (newFilter) {
          ref.read(favoriteListProvider.notifier).updateFilter(newFilter);
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case '0':
        return '未学习';
      case '1':
        return '学习中';
      case '2':
        return '已掌握';
      case '3':
        return '模糊';
      default:
        return status;
    }
  }
}

/// 收藏汉字卡片
class _FavoriteCharCard extends StatelessWidget {
  final Character character;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteCharCard({
    required this.character,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 汉字内容
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 难度标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getLevelColor(character.level),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lv.${character.level}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 汉字
                Text(
                  character.character,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // 拼音
                Text(
                  character.pinyin,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            // 收藏按钮
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                iconSize: 20,
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 筛选底部弹窗
class _FilterSheet extends StatefulWidget {
  final FavoriteFilter filter;
  final ValueChanged<FavoriteFilter> onApply;

  const _FilterSheet({
    required this.filter,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late List<int> _selectedLevels;
  late List<String> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedLevels = List.from(widget.filter.levels);
    _selectedStatuses = List.from(widget.filter.statuses);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '筛选收藏',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedLevels.clear();
                    _selectedStatuses.clear();
                  });
                },
                child: const Text('重置'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 难度筛选
          const Text('难度等级',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4].map((level) {
              final isSelected = _selectedLevels.contains(level);
              return FilterChip(
                label: Text('Lv.$level'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLevels.add(level);
                    } else {
                      _selectedLevels.remove(level);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 学习状态筛选
          const Text('学习状态',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ('0', '未学习'),
              ('1', '学习中'),
              ('2', '已掌握'),
              ('3', '模糊'),
            ].map((item) {
              final (value, label) = item;
              final isSelected = _selectedStatuses.contains(value);
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStatuses.add(value);
                    } else {
                      _selectedStatuses.remove(value);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(widget.filter.copyWith(
                  levels: _selectedLevels,
                  statuses: _selectedStatuses,
                ));
                Navigator.pop(context);
              },
              child: const Text('应用筛选'),
            ),
          ),
        ],
      ),
    );
  }
}
