import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/login_cubit/login_state.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/service/cache_helper.dart';
import '../../../domain/repo/login_repo.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit(this.loginRepo) : super(LoginInitial());
  TextEditingController emailController =
      TextEditingController(text: "nigga@gmail.com");
  TextEditingController passController =
      TextEditingController(text: "nigga123");
      
  Future<void> loginUser(bool rememberMe) async {
    emit(LoginLoadingState());

    try {
      var response =
          await loginRepo.login(emailController.text, passController.text);
      // !TODO : Clean this shit
      var accessToken = response['user']['access_token'];
      var refreshToken = response['user']['refresh_token'];

      if (rememberMe) {
        saveAccessToken(accessToken);
        saveRefreshToken(refreshToken);
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
