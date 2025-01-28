import '../cache_helper.dart';

class EndPoints {
  static const String baseUrl = "";

  static String token = SharedPref.get(key: "accessToken") ?? "";

  static const String loginToken = "/login/";

  static const String signUpToken = "/registration/";

  static const String resetPassword = "/reset_password/";

  static const String profileData = "/profile/";
}
