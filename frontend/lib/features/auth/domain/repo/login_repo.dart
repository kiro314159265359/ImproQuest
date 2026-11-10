abstract class LoginRepo {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<void> forgetPassword(String email);
  Future<Map<String, dynamic>> verifyOTP(String email, String otp);
  Future<void> resetPassword(String newPassword, String resetToken);
}
