import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/data/quest_reward_data.dart';
import 'package:flutter_application_2/game/models/shop_item.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:image_picker/image_picker.dart'; // Added for XFile
import '../../../../core/error/failure.dart';
import '../../../../core/service/cache_helper.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../../game/logic/shop_bloc.dart';
import '../../data/model/user_model.dart';
import '../../domain/repo/user_repo.dart';
import 'package:intl/intl.dart';

class UserCubit extends HydratedCubit<UserState> {
  final UserRepo userRepo;
  UserModel? currentUser;
  List<ShopItem>? itemsList;
  bool _isFetching = false; // Flag to prevent concurrent fetches
  UserCubit(this.userRepo) : super(UserInitial());

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController birthDayController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  /// Helper method to get current distance from state
  double get _currentDistance =>
      (state is UserLoaded) ? (state as UserLoaded).totalDistance : 0.0;

  Future<UserModel> fetchUserData({bool forceRefresh = false}) async {
    // Prevent concurrent fetches
    if (_isFetching) {
      print("Fetch already in progress, waiting for it to complete...");
      // Wait for the current fetch to complete
      while (_isFetching) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      if (currentUser != null) {
        return currentUser!;
      }
    }

    // Check if we already have fresh data and don't need to refetch
    if (!forceRefresh &&
        (state is UserLoaded || state is UserUpdated) &&
        currentUser != null) {
      print("User data already loaded, skipping fetch");
      return currentUser!;
    }

    _isFetching = true;

    // Capture the previous distance before emitting a new state.
    double previousDistance = 0.0;
    if (state is UserLoaded) {
      previousDistance = (state as UserLoaded).totalDistance;
    }
    print("Captured previousDistance: $previousDistance");

    try {
      // Now emit loading without affecting the captured value.
      emit(UserLoading());

      print("Fetching fresh user data from API...");
      final freshUser = await userRepo.getUserData();
      print("GAY: ${freshUser.toJson()}");
      print("Fetched new user data. Preserving distance: $previousDistance");
      currentUser = freshUser;
      // Emit the new state with the preserved distance.
      emit(UserLoaded(currentUser!, totalDistance: previousDistance));
      _updateGetItRegistrations(currentUser!);

      return currentUser!;
    } catch (error) {
      print("API error: ${error.toString()}");
      // If we have cached data and there's a network error, fall back to it
      if (currentUser != null) {
        print("Falling back to cached user data");
        emit(UserLoaded(currentUser!, totalDistance: previousDistance));
        return currentUser!;
      }

      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
      }
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  Future<void> updateUserData({XFile? profilePicture}) async {
    emit(UserUpdating());
    try {
      final raw = birthDayController.text;
      String isoDate;
      try {
        final dt = DateFormat('MM/dd/yyyy').parseStrict(raw);
        isoDate = DateTime(dt.year, dt.month, dt.day).toIso8601String();
      } catch (_) {
        isoDate = raw;
      }
      currentUser = await userRepo.updateUserData(
          user: currentUser!,
          username: userNameController.text,
          email: emailController.text,
          height: int.parse(heightController.text),
          weight: int.parse(weightController.text),
          gender: genderController.text,
          birthDate: isoDate,
          profilePicture: profilePicture);

      currentUser!.username = userNameController.text;
      currentUser!.email = emailController.text;
      currentUser!.weight = int.tryParse(weightController.text);
      currentUser!.height = int.tryParse(heightController.text);
      currentUser!.birthDate = birthDayController.text;
      currentUser!.gender = genderController.text;
      emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
      emit(UserUpdated(currentUser!));

      _updateGetItRegistrations(currentUser!);
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
          emit(UserUpdated(currentUser!));
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

      // Check if all non-custom (running) quests are completed for streak completion
      bool allRunningQuestsCompleted = quests.isNotEmpty &&
          quests.every((quest) => quest.isCompleted == true);

      if (allRunningQuestsCompleted) {
        currentUser = await userRepo.getUserData();
      }

      // Always emit as loaded with the preserved distance.
      emit(UserLoaded(currentUser!, totalDistance: _currentDistance));

      _updateGetItRegistrations(currentUser!);

      if (allRunningQuestsCompleted) {
        // Send reset command to the background service.
        await FlutterForegroundTask.stopService();
        // Optionally, update the local state to reflect that totalDistance is now reset.
        emit(UserLoaded(currentUser!, totalDistance: 0.0));
        FlutterForegroundTask.saveData(key: 'totalDistance', value: 0.0);
      }
    } catch (error) {
      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
        }
      }
    }
  }

  Future<void> editQuest(Quests quest, String questName,
      int questDifficultyLevel, String questType) async {
    emit(UserUpdating());
    try {
      final rewards = QuestRewardData.questRewards(questDifficultyLevel);

      await userRepo.editQuest(
          quest.sId, questName, rewards.xp, rewards.gold, questType);

      if (currentUser != null && currentUser!.quests != null) {
        final questIndex =
            currentUser!.quests!.indexWhere((q) => q.sId == quest.sId);
        if (questIndex != -1) {
          currentUser!.quests![questIndex].name = questName;
          currentUser!.quests![questIndex].type = questType;
          currentUser!.quests![questIndex].xpReward = rewards.xp;
          currentUser!.quests![questIndex].goldReward = rewards.gold;
        }
      }

      emit(UserUpdated(currentUser!));

      _updateGetItRegistrations(currentUser!);
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserUpdated(currentUser!));
        }
      }
    }
  }

  Future<void> deleteQuest(Quests? q) async {
    try {
      await userRepo.deleteQuest(q?.sId);

      if (currentUser != null && currentUser!.quests != null) {
        currentUser!.quests =
            currentUser!.quests!.where((quest) => quest.sId != q?.sId).toList();
      }

      emit(UserLoaded(currentUser!));

      _updateGetItRegistrations(currentUser!);
    } catch (error) {
      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
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
      final rewards = QuestRewardData.questRewards(questDifficultyLevel);

      await userRepo.addCustomQuest(
          questName, rewards.xp, rewards.gold, questType);

      currentUser = await userRepo.getUserData();

      // Emit loaded state with preserved distance
      emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
      emit(UserUpdated(currentUser!));

      _updateGetItRegistrations(currentUser!);
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        if (currentUser != null) {
          emit(UserLoaded(currentUser!, totalDistance: _currentDistance));
          emit(UserUpdated(currentUser!));
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

      if (questsToComplete != null && questsToComplete.isNotEmpty) {
        // If we have quests to complete, fetch fresh data first to avoid
        // completing quests that might have been completed in another session
        try {
          print("Fetching fresh data before completing quests");
          await fetchUserData(forceRefresh: true);

          // Re-evaluate quests with fresh data while preserving distance
          if (state is UserLoaded) {
            final updatedState = state as UserLoaded;
            updateDistance(distance); // Restore our tracking distance

            final updatedQuestsToComplete = updatedState.user.quests?.where(
                (quest) =>
                    quest.isCompleted != true &&
                    quest.goal != null &&
                    distance >= quest.goal!);

            if (updatedQuestsToComplete != null) {
              for (var quest in updatedQuestsToComplete) {
                await completeQuest(quest);
              }
            }
          }
        } catch (e) {
          print("Error refreshing data before completing quests: $e");
          // Fall back to completing quests with current data
          for (var quest in questsToComplete) {
            await completeQuest(quest);
          }
        }
      }
    }
  }

  Future<void> deleteAccount() async {
    emit(UserDeleting());
    try {
      await userRepo.deleteAccount(currentUser!);

      currentUser = null;
      await clear();
      clearTokens();
      emit(UserInitial());

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }

      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> logout() async {
    emit(UserDeleting());
    try {
      currentUser = null;
      await clear();
      clearTokens();

      // Reset the fetching flag
      _isFetching = false;

      emit(UserInitial()); // Reset to initial state instead of UserDeleted

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }

      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
    } catch (error) {
      emit(UpdateError(ServerFailure(error.toString())));
    }
  }

  void _updateGetItRegistrations(UserModel user) {
    if (getIt.isRegistered<UserModel>()) {
      getIt.unregister<UserModel>();
    }
    getIt.registerSingleton<UserModel>(user);

    if (getIt.isRegistered<ShopBloc>()) {
      getIt.unregister<ShopBloc>();
    }
    getIt.registerSingleton<ShopBloc>(ShopBloc(user: user));
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
