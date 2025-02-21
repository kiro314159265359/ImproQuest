import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../../game/logic/shop_bloc.dart';
import '../../data/model/user_model.dart';
import '../../domain/repo/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;
  UserModel? currentUser;

  UserCubit(this.userRepo) : super(UserInitial());

  Future<UserModel> fetchUserData() async {
    emit(UserLoading());
    try {
      final currentUser = await userRepo.getUserData();
      emit(UserLoaded(currentUser));

      // Update GetIt with the new UserModel.
      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser);

      // Register or update the ShopBloc with the fetched user.
      if (getIt.isRegistered<ShopBloc>()) {
        getIt.unregister<ShopBloc>();
      }
      getIt.registerSingleton<ShopBloc>(ShopBloc(user: currentUser));

      return currentUser;
    } catch (error) {
      if (error is DioException) {
        emit(UserError(ServerFailure.fromDioError(error)));
      } else {
        emit(UserError(ServerFailure(error.toString())));
      }
      rethrow;
    }
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    emit(UserUpdating());
    try {
      final currentUser = await userRepo.updateUserData(updatedUser);

      if (getIt.isRegistered<UserModel>()) {
        getIt.unregister<UserModel>();
      }
      getIt.registerSingleton<UserModel>(currentUser);

      emit(UserUpdated(currentUser));
    } catch (error) {
      if (error is DioException) {
        emit(UpdateError(ServerFailure.fromDioError(error)));
      } else {
        emit(UpdateError(ServerFailure(error.toString())));
        emit(UserLoaded(currentUser!));
      }
    }
  }
}
