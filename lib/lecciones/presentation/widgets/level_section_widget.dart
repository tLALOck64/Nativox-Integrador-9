import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';

class LevelSectionWidget extends StatelessWidget {
  final int level;
  final List<Lesson> lessons;
  final Function(Lesson) onLessonTap;

  const LevelSectionWidget({
    super.key,
    required this.level,
    required this.lessons,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nivel $level',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3728),
            ),
          ),
          const SizedBox(height: 10),
          ...lessons.map((lesson) => _buildLessonItem(context, lesson)),
        ],
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, Lesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          lesson.isCompleted ? Icons.check_circle : Icons.play_circle_outline,
          color: lesson.isCompleted ? Colors.green : const Color(0xFFD4A574),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A3728),
          ),
        ),
        subtitle: Text(
          lesson.isCompleted ? 'Completada' : 'Pendiente',
          style: const TextStyle(color: Color(0xFF6B5B4A)),
        ),
        onTap: () => onLessonTap(lesson),
      ),
    );
  }
}