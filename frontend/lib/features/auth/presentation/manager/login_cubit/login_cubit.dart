import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/login_cubit/login_state.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/service/cache_helper.dart';
import '../../../../../core/utils/get_it_constants.dart';
import '../../../../home/presentation/manager/user_cubit.dart';
import '../../../domain/repo/login_repo.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit(this.loginRepo) : super(LoginInitial());
  TextEditingController emailController =
      TextEditingController(text: "nigga@gmail.com");
  TextEditingController passController =
      TextEditingController(text: "nigga123");

  Future<void> loginUser() async {
    emit(LoginLoadingState());

    try {
      var response =
          await loginRepo.login(emailController.text, passController.text);
      // !TODO : Clean this shit
      var accessToken = response['user']['access_token'];
      var refreshToken = response['user']['refresh_token'];

      saveAccessToken(accessToken);
      saveRefreshToken(refreshToken);

      // Fetch user data to initialize UserCubit state
      try {
        final userCubit = getIt<UserCubit>();
        await userCubit.fetchUserData(forceRefresh: true);
      } catch (e) {
        print("Warning: Failed to fetch user data after login: $e");
        // Continue with login success even if user data fetch fails
      }

      emit(LoginSuccessState());
    } catch (error) {
      if (error is DioException) {
        emit(LoginErrorState(ServerFailure.fromDioError(error)));
      } else {
        emit(LoginErrorState(ServerFailure(error.toString())));
      }
    }
  }
}
