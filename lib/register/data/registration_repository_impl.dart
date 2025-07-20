import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import '../domain/entities/registration_request.dart';
import '../domain/entities/registration_response.dart';
import '../domain/repository/registration_repository.dart';
import 'datasource/registration_datasource.dart';
import 'model/registration_request_model.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationDataSource dataSource;

  RegistrationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, RegistrationResponse>> registerWithEmailAndPassword(
    RegistrationRequest request,
  ) async {
    try {
      final model = RegistrationRequestModel(
        nombre: request.nombre,
        apellido: request.apellido,
        email: request.email,
        phone: request.phone,
        contrasena: request.contrasena,
        idiomaPreferido: request.idiomaPreferido,
        fcmToken: request.fcmToken,
        isGoogle: request.isGoogle,
      );
      final response = await dataSource.registerWithEmailAndPassword(model);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegistrationResponse>> registerWithFirebase(
    RegistrationRequest request,
    String displayName,
    String firebaseUid,
    bool emailVerified,
  ) async {
    try {
      final model = RegistrationRequestModel(
        nombre: request.nombre,
        apellido: request.apellido,
        email: request.email,
        phone: request.phone,
        contrasena: request.contrasena,
        idiomaPreferido: request.idiomaPreferido,
        fcmToken: request.fcmToken,
        isGoogle: request.isGoogle,
      );
      final response = await dataSource.registerWithFirebase(
        model,
        displayName,
        firebaseUid,
        emailVerified,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
