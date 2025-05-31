// ${filename}
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

// Data layer
import 'data/datasources/server_api.dart';
import 'data/datasources/local_storage.dart';
import 'data/repositories/server_repository.dart';
import 'data/repositories/vpn_repository.dart';

// Domain layer
import 'domain/repositories/server_repository.dart';
import 'domain/repositories/vpn_repository.dart';

// Presentation layer
import 'presentation/bloc/server/server_bloc.dart';
import 'presentation/bloc/vpn/vpn_bloc.dart';

// Core
import 'core/constants/api_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  sl.registerLazySingleton(() => _createDio());

  // Data sources
  sl.registerLazySingleton<ServerApi>(() => ServerApiImpl(sl()));
  sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sl()));

  // Repositories
  sl.registerLazySingleton<ServerRepository>(
    () => ServerRepositoryImpl(
      serverApi: sl(),
      localStorage: sl(),
    ),
  );
  sl.registerLazySingleton<VpnRepository>(() => VpnRepositoryImpl());

  // BLoCs
  sl.registerFactory(() => ServerBloc(sl()));
  sl.registerFactory(() => VpnBloc(sl()));
}

Dio _createDio() {
  final dio = Dio();

  dio.options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  // Add interceptors for logging in debug mode
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) => print(object),
  ));

  return dio;
}
