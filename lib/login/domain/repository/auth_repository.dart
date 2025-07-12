import 'package:integrador/login/domain/entities/auth_result.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;

abstract class AuthRepository {
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  Future<domain.User?> getCurrentUser();
  Stream<domain.User?> get authStateChanges;
}
