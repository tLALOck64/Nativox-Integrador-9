class LessonStats {
  final int completed;
  final int inProgress;
  final int totalWords;
  final int totalLessons;
  final double averageProgress;
  final double completionRate;

  const LessonStats({
    required this.completed,
    required this.inProgress,
    required this.totalWords,
    required this.totalLessons,
    required this.averageProgress,
    required this.completionRate,
  });

  static const LessonStats empty = LessonStats(
    completed: 0,
    inProgress: 0,
    totalWords: 0,
    totalLessons: 0,
    averageProgress: 0.0,
    completionRate: 0.0,
  );

  factory LessonStats.fromMap(Map<String, int> statsMap) {
    final completed = statsMap['completed'] ?? 0;
    final inProgress = statsMap['inProgress'] ?? 0;
    final totalWords = statsMap['totalWords'] ?? 0;
    final totalLessons = completed + inProgress + (statsMap['remaining'] ?? 0);
    
    return LessonStats(
      completed: completed,
      inProgress: inProgress,
      totalWords: totalWords,
      totalLessons: totalLessons,
      averageProgress: totalLessons > 0 ? completed / totalLessons : 0.0,
      completionRate: totalLessons > 0 ? completed / totalLessons : 0.0,
    );
  }

  Map<String, int> toMap() {
    return {
      'completed': completed,
      'inProgress': inProgress,
      'totalWords': totalWords,
    };
  }
}