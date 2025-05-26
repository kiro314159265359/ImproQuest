import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../home/domain/repo/user_repo.dart';
import '../../../home/presentation/manager/user_cubit.dart';
import 'character_state.dart';

class CharacterCubit extends Cubit<CharacterState> {
  final UserRepo userRepo;
  final UserCubit userCubit;

  CharacterCubit({required this.userRepo, required this.userCubit})
      : super(CharacterInitial());

  Future<void> getUserItems(String? slot) async {
    emit(InventoryLoading());
    try {
      final invModel = await userRepo.getUserItems();
      final itemsList =
          invModel.items?.where((inv) => inv.slot == slot).toList() ?? [];
      emit(InventoryLoaded(itemsList));
    } catch (error) {
      if (error is DioException) {
        emit(InventoryError(ServerFailure.fromDioError(error)));
      } else {
        emit(InventoryError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> equipItem(String? itemId, String? slot) async {
    emit(InventoryUpdating());
    try {
      await userRepo.equipItem(itemId, slot);
      await userCubit.fetchUserData(forceRefresh: true);
      emit(InventorySuccess());
    } catch (error) {
      if (error is DioException) {
        emit(InventoryError(ServerFailure.fromDioError(error)));
      } else {
        emit(InventoryError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> unequipItem(String? itemId, String? slot) async {
    emit(InventoryUpdating());
    try {
      await userRepo.unequipItem(itemId, slot);
      await userCubit.fetchUserData(forceRefresh: true);
      emit(InventorySuccess());
    } catch (error) {
      if (error is DioException) {
        emit(InventoryError(ServerFailure.fromDioError(error)));
      } else {
        emit(InventoryError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> skillPoints(String? stats, int? points) async {
    emit(SkillPointUpdating());
    try {
      await userRepo.skillPoints(stats, points);
      await userCubit.fetchUserData(forceRefresh: true);
      emit(SkillPointSuccess());
    } catch (error) {
      if (error is DioException) {
        emit(SkillPointError(ServerFailure.fromDioError(error)));
      } else {
        emit(SkillPointError(ServerFailure(error.toString())));
      }
    }
  }
}
