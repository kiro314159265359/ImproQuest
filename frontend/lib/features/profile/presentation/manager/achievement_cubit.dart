import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../home/domain/repo/user_repo.dart';
import 'achievement_state.dart';

class AchievementCubit extends Cubit<AchievementState> {
  final UserRepo userRepo;
  AchievementCubit(this.userRepo) : super(AchievementInitial());

  Future<void> getAchievementsList() async {
    emit(AchievementLoading());
    try {
      final unlockedList = await userRepo.getUnlockedAchievementModelList();
      final lockedList = await userRepo.getlockedAchievementModelList();
      emit(AchievementsLoaded(
        unlockedAchievementsList: unlockedList,
        lockedAchievementsList: lockedList,
      ));
    } catch (error) {
      if (error is DioException) {
        emit(AchievementError(ServerFailure.fromDioError(error)));
      } else {
        emit(AchievementError(ServerFailure(error.toString())));
      }
    }
  }
}
