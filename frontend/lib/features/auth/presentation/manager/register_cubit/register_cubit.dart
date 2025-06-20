import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/domain/repo/register_repo.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/register_cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failure.dart';
import 'package:intl/intl.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo registerRepo;

  RegisterCubit(this.registerRepo) : super(RegisterInitial());
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confPassController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController birthDayController = TextEditingController();
  Future<void> registerUser(String gender) async {
    emit(RegisterLoadingState());
    try {
      final raw = birthDayController.text;
      final parsedDate = DateFormat('M/d/yyyy').parseStrict(raw);
      final formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);

      await registerRepo.register(
          emailController.text,
          passController.text,
          userNameController.text,
          int.parse(heightController.text),
          int.parse(weightController.text),
          gender,
          formattedDate);
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
