import '../../domain/entities/lesson.dart';

class LessonModel {
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

  const LessonModel({
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

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📚',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'Medio',
      duration: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      progress: double.tryParse(json['progress']?.toString() ?? '0.0') ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? true,
      lessonNumber: int.tryParse(json['lessonNumber']?.toString() ?? '0') ?? 0,
      level: json['level']?.toString() ?? 'Básico',
      wordCount: int.tryParse(json['wordCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
      'difficulty': difficulty,
      'duration': duration,
      'progress': progress,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'lessonNumber': lessonNumber,
      'level': level,
      'wordCount': wordCount,
    };
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      icon: icon,
      title: title,
      subtitle: subtitle,
      difficulty: difficulty,
      duration: duration,
      progress: progress,
      isCompleted: isCompleted,
      isLocked: isLocked,
      lessonNumber: lessonNumber,
      level: level,
      wordCount: wordCount,
    );
  }

  factory LessonModel.fromEntity(Lesson lesson) {
    return LessonModel(
      id: lesson.id,
      icon: lesson.icon,
      title: lesson.title,
      subtitle: lesson.subtitle,
      difficulty: lesson.difficulty,
      duration: lesson.duration,
      progress: lesson.progress,
      isCompleted: lesson.isCompleted,
      isLocked: lesson.isLocked,
      lessonNumber: lesson.lessonNumber,
      level: lesson.level,
      wordCount: lesson.wordCount,
    );
  }

  LessonModel copyWith({
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
    return LessonModel(
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
}