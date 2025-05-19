import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../home/domain/repo/user_repo.dart';
import 'distance_state.dart';

class DistanceCubit extends Cubit<DistanceState> {
  final UserRepo userRepo;
  DistanceCubit(this.userRepo) : super(DistanceInitial());

  Future<void> getDistanceToday() async {
    emit(DistanceLoading());
    try {
      final distance = await userRepo.getDistanceToday(getIt<UserModel>());

      emit(DistanceTodayLoaded(distance));
    } catch (error) {
      if (error is DioException) {
        emit(DistanceError(ServerFailure.fromDioError(error)));
      } else {
        emit(DistanceError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> getDistanceWeek() async {
    emit(DistanceLoading());
    try {
      final distance = await userRepo.getDistanceWeek(getIt<UserModel>());

      emit(DistanceLoaded(distance));
    } catch (error) {
      if (error is DioException) {
        emit(DistanceError(ServerFailure.fromDioError(error)));
      } else {
        emit(DistanceError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> getDistanceMonth() async {
    emit(DistanceLoading());
    try {
      final distance = await userRepo.getDistanceMonth(getIt<UserModel>());

      emit(DistanceLoaded(distance));
    } catch (error) {
      if (error is DioException) {
        emit(DistanceError(ServerFailure.fromDioError(error)));
      } else {
        emit(DistanceError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> getDistanceYear() async {
    emit(DistanceLoading());
    try {
      final distance = await userRepo.getDistanceYear(getIt<UserModel>());

      emit(DistanceLoaded(distance));
    } catch (error) {
      if (error is DioException) {
        emit(DistanceError(ServerFailure.fromDioError(error)));
      } else {
        emit(DistanceError(ServerFailure(error.toString())));
      }
    }
  }
}
