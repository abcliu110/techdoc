import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../core/theme/app_theme.dart';

/// 汉字卡片组件
class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;
  final bool showDetails;

  const CharacterCard({
    super.key,
    required this.character,
    this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 汉字主体
              Text(
                character.character,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // 拼音
              Text(
                character.pinyin,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (showDetails) ...[
                const SizedBox(height: 12),
                // 部首
                Text(
                  '部首: ${character.radical}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textHint,
                  ),
                ),
                // 笔画
                Text(
                  '笔画: ${character.strokes}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textHint,
                  ),
                ),
                // 六书分类
                if (character.sixBook != null)
                  Text(
                    '六书: ${character.sixBook!.label}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 汉字大字展示组件
class CharacterDisplay extends StatelessWidget {
  final Character character;
  final double fontSize;
  final Color? textColor;
  final bool showPhonetic;
  final bool showSemantic;

  const CharacterDisplay({
    super.key,
    required this.character,
    this.fontSize = 120,
    this.textColor,
    this.showPhonetic = false,
    this.showSemantic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 汉字
        Text(
          character.character,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor ?? AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // 拼音
        Text(
          character.pinyin,
          style: TextStyle(
            fontSize: fontSize * 0.2,
            color: AppTheme.textSecondary,
          ),
        ),
        // 形声信息
        if (showPhonetic && character.phonetic != null) ...[
          const SizedBox(height: 16),
          _buildPhoneticInfo(),
        ],
      ],
    );
  }

  Widget _buildPhoneticInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.characterCardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (character.semantic != null) ...[
            Text(
              character.semantic!,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.semanticCharColor,
              ),
            ),
            const Text(
              ' (形旁) + ',
              style: TextStyle(fontSize: 14, color: AppTheme.textHint),
            ),
          ],
          Text(
            character.phonetic!,
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.phoneticCharColor,
            ),
          ),
          const Text(
            ' (声旁)',
            style: TextStyle(fontSize: 14, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}
