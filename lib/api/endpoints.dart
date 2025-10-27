class Endpoints {
  static const String baseUrl = "https://ama-backend-apis.vercel.app/api";
  static const String signup = "$baseUrl/register";
  static const String login = "$baseUrl/login";
  static const String sendOtp = "$baseUrl/otp/send-otp";
  static const String verifyOtp = "$baseUrl/otp/verify-otp";
  static const String uploadProfilePhoto = "$baseUrl/profile/upload-profile";
  static const String updateProfilePhoto = "$baseUrl/profile/update-profile";
  static const String getProfilePhoto = "$baseUrl/profile/get-photo";
  static const String getUserCompleteInfo = "$baseUrl/get-complete-info";
  static const String raiseUserQuery = "$baseUrl/query/raise-query";
  static const String getUserQuery = "$baseUrl/query/get-query";
  static const String getAllQuestions = "$baseUrl/question/get";
  static String getUserQuestions(String userId) =>
      "$baseUrl/question/user/$userId";
  static const String createQuestion = "$baseUrl/question/create";
  static String addAnswer(String questionId) =>
      "$baseUrl/question/add/$questionId/answer";

  static const String addComments = "$baseUrl/question/comment/add";
  static const String getComments = "$baseUrl/question/comment/get";
  static String getCommentsCount(String questionId) =>
      "$baseUrl/question/comment/get/$questionId/count";

  static const String markResolvedQuery = "$baseUrl/query/resolved";

  static const String sendTopicNotifications =
      "$baseUrl/notifications/send-topic-notification";

  static String getNotifications(String role) =>
      "$baseUrl/notifications/get-notification/$role";

  static const String getWeeklyClientsCount = "$baseUrl/clients/week-count";

  static const String sendNotificationToAllAdvocates =
      "$baseUrl/notification/advocate/send";
}
