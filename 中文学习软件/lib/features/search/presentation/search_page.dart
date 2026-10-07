import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/search_provider.dart';
import '../../detail/presentation/character_detail_page.dart';
import '../../favorites/widgets/favorite_button.dart';

/// 自由查询页面
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'all'; // all, pinyin, radical, strokes, sixbook

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自由查询'),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入汉字、拼音或部首',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchProvider.notifier).clearResults();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),

          // 搜索类型选择
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('全部', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('拼音', 'pinyin'),
                const SizedBox(width: 8),
                _buildFilterChip('部首', 'radical'),
                const SizedBox(width: 8),
                _buildFilterChip('笔画', 'strokes'),
                const SizedBox(width: 8),
                _buildFilterChip('六书', 'sixbook'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 快捷查询
          if (state.results.isEmpty && !state.isLoading)
            _buildQuickSearch(),

          // 搜索结果
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.results.isEmpty
                    ? const Center(
                        child: Text(
                          '输入汉字或拼音开始搜索',
                          style: TextStyle(color: AppTheme.textHint),
                        ),
                      )
                    : _buildResults(state.results),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _searchType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _searchType = value;
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
    );
  }

  Widget _buildQuickSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '按六书查询',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SixBook.values.map((book) {
              return ActionChip(
                label: Text(book.label),
                onPressed: () {
                  _searchBySixBook(book);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            '常用部首',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['氵', '忄', '扌', '讠', '艹', '日', '月', '木', '火', '土', '人', '口'].map((radical) {
              return ActionChip(
                label: Text(radical),
                onPressed: () {
                  _searchController.text = radical;
                  _searchType = 'radical';
                  _performSearch(radical);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<Character> results) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final char = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.characterCardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                char.character,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              char.pinyin,
              style: const TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              '${char.sixBook?.label ?? '未知'} · ${char.radical}部 · ${char.strokes}画',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FavoriteButton(
                  characterId: char.id,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterDetailPage(character: char),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      ref.read(searchProvider.notifier).clearResults();
      return;
    }
    ref.read(searchProvider.notifier).search(query, _searchType);
  }

  void _searchBySixBook(SixBook book) {
    ref.read(searchProvider.notifier).searchBySixBook(book);
  }
}
