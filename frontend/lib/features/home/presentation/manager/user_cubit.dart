import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';

import '../../../../core/error/failure.dart';
import '../../data/model/user_model.dart';
import '../../domain/repo/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;
  UserModel? currentUser;

  UserCubit(this.userRepo) : super(UserInitial());

  Future<void> fetchUserData() async {
    emit(UserLoading());
    try {
      final currentUser = await userRepo.getUserData();
      emit(UserLoaded(currentUser));
    } catch (error) {
      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    emit(UserUpdating());
    try {
      final currentUser = await userRepo.updateUserData(updatedUser);
      emit(UserUpdated(currentUser));
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        emit(UserLoaded(currentUser!));
      }
    }
  }
}
