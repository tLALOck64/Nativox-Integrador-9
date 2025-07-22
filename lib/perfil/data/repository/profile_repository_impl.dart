import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/network/network_info.dart';
import 'package:integrador/core/services/cache_service.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/perfil/data/datasource/profile_datasource.dart';
import 'package:integrador/perfil/domain/entities/user_profile.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final CacheService _cacheService;
  final StorageService _storageService;

  ProfileRepositoryImpl(
    this._dataSource,
    this._networkInfo,
    this._cacheService,
    StorageService storageService,
  ) : _storageService = storageService;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final cachedProfile = _cacheService.get<UserProfile>('user_profile');
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }

      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        return Left(NetworkFailure.noInternet());
      }

      final model = await _dataSource.getUserProfile();
      final profile = model.toEntity();

      _cacheService.put(
        'user_profile',
        profile,
        expiry: const Duration(hours: 1),
      );

      return Right(profile);
    } catch (e) {
      return Left(ServerFailure('Error al obtener perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getAchievements() async {
    try {
      final cachedAchievements = _cacheService.get<List<Achievement>>(
        'achievements',
      );
      if (cachedAchievements != null) {
        return Right(cachedAchievements);
      }

      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        return Left(NetworkFailure.noInternet());
      }

      final models = await _dataSource.getAchievements();
      final achievements = models.map((model) => model.toEntity()).toList();

      _cacheService.put(
        'achievements',
        achievements,
        expiry: const Duration(minutes: 30),
      );

      return Right(achievements);
    } catch (e) {
      return Left(ServerFailure('Error al obtener logros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SettingItem>>> getSettings() async {
    try {
      final settings = await _dataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(
        ServerFailure('Error al obtener configuraciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSetting(bool enabled) async {
    try {
      final hasConnection = await _networkInfo.isConnected;
      if (!hasConnection) {
        return Left(NetworkFailure.noInternet());
      }

      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Error al actualizar notificaciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateThemeSetting(bool isDarkMode) async {
    try {
      await _storageService.saveBool('dark_mode', isDarkMode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al guardar tema: ${e.toString()}'));
    }
  }
}
