import 'package:flutter/material.dart';
import 'package:integrador/games/lecciones/lesson_model.dart';
import 'lesson_list_item_widget.dart';

class LevelSectionWidget extends StatelessWidget {
  final String level;
  final List<LessonModel> lessons;
  final Function(LessonModel) onLessonTap;

  const LevelSectionWidget({
    super.key,
    required this.level,
    required this.lessons,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    final levelIcon = lessons.first.levelIcon;
    final levelDescription = lessons.first.levelDescription;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20, 
              vertical: isSmallScreen ? 12 : 15
            ),
            child: Row(
              children: [
                // Level Icon
                Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      levelIcon,
                      style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                    ),
                  ),
                ),
                
                SizedBox(width: isSmallScreen ? 12 : 15),
                
                // Level Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C2C2C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        levelDescription,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: const Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator for the level
                _buildLevelProgress(isSmallScreen),
              ],
            ),
          ),
          
          // Lessons List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
            child: Column(
              children: lessons.map((lesson) {
                return LessonListItemWidget(
                  lesson: lesson,
                  onTap: () => onLessonTap(lesson),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(bool isSmallScreen) {
    final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
    final totalLessons = lessons.length;
    final progressPercentage = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8, 
        vertical: isSmallScreen ? 3 : 4
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$completedLessons/$totalLessons',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD4A574),
            ),
          ),
          SizedBox(width: isSmallScreen ? 3 : 4),
          if (progressPercentage == 1.0)
            Text(
              '✅',
              style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
            )
          else
            Container(
              width: isSmallScreen ? 10 : 12,
              height: isSmallScreen ? 10 : 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: FractionallySizedBox(
                widthFactor: progressPercentage,
                heightFactor: progressPercentage,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD4A574),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}