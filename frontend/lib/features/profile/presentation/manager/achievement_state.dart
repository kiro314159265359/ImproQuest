import '../../../../../core/error/failure.dart';
import '../../../home/data/model/achievement_model.dart';

abstract class AchievementState {}

final class AchievementInitial extends AchievementState {}

final class AchievementsLoaded extends AchievementState {
  final List<AchievementModel> unlockedAchievementsList;
  final List<AchievementModel> lockedAchievementsList;

  AchievementsLoaded({
    required this.unlockedAchievementsList,
    required this.lockedAchievementsList,
  });
}

final class AchievementLoading extends AchievementState {
  final List<AchievementModel> achievementsList = List.generate(
    10,
    (index) => AchievementModel(
      name: 'Achievement',
      description: 'Description',
    ),
  );

  AchievementLoading();
}

class AchievementError extends AchievementState {
  Failure failure;

  AchievementError(this.failure);
}
