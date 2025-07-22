class Lesson {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final String difficulty;
  final int duration;
  final double progress;
  final bool isCompleted;
  final bool isLocked;
  final int lessonNumber;
  final String level;
  final int wordCount;

  const Lesson({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.duration,
    required this.progress,
    required this.isCompleted,
    required this.isLocked,
    required this.lessonNumber,
    required this.level,
    required this.wordCount,
  });

  Lesson copyWith({
    String? id,
    String? icon,
    String? title,
    String? subtitle,
    String? difficulty,
    int? duration,
    double? progress,
    bool? isCompleted,
    bool? isLocked,
    int? lessonNumber,
    String? level,
    int? wordCount,
  }) {
    return Lesson(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      level: level ?? this.level,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
