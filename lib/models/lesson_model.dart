class LessonModel {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final double progress;
  final String difficulty;
  final int duration; // en minutos
  final bool isCompleted;
  final bool isLocked;
  final int lessonNumber;
  final String level; // Básico, Intermedio, Avanzado
  final int wordCount; // número de palabras en la lección

  LessonModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.difficulty,
    required this.duration,
    this.isCompleted = false,
    this.isLocked = false,
    required this.lessonNumber,
    required this.level,
    required this.wordCount,
  });

  // Factory constructor para crear desde JSON
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      icon: json['icon'],
      title: json['title'],
      subtitle: json['subtitle'],
      progress: json['progress'].toDouble(),
      difficulty: json['difficulty'],
      duration: json['duration'],
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
      lessonNumber: json['lessonNumber'],
      level: json['level'],
      wordCount: json['wordCount'],
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
      'progress': progress,
      'difficulty': difficulty,
      'duration': duration,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'lessonNumber': lessonNumber,
      'level': level,
      'wordCount': wordCount,
    };
  }

  // Método para crear una copia con modificaciones
  LessonModel copyWith({
    String? id,
    String? icon,
    String? title,
    String? subtitle,
    double? progress,
    String? difficulty,
    int? duration,
    bool? isCompleted,
    bool? isLocked,
    int? lessonNumber,
    String? level,
    int? wordCount,
  }) {
    return LessonModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      progress: progress ?? this.progress,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      level: level ?? this.level,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  // Getters útiles
  String get statusIcon {
    if (isCompleted) return '✅';
    if (isLocked) return '🔒';
    return '▶️';
  }

  String get durationText => '⏱️ $duration min';
  String get wordCountText => '📝 $wordCount palabras';
  
  String get levelIcon {
    switch (level) {
      case 'Básico':
        return '🌱';
      case 'Intermedio':
        return '🌿';
      case 'Avanzado':
        return '🌳';
      default:
        return '📚';
    }
  }

  String get levelDescription {
    switch (level) {
      case 'Básico':
        return 'Fundamentos del Náhuatl';
      case 'Intermedio':
        return 'Amplía tu vocabulario';
      case 'Avanzado':
        return 'Domina el idioma';
      default:
        return 'Aprende Náhuatl';
    }
  }
}