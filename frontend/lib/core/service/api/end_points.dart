import '../cache_helper.dart';

class EndPoints {
  static const String baseUrl = "http://10.0.2.2:5000";

  static String token = SharedPref.get(key: "accessToken") ?? "";

  static const String loginToken = "/users/login";

  static const String registerToken = "/users/signup";

  static const String resetPassword = "/reset_password/";

  static const String profileData = "/profile/";
}
