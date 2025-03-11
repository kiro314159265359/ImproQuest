import 'package:flutter_application_2/core/service/api/api_service.dart';
import 'package:flutter_application_2/features/auth/data/api/login_api.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import 'package:flutter_application_2/features/home/data/api/user_api.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/core/network/dio_interceptor.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize ApiService once.
  final apiService = ApiService();

  // Inject the ApiService into LoginApi.
  final LoginRepo loginRepo = LoginApi(apiService);

  final UserApi userApi = UserApi(apiService);

  // Create and add the token interceptor.
  final tokenInterceptor =
      TokenInterceptor(dio: apiService.dio, loginRepo: loginRepo);
  apiService.dio.interceptors.add(tokenInterceptor);

  // Register your single instances.
  getIt.registerSingleton<ApiService>(apiService);
  getIt.registerSingleton<LoginRepo>(loginRepo);
  getIt.registerSingleton<UserCubit>(UserCubit(userApi));
}
