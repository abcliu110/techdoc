import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/radical_provider.dart';
import '../data/radical_data.dart';
import '../../../core/theme/app_theme.dart';

/// 部首TabBar组件 - 按笔画数分类
class RadicalTabBar extends ConsumerWidget {
  const RadicalTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(radicalNotifierProvider);
    final selectedIndex = ref.watch(radicalTabIndexProvider);

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              ref.read(radicalTabIndexProvider.notifier).state = index;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                '${group.strokes}画',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 部首TabBar（按部首分类）
class RadicalCategoryTabBar extends ConsumerWidget {
  const RadicalCategoryTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(radicalTabIndexProvider);

    final categories = ['按笔画', '按位置', '搜索'];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(radicalTabIndexProvider.notifier).state = index;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
