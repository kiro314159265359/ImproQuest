class AchievementModel {
  String? sId;
  String? name;
  String? description;
  String? reward;

  AchievementModel({
    this.sId,
    this.name,
    this.description,
    this.reward,
  });

  AchievementModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    reward = json['reward'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['reward'] = reward;
    return data;
  }
}
