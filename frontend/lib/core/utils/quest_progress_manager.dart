import 'package:shared_preferences/shared_preferences.dart';

class QuestProgressManager {
  static const String _questProgressPrefix = 'quest_progress_';

  // Save progress for a specific quest
  static Future<void> saveQuestProgress(String questId, double distance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_questProgressPrefix$questId', distance);
  }

  // Get progress for a specific quest
  static Future<double> getQuestProgress(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_questProgressPrefix$questId') ?? 0.0;
  }

  // Update progress for a quest by adding new distance
  static Future<double> updateQuestProgress(
      String questId, double additionalDistance) async {
    final currentProgress = await getQuestProgress(questId);
    final newProgress = currentProgress + additionalDistance;
    await saveQuestProgress(questId, newProgress);
    return newProgress;
  }

  // Get all stored quest progress as a map of questId -> progress
  static Future<Map<String, double>> getAllQuestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, double> progressMap = {};

    for (final key in prefs.getKeys()) {
      if (key.startsWith(_questProgressPrefix)) {
        final questId = key.substring(_questProgressPrefix.length);
        final progress = prefs.getDouble(key);
        if (progress != null) {
          progressMap[questId] = progress;
        }
      }
    }

    return progressMap;
  }

  // Clear progress for a specific quest (implementation was missing)
  static Future<void> clearQuestProgress(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_questProgressPrefix$questId');
  }



  // Reset all quest progress
  static Future<void> resetAllQuestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_questProgressPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
