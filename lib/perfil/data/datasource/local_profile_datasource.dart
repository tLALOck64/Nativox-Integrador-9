import 'package:integrador/perfil/data/datasource/profile_datasource.dart';
import 'package:integrador/perfil/data/models/user_profile_model.dart';
import 'package:integrador/perfil/data/models/achievement_model.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';

class LocalProfileDataSource implements ProfileDataSource {
  @override
  Future<UserProfileModel> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const UserProfileModel(
      id: '1',
      name: 'Andrea Isabella Trejo Morales',
      title: 'Estudiante de zapoteco',
      avatarUrl: '',
      level: 0,
      activeDays: 0,
      totalXP: 0,
      badges: 0,
      currentXP: 0,
      nextLevelXP: 0,
      vocabularyCount: 0,
      vocabularyGoal: 0,
    );
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      AchievementModel(
        id: '1',
        title: 'Racha de 7 días',
        icon: '🔥',
        isUnlocked: true,
      ),
      AchievementModel(
        id: '2',
        title: 'Primera lección',
        icon: '🌟',
        isUnlocked: true,
      ),
      AchievementModel(
        id: '3',
        title: '100% precisión',
        icon: '🎯',
        isUnlocked: true,
      ),
      AchievementModel(
        id: '4',
        title: 'Nivel 10',
        icon: '🏅',
        isUnlocked: false,
      ),
      AchievementModel(
        id: '5',
        title: 'Bookworm',
        icon: '📚',
        isUnlocked: true,
      ),
      AchievementModel(
        id: '6',
        title: 'Velocidad',
        icon: '⚡',
        isUnlocked: true,
      ),
      AchievementModel(
        id: '7',
        title: 'Maestro',
        icon: '🎪',
        isUnlocked: false,
      ),
      AchievementModel(
        id: '8',
        title: 'Experto',
        icon: '👑',
        isUnlocked: false,
      ),
    ];
  }

  @override
  Future<List<SettingItem>> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return const [
      SettingItem(
        id: '1',
        title: 'Notificaciones',
        subtitle: 'Recordatorios diarios',
        icon: '🔔',
        hasNotification: false,
        type: SettingType.notifications,
      ),
      SettingItem(
        id: '2',
        title: 'Audio',
        subtitle: 'Sonidos y pronunciación',
        icon: '🎵',
        hasNotification: false,
        type: SettingType.audio,
      ),
      SettingItem(
        id: '3',
        title: 'Tema oscuro',
        subtitle: 'Apariencia',
        icon: '🌙',
        hasNotification: false,
        type: SettingType.theme,
      ),
      SettingItem(
        id: '4',
        title: 'Ayuda',
        subtitle: 'Soporte y FAQ',
        icon: '❓',
        hasNotification: false,
        type: SettingType.help,
      ),
    ];
  }
}
