import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
// import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
// import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/provider/ama/comment_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
// import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
// import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';
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

// void _showAddCommentDialog(
//   BuildContext context,
//   CommentProvider provider,
//   String mode,
//   String questionId,
//   String? userName,
//   String? userRole,
//   String? userPhone,
//   String? profileImgUrl,
// ) {
//   final TextEditingController _controller = TextEditingController();
//   bool isLoading = false;

//   showDialog(
//     context: context,
//     builder: (context) {
//       final screenWidth = MediaQuery.of(context).size.width;
//       final screenHeight = MediaQuery.of(context).size.height;
//       final isSmallScreen = screenWidth < 360;

//       return StatefulBuilder(
//         builder: (context, setState) {
//           bool isSending = false;
//           Future<void> _sendComment() async {
//             final text = provider.commentController.text.trim();
//             if (text.isEmpty) return;

//             setState(() => isSending = true);

//             final success = await provider.postComment(
//               context: context,
//               questionId: questionId,
//               content: text,
//               commentedBy: userName ?? "",
//               userRole: userRole ?? "",
//               phone: userPhone ?? "",
//               profileImgUrl: profileImgUrl ?? "",
//             );

//             if (success) {
//               provider.commentController.clear();
//             }

//             setState(() => isSending = false);
//           }

//           return Container(
//             padding: EdgeInsets.only(
//               left: screenWidth * 0.03,
//               right: screenWidth * 0.03,
//               top: screenHeight * 0.01,
//               bottom:
//                   MediaQuery.of(context).viewInsets.bottom +
//                   screenHeight * 0.01,
//             ),
//             decoration: BoxDecoration(
//               color: Color(0xFF323232),
//               borderRadius: BorderRadius.circular(33),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.25),
//                   blurRadius: 22.8,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             margin: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.05,
//               vertical: screenHeight * 0.01,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: provider.commentController,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: screenWidth * 0.04,
//                     ),
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText: "Your Comment",
//                       hintStyle: TextStyle(
//                         color: Colors.white,
//                         fontSize: screenWidth * 0.04,
//                       ),
//                     ),
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: (_) => _sendComment(),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 GestureDetector(
//                   onTap: isSending ? null : _sendComment,
//                   child: isSending
//                       ? SizedBox(
//                           width: screenWidth * 0.06,
//                           height: screenWidth * 0.06,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : Icon(
//                           Icons.send,
//                           color: Colors.white,
//                           size: screenWidth * 0.06,
//                         ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }

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

  // Reset comments and fetch first page
  provider.clearExistingComments();
  provider.fetchComments(questionId, reset: true);

  final String createdAtTime = _formatTimestamp(question.timestamp as int?);
  final FocusNode commentFocusNode = FocusNode();

  // The send handler uses provider.setSending so provider controls loader state
  Future<void> _sendComment(CommentProvider provider) async {
    final String text = provider.commentController.text.trim();
    if (text.isEmpty) return;

    provider.setSending(true);
    try {
      final success = await provider.postComment(
        context: context,
        questionId: questionId,
        content: text,
        commentedBy: userName ?? "",
        userRole: userRole ?? "",
        phone: userPhone ?? "",
        profileImgUrl: profileImgUrl ?? "",
      );

      if (success) {
        // FocusScope.of(context).unfocus();

        commentFocusNode.unfocus();

        provider.commentController.clear();
        // Optionally scroll the comments list to top if you have a scroll controller
      }
    } finally {
      // always make sure to clear sending flag
      provider.setSending(false);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      // AnimatedPadding makes the sheet move up when keyboard opens.
      return AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // dismiss keyboard when tapping outside input
            FocusScope.of(ctx).unfocus();
          },
          child: Container(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.95),
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
                        onTap: () => Navigator.pop(ctx),
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
                      SizedBox(width: screenWidth * 0.05),
                    ],
                  ),
                ),

                // Question card
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
                                      (question.profileImgUrl as String)
                                          .isNotEmpty)
                                  ? NetworkImage(
                                      "${question.profileImgUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                    )
                                  : AssetImage(AppAssets.userIcon)
                                        as ImageProvider,
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
                                    "$createdAtTime",
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
                        const SizedBox(height: 10),
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
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.010,
                              horizontal: screenWidth * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD29F2A,
                              ), // Background color
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Rounded corners
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        AppAssets.appIcon,
                                        width:
                                            screenWidth *
                                            0.05, // Responsive width
                                        height:
                                            screenWidth *
                                            0.05, // Responsive height
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0x33FFFFFF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          "from ${question.answer!.role ?? ''}",
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
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
                                    fontWeight:
                                        FontWeight.w400, // 400 = Regular
                                    fontStyle: FontStyle.normal, // Regular
                                    fontSize:
                                        screenWidth * 0.032, // ~13px responsive
                                    height:
                                        15 /
                                        13, // line-height: 15px for 13px font
                                    letterSpacing: 0, // 0%
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Comments list
                Expanded(
                  child: Consumer<CommentProvider>(
                    builder: (context, commentProvider, _) {
                      if (commentProvider.isLoading &&
                          commentProvider.comments.isEmpty) {
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
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
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
                              fromTag:
                                  "from ${comment.userRole}" ?? "From User",
                              description: comment.content ?? "",
                              profileUrl: comment.profileImgUrl,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Input bar (pinned)
                Consumer<CommentProvider>(
                  builder: (context, provider, _) {
                    if (userRole?.toLowerCase() == "guest") {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: 8,
                        ),
                        child: SafeArea(
                          top: false,
                          child: GestureDetector(
                            onTap: () {
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
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                              ),
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF323232),
                                borderRadius: BorderRadius.circular(33),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Login to comment",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.03,
                        right: screenWidth * 0.03,
                        top: 8,
                        bottom: 8,
                      ),
                      child: SafeArea(
                        top: false,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF323232),
                            borderRadius: BorderRadius.circular(33),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: provider.commentController,
                                  focusNode: commentFocusNode,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Your Comment",
                                    hintStyle: TextStyle(color: Colors.white),
                                  ),
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) async {
                                    await _sendComment(provider);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: provider.isSending
                                    ? null
                                    : () async {
                                        FocusScope.of(ctx).unfocus();
                                        await _sendComment(provider);
                                      },
                                child: provider.isSending
                                    ? SizedBox(
                                        width: screenWidth * 0.06,
                                        height: screenWidth * 0.06,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: screenWidth * 0.06,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
