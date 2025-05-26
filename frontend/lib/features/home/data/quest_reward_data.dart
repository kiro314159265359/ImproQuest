class QuestRewardsModel {
  final int xp;
  final int gold;

  const QuestRewardsModel({required this.xp, required this.gold});
}

class QuestRewardData {
  static QuestRewardsModel questRewards(int questDifficultyLevel) {
    switch (questDifficultyLevel) {
      case 0:
        return const QuestRewardsModel(xp: 10, gold: 10);
      case 1:
        return const QuestRewardsModel(xp: 20, gold: 20);
      case 2:
        return const QuestRewardsModel(xp: 30, gold: 30);
      case 3:
        return const QuestRewardsModel(xp: 40, gold: 40);
      case 4:
        return const QuestRewardsModel(xp: 50, gold: 50);
      case 5:
        return const QuestRewardsModel(xp: 60, gold: 60);
      default:
        return const QuestRewardsModel(xp: 0, gold: 0);
    }
  }

  static double questDifficultyLevel(int xpReward) {
    switch (xpReward) {
      case 10:
        return 0.0;
      case 20:
        return 1.0;
      case 30:
        return 2.0;
      case 40:
        return 3.0;
      case 50:
        return 4.0;
      case 60:
        return 5.0;
      default:
        return 0.0;
    }
  }
}
