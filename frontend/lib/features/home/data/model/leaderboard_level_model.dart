class LeaderboardLevelListModel {
  List<LeaderboardLevelModel>? leaderboardList;
  String? rank;
  String? type;

  LeaderboardLevelListModel({this.leaderboardList, this.rank, this.type});

  LeaderboardLevelListModel.fromJson(Map<String, dynamic> json) {
    if (json['leaderboard'] != null) {
      leaderboardList = <LeaderboardLevelModel>[];
      json['leaderboard'].forEach((v) {
        leaderboardList!.add(LeaderboardLevelModel.fromJson(v));
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

class LeaderboardLevelModel {
  String? sId;
  int? level;
  String? rank;
  String? username;
  int? xp;

  LeaderboardLevelModel(
      {this.sId, this.level, this.rank, this.username, this.xp});

  LeaderboardLevelModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    level = json['level'];
    rank = json['rank'];
    username = json['username'];
    xp = json['xp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['level'] = level;
    data['rank'] = rank;
    data['username'] = username;
    data['xp'] = xp;
    return data;
  }
}
