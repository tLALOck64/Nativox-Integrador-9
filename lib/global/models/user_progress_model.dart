class UserProgressModel {
  final String userId;
  final double overallProgress;
  final String currentLevel;
  final int streakDays;
  final int totalLessonsCompleted;
  final int totalTimeSpent; // en minutos
  final String nextLesson;
  final DateTime lastActivity;

  UserProgressModel({
    required this.userId,
    required double overallProgress,
    required this.currentLevel,
    required this.streakDays,
    required this.totalLessonsCompleted,
    required this.totalTimeSpent,
    required this.nextLesson,
    required this.lastActivity,
  }) : overallProgress = (overallProgress.isNaN ? 0.0 : overallProgress.clamp(0.0, 1.0));

  // Factory constructor para crear desde JSON
  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    double progress = 0.0;
    try {
      progress = json['overallProgress']?.toDouble() ?? 0.0;
      if (progress.isNaN) progress = 0.0;
      progress = progress.clamp(0.0, 1.0);
    } catch (_) {
      progress = 0.0;
    }
    return UserProgressModel(
      userId: json['userId'],
      overallProgress: progress,
      currentLevel: json['currentLevel'],
      streakDays: json['streakDays'],
      totalLessonsCompleted: json['totalLessonsCompleted'],
      totalTimeSpent: json['totalTimeSpent'],
      nextLesson: json['nextLesson'],
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'overallProgress': overallProgress,
      'currentLevel': currentLevel,
      'streakDays': streakDays,
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalTimeSpent': totalTimeSpent,
      'nextLesson': nextLesson,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  // Método para crear una copia con modificaciones
  UserProgressModel copyWith({
    String? userId,
    double? overallProgress,
    String? currentLevel,
    int? streakDays,
    int? totalLessonsCompleted,
    int? totalTimeSpent,
    String? nextLesson,
    DateTime? lastActivity,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      overallProgress: overallProgress ?? this.overallProgress,
      currentLevel: currentLevel ?? this.currentLevel,
      streakDays: streakDays ?? this.streakDays,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      nextLesson: nextLesson ?? this.nextLesson,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  // Método para obtener el progreso en porcentaje como string
  String get progressPercentage => '${(overallProgress * 100).toInt()}%';

  // Método para verificar si el usuario está en una racha activa
  bool get isStreakActive {
    final now = DateTime.now();
    final daysSinceLastActivity = now.difference(lastActivity).inDays;
    return daysSinceLastActivity <= 1;
  }
}