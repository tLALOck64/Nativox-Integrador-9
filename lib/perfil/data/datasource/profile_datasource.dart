import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/domain/entities/user_profile.dart';

abstract class ProfileDataSource {
  Future<UserProfile> getUserProfile();
  Future<List<Achievement>> getAchievements();
  Future<List<SettingItem>> getSettings();
  Future<void> updateNotificationSetting(bool enabled);
  Future<void> updateThemeSetting(bool isDarkMode);
}
