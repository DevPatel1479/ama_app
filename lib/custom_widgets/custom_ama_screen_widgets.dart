import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/provider/ama/comment_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget buildDoubtItem({
  required String mode,
  required BuildContext context,
  required double screenWidth,
  required double screenHeight,
  required String userName,
  required String askedTime,
  required String fromTag,
  required String description,
  String? profileUrl,
}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      color: const Color(0xFF252525),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row with user info and "From User" badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.asset(
            //   AppAssets.userIcon,
            //   width: screenWidth * 0.10,
            //   height: screenWidth * 0.10,
            // ),
            CircleAvatar(
              radius: screenWidth * 0.06,
              backgroundColor: Colors.grey[800],
              backgroundImage: (profileUrl != null && profileUrl!.isNotEmpty)
                  ? NetworkImage(
                      "${profileUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                    )
                  : AssetImage(AppAssets.userIcon) as ImageProvider,
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    askedTime,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: screenHeight * 0.025,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.003,
                horizontal: screenWidth * 0.04,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 70, 70, 70),
                border: fromTag == "From User"
                    ? Border.all(color: const Color(0xFF8383F6), width: 1)
                    : Border.all(color: const Color(0xFF04C527), width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                fromTag,
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w400,
                  color: fromTag == "From User"
                      ? const Color(0xFF8383F6)
                      : const Color(0xFF04C527),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        // Description text
        Text(
          description,
          style: GoogleFonts.outfit(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        // Like and Answer row
        // Row(
        //   children: [
        //     Image.asset(
        //       AppAssets.likeHeartIcon,
        //       width: screenWidth * 0.04,
        //       height: screenWidth * 0.04,
        //     ),
        //     SizedBox(width: screenWidth * 0.02),
        //     Text(
        //       "Like",
        //       style: GoogleFonts.outfit(
        //         fontSize: screenWidth * 0.025,
        //         fontWeight: FontWeight.w400,
        //         color: Colors.white,
        //       ),
        //     ),
        //     SizedBox(width: screenWidth * 0.05),
        //     Image.asset(
        //       AppAssets.answerIcon,
        //       width: screenWidth * 0.04,
        //       height: screenWidth * 0.04,
        //     ),
        //     SizedBox(width: screenWidth * 0.02),
        //     Text(
        //       "Answer",
        //       style: GoogleFonts.outfit(
        //         fontSize: screenWidth * 0.025,
        //         fontWeight: FontWeight.w400,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    ),
  );
}

String formatTimestamp(int timestamp) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  return DateFormat("MMM d, yyyy • h:mm a").format(dateTime);
}

void _showAddCommentDialog(
  BuildContext context,
  CommentProvider provider,
  String mode,
  String questionId,
  String? userName,
  String? userRole,
  String? userPhone,
  String? profileImgUrl,
) {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: mode == "light"
                ? Colors.white
                : const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Add Comment",
              style: TextStyle(
                color: mode == "light" ? const Color(0xFF1E1E1E) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: TextField(
                textInputAction: TextInputAction.done,
                controller: _controller,
                maxLines: 4,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  hintText: "Write your comment...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () async {
                        if (_controller.text.trim().isEmpty) {
                          showCustomMessage(
                            context,
                            "Please enter comment",
                            true,
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        await provider.postComment(
                          context: context,
                          questionId: questionId,
                          content: _controller.text.trim(),
                          commentedBy:
                              userName ?? "", // TODO: Replace with actual user
                          userRole: userRole ?? "",
                          phone: userPhone ?? "",
                          profileImgUrl: profileImgUrl ?? "",
                        );

                        setState(() => isLoading = false);

                        // Only pop if comment was posted successfully
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.pop(context);
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Send",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

String _formatTimestamp(int? timestampMs) {
  if (timestampMs == null) return '';
  try {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  } catch (_) {
    return '';
  }
}

void showAskDoubtBottomSheet(
  BuildContext context,
  CommentProvider provider,
  String mode,
  String questionId,
  String? userName,
  String? userRole,
  String? userPhone,

  String? profileImgUrl,
  dynamic question,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  provider.clearExistingComments();
  provider.fetchComments(questionId, reset: true); // Initial fetch
  String createdAtTime = _formatTimestamp(question.timestamp as int?);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: screenHeight * 0.95,
        decoration: BoxDecoration(
          color: mode == "dark" ? const Color(0xFF252525) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      AppAssets.backArrowIcon,
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      color: mode == "light"
                          ? const Color(0xFF252525)
                          : Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Comments",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: mode == "light"
                              ? const Color(0xFF252525)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_comment,
                      color: mode == "light"
                          ? const Color(0xFF252525)
                          : Colors.white,
                    ),
                    onPressed: () {
                      if (userRole?.toLowerCase() == "guest") {
                        final isDark = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).isDarkMode;
                        showDialog(
                          context: context,
                          builder: (_) => LoginRequiredDialog(
                            isDarkTheme: isDark,

                            onLoginPressed: () {
                              Navigator.pop(context);
                              context.goNamed(AppScreenNames.logIn);
                              // context.pushNamed(AppScreenNames.l);
                            },
                          ),
                        );
                        return;
                      }
                      _showAddCommentDialog(
                        context,
                        provider,
                        mode,
                        questionId,
                        userName,
                        userRole,
                        userPhone,
                        profileImgUrl,
                      );
                    },
                  ),
                  SizedBox(width: screenWidth * 0.05),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(210, 159, 42, 0.65),
                    Color.fromRGBO(255, 255, 255, 0.65),
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2319),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              (question.profileImgUrl != null &&
                                  (question.profileImgUrl as String).isNotEmpty)
                              ? NetworkImage(
                                  "${question.profileImgUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                )
                              : AssetImage(AppAssets.userIcon) as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.userName ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${createdAtTime}",
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.content ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (question.answer != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                AppAssets.appIcon,
                                width: 40,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x33FFFFFF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "from ${question.answer!.role ?? ''}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFD29F2A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            question.answer!.content ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFFD29F2A),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comments body
            Expanded(
              child: Consumer<CommentProvider>(
                builder: (context, commentProvider, _) {
                  if (commentProvider.isLoading &&
                      commentProvider.comments.isEmpty) {
                    // Show loading indicator while fetching first batch
                    return Center(
                      child: CircularProgressIndicator(
                        color: mode == "light"
                            ? const Color(0xFF252525)
                            : Colors.white,
                      ),
                    );
                  }

                  if (commentProvider.comments.isEmpty) {
                    return Center(
                      child: Text(
                        "No comments yet",
                        style: TextStyle(
                          color: mode == "light"
                              ? const Color(0xFF252525)
                              : Colors.white,
                        ),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.pixels >=
                              scrollNotification.metrics.maxScrollExtent -
                                  100 &&
                          !commentProvider.isLoading &&
                          commentProvider.hasMore) {
                        // Fetch next page for lazy loading
                        commentProvider.fetchComments(questionId);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      itemCount: commentProvider.hasMore
                          ? commentProvider.comments.length + 1
                          : commentProvider.comments.length,
                      itemBuilder: (context, index) {
                        if (index == commentProvider.comments.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: mode == "light"
                                    ? const Color(0xFF252525)
                                    : Colors.white,
                              ),
                            ),
                          );
                        }

                        final comment = commentProvider.comments[index];

                        return buildDoubtItem(
                          mode: mode,
                          context: context,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          userName: comment.commentedBy ?? "Unknown",
                          askedTime: comment.timestamp != null
                              ? formatTimestamp(comment.timestamp)
                              : "Asked just now",

                          fromTag: "from ${comment.userRole}" ?? "From User",
                          description: comment.content ?? "",
                          profileUrl: comment.profileImgUrl,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
