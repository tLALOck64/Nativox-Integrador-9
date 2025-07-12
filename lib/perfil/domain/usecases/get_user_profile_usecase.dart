import 'package:integrador/perfil/domain/entities/user_profile.dart';
import 'package:integrador/perfil/domain/repository/profile_repository.dart';

class GetUserProfileUsecase {
  final ProfileRepository _profileRepository;

  GetUserProfileUsecase(this._profileRepository);

  Future<UserProfile> call() {
    return _profileRepository.getUserProfile();
  }
}