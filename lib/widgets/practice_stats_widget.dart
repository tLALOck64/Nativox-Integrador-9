import 'package:flutter/material.dart';
import '../models/practice_stats_model.dart';

class PracticeStatsWidget extends StatelessWidget {
  final PracticeStatsModel stats;
  final VoidCallback? onGoalTap;

  const PracticeStatsWidget({
    super.key,
    required this.stats,
    this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A574).withOpacity(0.1),
            const Color(0xFFB8956A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  stats.wordsPracticed.toString(),
                  'Palabras practicadas',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  stats.accuracyText,
                  'Precisión',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Weekly Goal
          _buildWeeklyGoal(context),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD4A574),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoal(BuildContext context) {
    return GestureDetector(
      onTap: onGoalTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      '🎯',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Meta semanal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ],
                ),
                Text(
                  stats.weeklyGoalText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD4A574),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Progress bar
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stats.weeklyGoalProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            // Achievement indicator
            if (stats.hasMetWeeklyGoal)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🏆',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '¡Meta alcanzada!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}