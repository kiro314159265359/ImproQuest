import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../../core/utils/quest_progress_manager.dart'; // Add this import
import '../../../../game/logic/shop_bloc.dart';
import '../../data/model/user_model.dart';
import '../../domain/repo/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;
  UserModel? currentUser;

  UserCubit(this.userRepo) : super(UserInitial());

  Future<UserModel> fetchUserData() async {
    emit(UserLoading());
    try {
      // Fetch user data from API
      currentUser = await userRepo.getUserData();

      // Merge local quest progress with API data
      if (currentUser != null && currentUser!.quests != null) {
        await _mergeLocalQuestProgress();
      }

      emit(UserLoaded(currentUser!));

      // Update GetIt with the new UserModel.
      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser!);

      // Register or update the ShopBloc with the fetched user.
      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
      getIt.registerSingleton<ShopBloc>(ShopBloc(user: currentUser!));

      return currentUser!;
    } catch (error) {
      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
      }
      rethrow;
    }
  }

  // New method to merge local quest progress with API data
  Future<void> _mergeLocalQuestProgress() async {
    try {
      // Get all stored local progress
      final progressMap = await QuestProgressManager.getAllQuestProgress();

      // Apply local progress to each quest
      for (final quest in currentUser!.quests!) {
        if (quest.sId != null && progressMap.containsKey(quest.sId)) {
          // If the quest is not completed, apply the local progress
          if (quest.isCompleted != true) {
            // Assuming there's a progress field in the Quest model
            // If not, you'll need to extend the model
            quest.progress = progressMap[quest.sId] ?? 0.0;

            // Check if we should mark the quest as completed based on local progress
            if (quest.goal != null && quest.progress >= quest.goal!) {
              await completeQuest(quest);
            }
          } else {
            // Quest is already completed, clear its local progress
            await QuestProgressManager.clearQuestProgress(quest.sId!);
          }
        }
      }
    } catch (e) {
      print('Error merging local quest progress: $e');
    }
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    emit(UserUpdating());
    try {
      final currentUser = await userRepo.updateUserData(updatedUser);

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser);

      emit(UserUpdated(currentUser));
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!));
        }
      }
    }
  }

  int get completedQuestCount =>
      currentUser?.quests?.where((q) => q.isCompleted == true).length ?? 0;

  int get totalQuestCount => currentUser?.quests?.length ?? 0;

  int get remainingQuestCount => totalQuestCount - completedQuestCount;

  double get questCompletionPercent =>
      totalQuestCount > 0 ? completedQuestCount / totalQuestCount : 0.0;

  Future<void> completeQuest(Quests? q) async {
    if (q?.isCompleted == true) return;

    try {
      await userRepo.completeQuest(q?.sId);

      currentUser = await userRepo.getUserData();

      if (totalQuestCount > 0 && completedQuestCount == totalQuestCount) {
        await userRepo.completeStreak();

        currentUser = await userRepo.getUserData();
      }

      emit(UserLoaded(currentUser!));

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser!);

      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
      getIt.registerSingleton<ShopBloc>(ShopBloc(user: currentUser!));
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!));
        }
      }
    }
  }
}
