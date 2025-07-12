class SettingItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final bool hasNotification;
  final SettingType type;

  const SettingItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.hasNotification,
    required this.type,
  });
}

enum SettingType { notifications, audio, theme, help }