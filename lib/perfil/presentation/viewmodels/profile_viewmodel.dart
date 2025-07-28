import 'package:flutter/foundation.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/navigation/navigation_service.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/perfil/domain/entities/user_profile.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/domain/usecases/get_user_profile_usecase.dart';
import 'package:integrador/perfil/domain/usecases/get_achievements_usecase.dart';
import 'package:integrador/perfil/domain/usecases/get_settings_usecase.dart';
import 'package:integrador/perfil/presentation/states/profile_state.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetUserProfileUsecase _getUserProfileUseCase;
  final GetAchievementsUsecase _getAchievementsUseCase;
  final GetSettingsUsecase _getSettingsUseCase;

  ProfileState _state = ProfileState.loading();
  ProfileState get state => _state;

  ProfileViewModel({
    required GetUserProfileUsecase getUserProfileUseCase,
    required GetAchievementsUsecase getAchievementsUseCase,
    required GetSettingsUsecase getSettingsUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _getAchievementsUseCase = getAchievementsUseCase,
       _getSettingsUseCase = getSettingsUseCase;

  Future<void> loadProfile() async {
    _updateState(_state.copyWith(status: ProfileStatus.loading));

    try {
      final results = await Future.wait([
        _getUserProfileUseCase(),
        _getAchievementsUseCase(),
        _getSettingsUseCase(),
      ]);

      final profileResult = results[0] as Either<Failure, UserProfile>;
      final achievementsResult = results[1] as Either<Failure, List<Achievement>>;
      final settingsResult = results[2] as Either<Failure, List<SettingItem>>;

      // Verificar si alguno falló
      if (profileResult.isLeft) {
        _handleFailure(profileResult.left);
        return;
      }

      if (achievementsResult.isLeft) {
        _handleFailure(achievementsResult.left);
        return;
      }

      if (settingsResult.isLeft) {
        _handleFailure(settingsResult.left);
        return;
      }

      // Todos exitosos
      _updateState(_state.copyWith(
        status: ProfileStatus.loaded,
        userProfile: profileResult.right,
        achievements: achievementsResult.right,
        settings: settingsResult.right,
      ));

    } catch (e) {
      _handleFailure(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  void onSettingTapped(SettingItem setting) {
    switch (setting.type) {
      case SettingType.notifications:
        NavigationService.push('${RouteNames.settings}/notifications');
        break;
      case SettingType.audio:
        NavigationService.push('${RouteNames.settings}/audio');
        break;
      case SettingType.theme:
        NavigationService.push(RouteNames.downloadPdf);
        break;
      case SettingType.help:
        NavigationService.push('${RouteNames.settings}/help');
        break;
    }
  }

  void _handleFailure(Failure failure) {
    String errorMessage = _getErrorMessage(failure);
    
    _updateState(_state.copyWith(
      status: ProfileStatus.error,
      errorMessage: errorMessage,
    ));
  }

  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Sin conexión. Verifica tu internet.';
    } else if (failure is CacheFailure) {
      return 'Error al cargar datos guardados.';
    } else if (failure is ServerFailure) {
      return 'Error del servidor. Intenta más tarde.';
    } else {
      return 'Error inesperado. Intenta nuevamente.';
    }
  }

  void _updateState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }
}
