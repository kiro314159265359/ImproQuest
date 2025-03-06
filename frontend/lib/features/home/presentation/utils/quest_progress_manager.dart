import '../../../../core/sensors/tracking_utils.dart';
import '../../../home/data/model/user_model.dart';

class QuestProgressManager {
  // Update quest progress based on distance
  static Future<List<Quests>> updateQuestsProgress(List<Quests>? quests) async {
    if (quests == null || quests.isEmpty) {
      return [];
    }

    final savedDistance = await TrackingUtils.getTotalDistance();
    final updatedQuests = <Quests>[];

    for (final quest in quests) {
      // Skip already completed quests
      if (quest.isCompleted == true) {
        updatedQuests.add(quest);
        continue;
      }

      // Calculate progress for distance-based quests
      if (quest.name?.toLowerCase().contains('distance') == true ||
          quest.name?.toLowerCase().contains('walk') == true ||
          quest.name?.toLowerCase().contains('run') == true) {
        // Calculate progress as a percentage of the goal
        final goal = quest.goal ?? 1000; // Default to 1000 if no goal set
        final progress = (savedDistance / goal).clamp(0.0, 1.0);

        // Save progress to SharedPreferences
        await TrackingUtils.updateQuestProgress(quest.sId ?? '', progress);

        // If quest is completed by distance, we'll mark it visually
        // The actual completion will happen when the user clicks the complete button
        if (progress >= 1.0) {
          final updatedQuest = Quests(
            sId: quest.sId,
            name: quest.name,
            goal: quest.goal,
            xpReward: quest.xpReward,
            goldReward: quest.goldReward,
            difficulty: quest.difficulty,
            isCompleted:
                false, // Still false officially until user completes it
          );
          updatedQuests.add(updatedQuest);
        } else {
          updatedQuests.add(quest);
        }
      } else {
        // Non-distance quests remain unchanged
        updatedQuests.add(quest);
      }
    }

    return updatedQuests;
  }

  // Get progress for a specific quest
  static Future<double> getQuestProgress(String questId) async {
    return await TrackingUtils.getQuestProgress(questId);
  }

  // Calculate visual progress for quest display
  static Future<double> calculateVisualProgress(Quests quest) async {
    if (quest.isCompleted == true) {
      return 1.0;
    }

    if (quest.name?.toLowerCase().contains('distance') == true ||
        quest.name?.toLowerCase().contains('walk') == true ||
        quest.name?.toLowerCase().contains('run') == true) {
      final savedProgress =
          await TrackingUtils.getQuestProgress(quest.sId ?? '');
      if (savedProgress > 0) {
        return savedProgress;
      }

      final savedDistance = await TrackingUtils.getTotalDistance();
      final goal = quest.goal ?? 1000;
      return (savedDistance / goal).clamp(0.0, 1.0);
    }

    return 0.0; // Default progress for non-distance quests
  }
}
