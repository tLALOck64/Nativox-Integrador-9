import 'package:flutter/material.dart';

class LessonStatsWidget extends StatelessWidget {
  final Map<String, int> stats;
  final VoidCallback? onTap;

  const LessonStatsWidget({
    super.key,
    required this.stats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A574).withOpacity(0.1),
            const Color(0xFFB8956A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.2),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              stats['completed']?.toString() ?? '0',
              'Completadas',
            ),
            _buildStatItem(
              stats['inProgress']?.toString() ?? '0',
              'En progreso',
            ),
            _buildStatItem(
              stats['totalWords']?.toString() ?? '0',
              'Palabras',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD4A574),
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}