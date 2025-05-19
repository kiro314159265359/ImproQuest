class LeaderboardStreakListModel {
  List<LeaderboardStreakModel>? leaderboardList;
  String? rank;
  String? type;

  LeaderboardStreakListModel({this.leaderboardList, this.rank, this.type});

  LeaderboardStreakListModel.fromJson(Map<String, dynamic> json) {
    if (json['leaderboard'] != null) {
      leaderboardList = <LeaderboardStreakModel>[];
      json['leaderboard'].forEach((v) {
        leaderboardList!.add(LeaderboardStreakModel.fromJson(v));
      });
    }
    rank = json['rank'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (leaderboardList != null) {
      data['leaderboard'] = leaderboardList!.map((v) => v.toJson()).toList();
    }
    data['rank'] = rank;
    data['type'] = type;
    return data;
  }
}

class LeaderboardStreakModel {
  String? sId;
  String? avatarUrl;
  int? currentStreak;
  int? highestStreak;
  String? rank;
  String? username;

  LeaderboardStreakModel(
      {this.sId,
      this.avatarUrl,
      this.currentStreak,
      this.highestStreak,
      this.rank,
      this.username});

  LeaderboardStreakModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    avatarUrl = json['avatar_url'];
    currentStreak = json['current_streak'];
    highestStreak = json['highest_streak'];
    rank = json['rank'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['avatar_url'] = avatarUrl;
    data['current_streak'] = currentStreak;
    data['highest_streak'] = highestStreak;
    data['rank'] = rank;
    data['username'] = username;
    return data;
  }
}
