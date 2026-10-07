import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/review_provider.dart';
import 'review_flow_page.dart';

/// 复习页面
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('待复习 (${state.reviewChars.length})'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reviewChars.isEmpty
              ? _buildEmptyState()
              : _buildReviewList(context, ref, state),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.successColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '太棒了！',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '暂时没有需要复习的汉字',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(BuildContext context, WidgetRef ref, ReviewState state) {
    return Column(
      children: [
        // 复习说明
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '今日需复习 ${state.reviewChars.length} 个字',
                  style: const TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ),

        // 复习列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reviewChars.length,
            itemBuilder: (context, index) {
              final char = state.characters.length > index
                  ? state.characters[index]
                  : null;
              if (char == null) return const SizedBox.shrink();

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
                  title: Text(char.pinyin),
                  subtitle: Text(
                    '${char.sixBook?.label ?? ''} · ${char.radical}部',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      _showReviewDialog(context, ref, char);
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // 开始复习按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _startReview(context, ref);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('开始复习'),
            ),
          ),
        ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, Character char) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(char.character),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('拼音: ${char.pinyin}'),
            if (char.originalMeaning != null)
              Text('本义: ${char.originalMeaning}'),
            const SizedBox(height: 16),
            const Text('你记得这个字的意思吗？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              UserRepository().markMastered(char.id, false);
              Navigator.pop(context);
              ref.read(reviewProvider.notifier).loadReviewChars();
            },
            child: const Text('模糊'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('不确定'),
          ),
          ElevatedButton(
            onPressed: () {
              UserRepository().markMastered(char.id, true);
              Navigator.pop(context);
              ref.read(reviewProvider.notifier).loadReviewChars();
            },
            child: const Text('记住了'),
          ),
        ],
      ),
    );
  }

  void _startReview(BuildContext context, WidgetRef ref) {
    final state = ref.read(reviewProvider);
    if (state.reviewChars.isEmpty) return;

    // 跳转到复习流程页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReviewFlowPage()),
    ).then((_) {
      // 复习完成后刷新列表
      ref.read(reviewProvider.notifier).loadReviewChars();
    });
  }
}
