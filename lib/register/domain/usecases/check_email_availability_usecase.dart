import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import '../../data/datasource/registration_datasource.dart';

class CheckEmailAvailabilityUseCase {
  final RegistrationDataSource _registrationDataSource;

  CheckEmailAvailabilityUseCase(this._registrationDataSource);

  Future<Either<Failure, bool>> call(String email) async {
    try {
      final isAvailable = await _registrationDataSource.checkEmailAvailability(
        email,
      );
      return Right(isAvailable);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
