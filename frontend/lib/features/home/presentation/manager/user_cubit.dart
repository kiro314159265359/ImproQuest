import 'package:dio/dio.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../../game/logic/shop_bloc.dart';
import '../../data/model/user_model.dart';
import '../../domain/repo/user_repo.dart';

class UserCubit extends HydratedCubit<UserState> {
  final UserRepo userRepo;
  UserModel? currentUser;

  UserCubit(this.userRepo) : super(UserInitial());

  Future<UserModel> fetchUserData() async {
    emit(UserLoading());
    try {
      currentUser = await userRepo.getUserData();
      // Always emit a UserLoaded state so that persistence works.
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

  Future<void> updateUserData(UserModel updatedUser) async {
    emit(UserUpdating());
    try {
      currentUser = await userRepo.updateUserData(updatedUser);

      // Emit as loaded so that state persists.
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

  int get completedQuestCount =>
      currentUser?.quests?.where((q) => q.isCompleted == true).length ?? 0;

  int get totalQuestCount => currentUser?.quests?.length ?? 0;

  int get remainingQuestCount => totalQuestCount - completedQuestCount;

  double get questCompletionPercent =>
      totalQuestCount > 0 ? completedQuestCount / totalQuestCount : 0.0;

  List<Quests> get quests =>
      currentUser?.quests?.where((q) => q.isCustom == false).toList() ?? [];

  List<Quests> get customQuests =>
      currentUser?.quests?.where((q) => q.isCustom == true).toList() ?? [];

  Future<void> completeQuest(Quests? q) async {
    if (q?.isCompleted == true) return;

    try {
      await userRepo.completeQuest(q?.sId);

      currentUser = await userRepo.getUserData();

      if (totalQuestCount > 0 && completedQuestCount == totalQuestCount) {
        await userRepo.completeStreak();
        currentUser = await userRepo.getUserData();
      }

      // Always emit as loaded.
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

  Future<void> addCustomQuest(
      String questName, int questDifficultyLevel, String questType) async {
    emit(UserUpdating());
    try {
      int questXp = 0;
      int questGold = 0;

      switch (questDifficultyLevel) {
        case 0:
          questXp = 10;
          questGold = 10;
          break;
        case 1:
          questXp = 20;
          questGold = 20;
          break;
        case 2:
          questXp = 30;
          questGold = 30;
          break;
        case 3:
          questXp = 40;
          questGold = 40;
          break;
        case 4:
          questXp = 50;
          questGold = 50;
          break;
        case 5:
          questXp = 60;
          questGold = 60;
          break;
        default:
          questXp = 0;
          questGold = 0;
          break;
      }
      await userRepo.addCustomQuest(questName, questXp, questGold, questType);

      currentUser = await userRepo.getUserData();

      // Emit loaded state
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

  Future<bool> updateQuestProgress(String? questId, double? progress) async {
    emit(UserUpdating());
    try {
      await userRepo.updateQuestProgress(questId!, progress!);

      currentUser = await userRepo.getUserData();

      // Emit as loaded.
      emit(UserLoaded(currentUser!));

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser!);
      
      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
      getIt.registerSingleton<ShopBloc>(ShopBloc(user: currentUser!));

      return true;
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!));
        }
      }
      return false;
    }
  }

  void updateDistance(double distance) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(UserLoaded(currentState.user, totalDistance: distance));
    }
  }

  /// Handles distance updates and checks quest progress.
  Future<void> updateDistanceAndCheckQuests(double distance) async {
    updateDistance(distance);
    if (state is UserLoaded) {
      final loadedState = state as UserLoaded;
      final questsToComplete = loadedState.user.quests?.where((quest) =>
          quest.isCompleted != true &&
          quest.goal != null &&
          distance >= quest.goal!);
      if (questsToComplete != null) {
        for (var quest in questsToComplete) {
          await completeQuest(quest);
        }
      }
    }
  }

  // --- HydratedCubit overrides ---
  @override
  UserState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('user')) {
        final user = UserModel.fromJson(json['user']);
        final totalDistance = json['totalDistance'] ?? 0.0;
        currentUser = user;
        return UserLoaded(user, totalDistance: totalDistance);
      }
      return UserInitial();
    } catch (_) {
      return UserInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    if (state is UserLoaded) {
      return {
        'user': state.user.toJson(),
        'totalDistance': state.totalDistance,
      };
    }
    return null;
  }
}
