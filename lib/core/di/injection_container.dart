// core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:integrador/core/network/api_client.dart';
import 'package:integrador/core/network/network_info.dart';
import 'package:integrador/core/services/storage_service.dart';
import 'package:integrador/core/services/cache_service.dart';
import 'package:integrador/core/services/notifications_service.dart';

// Login imports
import 'package:integrador/login/data/datasource/auth_datasource.dart';
import 'package:integrador/login/data/datasource/firebase_auth_datasource.dart';
import 'package:integrador/login/data/repository/auth_repository_impl.dart';
import 'package:integrador/login/domain/repository/auth_repository.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:integrador/login/domain/usecases/sign_in_with_google_usecase.dart';
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

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  
  // Core Services
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<CacheService>(() => CacheService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  
  // LOGIN FEATURE
  sl.registerLazySingleton<AuthDataSource>(
    () => FirebaseAuthDataSource(sl(), sl()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl<NetworkInfo>()),
  );
  
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl(), sl<StorageService>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl(), sl<StorageService>()));
  
  sl.registerFactory(() => LoginViewModel(
    signInWithEmailUseCase: sl(),
    signInWithGoogleUseCase: sl(),
    getCurrentUserUseCase: sl(),
    signOutUseCase: sl(),
    storageService: sl<StorageService>(),
  ));
  
  // PROFILE FEATURE
  // ✅ CORREGIDO: Faltaba ProfileDataSource
  sl.registerLazySingleton<ProfileDataSource>(
    () => LocalProfileDataSource(),
  );
  
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      sl(), 
      sl<NetworkInfo>(), 
      sl<CacheService>(),
      sl<StorageService>(),
    ),
  );
  
  // ✅ CORREGIDO: Nombres de clases (Case no case)
  sl.registerLazySingleton(() => GetUserProfileUsecase(sl()));
  sl.registerLazySingleton(() => GetAchievementsUsecase(sl()));
  sl.registerLazySingleton(() => GetSettingsUsecase(sl()));
  
  sl.registerFactory(() => ProfileViewModel(
    getUserProfileUseCase: sl(),
    getAchievementsUseCase: sl(),
    getSettingsUseCase: sl(),
  ));
}