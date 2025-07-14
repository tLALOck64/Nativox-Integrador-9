import 'package:flutter/material.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';

class AchievementGridWidget extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementGridWidget({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementItem(achievement: achievement);
      },
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Achievement achievement;

  const _AchievementItem({required this.achievement});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 24,
                    color: achievement.isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked ? const Color(0xFF2C2C2C) : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
