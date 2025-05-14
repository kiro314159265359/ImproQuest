import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/repo/login_repo.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final LoginRepo loginRepo;

  ForgetPasswordCubit(this.loginRepo) : super(ForgetPasswordInitial());
  TextEditingController emailController = TextEditingController();

  Future<void> forgetPassword() async {
    emit(EmailSendingState());

    try {
      await loginRepo.forgetPassword(emailController.text);

      emit(EmailSuccessState());
    } catch (error) {
      if (error is DioException) {
        emit(EmailErrorState(ServerFailure.fromDioError(error)));
      } else {
        emit(EmailErrorState(ServerFailure(error.toString())));
      }
    }
  }
}
