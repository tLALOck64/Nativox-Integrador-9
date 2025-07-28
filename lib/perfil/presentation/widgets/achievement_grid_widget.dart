import 'package:flutter/material.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';

class AchievementGridWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final int crossAxisCount;
  final bool isLarge;

  const AchievementGridWidget({
    super.key,
    required this.achievements,
    this.crossAxisCount = 4,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = isLarge ? 16.0 : 12.0;
    final itemSize = (screenWidth - (spacing * (crossAxisCount + 1))) / crossAxisCount;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementItem(
          achievement: achievement,
          isLarge: isLarge,
          itemSize: itemSize,
        );
      },
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Achievement achievement;
  final bool isLarge;
  final double itemSize;

  const _AchievementItem({
    required this.achievement,
    this.isLarge = false,
    this.itemSize = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular tamaños dinámicamente basados en el tamaño del item
    final iconSize = isLarge ? 52.0 : (itemSize * 0.4).clamp(32.0, 44.0);
    final fontSize = isLarge ? 13.0 : (itemSize * 0.08).clamp(9.0, 11.0);
    final padding = isLarge ? 16.0 : (itemSize * 0.12).clamp(8.0, 12.0);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked ? const Color(0xFFD4A574) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: achievement.isUnlocked ? () {} : null,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? const Color(0xFFD4A574).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: achievement.isUnlocked
                          ? const Color(0xFFD4A574).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: iconSize * 0.5,
                        color: achievement.isUnlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: padding * 0.5),
                Flexible(
                  child: Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: achievement.isUnlocked ? const Color(0xFF2C2C2C) : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
