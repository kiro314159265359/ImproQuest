import 'package:intl/intl.dart';

class UserModel {
  String? sId;
  String? username;
  String? mobileNumber;
  String? email;
  int? height;
  String? gender;
  String? userType;
  String? birthDate;
  int? weight;
  int? xp;
  int? maxXP;
  int? level;
  int? gold;
  Streak? streak;
  String? inventoryId;
  String? avatarUrl;
  List<Quests>? quests;
  Stats? stats;
  EquippedItems? equippedItems;
  double? accumDistance;
  String? rank;
  int? skillPoints;
  String? createdAt;
  String? updatedAt;

  UserModel(
      {this.sId,
      this.username,
      this.mobileNumber,
      this.email,
      this.height,
      this.gender,
      this.userType,
      this.birthDate,
      this.weight,
      this.xp,
      this.maxXP,
      this.level,
      this.gold,
      this.streak,
      this.inventoryId,
      this.avatarUrl,
      this.quests,
      this.stats,
      this.equippedItems,
      this.accumDistance,
      this.rank,
      this.skillPoints,
      this.createdAt,
      this.updatedAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    mobileNumber = json['mobile_number'];
    email = json['email'];
    height = json['height'];
    gender = json['gender'];
    userType = json['user_type'];
    if (json['birth_date'] != null) {
      try {
        final dateTime = DateTime.parse(json['birth_date']);
        birthDate = DateFormat('MM/dd/yyyy').format(dateTime);
      } catch (e) {
        birthDate = json['birth_date'];
      }
    }
    weight = json['weight'];
    xp = json['xp'];
    maxXP = json['maxXp'];
    level = json['level'];
    gold = json['gold'];
    streak = json['streak'] != null ? Streak.fromJson(json['streak']) : null;
    inventoryId = json['inventory_id'];
    avatarUrl = json['avatar_url'];
    if (json['quests'] != null) {
      quests = <Quests>[];
      json['quests'].forEach((v) {
        quests!.add(Quests.fromJson(v));
      });
    }
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    equippedItems = json['equipped_items'] != null
        ? EquippedItems.fromJson(json['equipped_items'])
        : null;
    if (json['accum_distance'] != null) {
      if (json['accum_distance'] is int) {
        accumDistance = (json['accum_distance'] as int).toDouble();
      } else {
        accumDistance = json['accum_distance'];
      }
    } else {
      accumDistance = null;
    }
    rank = json['rank'];
    skillPoints = json['skill_points'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['username'] = username;
    data['mobile_number'] = mobileNumber;
    data['email'] = email;
    data['height'] = height;
    data['gender'] = gender;
    data['user_type'] = userType;
    data['birth_date'] = birthDate;
    data['weight'] = weight;
    data['xp'] = xp;
    data['level'] = level;
    data['maxXp'] = maxXP;
    data['gold'] = gold;
    if (streak != null) {
      data['streak'] = streak!.toJson();
    }
    data['inventory_id'] = inventoryId;
    data['avatar_url'] = avatarUrl;
    if (quests != null) {
      data['quests'] = quests!.map((v) => v.toJson()).toList();
    }
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    data['accum_distance'] = accumDistance;
    data['rank'] = rank;
    data['skill_points'] = skillPoints;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Streak {
  String? sId;
  int? current;
  int? highestStreak;

  Streak({this.sId, this.current, this.highestStreak});

  Streak.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    current = json['current'];
    highestStreak = json['highest_streak'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['current'] = current;
    data['highest_streak'] = highestStreak;
    return data;
  }
}

class Quests {
  String? sId;
  String? name;
  String? type;
  int? goal;
  double? progress;
  int? xpReward;
  int? goldReward;
  bool? isCompleted;
  bool? isCustom;

  Quests(
      {this.sId,
      this.name,
      this.type,
      this.goal,
      this.progress,
      this.xpReward,
      this.goldReward,
      this.isCustom,
      this.isCompleted});

  Quests.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    type = json['type'];
    goal = json['goal'];
    progress = json['progress'];
    xpReward = json['xp_reward'];
    goldReward = json['gold_reward'];
    isCompleted = json['is_completed'];
    isCustom = json['is_custom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['type'] = type;
    data['goal'] = goal;
    data['progress'] = progress;
    data['xp_reward'] = xpReward;
    data['gold_reward'] = goldReward;
    data['is_completed'] = isCompleted;
    data['is_custom'] = isCustom;
    return data;
  }
}

class Stats {
  int? vitality;
  int? strength;
  int? endurance;
  int? agility;

  Stats({this.vitality, this.strength, this.endurance, this.agility});

  Stats.fromJson(Map<String, dynamic> json) {
    vitality = json['vitality'];
    strength = json['strength'];
    endurance = json['endurance'];
    agility = json['agility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vitality'] = vitality;
    data['strength'] = strength;
    data['endurance'] = endurance;
    data['agility'] = agility;
    return data;
  }
}

class EquippedItems {
  String? boots;
  String? helmet;
  String? gloves;
  String? armor;
  String? weapon;

  EquippedItems({
    this.boots,
    this.helmet,
    this.gloves,
    this.armor,
    this.weapon,
  });

  EquippedItems.fromJson(Map<String, dynamic> json) {
    boots = json['boots'];
    helmet = json['helmet'];
    gloves = json['gloves'];
    armor = json['armor'];
    weapon = json['weapon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boots'] = boots;
    data['helmet'] = helmet;
    data['gloves'] = gloves;
    data['armor'] = armor;
    data['weapon'] = weapon;
    return data;
  }
}
