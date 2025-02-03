import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repo/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;

  UserCubit(this.userRepo) : super(UserInitial());

  Future<void> fetchUserData() async {
    emit(UserLoading());
    try {
      final user = await userRepo.getUserData();
      emit(UserLoaded(user));
    } catch (error) {
      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
      }
    }
  }
}
