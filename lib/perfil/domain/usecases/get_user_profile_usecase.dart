import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/perfil/domain/entities/user_profile.dart';
import 'package:integrador/perfil/domain/repository/profile_repository.dart';

class GetUserProfileUsecase {
  final ProfileRepository _profileRepository;

  GetUserProfileUsecase(this._profileRepository);

  Future<Either<Failure, UserProfile>> call() {
    return _profileRepository.getUserProfile();
  }
}