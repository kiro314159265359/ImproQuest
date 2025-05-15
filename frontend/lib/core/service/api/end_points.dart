class EndPoints {
  // static const String baseUrl = "http://192.168.1.3:5000"; //  Asaad's IP
  // static const String baseUrl = "http://192.168.1.5:5000"; // Hanna's IP
  static const String baseUrl = "http://10.0.2.2:5000"; // emu IP
  // static const String baseUrl = "https://api.improquest.mavoid.com"; // EC2 IP

  static const String login = "/users/login";

  static const String register = "/users/signup";

  static const String refreshToken = "/users/refresh";

  static const String userData = "/users/mydata";

  static const String quests = "/users/quests";

  static const String customQuest = "/users/customQuest";

  static const String streak = "/quests/streak";

  static const String questProgress = "/users/updateQuestProgress";

  static const String leaderboardByStreak = "/leaderboard/streak";
  static const String leaderboardByLevel = "/leaderboard/level";

  static const String userItems = "/users/inventory/items";
  static const String equipItems = "/users/equip";
  static const String unequipItems = "/users/unequip";

  // Shop endpoints
  static const String permanentShop = "/shop/permanent";
  static const String purchaseItem = "/shop/buy";
  static const String temporaryShop = "/shop/consumables";

  static const String forgetPassword = "/users/forgot-password";
  static const String verifyOTP = "/users/verify-otp";
  static const String resetPassword = "/users/reset-password";

  //
  // static const String profileData = "/profile/";
}
