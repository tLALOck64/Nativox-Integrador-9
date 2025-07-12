import 'package:integrador/login/data/datasource/auth_datasource.dart';
import 'package:integrador/login/domain/entities/auth_result.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain; // ← Alias para tu entidad
import 'package:integrador/login/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userModel = await _authDataSource.signInWithEmailAndPassword(email, password);
      if (userModel != null) {
        return AuthResult.success(userModel.toEntity());
      }
      return AuthResult.failure('Error al iniciar sesión');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final userModel = await _authDataSource.signInWithGoogle();
      if (userModel != null) {
        return AuthResult.success(userModel.toEntity());
      }
      return AuthResult.failure('Inicio de sesión cancelado');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    final userModel = await _authDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<domain.User?> get authStateChanges {
    return _authDataSource.authStateChanges.map((userModel) => userModel?.toEntity());
  }
}