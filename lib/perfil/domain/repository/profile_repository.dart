import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/perfil/domain/entities/user_profile.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart'; // ✅ Import Achievement
import 'package:integrador/perfil/domain/entities/sentting_item.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, List<Achievement>>> getAchievements(); // ✅ Usa Achievement entity
  Future<Either<Failure, List<SettingItem>>> getSettings();
  Future<Either<Failure, void>> updateNotificationSetting(bool enabled);
  Future<Either<Failure, void>> updateThemeSetting(bool isDarkMode);
}