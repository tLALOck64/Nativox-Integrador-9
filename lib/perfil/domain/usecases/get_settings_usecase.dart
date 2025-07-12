import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/domain/repository/profile_repository.dart';

class GetSettingsUsecase {
  final ProfileRepository _profileRepository;

  GetSettingsUsecase(this._profileRepository);

  Future<List<SettingItem>> call() {
    return _profileRepository.getSettings();
  }
}