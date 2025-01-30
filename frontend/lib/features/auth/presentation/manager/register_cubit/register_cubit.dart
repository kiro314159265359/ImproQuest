import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/domain/repo/register_repo.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/register_cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failure.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo registerRepo;

  RegisterCubit(this.registerRepo) : super(RegisterInitial());
  static RegisterCubit get(context) => BlocProvider.of(context);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confPassController = TextEditingController();

  Future<void> registerUser(String email, String password, String username,
      int height, int weight, String gender, DateTime birthday) async {
    print(email);
    print(emailController.text);
    emit(RegisterLoadingState());
    try {
      await registerRepo.register(
          email, password, username, height, weight, gender, birthday);
      emit(RegisterSuccessState());
    } catch (error) {
      if (error is DioException) {
        emit(RegisterErrorState(ServerFailure.fromDioError(error)));
      } else {
        emit(RegisterErrorState(ServerFailure(error.toString())));
      }
    }
  }
}
