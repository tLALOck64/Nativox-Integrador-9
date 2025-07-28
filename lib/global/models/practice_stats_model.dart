class PracticeStatsModel {
  final int wordsPracticed;
  final double accuracy;
  final int weeklyGoalDays;
  final int weeklyGoalTarget;
  final int totalSessions;
  final int totalTimeMinutes;
  final DateTime lastPracticeDate;
  final Map<String, int> categoryProgress;

  PracticeStatsModel({
    required this.wordsPracticed,
    required this.accuracy,
    required this.weeklyGoalDays,
    required this.weeklyGoalTarget,
    required this.totalSessions,
    required this.totalTimeMinutes,
    required this.lastPracticeDate,
    this.categoryProgress = const {},
  });

  // Factory constructor para crear desde JSON
  factory PracticeStatsModel.fromJson(Map<String, dynamic> json) {
    return PracticeStatsModel(
      wordsPracticed: json['wordsPracticed'],
      accuracy: json['accuracy'].toDouble(),
      weeklyGoalDays: json['weeklyGoalDays'],
      weeklyGoalTarget: json['weeklyGoalTarget'],
      totalSessions: json['totalSessions'],
      totalTimeMinutes: json['totalTimeMinutes'],
      lastPracticeDate: DateTime.parse(json['lastPracticeDate']),
      categoryProgress: Map<String, int>.from(json['categoryProgress'] ?? {}),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'wordsPracticed': wordsPracticed,
      'accuracy': accuracy,
      'weeklyGoalDays': weeklyGoalDays,
      'weeklyGoalTarget': weeklyGoalTarget,
      'totalSessions': totalSessions,
      'totalTimeMinutes': totalTimeMinutes,
      'lastPracticeDate': lastPracticeDate.toIso8601String(),
      'categoryProgress': categoryProgress,
    };
  }

  // Método para crear una copia con modificaciones
  PracticeStatsModel copyWith({
    int? wordsPracticed,
    double? accuracy,
    int? weeklyGoalDays,
    int? weeklyGoalTarget,
    int? totalSessions,
    int? totalTimeMinutes,
    DateTime? lastPracticeDate,
    Map<String, int>? categoryProgress,
  }) {
    return PracticeStatsModel(
      wordsPracticed: wordsPracticed ?? this.wordsPracticed,
      accuracy: accuracy ?? this.accuracy,
      weeklyGoalDays: weeklyGoalDays ?? this.weeklyGoalDays,
      weeklyGoalTarget: weeklyGoalTarget ?? this.weeklyGoalTarget,
      totalSessions: totalSessions ?? this.totalSessions,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      categoryProgress: categoryProgress ?? this.categoryProgress,
    );
  }

  // Getters útiles
  double get weeklyGoalProgress => weeklyGoalDays / weeklyGoalTarget;
  
  String get weeklyGoalText => '$weeklyGoalDays/$weeklyGoalTarget días';
  
  String get accuracyText => '${accuracy.toInt()}%';
  
  int get totalHours => (totalTimeMinutes / 60).round();
  
  double get averageSessionTime => totalSessions > 0 
      ? totalTimeMinutes / totalSessions 
      : 0.0;
  
  bool get hasMetWeeklyGoal => weeklyGoalDays >= weeklyGoalTarget;
  
  // Calcular racha de días consecutivos
  int calculateCurrentStreak() {
    final now = DateTime.now();
    final daysSinceLastPractice = now.difference(lastPracticeDate).inDays;
    
    // Si no ha practicado en más de 1 día, la racha se rompe
    if (daysSinceLastPractice > 1) {
      return 0;
    }
    
    // Aquí podrías implementar lógica más compleja para calcular
    // la racha basada en el historial de práctica
    return weeklyGoalDays; // Simplificado para el ejemplo
  }
}