abstract class LoginRepo{
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}