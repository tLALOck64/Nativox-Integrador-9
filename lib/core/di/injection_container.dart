import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:integrador/core/network/api_client.dart';
import 'package:integrador/core/network/network_info.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/services/cache_service.dart';
import 'package:integrador/core/services/notifications_service.dart';
import 'package:integrador/core/services/fcm_service.dart';
import 'package:integrador/login/data/datasource/auth_datasource.dart';
import 'package:integrador/login/data/repository/auth_repository_impl.dart';
import 'package:integrador/login/domain/repository/auth_repository.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_or_register_with_google_usecase.dart';
import 'package:integrador/login/domain/usecases/get_current_user_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_out_usecase.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';

// Profile imports
import 'package:integrador/perfil/data/datasource/profile_datasource.dart';
import 'package:integrador/perfil/data/datasource/local_profile_datasource.dart';
import 'package:integrador/perfil/data/repository/profile_repository_impl.dart';
import 'package:integrador/perfil/domain/repository/profile_repository.dart';
import 'package:integrador/perfil/domain/usecases/get_user_profile_usecase.dart';
import 'package:integrador/perfil/domain/usecases/get_achievements_usecase.dart';
import 'package:integrador/perfil/domain/usecases/get_settings_usecase.dart';
import 'package:integrador/perfil/presentation/viewmodels/profile_viewmodel.dart';

// REGISTER FEATURE
import 'package:integrador/register/data/datasource/registration_datasource.dart';
import 'package:integrador/register/data/registration_repository_impl.dart';
import 'package:integrador/register/domain/repository/registration_repository.dart';
import 'package:integrador/register/domain/usecases/register_with_email_usecase.dart';
import 'package:integrador/register/domain/usecases/check_email_availability_usecase.dart';
import 'package:integrador/register/domain/usecases/register_with_firebase_email_usecase.dart';
import 'package:integrador/register/domain/usecases/register_with_google_usecase.dart';
import 'package:integrador/register/presentation/viewmodels/registration_viewmodel.dart';
import 'package:integrador/login/data/datasource/firebase_auth_datasource.dart';

final GetIt sl = GetIt.instance;

bool _isInitialized = false;

Future<void> initializeDependencies() async {
  if (_isInitialized) {
    print('⚠️ DI: Dependencies already initialized, skipping...');
    return;
  }

  print('🔧 DI: Starting dependency initialization...');

  // External
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Core Services
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<CacheService>(() => CacheService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<FCMService>(() => FCMService());

  // ✅ LOGIN FEATURE - CORREGIDO
  sl.registerLazySingleton<AuthDataSource>(() {
    print('🎯 DI: Registering AuthDataSourceImpl (API + Firebase hybrid)');
    return AuthDataSourceImpl(sl(), sl());
  });

  sl.registerLazySingleton<AuthRepository>(() {
    print('🎯 DI: Registering AuthRepositoryImpl');
    return AuthRepositoryImpl(sl(), sl<NetworkInfo>());
  });

  sl.registerLazySingleton(() {
    print('🎯 DI: Registering SignInWithEmailUseCase');
    return SignInWithEmailUseCase(sl());
  });

  sl.registerLazySingleton(() {
    print('🎯 DI: Registering SignInWithGoogleUseCase');
    return SignInWithGoogleUseCase(sl());
  });

  sl.registerLazySingleton(() {
    print('🎯 DI: Registering SignInOrRegisterWithGoogleUseCase');
    return SignInOrRegisterWithGoogleUseCase(
      sl(),
      sl<RegistrationDataSource>(),
      sl<FirebaseAuth>(),
      sl<FCMService>(),
    );
  });

  sl.registerLazySingleton(
    () => GetCurrentUserUseCase(sl(), sl<StorageService>()),
  );
  sl.registerLazySingleton(() => SignOutUseCase(sl(), sl<StorageService>()));

  sl.registerFactory(() {
    print('🎯 DI: Creating LoginViewModel instance');
    return LoginViewModel(
      signInWithEmailUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      signInOrRegisterWithGoogleUseCase: sl(),
      getCurrentUserUseCase: sl(),
      signOutUseCase: sl(),
      storageService: sl<StorageService>(),
    );
  });

  sl.registerLazySingleton<ProfileDataSource>(() => LocalProfileDataSource());

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      sl(),
      sl<NetworkInfo>(),
      sl<CacheService>(),
      sl<StorageService>(),
    ),
  );

  sl.registerLazySingleton(() => GetUserProfileUsecase(sl()));
  sl.registerLazySingleton(() => GetAchievementsUsecase(sl()));
  sl.registerLazySingleton(() => GetSettingsUsecase(sl()));

  sl.registerFactory(
    () => ProfileViewModel(
      getUserProfileUseCase: sl(),
      getAchievementsUseCase: sl(),
      getSettingsUseCase: sl(),
    ),
  );

  // REGISTER FEATURE
  sl.registerLazySingleton<RegistrationDataSource>(
    () => RegistrationDataSourceImpl(),
  );
  sl.registerLazySingleton<RegistrationRepository>(
    () => RegistrationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => RegisterWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => CheckEmailAvailabilityUseCase(sl()));
  sl.registerLazySingleton(
    () => FirebaseAuthDataSource(sl<FirebaseAuth>(), sl<GoogleSignIn>()),
  );
  sl.registerLazySingleton(() => RegisterWithFirebaseEmailUseCase(sl()));
  sl.registerLazySingleton(
    () => RegisterWithGoogleUseCase(
      sl<FirebaseAuthDataSource>(),
      sl<RegistrationDataSource>(),
    ),
  );
  sl.registerFactory(
    () => RegistrationViewModel(
      registerUseCase: sl(),
      checkEmailUseCase: sl(),
      storageService: sl<SecureStorageService>(),
      registerWithFirebaseEmailUseCase: sl(),
      registerWithGoogleUseCase: sl(),
    ),
  );

  _isInitialized = true;
  print('🎯 DI: All dependencies initialized successfully');
  print(
    '🎯 DI: AuthDataSource -> AuthDataSourceImpl (API for email, Firebase for Google)',
  );
  print('🎯 DI: Ready for login operations');
}

void verifyDependencies() {
  try {
    print('🔍 DI Verification:');

    final authDataSource = sl<AuthDataSource>();
    print('✅ AuthDataSource: ${authDataSource.runtimeType}');

    final authRepository = sl<AuthRepository>();
    print('✅ AuthRepository: ${authRepository.runtimeType}');

    final emailUseCase = sl<SignInWithEmailUseCase>();
    print('✅ SignInWithEmailUseCase: ${emailUseCase.runtimeType}');

    final googleUseCase = sl<SignInWithGoogleUseCase>();
    print('✅ SignInWithGoogleUseCase: ${googleUseCase.runtimeType}');

    print('✅ All login dependencies verified successfully');
  } catch (e) {
    print('❌ DI Verification failed: $e');
  }
}

// Función para resetear el estado de inicialización (útil para testing)
void resetDependencies() {
  _isInitialized = false;
  sl.reset();
  print('🔄 DI: Dependencies reset');
}