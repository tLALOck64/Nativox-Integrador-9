import '../entities/registration_request.dart';
import '../entities/registration_response.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, RegistrationResponse>> registerWithEmailAndPassword(
    RegistrationRequest request,
  );

  Future<Either<Failure, RegistrationResponse>> registerWithFirebase(
    RegistrationRequest request,
    String displayName,
    String firebaseUid,
    bool emailVerified,
  );
}
