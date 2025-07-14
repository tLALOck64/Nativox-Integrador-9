import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/login/domain/repository/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  SignOutUseCase(this._authRepository, this._storageService);

  Future<Either<Failure, void>> call() async {
    final result = await _authRepository.signOut();
    
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        try {
          // Limpiar datos locales después del signOut exitoso
          await _storageService.clearTokens();
          await _storageService.remove('user_data');
          return const Right(null);
        } catch (e) {
          // Si falla la limpieza local, no es crítico
          return Left(CacheFailure('Error al limpiar datos locales: ${e.toString()}'));
        }
      },
    );
  }
}
