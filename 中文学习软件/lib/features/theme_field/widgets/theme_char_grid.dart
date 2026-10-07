import 'package:flutter/material.dart';
import '../../../data/models/models.dart';

/// 主题汉字网格组件
class ThemeCharGrid extends StatelessWidget {
  final List<Character> characters;
  final Function(Character)? onCharTap;
  final Color? accentColor;

  const ThemeCharGrid({
    super.key,
    required this.characters,
    this.onCharTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const Center(
        child: Text(
          '暂无汉字数据',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final char = characters[index];
        return _CharacterItem(
          character: char,
          onTap: onCharTap != null ? () => onCharTap!(char) : null,
          accentColor: accentColor,
        );
      },
    );
  }
}

class _CharacterItem extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _CharacterItem({
    required this.character,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).primaryColor;

    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                character.character,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                character.pinyin,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
