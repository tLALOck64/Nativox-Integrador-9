import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
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

    final levelIcon = lessons.first.levelIcon;
    final levelDescription = lessons.first.levelDescription;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                // Level Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      levelIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Level Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        levelDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator for the level
                _buildLevelProgress(),
              ],
            ),
          ),
          
          // Lessons List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildLevelProgress() {
    final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
    final totalLessons = lessons.length;
    final progressPercentage = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$completedLessons/$totalLessons',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4A574),
            ),
          ),
          const SizedBox(width: 4),
          if (progressPercentage == 1.0)
            const Text(
              '✅',
              style: TextStyle(fontSize: 12),
            )
          else
            Container(
              width: 12,
              height: 12,
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