import 'package:integrador/perfil/domain/entities/achievement.dart';

class AchievementModel {
  final String id;
  final String title;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedDate: json['unlockedDate'] != null 
          ? DateTime.parse(json['unlockedDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
    };
  }

  // ✅ MÉTODO toEntity() QUE NECESITAS
  Achievement toEntity() {
    return Achievement(
      id: id,
      title: title,
      icon: icon,
      isUnlocked: isUnlocked,
      unlockedDate: unlockedDate,
    );
  }

  @override
  String toString() {
    return 'AchievementModel(id: $id, title: $title, icon: $icon, isUnlocked: $isUnlocked)';
  }
}