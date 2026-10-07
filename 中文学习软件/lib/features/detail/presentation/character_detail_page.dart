import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/theme/app_theme.dart';
import '../../favorites/widgets/favorite_button.dart';

/// 汉字详情页面
class CharacterDetailPage extends ConsumerStatefulWidget {
  final Character character;
  final bool fromSearch;

  const CharacterDetailPage({
    super.key,
    required this.character,
    this.fromSearch = false,
  });

  @override
  ConsumerState<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends ConsumerState<CharacterDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WordExample> _examples = [];
  List<Character> _familyChars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRelatedData();
  }

  Future<void> _loadRelatedData() async {
    final charRepo = CharacterRepository();

    // 加载例词
    final examples = await charRepo.getWordExamples(widget.character.id);

    // 加载同声旁字族
    List<Character> familyChars = [];
    if (widget.character.phonetic != null) {
      familyChars = await charRepo.getByPhonetic(widget.character.phonetic!);
      familyChars = familyChars.where((c) => c.id != widget.character.id).toList();
    }

    setState(() {
      _examples = examples;
      _familyChars = familyChars;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汉字详情'),
        actions: [
          // 收藏按钮
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FavoriteButton(
              characterId: widget.character.id,
              size: 28,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '基本信息'),
            Tab(text: '字源演变'),
            Tab(text: '字族学习'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildEtymologyTab(),
          _buildFamilyTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 基本信息标签页
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 汉字大字展示
          Center(
            child: Column(
              children: [
                Text(
                  widget.character.character,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.character.pinyin,
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 六书分类卡片
          if (widget.character.sixBook != null) ...[
            _buildInfoCard(
              title: '六书分类',
              icon: Icons.category,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.character.sixBook!.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getSixBookDetail(widget.character.sixBook!),
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 形声规律
          if (widget.character.semantic != null && widget.character.phonetic != null) ...[
            _buildInfoCard(
              title: '形声规律',
              icon: Icons.architecture,
              child: Row(
                children: [
                  Expanded(
                    child: _buildComponentBox(
                      widget.character.semantic!,
                      '形旁',
                      AppTheme.semanticCharColor,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.add, size: 32, color: AppTheme.textHint),
                  ),
                  Expanded(
                    child: _buildComponentBox(
                      widget.character.phonetic!,
                      '声旁',
                      AppTheme.phoneticCharColor,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.arrow_forward, size: 32, color: AppTheme.textHint),
                  ),
                  Expanded(
                    child: _buildComponentBox(
                      widget.character.character,
                      '合成字',
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 基本信息
          _buildInfoCard(
            title: '基本信息',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _buildInfoRow('部首', widget.character.radical),
                _buildInfoRow('笔画', '${widget.character.strokes}画'),
                _buildInfoRow('字频', '第${widget.character.frequency}位常用字'),
                _buildInfoRow('等级', _getLevelText(widget.character.level)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 本义
          if (widget.character.originalMeaning != null) ...[
            _buildInfoCard(
              title: '本义',
              icon: Icons.history_edu,
              child: Text(
                widget.character.originalMeaning!,
                style: const TextStyle(fontSize: 18, height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 引申义
          if (widget.character.extendedMeanings.isNotEmpty) ...[
            _buildInfoCard(
              title: '引申义',
              icon: Icons.trending_up,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.character.extendedMeanings.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 例词
          if (_examples.isNotEmpty) ...[
            _buildInfoCard(
              title: '常用词语',
              icon: Icons.format_quote,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _examples.map((example) {
                  return Chip(
                    label: Text(example.word),
                    backgroundColor: AppTheme.characterCardBg,
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 字源演变标签页
  Widget _buildEtymologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题说明
          const Text(
            '汉字演变历史',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '从甲骨文到楷书，汉字经历了数千年的演变',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // 字形演变卡片
          _buildEvolutionCard(),

          const SizedBox(height: 24),

          // 六书详解
          if (widget.character.sixBook != null) ...[
            _buildInfoCard(
              title: '六书详解',
              icon: Icons.menu_book,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.character.sixBook!.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSixBookDetail(widget.character.sixBook!),
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 字族学习标签页
  Widget _buildFamilyTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.character.phonetic != null) ...[
            // 字族说明
            _buildInfoCard(
              title: '字族学习',
              icon: Icons.family_restroom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '以"${widget.character.phonetic}"为声旁的形声字家族',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '形声字由"形旁"和"声旁"组成。形旁表示字的意义类别，声旁提示字的读音。'
                    '学习字族可以帮助我们通过已学汉字快速掌握一批相关汉字。',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 字族成员
            if (_familyChars.isNotEmpty) ...[
              const Text(
                '同族汉字',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _familyChars.length,
                itemBuilder: (context, index) {
                  final char = _familyChars[index];
                  return _buildFamilyCharCard(char);
                },
              ),
            ],
          ] else ...[
            // 非形声字说明
            _buildInfoCard(
              title: '字族学习',
              icon: Icons.info_outline,
              child: Text(
                '这个字不是形声字，没有同声旁的字族。\n\n'
                '但它可以成为其他形声字的声旁或形旁，帮助我们学习更多汉字。',
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 学习技巧
          _buildInfoCard(
            title: '学习技巧',
            icon: Icons.lightbulb_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('1. 记住一个声旁，可以学习一串相关汉字', style: TextStyle(fontSize: 15)),
                SizedBox(height: 8),
                Text('2. 注意形旁的意义类别，帮助理解字义', style: TextStyle(fontSize: 15)),
                SizedBox(height: 8),
                Text('3. 对比同族汉字的异同，加深记忆', style: TextStyle(fontSize: 15)),
                SizedBox(height: 8),
                Text('4. 在词语和句子中使用，学以致用', style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionCard() {
    // 字形演变数据（模拟数据，实际应从数据库获取）
    final forms = [
      _EvolutionForm('甲骨文', widget.character.originJiaguwen ?? widget.character.character, '约公元前1600年'),
      _EvolutionForm('金文', widget.character.originJinwen ?? widget.character.character, '约公元前1200年'),
      _EvolutionForm('小篆', widget.character.originXiaozhuan ?? widget.character.character, '公元前221年'),
      _EvolutionForm('隶书', widget.character.character, '公元前200年'),
      _EvolutionForm('楷书', widget.character.character, '公元后200年'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: forms.map((form) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.characterCardBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          form.char,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        form.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        form.period,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '汉字演变规律：象形→表意→形声',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentBox(String char, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            char,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyCharCard(Character char) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CharacterDetailPage(
                character: char,
                fromSearch: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                char.character,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await UserRepository().markLearned(widget.character.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已加入学习计划')),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('加入学习'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelText(int level) {
    switch (level) {
      case 1:
        return '一级（基础常用字）';
      case 2:
        return '二级（进阶常用字）';
      case 3:
        return '三级（较高频字）';
      case 4:
        return '四级（专业/古语字）';
      default:
        return '未知';
    }
  }

  String _getSixBookDetail(SixBook sixBook) {
    switch (sixBook) {
      case SixBook.pictogram:
        return '象形字是最古老的造字方法，用线条描画事物的形状。'
            '如"日"像太阳的形状，"月"像月亮的形状。';
      case SixBook.indicative:
        return '指事字是用抽象符号或在象形字基础上添加指示符号来表示意义。'
            '如"上"用一横一弧线表示上方，"本"在"木"下加一点表示树根。';
      case SixBook.associative:
        return '会意字是由两个或多个字组合在一起，表示一个新的意义。'
            '如"明"由"日"和"月"组成，表示明亮；"休"由"人"和"木"组成，表示休息。';
      case SixBook.phonetic:
        return '形声字由"形旁"和"声旁"组成，形旁表示意义类别，声旁提示读音。'
            '这是汉字中最主要的造字方法，汉字中约80%是形声字。';
      case SixBook.mutual:
        return '转注是指意义相同或相近的字可以互相解释。'
            '如"考"和"老"意义相同，可以互相解释。';
      case SixBook.phoneticLoan:
        return '假借是用一个已有的字来表示与之同音的新意义，而不再造新字。'
            '这种方法扩大了字的使用范围。';
    }
  }
}

/// 字形演变数据类
class _EvolutionForm {
  final String name;
  final String char;
  final String period;

  _EvolutionForm(this.name, this.char, this.period);
}
