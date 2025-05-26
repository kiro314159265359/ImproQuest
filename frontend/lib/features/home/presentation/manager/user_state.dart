import '../../../../core/error/failure.dart';
import '../../data/model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {
  final UserModel user = UserModel(
    username: "John Doe",
    email: " hi@gmail.com",
    xp: 120,
    level: 10,
    gold: 1000,
    streak: Streak(current: 1, highestStreak: 5),
    quests: [
      Quests(
        isCompleted: false,
        goal: 1,
        goldReward: 50,
        xpReward: 100,
        name: "Quest 1",
        progress: 0,
        isCustom: false,
      ),
      Quests(
        isCompleted: false,
        goal: 1,
        goldReward: 50,
        xpReward: 100,
        name: "Quest 1",
        progress: 0,
        isCustom: true,
      ),
      Quests(
        isCompleted: false,
        goal: 1,
        goldReward: 50,
        xpReward: 100,
        name: "Quest 1",
        progress: 0,
        isCustom: true,
      ),
      Quests(
        isCompleted: false,
        goal: 1,
        goldReward: 50,
        xpReward: 100,
        name: "Quest 1",
        progress: 0,
        isCustom: true,
      ),
      Quests(
        isCompleted: true,
        goal: 1,
        goldReward: 50,
        xpReward: 100,
        name: "Quest 1",
        progress: 0,
        isCustom: true,
      )
    ],
  );

  UserLoading();
}

class UserLoaded extends UserState {
  final UserModel user;
  double totalDistance;

  UserLoaded(this.user, {this.totalDistance = 0.0});
}

class UserError extends UserState {
  Failure failure;
  UserError(this.failure);
}

class UserDeleting extends UserState {}

class UserDeleted extends UserState {}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {
  final UserModel user;
  UserUpdated(this.user);
}

class UpdateError extends UserState {
  Failure failure;
  UpdateError(this.failure);
}
