import 'package:dio/dio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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

  /// Helper method to get current distance from state
  double get _currentDistance =>
      (state is UserLoaded) ? (state as UserLoaded).totalDistance : 0.0;

  Future<UserModel> fetchUserData() async {
    // Capture the previous distance before emitting a new state.
    double previousDistance = 0.0;
    if (state is UserLoaded) {
      previousDistance = (state as UserLoaded).totalDistance;
    }
    print("Captured previousDistance: $previousDistance");

    // Now emit loading without affecting the captured value.
    emit(UserLoading());
    try {
      final freshUser = await userRepo.getUserData();
      print("Fetched new user data. Preserving distance: $previousDistance");
      currentUser = freshUser;
      // Emit the new state with the preserved distance.
      emit(UserLoaded(currentUser!, totalDistance: previousDistance));

      // Update GetIt registrations...
      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser!);

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

      // Emit as loaded so that state persists with the current distance
      emit(UserLoaded(currentUser!, totalDistance: _currentDistance));

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
          emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
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

      // Always emit as loaded with the preserved distance.
      emit(UserLoaded(currentUser!, totalDistance: _currentDistance));

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser!);

      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
      getIt.registerSingleton<ShopBloc>(ShopBloc(user: currentUser!));

      if (quests.isNotEmpty &&
          quests.every((quest) => quest.isCompleted == true)) {
        // Send reset command to the background service.
        await FlutterForegroundTask.stopService();
        // Optionally, update the local state to reflect that totalDistance is now reset.
        emit(UserLoaded(currentUser!, totalDistance: 0.0));
      }
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
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

      // Emit loaded state with preserved distance
      emit(UserLoaded(currentUser!, totalDistance: _currentDistance));

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
          emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
        }
      }
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
      print("Hydrating state from: $json");
      if (json.containsKey('user')) {
        final user = UserModel.fromJson(json['user']);
        final totalDistance = json['totalDistance'] ?? 0.0;
        print("Hydrated totalDistance: $totalDistance");
        currentUser = user;
        return UserLoaded(user, totalDistance: totalDistance);
      }
      return UserInitial();
    } catch (e) {
      print("Error in hydration: $e");
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
