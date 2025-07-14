import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'package:integrador/login/domain/entities/user.dart' as domain;

abstract class AuthRepository {
  Future<Either<Failure, domain.User>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, domain.User>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, domain.User?>> getCurrentUser();
  Stream<domain.User?> get authStateChanges;
}