import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/statistics_provider.dart';

/// 统计数据展示卡片
class StatisticsCard extends ConsumerWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '学习统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (state.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () {
                      ref.read(statisticsProvider.notifier).refresh();
                    },
                    tooltip: '刷新',
                  ),
              ],
            ),
          ),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            )
          else
            _buildStatsContent(state),
        ],
      ),
    );
  }

  Widget _buildStatsContent(StatisticsState state) {
    final stats = state.statistics;

    return Column(
      children: [
        // 主统计数字
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatNumber(
                value: stats.learnedCount,
                label: '已学',
                color: AppTheme.primaryColor,
              ),
              _StatNumber(
                value: stats.masteredCount,
                label: '掌握',
                color: AppTheme.successColor,
              ),
              _StatNumber(
                value: stats.learningCount,
                label: '学习中',
                color: AppTheme.warningColor,
              ),
              _StatNumber(
                value: stats.notLearnedCount,
                label: '未学',
                color: Colors.grey,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '学习进度',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${(stats.progressPercent * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stats.progressPercent,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 今日统计
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TodayStat(
                icon: Icons.today,
                value: stats.todayLearnedCount,
                label: '今日已学',
                color: AppTheme.primaryColor,
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              _TodayStat(
                icon: Icons.replay,
                value: stats.todayReviewCount,
                label: '待复习',
                color: Colors.orange,
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              _TodayStat(
                icon: Icons.local_fire_department,
                value: stats.streakDays,
                label: '连续天数',
                color: AppTheme.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 统计数据数字
class _StatNumber extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatNumber({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
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

/// 今日统计项
class _TodayStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _TodayStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
