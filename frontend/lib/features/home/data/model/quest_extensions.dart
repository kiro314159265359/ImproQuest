import 'user_model.dart';

extension QuestExtensions on Quests {
  // Calculate progress percentage
  double get progressPercent {
    if (goal == null || goal! <= 0) return 0.0;
    return (progress / goal!).clamp(0.0, 1.0);
  }

  // Check if quest should be marked as complete based on progress
  bool get shouldComplete {
    return !isCompleted! &&
        goal != null &&
        progress >= goal!;
  }

  // Format progress for display
  String get progressFormatted {
    return '${progress.toStringAsFixed(1)}/${goal?.toStringAsFixed(1) ?? "?"}m';
  }
}
