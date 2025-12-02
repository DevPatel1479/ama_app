import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  static final String baseUrl = dotenv.env["API_BASE_URL"]!;

  static final String signup = "$baseUrl/register";
  static final String login = "$baseUrl/login";
  static final String sendOtp = "$baseUrl/otp/send-otp";
  static final String verifyOtp = "$baseUrl/otp/verify-otp";
  static final String uploadProfilePhoto = "$baseUrl/profile/upload-profile";
  static final String updateProfilePhoto = "$baseUrl/profile/update-profile";
  static final String getProfilePhoto = "$baseUrl/profile/get-photo";
  static final String getUserCompleteInfo = "$baseUrl/get-complete-info";
  static final String raiseUserQuery = "$baseUrl/query/raise-query";
  static final String getUserQuery = "$baseUrl/query/get-query";
  static final String getAllQuestions = "$baseUrl/question/get";
  static String getUserQuestions(String userId) =>
      "$baseUrl/question/user/$userId";
  static final String createQuestion = "$baseUrl/question/create";
  static String addAnswer(String questionId) =>
      "$baseUrl/question/add/$questionId/answer";

  static final String addComments = "$baseUrl/question/comment/add";
  static final String getComments = "$baseUrl/question/comment/get";
  static String getCommentsCount(String questionId) =>
      "$baseUrl/question/comment/get/$questionId/count";

  static final String markResolvedQuery = "$baseUrl/query/resolved";

  static final String sendTopicNotifications =
      "$baseUrl/notifications/send-topic-notification";

  static String getNotifications(String role) =>
      "$baseUrl/notifications/get-notification/$role";

  static String getNotificationHistory(String userId) =>
      "$baseUrl/notifications/history/$userId";

  static final String getWeeklyClientsCount = "$baseUrl/clients/week-count";

  static final String sendNotificationToAllAdvocates =
      "$baseUrl/notification/advocate/send";



  static final String submitFeedback = "$baseUrl/feedback/submit";
  static final String fileDispute = "$baseUrl/file-dispute";

  static String getLeadByPhone(String? phone) =>
      "$baseUrl/leads/$phone"; // GET /api/leads/:phone
  static final String updateUserData = "$baseUrl/leads/update";
}
