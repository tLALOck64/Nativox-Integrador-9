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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, icon: $icon, isUnlocked: $isUnlocked)';
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedDate,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }
}