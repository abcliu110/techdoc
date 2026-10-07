import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 学习进度条
class LearningProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LearningProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.height = 12,
    this.backgroundColor,
    this.foregroundColor,
  });

  double get progress => total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: backgroundColor ?? const Color(0xFFE8E8E8),
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current / $total',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 等级进度卡片
class LevelProgressCard extends StatelessWidget {
  final int level; // 1-4
  final int learned;
  final int target;
  final bool isUnlocked;
  final bool isCurrent;

  const LevelProgressCard({
    super.key,
    required this.level,
    required this.learned,
    required this.target,
    this.isUnlocked = false,
    this.isCurrent = false,
  });

  String get levelName {
    switch (level) {
      case 1:
        return '500字';
      case 2:
        return '1000字';
      case 3:
        return '2000字';
      case 4:
        return '3500字';
      default:
        return '${level * 500}字';
    }
  }

  Color get levelColor {
    switch (level) {
      case 1:
        return const Color(0xFF52C41A);
      case 2:
        return const Color(0xFF4A90D9);
      case 3:
        return const Color(0xFF722ED1);
      case 4:
        return const Color(0xFFD46B08);
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUnlocked ? levelColor.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: levelColor, width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            levelName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? levelColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            isUnlocked
                ? (isCurrent ? Icons.play_circle_filled : Icons.check_circle)
                : Icons.lock,
            color: isUnlocked ? levelColor : Colors.grey,
            size: 24,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 4),
            Text(
              '$learned',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 周学习日历
class WeekLearningCalendar extends StatelessWidget {
  final List<bool> weekStatus; // 7天是否有学习
  final int todayIndex; // 今天的位置 0-6

  const WeekLearningCalendar({
    super.key,
    required this.weekStatus,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isToday = index == todayIndex;
        final isCompleted = weekStatus.length > index && weekStatus[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              days[index],
              style: TextStyle(
                fontSize: 12,
                color: isToday ? AppTheme.primaryColor : AppTheme.textHint,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successColor
                    : (isToday ? AppTheme.primaryColor : Colors.grey.shade200),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : (isToday
                        ? const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 14)
                        : null),
              ),
            ),
          ],
        );
      }),
    );
  }
}
