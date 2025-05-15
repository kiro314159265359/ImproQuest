import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/repo/login_repo.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final LoginRepo loginRepo;
  String? resetToken;

  ForgetPasswordCubit(this.loginRepo) : super(ForgetPasswordInitial());

  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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

  Future<void> verifyOTP() async {
    emit(OTPSendingState());

    try {
      var response =
          await loginRepo.verifyOTP(emailController.text, otpController.text);
      resetToken = response['reset_token'];

      emit(OTPSuccessState());
    } catch (error) {
      if (error is DioException) {
        emit(OTPErrorState(ServerFailure.fromDioError(error)));
      } else {
        emit(OTPErrorState(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> resetPassword() async {
    emit(ResetPasswordSendingState());

    try {
      await loginRepo.resetPassword(
        newPasswordController.text,
        resetToken!,
      );

      emit(ResetPasswordSuccessState());
    } catch (error) {
      if (error is DioException) {
        emit(ResetPasswordErrorState(ServerFailure.fromDioError(error)));
      } else {
        emit(ResetPasswordErrorState(ServerFailure(error.toString())));
      }
    }
  }
}
