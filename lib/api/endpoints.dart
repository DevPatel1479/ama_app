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
  static String searchQuestions = "$baseUrl/question/search-questions";
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
      "$baseUrl/notifications/get-notification/v2/$role";

  static String lastSeenNotification = "$baseUrl/notifications/last-seen";
  static String markNotificationSeen = "$baseUrl/notifications/mark-seen";

  static String adminLastSeenNotification =
      "$baseUrl/notifications/admin/last-seen";

  static String adminMarkNotification =
      "$baseUrl/notifications/admin/mark-seen";

  static String getNotificationHistory(String userId) =>
      "$baseUrl/notifications/history/$userId";

  static final String getWeeklyClientsCount = "$baseUrl/clients/week-count";

  static String clientRemarks(String phone) =>
      "$baseUrl/clients/remarks?phone=$phone";

  static String checkServiceType(String phone) =>
      "$baseUrl/clients/check-service-type?phone=$phone";

  static final String sendNotificationToAllAdvocates =
      "$baseUrl/notification/advocate/send";

  static final String submitFeedback = "$baseUrl/feedback/submit";
  static final String fileDispute = "$baseUrl/file-dispute";

  static String getLeadByPhone(String? phone) =>
      "$baseUrl/leads/$phone"; // GET /api/leads/:phone
  static final String updateUserData = "$baseUrl/leads/update";

  static final String getTeamMembers = "$baseUrl/team/data";

  static final String deleteQuestion = "$baseUrl/question/delete-question";
  static final String deleteComment =
      "$baseUrl/question/comment/delete-comment";

  static String imagesByType(String type) => "$baseUrl/images/get/$type";

  static String scheduleNotification = "$baseUrl/notifications/schedule";

  static String fetchAmaLeads(
    String name,
    int limit,
    String? cursorId, {
    String? search,
  }) {
    final params = <String, String>{"name": name, "limit": limit.toString()};

    if (cursorId != null) params["cursorId"] = cursorId;
    if (search != null && search.trim().isNotEmpty) params["search"] = search;

    final query = Uri(queryParameters: params).query;
    return "$baseUrl/ama-leads?$query";
  }

  static String fetchAmaLeadsAdmin(
    int limit,
    String? cursorId, {
    String? search,
  }) {
    final params = <String, String>{"role": "admin", "limit": limit.toString()};
    if (search != null && search.trim().isNotEmpty) params["search"] = search;
    if (cursorId != null) {
      params["cursorId"] = cursorId;
    }

    final query = Uri(queryParameters: params).query;
    return "$baseUrl/ama-leads/admin?$query";
  }

  static String fetchBillCutLeads(
    String name,
    int limit,
    String? cursorId, {
    String? search,
  }) {
    final params = <String, String>{"name": name, "limit": limit.toString()};

    if (cursorId != null) params["cursorId"] = cursorId;
    if (search != null && search.trim().isNotEmpty) params["search"] = search;

    final query = Uri(queryParameters: params).query;

    return "$baseUrl/billCut-leads?$query";
  }

  static String fetchBillCutLeadsAdmin(
    int limit,
    String? cursorId, {
    String? search,
  }) {
    final params = <String, String>{"role": "admin", "limit": limit.toString()};
    if (search != null && search.trim().isNotEmpty) params["search"] = search;
    if (cursorId != null) {
      params["cursorId"] = cursorId;
    }

    final query = Uri(queryParameters: params).query;
    return "$baseUrl/billCut-leads/admin?$query";
  }

  static String updateQueryRemarks = "$baseUrl/query/update/remarks";
}
