import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:integrador/perfil/domain/repository/profile_repository.dart';

class GetAchievementsUsecase {
  final ProfileRepository _profileRepository;

  GetAchievementsUsecase(this._profileRepository);

  Future<Either<Failure, List<Achievement>>> call() {
    return _profileRepository.getAchievements();
  }
}