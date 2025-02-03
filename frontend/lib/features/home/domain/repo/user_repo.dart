import '../../data/model/user_model.dart';

abstract class UserRepo {
  Future<UserModel> getUserData();
}
