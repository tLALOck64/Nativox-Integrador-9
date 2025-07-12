class UserProfile {
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

  const UserProfile({
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

  double get levelProgress => currentXP / nextLevelXP;
  double get vocabularyProgress => vocabularyCount / vocabularyGoal;
  int get xpToNextLevel => nextLevelXP - currentXP;
}