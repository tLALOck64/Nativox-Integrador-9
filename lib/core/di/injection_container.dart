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
// import 'package:integrador/profile/data/datasource/profile_datasource.dart';
// import 'package:integrador/profile/data/datasource/local_profile_datasource.dart';
// import 'package:integrador/profile/data/repository/profile_repository_impl.dart';
// import 'package:integrador/profile/domain/repository/profile_repository.dart';
// import 'package:integrador/profile/domain/usecases/get_user_profile_usecase.dart';
// import 'package:integrador/profile/domain/usecases/get_achievements_usecase.dart';
// import 'package:integrador/profile/domain/usecases/get_settings_usecase.dart';
// import 'package:integrador/profile/presentation/viewmodels/profile_viewmodel.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ==========================================
  // CORE DEPENDENCIES
  // ==========================================
  
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
  
  // ==========================================
  // LOGIN FEATURE
  // ==========================================
  
  // DataSources
  sl.registerLazySingleton<AuthDataSource>(
    () => FirebaseAuthDataSource(sl(), sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  
  // ViewModels
  sl.registerFactory(() => LoginViewModel(
    signInWithEmailUseCase: sl(),
    signInWithGoogleUseCase: sl(),
    getCurrentUserUseCase: sl(),
    signOutUseCase: sl(),
  ));
  
  // ==========================================
  // PROFILE FEATURE
  // ==========================================
  
  // DataSources
  sl.registerLazySingleton<ProfileDataSource>(
    () => LocalProfileDataSource(),
  );
  
  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAchievementsUseCase(sl()));
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  
  // ViewModels
  sl.registerFactory(() => ProfileViewModel(
    getUserProfileUseCase: sl(),
    getAchievementsUseCase: sl(),
    getSettingsUseCase: sl(),
  ));
}