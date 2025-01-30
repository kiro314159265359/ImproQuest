import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/login_cubit/login_state.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/repo/login_repo.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit(this.loginRepo) : super(LoginInitial());

  Future<void> loginUser(String email, String password) async {
    emit(LoginLoadingState());
    try {
      await loginRepo.login(email, password);
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
