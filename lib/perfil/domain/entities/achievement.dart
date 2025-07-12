class Achievement {
  final String id;
  final String title;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  const Achievement({
    required this.id,
    required this.title,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });
}
