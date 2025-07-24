import 'package:integrador/perfil/data/datasource/profile_datasource.dart';
import 'package:integrador/perfil/data/models/user_profile_model.dart';
import 'package:integrador/perfil/data/models/achievement_model.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/core/services/secure_storage_service.dart';

class LocalProfileDataSource implements ProfileDataSource {
  @override
  Future<UserProfileModel> getUserProfile() async {
    final storage = SecureStorageService();
    final userData = await storage.getUserData();
    print('Datos del usuario obtenidos: $userData');
    if (userData != null) {
      // Adaptar los datos de UserModel a UserProfileModel
      return UserProfileModel(
        id: userData['id'] ?? userData['uid'] ?? '',
        name: userData['displayName'] ?? userData['name'] ?? '',
        title: 'Estudiante de zapoteco', // Valor por defecto
        avatarUrl: userData['photoUrl'] ?? '',
        level: 1, // Valor por defecto
        activeDays: 0, // Valor por defecto
        totalXP: 0, // Valor por defecto
        badges: 0, // Valor por defecto
        currentXP: 0, // Valor por defecto
        nextLevelXP: 100, // Valor por defecto
        vocabularyCount: 0, // Valor por defecto
        vocabularyGoal: 200, // Valor por defecto
      );
    }
    // Si no hay datos, retornar un modelo vacío o con valores por defecto
    return const UserProfileModel(
      id: '',
      name: '',
      title: '',
      avatarUrl: '',
      level: 1,
      activeDays: 0,
      totalXP: 0,
      badges: 0,
      currentXP: 0,
      nextLevelXP: 100,
      vocabularyCount: 0,
      vocabularyGoal: 200,
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
