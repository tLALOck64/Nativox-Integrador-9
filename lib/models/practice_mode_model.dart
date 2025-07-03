enum PracticeDifficulty {
  easy,
  medium,
  hard,
}

class PracticeModeModel {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final PracticeDifficulty difficulty;
  final int completedSessions;
  final int totalSessions;
  final bool isUnlocked;

  PracticeModeModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    this.completedSessions = 0,
    this.totalSessions = 10,
    this.isUnlocked = true,
  });

  // Factory constructor para crear desde JSON
  factory PracticeModeModel.fromJson(Map<String, dynamic> json) {
    return PracticeModeModel(
      id: json['id'],
      icon: json['icon'],
      title: json['title'],
      subtitle: json['subtitle'],
      difficulty: PracticeDifficulty.values.firstWhere(
        (e) => e.toString() == 'PracticeDifficulty.${json['difficulty']}',
      ),
      completedSessions: json['completedSessions'] ?? 0,
      totalSessions: json['totalSessions'] ?? 10,
      isUnlocked: json['isUnlocked'] ?? true,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
      'difficulty': difficulty.toString().split('.').last,
      'completedSessions': completedSessions,
      'totalSessions': totalSessions,
      'isUnlocked': isUnlocked,
    };
  }

  // Método para crear una copia con modificaciones
  PracticeModeModel copyWith({
    String? id,
    String? icon,
    String? title,
    String? subtitle,
    PracticeDifficulty? difficulty,
    int? completedSessions,
    int? totalSessions,
    bool? isUnlocked,
  }) {
    return PracticeModeModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      difficulty: difficulty ?? this.difficulty,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  // Getters útiles
  double get progress => completedSessions / totalSessions;
  
  String get difficultyText {
    switch (difficulty) {
      case PracticeDifficulty.easy:
        return 'Fácil';
      case PracticeDifficulty.medium:
        return 'Medio';
      case PracticeDifficulty.hard:
        return 'Difícil';
    }
  }
} 