import '../../../../../core/error/failure.dart';
import '../../../home/data/model/distance_model.dart';

abstract class DistanceState {}

final class DistanceInitial extends DistanceState {}

final class DistanceLoaded extends DistanceState {
  List<DistanceModel> distanceList;

  DistanceLoaded(this.distanceList);
}

final class DistanceTodayLoaded extends DistanceState {
  double? distanceToday;

  DistanceTodayLoaded(this.distanceToday);
}

final class DistanceLoading extends DistanceState {}

class DistanceError extends DistanceState {
  Failure failure;

  DistanceError(this.failure);
}
