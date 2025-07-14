import 'package:integrador/perfil/data/models/user_profile_model.dart';
import 'package:integrador/perfil/data/models/achievement_model.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';

abstract class ProfileDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<List<AchievementModel>> getAchievements(); 
  Future<List<SettingItem>> getSettings();
}
