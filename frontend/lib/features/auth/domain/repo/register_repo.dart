abstract class RegisterRepo {
  Future<void> register(String email, String password, String username,
      int height, int weight, String gender, String birthday);
}
