import 'package:integrador/login/data/datasource/firebase_auth_datasource.dart';
import 'package:integrador/login/data/model/user_model.dart';

class RegisterWithFirebaseEmailUseCase {
  final FirebaseAuthDataSource firebaseAuthDataSource;

  RegisterWithFirebaseEmailUseCase(this.firebaseAuthDataSource);

  Future<UserModel?> call(String email, String password) async {
    return await firebaseAuthDataSource.registerWithEmailAndPassword(
      email,
      password,
    );
  }
}
