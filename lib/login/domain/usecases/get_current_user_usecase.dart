import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;
import 'package:integrador/login/domain/repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  GetCurrentUserUseCase(this._authRepository, this._storageService);

  Future<Either<Failure, domain.User?>> call() async {
    final result = await _authRepository.getCurrentUser();
    
    return result.fold(
      (failure) async {
        // Si falla Firebase, intentar obtener de cache local
        try {
          final userData = await _storageService.getUserData();
          if (userData != null) {
            final cachedUser = domain.User(
              id: userData['id'] ?? '',
              email: userData['email'] ?? '',
              displayName: userData['displayName'] ?? '',
              photoUrl: userData['photoUrl'],
            );
            return Right(cachedUser);
          }
          
          // No hay usuario ni en Firebase ni en cache
          return const Right(null);
        } catch (e) {
          // Error accediendo al cache, retornar el error original
          return Left(failure);
        }
      },
      (user) async {
        // Usuario obtenido exitosamente, actualizar cache
        if (user != null) {
          try {
            await _storageService.saveUserData({
              'id': user.id,
              'email': user.email,
              'displayName': user.displayName,
              'photoUrl': user.photoUrl,
            });
          } catch (e) {
            // Error guardando en cache, pero no es crítico
          }
        }
        return Right(user);
      },
    );
  }
}