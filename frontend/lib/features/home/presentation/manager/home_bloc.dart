import 'dart:async';
import 'dart:convert';
import 'package:flutter_application_2/features/home/presentation/manager/home_event.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/services/distance_tracking_service.dart';
import 'user_cubit.dart';
import 'user_state.dart';

// BLoC
class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final UserCubit userCubit;
  final DistanceTrackingService distanceService;
  late StreamSubscription<UserState> _userStateSub;
  bool _distanceSent = false;
  double _lastDistanceSent = 0.0;
  WebSocketChannel? channel;

  HomeBloc({
    required this.userCubit,
    required this.distanceService,
  }) : super(HomeInitial()) {
    on<HomeInitialized>(_onHomeInitialized);
    on<DistanceDataReceived>(_onDistanceDataReceived);
    on<CheckServiceDistance>(_onCheckServiceDistance);
    on<CompleteCustomQuest>(_onCompleteCustomQuest);

    // Set up service data callback
    distanceService.onDataReceived = _handleServiceData;

    // Listen to user state changes
    _userStateSub = userCubit.stream.listen(_onUserStateChanged);
  }

  void _handleServiceData(Map<String, dynamic> data) {
    final totalDistance = data['totalDistance'] ?? 0.0;
    add(DistanceDataReceived(totalDistance));
  }

  void _onUserStateChanged(UserState state) async {
    if (state is UserLoaded && !_distanceSent) {
      _distanceSent = true;
      distanceService.sendDistanceToService(state.totalDistance);
      await distanceService.startServiceIfNeeded(state);
    }
  }

  Future<void> _onHomeInitialized(
      HomeInitialized event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      // Always trigger user data fetch to ensure fresh data
      print("HomeBloc: Fetching fresh user data");
      await userCubit.fetchUserData(forceRefresh: true);

      // Check the service distance
      add(CheckServiceDistance());

      // Setup WebSocket connection
      channel = WebSocketChannel.connect(
        Uri.parse(
            'ws://api.improquest.mavoid.com/ws/runs?userId=${userCubit.currentUser?.sId}'),
      );
      print("Connected with sockets to $channel");

      // Ensure the service is running if needed
      final userState = userCubit.state;
      if (userState is UserLoaded) {
        await distanceService.startServiceIfNeeded(userState);

        // Send current distance to service
        if (!_distanceSent) {
          _distanceSent = true;
          distanceService.sendDistanceToService(userState.totalDistance);
          print("HomeBloc sent initial distance: ${userState.totalDistance}");
        }
      }

      emit(const HomeReady());
    } catch (e) {
      print("Error initializing home: $e");
      // Even on error, emit HomeReady to avoid infinite loading
      emit(const HomeReady());
    }
  }

  Future<void> _onDistanceDataReceived(
      DistanceDataReceived event, Emitter<HomeState> emit) async {
    print("HomeBloc received distance update: ${event.distance}");

    try {
      final newTotal = event.distance;
      final delta = newTotal - _lastDistanceSent;
      print(_lastDistanceSent);
      if (delta <= 0) {
        print("No additional distance to send (delta: $delta)");
        return;
      }

      final now = DateTime.now().toUtc();
      final payload = {
        'distance': delta,
        'timestamp': '${now.toIso8601String().split('.').first}Z'
      };
      print(payload);
      final msg = 'SendRun, ${jsonEncode(payload)}';
      channel?.sink.add(msg);
      _lastDistanceSent = newTotal;

      await userCubit.updateDistanceAndCheckQuests(event.distance);
      print("Updated user cubit with new distance: ${event.distance}");
    } catch (e) {
      print("Error updating distance in user cubit: $e");
    }
  }

  Future<void> _onCheckServiceDistance(
      CheckServiceDistance event, Emitter<HomeState> emit) async {
    print("Checking service distance...");

    try {
      final serviceDistance = await distanceService.getDistanceFromService();
      print("Retrieved service distance: $serviceDistance");

      if (serviceDistance > 0) {
        final currentState = userCubit.state;
        final hydratedDistance =
            currentState is UserLoaded ? currentState.totalDistance : 0.0;

        print(
            "Comparing distances - Service: $serviceDistance, Hydrated: $hydratedDistance");

        if (serviceDistance > hydratedDistance) {
          print("Using service distance as it's greater");
          userCubit.updateDistanceAndCheckQuests(serviceDistance);
          _distanceSent = true;
        } else if (hydratedDistance > 0) {
          print("Using hydrated distance as it's greater");
          distanceService.sendDistanceToService(hydratedDistance);
          _distanceSent = true;
        }
      } else {
        print("No distance found in service");

        // If we have a distance but service doesn't, send it
        final currentState = userCubit.state;
        if (currentState is UserLoaded && currentState.totalDistance > 0) {
          print("Sending hydrated distance to service");
          distanceService.sendDistanceToService(currentState.totalDistance);
          _distanceSent = true;
        }
      }
    } catch (e) {
      print("Error checking service distance: $e");
    }
  }

  Future<void> _onCompleteCustomQuest(
      CompleteCustomQuest event, Emitter<HomeState> emit) async {
    if (state is HomeReady) {
      final currentState = state as HomeReady;
      final newLoadingStates =
          Map<String, bool>.from(currentState.questLoadingStates);
      newLoadingStates[event.questId] = true;
      emit(currentState.copyWith(questLoadingStates: newLoadingStates));

      try {
        final quest = userCubit.customQuests.firstWhere(
          (q) => q.sId == event.questId,
          orElse: () => throw Exception("Quest not found"),
        );

        // Complete the quest and await the result
        await userCubit.completeQuest(quest);

        // Ensure we're still emitting a HomeReady state even if there was an error
        newLoadingStates[event.questId] = false;
        emit(currentState.copyWith(questLoadingStates: newLoadingStates));
      } catch (e) {
        print("Error completing quest: $e");
        // Always update loading state to false
        newLoadingStates[event.questId] = false;
        emit(currentState.copyWith(questLoadingStates: newLoadingStates));
      }
    }
  }

  @override
  Future<void> close() {
    _userStateSub.cancel();
    distanceService.onDataReceived = null;
    return super.close();
  }

  // HydratedBloc implementation
  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('type')) {
        if (json['type'] == 'initial') {
          return HomeInitial();
        } else if (json['type'] == 'loading') {
          return HomeLoading();
        } else if (json['type'] == 'ready') {
          final questLoadingStates = Map<String, bool>.from(
            json['questLoadingStates'] ?? {},
          );
          return HomeReady(questLoadingStates: questLoadingStates);
        }
      }
    } catch (e) {
      print("Error deserializing HomeState: $e");
    }
    return HomeInitial();
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    try {
      if (state is HomeInitial) {
        return {'type': 'initial'};
      } else if (state is HomeLoading) {
        return {'type': 'loading'};
      } else if (state is HomeReady) {
        return {
          'type': 'ready',
          'questLoadingStates': state.questLoadingStates,
        };
      }
    } catch (e) {
      print("Error serializing HomeState: $e");
    }
    return null;
  }
}
