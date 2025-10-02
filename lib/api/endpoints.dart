class Endpoints {
  static const String baseUrl = "https://ama-backend-apis.vercel.app/api";
  static const String signup = "$baseUrl/register";
  static const String login = "$baseUrl/login";
  static const String sendOtp = "$baseUrl/otp/send-otp";
  static const String verifyOtp = "$baseUrl/otp/verify-otp";
  static const String uploadProfilePhoto = "$baseUrl/profile/upload-profile";
  static const String updateProfilePhoto = "$baseUrl/profile/update-profile";
  static const String getProfilePhoto = "$baseUrl/profile/get-photo";
}
