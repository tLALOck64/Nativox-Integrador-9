import 'package:integrador/perfil/domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String title;
  final String avatarUrl;
  final int level;
  final int activeDays;
  final int totalXP;
  final int badges;
  final int currentXP;
  final int nextLevelXP;
  final int vocabularyCount;
  final int vocabularyGoal;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.level,
    required this.activeDays,
    required this.totalXP,
    required this.badges,
    required this.currentXP,
    required this.nextLevelXP,
    required this.vocabularyCount,
    required this.vocabularyGoal,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      level: json['level'] ?? 1,
      activeDays: json['activeDays'] ?? 0,
      totalXP: json['totalXP'] ?? 0,
      badges: json['badges'] ?? 0,
      currentXP: json['currentXP'] ?? 0,
      nextLevelXP: json['nextLevelXP'] ?? 100,
      vocabularyCount: json['vocabularyCount'] ?? 0,
      vocabularyGoal: json['vocabularyGoal'] ?? 200,
    );
  }

  // ✅ MÉTODO toEntity() QUE NECESITAS
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      title: title,
      avatarUrl: avatarUrl,
      level: level,
      activeDays: activeDays,
      totalXP: totalXP,
      badges: badges,
      currentXP: currentXP,
      nextLevelXP: nextLevelXP,
      vocabularyCount: vocabularyCount,
      vocabularyGoal: vocabularyGoal,
    );
  }
}