class DistanceModel {
  String? date;
  String? weekday;
  double? distance;
  int? count;

  DistanceModel({this.date, this.weekday, this.distance, this.count});

  DistanceModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    weekday = json['weekday'];
    distance = json['distance'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['weekday'] = weekday;
    data['distance'] = distance;
    data['count'] = count;
    return data;
  }
}
