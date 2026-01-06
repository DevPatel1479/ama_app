import 'dart:async';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/custom_ama_screen_widgets.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/question_model.dart';
import 'package:ama_legal_solutions/provider/ama/answer_provider.dart';
import 'package:ama_legal_solutions/provider/ama/comment_provider.dart';
import 'package:ama_legal_solutions/provider/ama/question_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ama_legal_solutions/screens/features/dark_theme/dark_ama_screen.dart'
    show filterQuestionsCompute;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LightAmaScreen extends StatefulWidget {
  const LightAmaScreen({super.key});
  @override
  _LightAmaScreenState createState() => _LightAmaScreenState();
}

class _LightAmaScreenState extends State<LightAmaScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  /// track which question ids are COLLAPSED. Default: expanded (not present in set)
  final Set<String> _collapsedIds = {};

  bool _initialFetchDone = false;
  String? userName, userRole, userPhone, profilImgUrl;
  // bool _expanded = false; // for view more/less toggle
  // late AnimationController _animationController;
  // late Animation<double> _animation;
  // Firestore real-time subscription
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _questionsSubscription;

  // final Map<String, int> _commentsCountMap = {};

  // Keep a reference to the provider to avoid looking up context inside the stream callback
  late final QuestionProvider _providerRef;

  Timer? _debounce;
  Timer? _searchDebounce;
  bool _isSearching = false;
  String _searchQuery = "";

  List _filteredQuestions = [];
  // Track if we're doing initial load vs real-time update
  bool _isInitialLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDataFromLocal();
    // _animationController = AnimationController(
    //   duration: const Duration(milliseconds: 600),
    //   vsync: this,
    // );
    // _animation = CurvedAnimation(
    //   parent: _animationController,
    //   curve: Curves.easeInOut,
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _providerRef = context.read<QuestionProvider>();
      if (!_initialFetchDone) {
        final provider = context.read<QuestionProvider>();
        // Use a special method for initial load that won't trigger loading state for real-time updates
        _loadInitialQuestions();
        _initialFetchDone = true;
      }
      _attachQuestionsListener();
    });

    _scrollController.addListener(() {
      final provider = context.read<QuestionProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          provider.hasMore &&
          !provider.isLoading) {
        provider.fetchQuestions(context);
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadInitialQuestions() async {
    if (!mounted) return;
    setState(() {
      _isInitialLoading = true;
    });
    await _providerRef.fetchQuestions(context, reset: true);
    if (!mounted) return;
    setState(() {
      _isInitialLoading = false;
    });
  }

  void fetchUserDataFromLocal() async {
    final name = await LocalStorageHelper.getString("userName");
    final role = await LocalStorageHelper.getString("userRole");
    final phone = await LocalStorageHelper.getString("userPhone");
    final profile = await LocalStorageHelper.getString("profile_photo_url");

    setState(() {
      userName = name;
      userRole = role;
      userPhone = phone;
      profilImgUrl = profile;
    });
    // print("user role set $userRole");
  }

  // void _toggleExpansion() {
  //   setState(() {
  //     _expanded = !_expanded;
  //     if (_expanded) {
  //       _animationController.forward();
  //     } else {
  //       _animationController.reverse();
  //     }
  //   });
  // }

  void _attachQuestionsListener() {
    if (_questionsSubscription != null) return;

    // Keep the same ordering & page size as your paginated API first page.
    final query = FirebaseFirestore.instance
        .collection('questions')
        .orderBy('timestamp', descending: true)
        .limit(10);

    _questionsSubscription = query.snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        if (!mounted) return;

        for (final change in snapshot.docChanges) {
          try {
            final doc = change.doc;
            // doc.data() may be null, so default to an empty map
            final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

            final map = <String, dynamic>{
              'id': doc.id,
              // use data['field'] which if missing will be null — your Question.fromJson
              // should handle nulls. You can also provide defaults here if you prefer.
              'userId': data['userId'],
              'userName': data['userName'],
              'userRole': data['userRole'],
              'phone': data['phone'],
              'profileImgUrl': data['profileImgUrl'],
              'content': data['content'],
              // normalize timestamp safely (function returns 0 when can't parse)
              'timestamp': _normalizeTimestampField(data['timestamp']),
              'answer': data['answer'],
              'commentsCount': data['commentsCount'] ?? 0,
            };

            final qObj = Question.fromJson(map);

            if (change.type == DocumentChangeType.added) {
              _providerRef.upsertQuestion(qObj);
            } else if (change.type == DocumentChangeType.modified) {
              _providerRef.upsertQuestion(qObj);
            } else if (change.type == DocumentChangeType.removed) {
              _providerRef.removeQuestionById(qObj.id);
            }
          } catch (e) {
            // Helpful logging during development — remove or lower log level in prod
            // print('Realtime parse error for doc ${change.doc.id}: $e\n$st');
          }
        }
      },
      onError: (err) {
        // optionally log
        // print('Questions listener error: $err');
      },
    );
  }

  /// helper to normalize timestamp field returned by Firestore:
  /// Accepts int (ms or seconds) or Timestamp instance, returns milliseconds int
  int _normalizeTimestampField(dynamic ts) {
    if (ts == null) return 0;
    if (ts is int) {
      // If seconds, convert to milliseconds
      if (ts < 1000000000000) return ts * 1000;
      return ts;
    }
    // Cloud Firestore Timestamp (from package cloud_firestore)
    try {
      // ts may be a Timestamp with toDate() method
      final date = ts.toDate();
      return date.millisecondsSinceEpoch;
    } catch (_) {
      // fallback: try double
      try {
        final d = (ts as num).toInt();
        if (d < 1000000000000) return d * 1000;
        return d;
      } catch (_) {
        return 0;
      }
    }
  }

  // Handle real-time updates without showing loading indicator
  // Future<void> _handleRealtimeUpdate() async {
  //   try {
  //     // Use the silent method
  //     await _providerRef.fetchQuestionsSilently(context, reset: true);
  //   } catch (e) {
  //     // Silently handle errors for real-time updates
  //     // print('Silent update error: $e');
  //   }
  // }

  Future<void> _detachQuestionsListener() async {
    await _questionsSubscription?.cancel();
    _questionsSubscription = null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _detachQuestionsListener();

    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    // Debounce: wait 300ms after last keystroke
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = q);
      // start searching
      _doSearch(q);
    });
  }

  Future<void> _doSearch(String query) async {
    // only search by content
    final q = query.trim();
    if (q.isEmpty) {
      if (!mounted) return;
      setState(() {
        _filteredQuestions = [];
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredQuestions = [];
      _searchQuery = q;
    });

    try {
      final provider = context.read<QuestionProvider>();

      // Convert provider.questions (Question objects) into plain Maps for compute
      final rawList = provider.questions.map((qItem) {
        final map = <String, dynamic>{
          'id': qItem.id,
          'userId': qItem.userId,
          'userName': qItem.userName,
          'userRole': qItem.userRole,
          'phone': qItem.phone,
          'profileImgUrl': qItem.profileImgUrl,
          'content': qItem.content,
          'timestamp': qItem.timestamp,
          'commentsCount': qItem.commentsCount ?? 0,
          'answer': qItem.answer != null
              ? {
                  'content': qItem.answer!.content,
                  'answered_by': qItem.answer!.answeredBy,
                  'role': qItem.answer!.role,
                  'timestamp': qItem.answer!.timestamp,
                }
              : null,
        };
        return map;
      }).toList();

      List<Map<String, dynamic>> matchedMaps;

      // On web, compute/isolate is not available - do synchronous filter
      if (kIsWeb) {
        final qLower = q.toLowerCase();
        matchedMaps = rawList.where((m) {
          final content = (m['content'] ?? '').toString().toLowerCase();
          return content.contains(qLower);
        }).toList();
      } else {
        // Run the filtering in a background isolate to avoid UI jank on large lists
        final res = await compute(filterQuestionsCompute, {
          'raw': rawList,
          'q': q,
        });
        matchedMaps = List<Map<String, dynamic>>.from(res);
      }

      // Convert back to Question objects (using your factory)
      final matchedQuestions = matchedMaps
          .map((m) => Question.fromJson(m))
          .toList();

      if (!mounted) return;
      setState(() {
        _filteredQuestions = matchedQuestions;
        _isSearching = false;
      });
    } catch (e) {
      // On error just stop searching; keep UX alive
      if (!mounted) return;
      setState(() {
        _filteredQuestions = [];
        _isSearching = false;
      });
      // optional: print or log e/st
      // print('Search error: $e\n$st');
    }
  }

  void _collapse(String id) {
    setState(() => _collapsedIds.add(id));
  }

  void _expand(String id) {
    setState(() => _collapsedIds.remove(id));
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

  bool _canUserAddAnswer() {
    final r = userRole?.toLowerCase() ?? '';
    // print("user role $r");
    return r == 'admin' || r == 'advocate';
  }

  bool _questionHasNoAnswer(Question question) {
    final ans = question.answer;
    if (ans == null) return true;
    final content = (ans.content).toString().trim();
    return content.isEmpty;
  }

  /// Dialog box for adding an answer
  void _showAddAnswerDialog(
    BuildContext context,
    String questionId,
    String answeredBy,
    String role,
  ) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFD29F2A), width: 1),
          ),
          title: Text(
            "Add Your Answer",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: screenWidth * 0.8,
            child: TextField(
              textInputAction: TextInputAction.done,
              controller: _controller,
              maxLines: 5,
              minLines: 3,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type your answer here...",
                hintStyle: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: screenWidth * 0.035,
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),

            // Add Answer Button (with loading)
            Consumer<AnswerProvider>(
              builder: (context, answerProvider, _) {
                return ElevatedButton(
                  onPressed: answerProvider.isLoading
                      ? null
                      : () async {
                          final content = _controller.text.trim();
                          if (content.isEmpty) {
                            showCustomMessage(
                              context,
                              "Please enter an answer",
                              true,
                            );
                            return;
                          }

                          await answerProvider.addOrUpdateAnswer(
                            context: context,
                            questionId: questionId,
                            content: content,
                            answeredBy: answeredBy,
                            role: role,
                          );

                          if (!answerProvider.isLoading) {
                            await Future.delayed(Duration(seconds: 2));
                            Navigator.pop(
                              context,
                            ); // Close dialog after success
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD29F2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.012,
                    ),
                  ),
                  child: answerProvider.isLoading
                      ? SizedBox(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Add",
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildDoubtItem({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required String userName,
    required String askedTime,
    required String fromTag,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row with user info and "From User" badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AppAssets.whiteUserIcon,
                width: screenWidth * 0.10,
                height: screenWidth * 0.10,
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
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      askedTime,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
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
              color: Colors.black,
              height: 1.5,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Like and Answer row
          Row(
            children: [
              Image.asset(
                AppAssets.likeHeartIcon,
                width: screenWidth * 0.04,
                height: screenWidth * 0.04,
                color: Colors.black,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Like",
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: screenWidth * 0.05),
              Image.asset(
                AppAssets.answerIcon,
                width: screenWidth * 0.04,
                height: screenWidth * 0.04,
                color: Colors.black,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Answer",
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;
    const searchFieldScaleFactor = 0.75;

    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;
    final headerVisualHeight = screenHeight * 0.03; // tweak if you need taller
    final appBarHeight =
        MediaQuery.of(context).padding.top + headerVisualHeight;
    final role = context.watch<RealTimeRoleProvider>().role;
    userRole = role;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF8BD00),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 244, 206, 83),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),

        // ⭐ NATIVE WAY TO ROUND ONLY BOTTOM
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.07),
            bottomRight: Radius.circular(screenWidth * 0.07),
          ),
        ),

        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,

        title: Padding(
          padding: EdgeInsets.only(
            // top: MediaQuery.of(context).padding.top,
            left: screenWidth * 0.04 * scaleFactor,
            right: screenWidth * 0.04 * scaleFactor,
            // bottom: screenHeight * 0.015 * scaleFactor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// fixed header + search area
              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppPathsForScreen.userHomePath),
                        child: Image.asset(
                          AppAssets.backArrowIcon,
                          width: screenWidth * 0.06 * scaleFactor,
                          height: screenWidth * 0.06 * scaleFactor,
                          fit: BoxFit.contain,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02 * scaleFactor),
                      Text(
                        "Ask Me Anything",
                        style: GoogleFonts.outfit(
                          fontSize:
                              (screenWidth / 100) *
                              6.5 *
                              scaleFactor, // proportional but safe scaling
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2, // keeps it compact for AppBar
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),

                      /// Ask Doubt Button at top-right
                      SizedBox(
                        width: screenWidth * 0.35 * scaleFactor,
                        height: screenHeight * 0.05 * scaleFactor,
                        child: ElevatedButton(
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
                                  },
                                ),
                              );
                              return;
                            }
                            context.pushNamed(
                              AppScreenNames.raiseQuery,
                              queryParameters: {"isQuestionPosting": "true"},
                            );
                          },

                          style:
                              ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(41),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.black.withOpacity(0.3),
                                elevation: 6,
                              ).copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(41),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Ask Question",
                                style: GoogleFonts.outfit(
                                  fontSize: 14 * scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: GradientTopLayout(
                screenName: "home",
                keepExpanded: false,

                // headerContent: Container(
                //   width: double.infinity,

                //   padding: EdgeInsets.symmetric(
                //     horizontal: screenWidth * 0.04 * scaleFactor,
                //     vertical: screenHeight * 0.015 * scaleFactor,
                //   ),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFD29F2A),
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(
                //         screenWidth * 0.07,
                //       ), // ~responsive
                //       bottomRight: Radius.circular(
                //         screenWidth * 0.07,
                //       ), // ~responsive
                //     ),
                //   ),
                //   child: Column(
                //     children: [
                //       /// fixed header + search area
                //       Column(
                //         children: [
                //           Row(
                //             children: [
                //               GestureDetector(
                //                 onTap: () =>
                //                     context.go(AppPathsForScreen.userHomePath),
                //                 child: Image.asset(
                //                   AppAssets.backArrowIcon,
                //                   width: screenWidth * 0.05 * scaleFactor,
                //                   height: screenWidth * 0.05 * scaleFactor,
                //                   fit: BoxFit.contain,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //               SizedBox(width: screenWidth * 0.12 * scaleFactor),
                //               Text(
                //                 "Ask Me Anything",
                //                 style: GoogleFonts.outfit(
                //                   fontSize:
                //                       (screenWidth / 100) *
                //                       6.5 *
                //                       scaleFactor, // proportional but safe scaling
                //                   fontWeight: FontWeight.w600,
                //                   color: Colors.black,
                //                   height: 1.2, // keeps it compact for AppBar
                //                 ),
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //                 textAlign: TextAlign.center,
                //               ),
                //               Spacer(),

                //               /// Ask Doubt Button at top-right
                //               SizedBox(
                //                 width: screenWidth * 0.35 * scaleFactor,
                //                 height: screenHeight * 0.05 * scaleFactor,
                //                 child: ElevatedButton(
                //                   onPressed: () {
                //                     context.pushNamed(
                //                       AppScreenNames.raiseQuery,
                //                       queryParameters: {
                //                         "isQuestionPosting": "true",
                //                       },
                //                     );
                //                   },

                //                   style:
                //                       ElevatedButton.styleFrom(
                //                         padding: EdgeInsets.zero,
                //                         shape: RoundedRectangleBorder(
                //                           borderRadius: BorderRadius.circular(
                //                             41,
                //                           ),
                //                         ),
                //                         backgroundColor: Colors.transparent,
                //                         shadowColor: Colors.black.withOpacity(
                //                           0.3,
                //                         ),
                //                         elevation: 6,
                //                       ).copyWith(
                //                         backgroundColor:
                //                             MaterialStateProperty.all(
                //                               Colors.transparent,
                //                             ),
                //                       ),
                //                   child: Ink(
                //                     decoration: BoxDecoration(
                //                       color: Colors.black,
                //                       borderRadius: BorderRadius.circular(41),
                //                     ),
                //                     child: Container(
                //                       alignment: Alignment.center,
                //                       child: Text(
                //                         "Ask Question",
                //                         style: GoogleFonts.outfit(
                //                           fontSize: 14 * scaleFactor,
                //                           fontWeight: FontWeight.w500,
                //                           color: Colors.white,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01 * scaleFactor,
                    vertical: screenHeight * 0.009 * scaleFactor,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "A quick, reliable space to ask any legal question and get clear, expert-backed answers instantly.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: screenWidth * 0.040 * scaleFactor,
                            fontWeight: FontWeight.w300,
                            height: 1.25,
                          ),
                        ),
                      ),
                      // SizedBox(height: screenHeight * 0.03 * scaleFactor),
                      // search bar (fixed height)
                      Padding(
                        padding: EdgeInsets.all(6.5),
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.08 *
                              searchFieldScaleFactor,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFF2D2319),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 16 * searchFieldScaleFactor),
                                Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 20 * searchFieldScaleFactor,
                                ),
                                SizedBox(width: 10 * searchFieldScaleFactor),
                                Expanded(
                                  child: TextField(
                                    textInputAction: TextInputAction.done,
                                    controller: _searchController,
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Search any question...",
                                      hintStyle: GoogleFonts.outfit(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _searchQuery = v.trim()),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      _doSearch(_searchController.text.trim()),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.08 *
                                        searchFieldScaleFactor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30 * searchFieldScaleFactor,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(25),
                                        bottomRight: Radius.circular(25),
                                      ),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF2D2319),
                                          Color.fromARGB(255, 116, 116, 116),
                                        ],
                                        stops: [0.2, 1.0],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: _isSearching
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: Colors.black,
                                            ),
                                          )
                                        : Text(
                                            "Search",
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16 * scaleFactor),

                      Expanded(
                        child: Consumer<QuestionProvider>(
                          builder: (context, provider, _) {
                            // Show initial loading only on first load
                            if (_isInitialLoading &&
                                provider.questions.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              );
                            }

                            // choose source: show filtered results when searching, otherwise provider list
                            final List sourceList = (_searchQuery.isNotEmpty)
                                ? _filteredQuestions
                                : provider.questions;

                            final List uniqueQuestions = [];
                            final seen = <String>{};
                            for (var item in sourceList) {
                              String? id;
                              if (item is Question) {
                                id = item.id;
                              } else if (item is Map && item['id'] != null) {
                                id = item['id'].toString();
                              } else {
                                // defensive fallback for dynamic objects
                                try {
                                  id = (item as dynamic).id as String?;
                                } catch (_) {
                                  id = null;
                                }
                              }
                              if (id == null || id.isEmpty) continue;
                              if (!seen.contains(id)) {
                                seen.add(id);
                                uniqueQuestions.add(item);
                              }
                            }

                            if (uniqueQuestions.isEmpty) {
                              // show searching loader if we're actively searching
                              if (_searchQuery.isNotEmpty && _isSearching) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                );
                              }

                              // show "no results" when search query present, otherwise "no questions"
                              return Center(
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? "No matching questions found"
                                      : "No questions found",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }
                            // Use filtered pagination only when not searching
                            final bool usePagination = _searchQuery.isEmpty;

                            // FIXED: Only add +1 to itemCount when actually loading more
                            final bool shouldShowLoader =
                                usePagination &&
                                provider.hasMore &&
                                provider.isLoading;

                            final int itemCount = shouldShowLoader
                                ? uniqueQuestions.length + 1
                                : uniqueQuestions.length;

                            return RefreshIndicator(
                              onRefresh: () async {
                                // reset data and re-fetch from first page
                                await provider.fetchQuestionsSilently(
                                  context,
                                  reset: true,
                                );
                                // reset collapse state so everything is expanded after refresh
                                setState(() {
                                  _collapsedIds.clear();
                                  _filteredQuestions = [];
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _isSearching = false;
                                });
                              },
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.only(
                                  left: screenWidth * 0.04,
                                  right: screenWidth * 0.04,
                                  top: screenHeight * 0.015,
                                  bottom: contentBottomPadding,
                                ),
                                itemCount: itemCount,
                                itemBuilder: (context, index) {
                                  // loader row (pagination)
                                  if (shouldShowLoader &&
                                      index == uniqueQuestions.length) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.transparent,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final question = uniqueQuestions[index];
                                  final questionId = question.id as String;
                                  final isExpanded = !_collapsedIds.contains(
                                    questionId,
                                  );
                                  final formattedDate = _formatTimestamp(
                                    question.timestamp as int?,
                                  );
                                  final showAddAnswerButton =
                                      _canUserAddAnswer() &&
                                      _questionHasNoAnswer(question);

                                  // determine answer preview limit (adjust as needed)
                                  final answerText =
                                      question.answer?.content ?? '';
                                  final int charLimit = screenWidth < 600
                                      ? 100
                                      : 160;
                                  final bool answerTooLong =
                                      answerText.length > charLimit;
                                  final String answerPreview = answerTooLong
                                      ? answerText
                                            .substring(0, charLimit)
                                            .trimRight()
                                      : answerText;

                                  return Container(
                                    key: ValueKey(questionId),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromRGBO(210, 159, 42, 0.65),
                                          Color.fromRGBO(255, 255, 255, 0.65),
                                        ],
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        // Entire card tap uses same logic as previous "View Replies" button
                                        onTap: () {
                                          if (question.commentsCount >= 0 &&
                                              isExpanded == true) {
                                            final commentProvider = context
                                                .read<CommentProvider>();
                                            showAskDoubtBottomSheet(
                                              context,
                                              commentProvider,
                                              "light",
                                              questionId,
                                              userName,
                                              userRole,
                                              userPhone,
                                              profilImgUrl,
                                              question,
                                            );
                                          } else {
                                            if (_collapsedIds.contains(
                                              questionId,
                                            )) {
                                              _expand(questionId);
                                            } else {
                                              _collapse(questionId);
                                            }
                                          }
                                        },

                                        child: Container(
                                          margin: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2D2319),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            mainAxisSize: MainAxisSize
                                                .min, // <- fixes the unbounded-height + Spacer issue
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // top row - identical to original
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage:
                                                        (question.profileImgUrl !=
                                                                null &&
                                                            (question.profileImgUrl
                                                                    as String)
                                                                .isNotEmpty)
                                                        ? NetworkImage(
                                                            "${question.profileImgUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                                          )
                                                        : AssetImage(
                                                                AppAssets
                                                                    .userIcon,
                                                              )
                                                              as ImageProvider,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          question.userName ??
                                                              '',
                                                          style:
                                                              GoogleFonts.outfit(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          formattedDate,
                                                          style:
                                                              GoogleFonts.outfit(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .white70,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (showAddAnswerButton)
                                                    Container(
                                                      height: 28,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          _showAddAnswerDialog(
                                                            context,
                                                            questionId,
                                                            userName!,
                                                            userRole!,
                                                          );
                                                        },
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      6,
                                                                    ),
                                                              ),
                                                            ).copyWith(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all(
                                                                    Colors
                                                                        .transparent,
                                                                  ),
                                                            ),
                                                        child: Ink(
                                                          decoration: BoxDecoration(
                                                            gradient: const LinearGradient(
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                              colors: [
                                                                Color(
                                                                  0xFFD29F2A,
                                                                ),
                                                                Color(
                                                                  0xFFFFFFFF,
                                                                ),
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            child: Text(
                                                              "Answer",
                                                              style: GoogleFonts.outfit(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),

                                              const SizedBox(height: 8),

                                              // QUESTION TEXT - remains 1 line ellipsis (no view more)
                                              Text(
                                                question.content ?? '',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                                // maxLines: 1,
                                                // overflow: TextOverflow.ellipsis,
                                              ),

                                              const SizedBox(height: 10),

                                              // ANSWER SECTION - ONLY IF ANSWER EXISTS
                                              if (question.answer != null)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,

                                                  children: [
                                                    Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ), // your desired radius
                                                          child: Image.asset(
                                                            AppAssets.appIcon,
                                                            width: 20,
                                                            height: 20,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 4,
                                                                  horizontal: 8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0x33FFFFFF,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "from ${question.answer!.role ?? ''}",
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    const Color(
                                                                      0xFFD29F2A,
                                                                    ),
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),

                                                    // ANSWER TEXT: truncated + "... view more" when long
                                                    // (the whole card tap still opens replies)
                                                    if (answerText.isNotEmpty)
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  answerTooLong
                                                                  ? "$answerPreview..." // truncated part + ellipsis
                                                                  : answerPreview,
                                                              style: GoogleFonts.outfit(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    const Color(
                                                                      0xFFD29F2A,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (answerTooLong)
                                                              TextSpan(
                                                                text:
                                                                    " view more",
                                                                style: GoogleFonts.outfit(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  // keep the same accent color or change if desired
                                                                  color: const Color(
                                                                    0xFFFFFFFF,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),

                                                    const SizedBox(height: 8),
                                                  ],
                                                ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    AppAssets.commentBtn,
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    "Comments",
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // const Spacer(),

                                              // Removed the bottom "View Replies/View More" button entirely
                                              // to fulfill the requirement (card itself handles taps).
                                              // To keep visual spacing consistent, keep a small bottom padding:
                                              // SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: const CustomBottomNav(),
            ),
          ),
        ],
      ),
    );
  }
}
