import 'dart:async';
import 'dart:math' show min, max;
import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';

import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/question_model.dart';
import 'package:ama_legal_solutions/provider/ama/answer_provider.dart';
import 'package:ama_legal_solutions/provider/ama/comment_provider.dart';
import 'package:ama_legal_solutions/provider/ama/delete_comment_provider.dart';
import 'package:ama_legal_solutions/provider/ama/delete_question_provider.dart';

import 'package:ama_legal_solutions/provider/ama/question_provider.dart';
import 'package:ama_legal_solutions/provider/profile/profile_photo_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_case_overview_screen.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_payment_view_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/dark_theme/dark_user_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

List<Map<String, dynamic>> filterQuestionsCompute(Map<String, dynamic> params) {
  final List raw = params['raw'] as List;
  final String q = (params['q'] as String).toLowerCase();

  final List<Map<String, dynamic>> results = [];
  for (final item in raw) {
    final content = (item['content'] ?? '').toString().toLowerCase();
    if (content.contains(q)) {
      results.add(Map<String, dynamic>.from(item));
    }
  }
  return results;
}

String timeAgo(int timestamp) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    final seconds = difference.inSeconds == 0 ? 1 : difference.inSeconds;

    return "$seconds second${seconds == 1 ? '' : 's'} ago";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
  } else if (difference.inDays < 30) {
    return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return "$months month${months == 1 ? '' : 's'} ago";
  } else {
    final years = (difference.inDays / 365).floor();
    return "$years year${years == 1 ? '' : 's'} ago";
  }
}

class _AskQuestionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double scaleFactor;

  const _AskQuestionButton({
    required this.onPressed,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scaleFactor,
            vertical: 12 * scaleFactor,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD29F2A),
            borderRadius: BorderRadius.circular(17),

            // /// 🔥 OUTER GLOW
            // boxShadow: const [
            //   BoxShadow(
            //     color: Color.fromRGBO(148, 148, 148, 0.44),
            //     blurRadius: 23.9,
            //     spreadRadius: 0,
            //   ),
            // ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ask AMA",
                style: GoogleFonts.outfit(
                  fontSize: 14 * scaleFactor,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2D2319),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}

Future<void> launch__(String url) async {
  final uri = Uri.parse(url.startsWith("http") ? url : "https://$url");

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

RichText buildLinkText(
  String text, {
  TextStyle? normalStyle,
  TextStyle? linkStyle,
}) {
  final spans = <TextSpan>[];

  final combinedRegex = RegExp(
    r'(https?:\/\/[^\s]+|www\.[^\s]+|\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b)',
    caseSensitive: false,
  );

  final matches = combinedRegex.allMatches(text);

  int lastIndex = 0;

  for (final match in matches) {
    if (match.start > lastIndex) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
          style: normalStyle,
        ),
      );
    }

    final matchedText = match.group(0)!;

    spans.add(
      TextSpan(
        text: matchedText,
        style:
            linkStyle ??
            normalStyle?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (matchedText.contains('@')) {
              openEmail(matchedText);
            } else {
              openBlog(matchedText: matchedText);
            }
          },
      ),
    );

    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex), style: normalStyle));
  }

  return RichText(text: TextSpan(children: spans));
}

class DarkAmaScreen extends StatefulWidget {
  final String? tappedQuestionId;
  final String? tappedCommentId;
  const DarkAmaScreen({super.key, this.tappedQuestionId, this.tappedCommentId});
  @override
  _DarkAmaScreenState createState() => _DarkAmaScreenState();
}

class _DarkAmaScreenState extends State<DarkAmaScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _activeFilter = "all";
  String? _openedCommentQuestionId;
  final Map<String, GlobalKey> _questionKeys = {};

  /// track which question ids are COLLAPSED. Default: expanded (not present in set)
  final Set<String> _collapsedIds = {};

  bool _initialFetchDone = false;
  String? userName, userRole, userPhone, profilImgUrl;

  // Firestore real-time subscription
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _questionsSubscription;

  final Map<String, int> _commentsCountMap = {};

  // Keep a reference to the provider to avoid looking up context inside the stream callback
  late final QuestionProvider _providerRef;

  Timer? _debounce;
  Timer? _searchDebounce;
  bool _isSearching = false;
  String _searchQuery = "";

  List _filteredQuestions = [];

  // Track if we're doing initial load vs real-time update
  bool _isInitialLoading = true;

  String? _highlightedQuestionId;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    fetchUserDataFromLocal();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _providerRef = context.read<QuestionProvider>();
      if (!_initialFetchDone) {
        // final provider = context.read<QuestionProvider>();
        // Use a special method for initial load that won't trigger loading state for real-time updates
        _loadInitialQuestions();
        _initialFetchDone = true;
      }
      _attachQuestionsListener();

      final phone = await LocalStorageHelper.getString("userPhone");
      final role = await LocalStorageHelper.getString("userRole");
      if (!mounted) return;
      if (phone != null && role != null) {
        final profileProv = context.read<ProfileProvider>();

        if (!profileProv.hasProfilePhoto) {
          profileProv.fetchProfilePhoto(context, phone: phone, role: role);
        }
      }
    });

    // _scrollController.addListener(() {
    //   final provider = context.read<QuestionProvider>();
    //   if (_scrollController.position.pixels >=
    //           _scrollController.position.maxScrollExtent - 200 &&
    //       provider.hasMore &&
    //       !provider.isLoading) {
    //     provider.fetchQuestions(context);
    //   }
    // });

    _scrollController.addListener(() {
      final provider = context.read<QuestionProvider>();

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_searchQuery.isNotEmpty) {
          // 🔍 SEARCH PAGINATION
          if (provider.searchHasMore && !provider.isSearching) {
            provider.searchQuestions(context, term: _searchQuery);
          }
        } else {
          // 🧠 NORMAL PAGINATION
          if (provider.hasMore && !provider.isLoading) {
            provider.fetchQuestions(context);
          }
        }
      }
    });
    _searchController.addListener(() {
      setState(() {}); // rebuild UI when text changes
    });
    if (widget.tappedQuestionId != null) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;

        /// 🔥 If comment deep link → open comments & highlight COMMENT (not question)
        if (widget.tappedCommentId != null) {
          _openCommentsAndScrollToQuestion(widget.tappedQuestionId!);
        }
        /// 🔥 Else → highlight QUESTION only
        else {
          _scrollToAndHighlightQuestion(widget.tappedQuestionId!);
        }
      });
    }
  }

  void _openCommentsAndScrollToQuestion(String questionId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _questionKeys[questionId];
      final ctx = key?.currentContext;

      if (ctx != null) {
        // Scroll to the question first
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );

        // Open comments
        final commentProvider = context.read<CommentProvider>();
        commentProvider.clearExistingComments();
        commentProvider.fetchComments(questionId, reset: true);

        setState(() {
          _openedCommentQuestionId = questionId;
        });
      } else {
        // Retry until widget is mounted
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _openCommentsAndScrollToQuestion(questionId);
        });
      }
    });
  }

  void toggleComments(String questionId) {
    setState(() {
      if (_openedCommentQuestionId == questionId) {
        _openedCommentQuestionId = null;
      } else {
        _openedCommentQuestionId = questionId;
      }
    });
  }

  void _scrollToAndHighlightQuestion(String questionId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _questionKeys[questionId];
      final ctx = key?.currentContext;

      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );

        setState(() {
          _highlightedQuestionId = questionId;
        });

        _highlightTimer?.cancel();
        _highlightTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _highlightedQuestionId = null);
          }
        });
      } else {
        // 🔁 Retry if widget not built yet (pagination / async load)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _scrollToAndHighlightQuestion(questionId);
        });
      }
    });
  }

  // Separate method for initial load that sets the initial loading state
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
  }

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
          'commentsCount': qItem.commentsCount,
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
    return r == 'admin' || r == 'advocate' || r == "legal_expert";
  }

  bool _questionHasNoAnswer(Question question) {
    final ans = question.answer;
    if (ans == null) return true;
    final content = (ans.content ?? '').toString().trim();
    return content.isEmpty;
  }

  /// Dialog box for adding an answer
  void _showAddAnswerDialog(
    BuildContext context,
    String questionId,
    String answeredBy,
    String role,
    String questionOwnerPhone,
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
                            questionOwnerPhone: questionOwnerPhone,
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

  Widget _buildFilterButton(
    String label,
    String filterKey,
    double screenWidth,
    double screenHeight,
  ) {
    final bool isActive = _activeFilter == filterKey;

    // Responsive font & padding with min/max caps
    final double fontSize = min(16, max(12, screenWidth * 0.04)); // 12-16px
    final double horizontalPadding = min(20, max(12, screenWidth * 0.04));
    final double verticalPadding = min(10, max(6, screenHeight * 0.012));

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = isActive ? null : filterKey;
        });
      },
      child: RepaintBoundary(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.33),
                blurRadius: 12.5,
              ),
            ],
            border: isActive
                ? Border.all(color: const Color(0xFFD29F2A), width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2D2319),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void scrollToQuestion(String questionId) {
    final key = _questionKeys[questionId];
    if (key == null) return;

    final context = key.currentContext;
    if (context == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.25, // keeps input above keyboard
      );
    });
  }

  List<Map<String, String>> _getDropdownValues() {
    final role = userRole?.toLowerCase() ?? "";

    if (role == "user" || role == "client" || role == "guest") {
      return [
        {'key': 'all', 'label': 'All'}, // default: all questions
        {'key': 'unanswered', 'label': 'Unanswered'},
        {'key': 'posted_by_me', 'label': 'My Questions'},
        {'key': 'answered', 'label': 'Answered'},
      ];
    } else {
      // admin / advocate
      return [
        {'key': 'all', 'label': 'All'}, // default: all questions
        {'key': 'unanswered', 'label': 'Unanswered'},
        {'key': 'answered_by_me', 'label': 'Answered by me'},
        {'key': 'answered', 'label': 'Answered'},
      ];
    }
  }

  // Widget _buildSearchBar(double screenWidth, double screenHeight) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: screenHeight * 0.02),
  //     padding: EdgeInsets.symmetric(
  //       horizontal: screenWidth * 0.04, // responsive instead of 16px
  //       vertical: screenHeight * 0.018, // responsive instead of 16–17px
  //     ),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(color: const Color.fromRGBO(161, 161, 161, 0.25)),
  //       color: Colors.white.withOpacity(0.02), // glass feel
  //     ),
  //     child: Row(
  //       children: [
  //         /// 🔍 SEARCH ICON
  //         Icon(
  //           Icons.search,
  //           color: Colors.white.withOpacity(0.5),
  //           size: screenWidth * 0.05,
  //         ),

  //         SizedBox(width: screenWidth * 0.03),

  //         /// ✍️ TEXT FIELD
  //         Expanded(
  //           child: TextField(
  //             controller: _searchController,
  //             onChanged: (value) {
  //               if (_searchDebounce?.isActive ?? false) {
  //                 _searchDebounce!.cancel();
  //               }

  //               _searchDebounce = Timer(const Duration(milliseconds: 500), () {
  //                 final provider = context.read<QuestionProvider>();

  //                 if (value.trim().isEmpty) {
  //                   provider.clearSearch();
  //                   setState(() {
  //                     _searchQuery = "";
  //                   });
  //                   return;
  //                 }

  //                 setState(() {
  //                   _searchQuery = value;
  //                 });

  //                 final isNewSearch =
  //                     value.trim().toLowerCase() != provider.currentSearchTerm;

  //                 provider.searchQuestions(
  //                   context,
  //                   term: value.trim().toLowerCase(),
  //                   reset: isNewSearch, // ✅ only reset when new query
  //                 );
  //               });

  //               setState(() {}); // 👈 refresh suffix icon instantly
  //             },
  //             style: GoogleFonts.outfit(
  //               color: Colors.white,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w400,
  //               height: 1,
  //             ),
  //             decoration: InputDecoration(
  //               isDense: true,
  //               border: InputBorder.none,

  //               /// ✨ HINT TEXT (as per your design)
  //               hintText: "Search legal queries…",
  //               hintStyle: GoogleFonts.outfit(
  //                 color: Colors.white.withOpacity(0.28),
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w400,
  //                 height: 1,
  //               ),

  //               /// ❌ REMOVE default padding
  //               contentPadding: EdgeInsets.zero,
  //             ),
  //           ),
  //         ),

  //         /// ❌ CLEAR BUTTON
  //         if (_searchController.text.isNotEmpty)
  //           GestureDetector(
  //             onTap: () {
  //               _searchController.clear();

  //               context.read<QuestionProvider>().clearSearch();

  //               setState(() {
  //                 _searchQuery = "";
  //               });
  //             },
  //             child: Padding(
  //               padding: EdgeInsets.only(left: screenWidth * 0.02),
  //               child: Icon(
  //                 Icons.close,
  //                 color: Colors.white.withOpacity(0.6),
  //                 size: screenWidth * 0.045,
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  double _getTextWidth(String text, double fontSize) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return textPainter.size.width;
  }

  Widget buildFilters(double screenWidth, double screenHeight) {
    final filters = _getDropdownValues();

    return Padding(
      padding: EdgeInsets.only(
        bottom: screenHeight * 0.02,
        left: screenWidth * 0.02,
        right: screenWidth * 0.02,
      ),
      child: SizedBox(
        height: screenHeight * 0.06,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: filters.length,
          separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.06),
          itemBuilder: (context, i) {
            final filter = filters[i];
            final bool isSelected = _activeFilter == filter['key'];
            final textWidth = _getTextWidth(
              filter['label']!,
              screenWidth * 0.04, // same as your font size
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque, // ✅ FIX
              onTap: () {
                setState(() {
                  _activeFilter = filter['key']!;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 🔤 LABEL TEXT
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: GoogleFonts.outfit(
                      color: isSelected
                          ? const Color(0xFFFBCF20)
                          : const Color.fromRGBO(193, 193, 193, 0.7),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                    child: Text(filter['label']!),
                  ),

                  SizedBox(height: screenHeight * 0.008),

                  /// 🟡 DASH
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    width: isSelected ? textWidth : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBCF20),
                      borderRadius: BorderRadius.circular(58),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;
    final headerHeight =
        MediaQuery.of(context).padding.top +
        kToolbarHeight + // appbar row
        // screenHeight * 0.07 + // search
        screenHeight * 0.042; // filters
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;
    final role = context.watch<RealTimeRoleProvider>().role;
    userRole = role;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: RepaintBoundary(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF171717), Color(0xFF0F0F0F)],
            ),
          ),
          child: Stack(
            children: [
              NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                  ];
                },
                body: SafeArea(
                  bottom: false,
                  // top: false,
                  child: Builder(
                    builder: (context) {
                      return
                      // questions grid - FIXED: LOADER ONLY WHEN LOADING MORE
                      Consumer<QuestionProvider>(
                        builder: (context, provider, _) {
                          // Show initial loading only on first load
                          if (_isInitialLoading && provider.questions.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }

                          // choose source: show filtered results when searching, otherwise provider list
                          // final List sourceList = (_searchQuery.isNotEmpty)
                          //     ? _filteredQuestions
                          //     : provider.questions;

                          final List sourceList = (_searchQuery.isNotEmpty)
                              ? provider.searchResults
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

                          // if (uniqueQuestions.isEmpty) {
                          //   // show searching loader if we're actively searching
                          //   // if (_searchQuery.isNotEmpty && _isSearching) {
                          //   if (_searchQuery.isNotEmpty &&
                          //       provider.isSearching) {
                          //     return const Center(
                          //       child: CircularProgressIndicator(
                          //         color: Colors.white,
                          //       ),
                          //     );
                          //   }

                          //   // show "no results" when search query present, otherwise "no questions"
                          //   // return Center(
                          //   //   child: Text(
                          //   //     _searchQuery.isNotEmpty
                          //   //         ? "No matching questions found"
                          //   //         : "No questions found",
                          //   //     style: const TextStyle(color: Colors.white),
                          //   //   ),
                          //   // );
                          // }
                          if (_searchQuery.isNotEmpty) {
                            /// 🔥 SHOW LOADER FIRST
                            if (provider.isSearching &&
                                uniqueQuestions.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            /// ❌ SHOW EMPTY ONLY AFTER SEARCH COMPLETES
                            if (!provider.isSearching &&
                                uniqueQuestions.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No matching questions found",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          } // Show message if filtered list is empty
                          List __filteredQuestions = uniqueQuestions;

                          switch (_activeFilter) {
                            case 'all': // show all questions
                              __filteredQuestions = uniqueQuestions;
                              __filteredQuestions.sort(
                                (a, b) => (b.timestamp ?? 0).compareTo(
                                  a.timestamp ?? 0,
                                ),
                              );
                              break;

                            case 'unanswered':
                              __filteredQuestions = uniqueQuestions
                                  .where((q) => q.answer == null)
                                  .toList();
                              break;

                            case 'posted_by_me':
                              __filteredQuestions = uniqueQuestions
                                  .where((q) => q.phone == userPhone)
                                  .toList();
                              break;

                            case 'answered_by_me':
                              __filteredQuestions = uniqueQuestions
                                  .where(
                                    (q) =>
                                        q.answer != null &&
                                        q.answer!.answeredBy.toLowerCase() ==
                                            userName?.toLowerCase(),
                                  )
                                  .toList();
                              break;

                            case 'answered':
                              __filteredQuestions = uniqueQuestions
                                  .where((q) => q.answer != null)
                                  .toList();
                              break;

                            default:
                              __filteredQuestions = uniqueQuestions;
                          }
                          // Use filtered pagination only when not searching
                          final bool usePagination = _searchQuery.isEmpty;

                          // FIXED: Only add +1 to itemCount when actually loading more
                          // final bool shouldShowLoader =
                          //     usePagination &&
                          //     provider.hasMore &&
                          //     provider.isLoading;

                          final bool shouldShowLoader =
                              (_searchQuery.isEmpty &&
                                  provider.hasMore &&
                                  provider.isLoading) ||
                              (_searchQuery.isNotEmpty &&
                                  provider.searchHasMore &&
                                  provider.isSearching);
                          final int itemCount =
                              2 +
                              uniqueQuestions.length +
                              (shouldShowLoader ? 1 : 0);

                          return RefreshIndicator(
                            edgeOffset:
                                MediaQuery.of(context).padding.top +
                                screenHeight *
                                    0.20 + // same as ListView top padding
                                8,
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
                              primary: false,
                              controller: _scrollController,
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.04,
                                right: screenWidth * 0.04,
                                top: headerHeight,
                                bottom:
                                    contentBottomPadding +
                                    keyboardHeight +
                                    screenHeight * 0.10,
                              ),
                              // itemCount:
                              //     2 + // carousel
                              //     uniqueQuestions.length +
                              //     (shouldShowLoader ? 1 : 0),
                              itemCount:
                                  1 + // search + carousel + filters
                                  uniqueQuestions.length +
                                  (shouldShowLoader ? 1 : 0),
                              itemBuilder: (context, index) {
                                // loader row (pagination)
                                // if (index == 0) {
                                //   return _buildSearchBar(
                                //     screenWidth,
                                //     screenHeight,
                                //   );
                                // }

                                /// map index → question index
                                if (index == 0) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.02,
                                    ),
                                    child: RealtimeImageCarousel(
                                      type: "ama",
                                      height: screenHeight * 0.22,
                                    ),
                                  );
                                }
                                // Adjust actual index for carousel + filter row
                                final int actualIndex = index - 1;

                                // If filtered list is empty → show message
                                if (__filteredQuestions.isEmpty) {
                                  // Only show message at the first "card index"
                                  if (actualIndex == 0) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        top: screenHeight * 0.1,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _activeFilter == "latest"
                                              ? "No latest questions found"
                                              : _activeFilter == "unanswered"
                                              ? "No unanswered questions found"
                                              : "No questions found",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink(); // prevent duplicate messages
                                  }
                                }

                                // 🟡 Pagination loader
                                if (shouldShowLoader &&
                                    actualIndex == uniqueQuestions.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                // 🛡️ Safety
                                if (actualIndex < 0 ||
                                    actualIndex >= uniqueQuestions.length) {
                                  return const SizedBox.shrink();
                                }

                                // Ensure actualIndex is safe for filtered list
                                if (actualIndex >= __filteredQuestions.length) {
                                  return const SizedBox.shrink();
                                }

                                final question =
                                    __filteredQuestions[actualIndex];
                                final questionId = question.id as String;
                                final clientPhone = question.phone as String;
                                final isExpanded = !_collapsedIds.contains(
                                  questionId,
                                );
                                final formattedDate = _formatTimestamp(
                                  question.timestamp as int?,
                                );
                                final showAddAnswerButton =
                                    _canUserAddAnswer() &&
                                    _questionHasNoAnswer(question);
                                _questionKeys.putIfAbsent(
                                  questionId,
                                  () => GlobalKey(),
                                );
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

                                // Inside your ListView.builder, replace the old card Container with this:
                                final bool isHighlighted =
                                    _highlightedQuestionId == questionId;
                                return RepaintBoundary(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),

                                    key: _questionKeys[questionId],
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? const Color.fromRGBO(
                                              210,
                                              159,
                                              42,
                                              0.35,
                                            )
                                          : const Color.fromRGBO(
                                              210,
                                              159,
                                              42,
                                              0.07,
                                            ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isHighlighted
                                              ? Colors.amber.withOpacity(0.8)
                                              : Colors.black.withOpacity(0.33),
                                          blurRadius: isHighlighted ? 25 : 12.5,
                                          spreadRadius: isHighlighted ? 2 : 0,
                                        ),
                                      ],
                                      border: isHighlighted
                                          ? Border.all(
                                              color: Colors.amberAccent,
                                              width: 1.5,
                                            )
                                          : null,
                                    ),

                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// TOP ROW: AVATAR + NAME + TIMESTAMP + ADD ANSWER BUTTON
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            buildAvatar(
                                              question.userName ?? "N/A",
                                              question.profileImgUrl,
                                              screenWidth * 0.035,
                                            ),

                                            SizedBox(width: screenWidth * 0.03),

                                            /// ✅ Username takes all remaining space
                                            Expanded(
                                              child: Text(
                                                question.userName ?? '',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontSize: screenWidth * 0.036,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.0,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            Row(
                                              children: [
                                                if (userRole?.toLowerCase() ==
                                                    "admin") ...[
                                                  SizedBox(
                                                    width: screenWidth * 0.02,
                                                  ),

                                                  Consumer<
                                                    DeleteQuestionProvider
                                                  >(
                                                    builder: (_, deleteProvider, __) {
                                                      final isDeleting =
                                                          deleteProvider
                                                              .isDeleting &&
                                                          deleteProvider
                                                                  .response
                                                                  ?.questionId ==
                                                              question.id;

                                                      return GestureDetector(
                                                        onTap: isDeleting
                                                            ? null
                                                            : () async {
                                                                final confirm =
                                                                    await showDeleteConfirmDialog(
                                                                      context,
                                                                      title:
                                                                          "Delete Question?",
                                                                      message:
                                                                          "This action cannot be undone.",
                                                                    );

                                                                if (!confirm)
                                                                  return;

                                                                final success = await deleteProvider
                                                                    .deleteQuestion(
                                                                      questionId:
                                                                          question
                                                                              .id,
                                                                      role:
                                                                          userRole!,
                                                                    );

                                                                if (success) {
                                                                  context
                                                                      .read<
                                                                        QuestionProvider
                                                                      >()
                                                                      .removeQuestionById(
                                                                        questionId,
                                                                      );
                                                                }
                                                              },
                                                        child: isDeleting
                                                            ? const SizedBox(
                                                                width: 18,
                                                                height: 18,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                color: Colors
                                                                    .redAccent,
                                                                size: 20,
                                                              ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ],
                                            ),
                                            // if (showAddAnswerButton)
                                            //   SizedBox(
                                            //     width: screenWidth * 0.03,
                                            //   ),
                                            // if (showAddAnswerButton)
                                            //   Container(
                                            //     height: screenHeight * 0.035,
                                            //     child: ElevatedButton(
                                            //       onPressed: () {
                                            //         _showAddAnswerDialog(
                                            //           context,
                                            //           questionId,
                                            //           userName!,
                                            //           userRole!,
                                            //           question.phone as String,
                                            //         );
                                            //       },
                                            //       style:
                                            //           ElevatedButton.styleFrom(
                                            //             padding:
                                            //                 EdgeInsets.zero,
                                            //             backgroundColor:
                                            //                 Colors.transparent,
                                            //             elevation: 0,
                                            //             shape: RoundedRectangleBorder(
                                            //               borderRadius:
                                            //                   BorderRadius.circular(
                                            //                     6,
                                            //                   ),
                                            //             ),
                                            //           ).copyWith(
                                            //             backgroundColor:
                                            //                 MaterialStateProperty.all(
                                            //                   Colors
                                            //                       .transparent,
                                            //                 ),
                                            //           ),
                                            //       child: Ink(
                                            //         decoration: BoxDecoration(
                                            //           gradient:
                                            //               const LinearGradient(
                                            //                 begin: Alignment
                                            //                     .centerLeft,
                                            //                 end: Alignment
                                            //                     .centerRight,
                                            //                 colors: [
                                            //                   Color(0xFFD29F2A),
                                            //                   Color(0xFFFFFFFF),
                                            //                 ],
                                            //               ),
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                 6,
                                            //               ),
                                            //         ),
                                            //         child: Container(
                                            //           padding:
                                            //               const EdgeInsets.symmetric(
                                            //                 horizontal: 8,
                                            //                 vertical: 4,
                                            //               ),
                                            //           child: Text(
                                            //             "Answer",
                                            //             style:
                                            //                 GoogleFonts.outfit(
                                            //                   color:
                                            //                       Colors.black,
                                            //                   fontSize:
                                            //                       screenWidth *
                                            //                       0.035,
                                            //                   fontWeight:
                                            //                       FontWeight
                                            //                           .w600,
                                            //                 ),
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                          ],
                                        ),

                                        SizedBox(height: screenHeight * 0.015),

                                        /// QUESTION TEXT
                                        Text(
                                          question.content ?? '',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.040,
                                            fontWeight: FontWeight.w300,
                                            height: 1.25,
                                          ),
                                        ),

                                        SizedBox(height: screenHeight * 0.02),

                                        /// ANSWER LAYOUT (IF ANSWER EXISTS)
                                        if (question.answer != null)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFC1A460),
                                              ),
                                            ),
                                            padding: EdgeInsets.all(
                                              screenWidth * 0.035,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Expert Remark + Green Dot
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical:
                                                                screenHeight *
                                                                0.005,
                                                            horizontal:
                                                                screenWidth *
                                                                0.025,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            const Color.fromRGBO(
                                                              243,
                                                              186,
                                                              54,
                                                              0.4,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Expert Remark",
                                                        style:
                                                            GoogleFonts.outfit(
                                                              color:
                                                                  const Color(
                                                                    0xFF2D2319,
                                                                  ),
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              height: 1.0,
                                                            ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: screenWidth * 0.03,
                                                      height:
                                                          screenWidth * 0.03,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Color(
                                                              0xFF04C527,
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(
                                                  height: screenHeight * 0.015,
                                                ),

                                                // Answer Content
                                                buildLinkText(
                                                  question.answer!.content ??
                                                      '',
                                                  normalStyle:
                                                      GoogleFonts.outfit(
                                                        color: const Color(
                                                          0xFF2D2319,
                                                        ),
                                                        fontSize:
                                                            screenWidth * 0.035,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.25,
                                                      ),
                                                ),

                                                SizedBox(
                                                  height: screenHeight * 0.015,
                                                ),

                                                // Answer by Icon + Text
                                                Row(
                                                  children: [
                                                    question?.answer?.role ==
                                                            "legal_expert"
                                                        ? Consumer<
                                                            ProfileProvider
                                                          >(
                                                            builder:
                                                                (
                                                                  context,
                                                                  profileProv,
                                                                  _,
                                                                ) {
                                                                  return CircleAvatar(
                                                                    radius:
                                                                        screenWidth *
                                                                        0.035,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade300,
                                                                    backgroundImage:
                                                                        profileProv.hasProfilePhoto &&
                                                                            profileProv.profilePhotoUrl !=
                                                                                null
                                                                        ? NetworkImage(
                                                                            "${profileProv.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                                                                          )
                                                                        : const AssetImage(
                                                                                AppAssets.userIcon,
                                                                              )
                                                                              as ImageProvider,
                                                                  );
                                                                },
                                                          )
                                                        : Image.asset(
                                                            AppAssets.appIcon,
                                                            width:
                                                                screenWidth *
                                                                0.08,
                                                            height:
                                                                screenWidth *
                                                                0.08,
                                                          ),
                                                    SizedBox(
                                                      width:
                                                          screenWidth * 0.025,
                                                    ),
                                                    Text(
                                                      question
                                                          ?.answer
                                                          ?.answeredBy,
                                                      style: GoogleFonts.outfit(
                                                        color: const Color(
                                                          0xFF2D2319,
                                                        ),
                                                        fontSize:
                                                            screenWidth * 0.035,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                        SizedBox(height: screenHeight * 0.015),

                                        /// COMMENT LAYOUT (Tappable)
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     // final commentProvider = context
                                        //     //     .read<CommentProvider>();
                                        //     // showAskDoubtBottomSheet(
                                        //     //   context,
                                        //     //   commentProvider,
                                        //     //   "dark",
                                        //     //   questionId,
                                        //     //   userName,
                                        //     //   userRole,
                                        //     //   userPhone,
                                        //     //   profilImgUrl,
                                        //     //   question,
                                        //     // );

                                        //     final commentProvider = context
                                        //         .read<CommentProvider>();

                                        //     if (_openedCommentQuestionId !=
                                        //         questionId) {
                                        //       commentProvider
                                        //           .clearExistingComments();
                                        //       commentProvider.fetchComments(
                                        //         questionId,
                                        //         reset: true,
                                        //       );
                                        //     }

                                        //     toggleComments(questionId);

                                        //     scrollToQuestion(questionId);
                                        //   },
                                        //   child: Container(
                                        //     height: screenHeight * 0.045,

                                        //     padding: EdgeInsets.symmetric(
                                        //       horizontal: screenWidth * 0.04,
                                        //       vertical: screenHeight * 0.01,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: const Color.fromRGBO(
                                        //         210,
                                        //         159,
                                        //         42,
                                        //         0.08,
                                        //       ),
                                        //       borderRadius:
                                        //           BorderRadius.circular(22),
                                        //       boxShadow: [
                                        //         BoxShadow(
                                        //           color: Colors.black
                                        //               .withOpacity(0.33),
                                        //           blurRadius: 12.5,
                                        //         ),
                                        //       ],
                                        //     ),
                                        //     child: Row(
                                        //       mainAxisSize: MainAxisSize.min,
                                        //       children: [
                                        //         Image.asset(
                                        //           AppAssets.cmmIcon,
                                        //           width: screenWidth * 0.05,
                                        //           height: screenWidth * 0.05,
                                        //         ),
                                        //         SizedBox(
                                        //           width: screenWidth * 0.025,
                                        //         ),
                                        //         Text(
                                        //           "${question.commentsCount ?? 0}",
                                        //           style: GoogleFonts.outfit(
                                        //             color: Colors.white,
                                        //             fontSize:
                                        //                 screenWidth * 0.037,
                                        //             fontWeight: FontWeight.w400,
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // ),
                                        GestureDetector(
                                          onTap: () {
                                            final commentProvider = context
                                                .read<CommentProvider>();

                                            if (_openedCommentQuestionId !=
                                                questionId) {
                                              commentProvider
                                                  .clearExistingComments();
                                              commentProvider.fetchComments(
                                                questionId,
                                                reset: true,
                                              );
                                            }

                                            toggleComments(questionId);
                                            scrollToQuestion(questionId);
                                          },
                                          child: Container(
                                            width: double
                                                .infinity, // full width row
                                            child: Row(
                                              children: [
                                                /// 🔘 COMMENT BUTTON (ONLY ONCE — NO NESTING)
                                                if (_openedCommentQuestionId !=
                                                    questionId)
                                                  GestureDetector(
                                                    onTap: () {
                                                      final commentProvider =
                                                          context
                                                              .read<
                                                                CommentProvider
                                                              >();

                                                      if (_openedCommentQuestionId !=
                                                          questionId) {
                                                        commentProvider
                                                            .clearExistingComments();
                                                        commentProvider
                                                            .fetchComments(
                                                              questionId,
                                                              reset: true,
                                                            );
                                                      }

                                                      toggleComments(
                                                        questionId,
                                                      );
                                                      scrollToQuestion(
                                                        questionId,
                                                      );
                                                    },
                                                    child: Container(
                                                      height:
                                                          screenHeight * 0.045,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal:
                                                                screenWidth *
                                                                0.04,
                                                            vertical:
                                                                screenHeight *
                                                                0.01,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            const Color.fromRGBO(
                                                              210,
                                                              159,
                                                              42,
                                                              0.08,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              22,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.33,
                                                                ),
                                                            blurRadius: 12.5,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize
                                                            .min, // 🔥 IMPORTANT
                                                        children: [
                                                          Image.asset(
                                                            AppAssets.cmmIcon,
                                                            width:
                                                                screenWidth *
                                                                0.05,
                                                            height:
                                                                screenWidth *
                                                                0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                screenWidth *
                                                                0.025,
                                                          ),
                                                          Text(
                                                            "${question.commentsCount ?? 0}",
                                                            style: GoogleFonts.outfit(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.037,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),

                                                /// 🔥 ANSWER BUTTON (AFTER COMMENT)
                                                if (showAddAnswerButton)
                                                  Container(
                                                    height:
                                                        screenHeight * 0.035,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _showAddAnswerDialog(
                                                          context,
                                                          questionId,
                                                          userName!,
                                                          userRole!,
                                                          question.phone
                                                              as String,
                                                        );
                                                      },
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.zero,
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
                                                          gradient:
                                                              const LinearGradient(
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
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                /// 🔥 SPACE PUSH
                                                const Spacer(),

                                                /// ⏱ TIME (RIGHT SIDE)
                                                Text(
                                                  timeAgo(question.timestamp),
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        if (_openedCommentQuestionId ==
                                            questionId)
                                          InlineCommentsSection(
                                            questionId: questionId,
                                            userName: userName,
                                            userRole: userRole,
                                            userPhone: clientPhone,
                                            profileImgUrl: profilImgUrl,
                                            tappedCommentId:
                                                widget.tappedCommentId,
                                            onClose: () {
                                              setState(() {
                                                _openedCommentQuestionId = null;
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,

                child: RepaintBoundary(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 8,
                          // left: screenWidth * 0.04,
                          right: screenWidth * 0.04,
                          bottom: 0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171717).withOpacity(0.45),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // BACK BUTTON
                                IconButton(
                                  padding:
                                      EdgeInsets.zero, // remove default padding

                                  icon: Image.asset(
                                    AppAssets.backArrowIcon,
                                    width: screenWidth * 0.06,
                                    height: screenWidth * 0.06,
                                    fit: BoxFit.contain,
                                  ),
                                  onPressed: () => context.go(
                                    AppPathsForScreen.userHomePath,
                                  ),
                                  splashRadius:
                                      24, // optional, makes tap area bigger
                                ),
                                // SizedBox(width: screenWidth * 0.05),
                                // TITLE (NOT CENTERED BY EXPANDED)
                                Text(
                                  "AMA",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.052,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),

                                const Spacer(),

                                // ASK QUESTION BUTTON
                                _AskQuestionButton(
                                  scaleFactor: scaleFactor,
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
                                            context.goNamed(
                                              AppScreenNames.logIn,
                                            );
                                          },
                                        ),
                                      );
                                      return;
                                    }

                                    context.pushNamed(
                                      AppScreenNames.raiseQuery,
                                      queryParameters: {
                                        "isQuestionPosting": "true",
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //     left: screenWidth * 0.035,
                            //   ),
                            //   child: _buildSearchBar(screenWidth, screenHeight),
                            // ),

                            // SizedBox(height: screenHeight * 0.03),
                            Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.035,
                              ),
                              child: buildFilters(screenWidth, screenHeight),
                            ),
                            // SUBTITLE
                          ],
                        ),
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
        ),
      ),
    );
  }
}

class InlineCommentsSection extends StatefulWidget {
  final String questionId;
  final String? userName;
  final String? userRole;
  final String? userPhone;
  final String? profileImgUrl;
  final VoidCallback onClose;
  final bool isLight;
  final String? tappedCommentId;

  const InlineCommentsSection({
    Key? key,
    required this.questionId,
    required this.onClose,
    this.userName,
    this.userRole,
    this.userPhone,
    this.profileImgUrl,
    this.isLight = false,
    this.tappedCommentId,
  }) : super(key: key);

  @override
  State<InlineCommentsSection> createState() => _InlineCommentsSectionState();
}

class _InlineCommentsSectionState extends State<InlineCommentsSection> {
  final Map<String, GlobalKey> _commentKeys = {};
  String? _highlightedCommentId;
  Timer? _highlightTimer;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;

        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<CommentProvider>();

        // Wait until comments are loaded
        if (widget.tappedCommentId != null) {
          await Future.delayed(const Duration(milliseconds: 600));
          _scrollToAndHighlightComment(widget.tappedCommentId!);
        }
      });
    });
  }

  void _scrollToAndHighlightComment(String commentId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _commentKeys[commentId];
      final ctx = key?.currentContext;

      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );

        setState(() => _highlightedCommentId = commentId);

        _highlightTimer?.cancel();
        _highlightTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _highlightedCommentId = null);
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _scrollToAndHighlightComment(commentId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<CommentProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),

            /// Divider
            // Container(
            //   width: double.infinity,
            //   height: 1,
            //   color: const Color(0xFF595959),
            // ),
            SizedBox(height: screenHeight * 0.015),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1), // ✅ background applied
                borderRadius: BorderRadius.circular(15), // ✅ 15px radius
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "${provider.comments.length} Comments",
                        style: GoogleFonts.outfit(
                          color: Color(0xFF2D2319),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.03),

                      /// 🔥 DASH LINE (responsive)
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C4C4C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.02),

                      /// 🔽 DOWN ARROW (instead of close)
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Icon(
                          Icons
                              .keyboard_arrow_down, // looks better than down for collapse
                          color: Color(0xFF2D2319),
                          size: screenWidth * 0.09,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  /// COMMENTS LIST
                  if (provider.isLoading && provider.comments.isEmpty)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2D2319),
                      ),
                    )
                  else if (provider.comments.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No comments yet",
                        style: TextStyle(color: Color(0xFF2D2319)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.comments.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          height: 1.5,
                          color: widget.isLight
                              ? const Color(0xFF2D2319)
                              : const Color(0xFF262626), // ✅ updated
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final c = provider.comments[index];
                        final isHighlighted = _highlightedCommentId == c.id;

                        final bool isExpert =
                            (c.userRole?.toLowerCase() != "user" &&
                            c.userRole?.toLowerCase() != "client");
                        final bool isLegalExpert =
                            c.userRole?.toLowerCase() == "legal_expert";
                        final commentId = c.id!;
                        _commentKeys.putIfAbsent(commentId, () => GlobalKey());
                        return AnimatedContainer(
                          key: _commentKeys[commentId],

                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? const Color.fromRGBO(210, 159, 42, 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isHighlighted
                                ? [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.7),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                            border: isHighlighted
                                ? Border.all(
                                    color: Colors.amberAccent,
                                    width: 1.2,
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  buildAvatar(
                                    c.commentedBy,
                                    c.profileImgUrl,
                                    screenWidth * 0.035,
                                    isLight: widget.isLight,
                                    usingInComment: true,
                                  ),

                                  SizedBox(width: screenWidth * 0.03),

                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            c.commentedBy ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              color: Color(0xFF635547),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),

                                        if (isExpert) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: widget.isLight
                                                  ? const Color(0xFF2D2319)
                                                  : const Color.fromRGBO(
                                                      255,
                                                      219,
                                                      137,
                                                      0.64,
                                                    ),
                                            ),
                                            child: Text(
                                              isLegalExpert == true
                                                  ? "Legal Expert"
                                                  : "Expert",
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                color: widget.isLight
                                                    ? Colors.white
                                                    : isLegalExpert == true
                                                    ? Colors.white
                                                    : const Color(0xFF2D2319),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.03),
                                        ],
                                      ],
                                    ),
                                  ),

                                  Text(
                                    timeAgo(c.timestamp ?? 1),
                                    style: GoogleFonts.outfit(
                                      color: Color(0xFF2D2319),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (widget.userRole?.toLowerCase() == "admin")
                                    Consumer<DeleteCommentProvider>(
                                      builder: (_, deleteProvider, __) {
                                        final isDeleting =
                                            deleteProvider.isDeleting &&
                                            deleteProvider
                                                    .response
                                                    ?.commentId ==
                                                c.id;

                                        return GestureDetector(
                                          onTap: isDeleting
                                              ? null
                                              : () async {
                                                  final confirm =
                                                      await showDeleteConfirmDialog(
                                                        context,
                                                        title:
                                                            "Delete Comment?",
                                                        message:
                                                            "This comment will be permanently removed.",
                                                      );

                                                  if (!confirm) return;

                                                  final success =
                                                      await deleteProvider
                                                          .deleteComment(
                                                            questionId: widget
                                                                .questionId,
                                                            commentId: c.id!,
                                                            role: widget
                                                                .userRole!,
                                                          );

                                                  if (success) {
                                                    /// ✅ deletes ONLY selected comment
                                                    provider
                                                        .removeCommentLocally(
                                                          c.id!,
                                                        );
                                                  }
                                                },
                                          child: isDeleting
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : Icon(
                                                  Icons.delete_outline,
                                                  color: widget.isLight
                                                      ? Colors.black
                                                      : Colors.redAccent,
                                                  size: 18,
                                                ),
                                        );
                                      },
                                    ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.01),

                              Text(
                                c.content ?? "",
                                style: GoogleFonts.outfit(
                                  color: Color(0xFF2D2319),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  SizedBox(height: screenHeight * 0.015),

                  /// INPUT BAR
                  if (widget.userRole?.toLowerCase() != "guest")
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF323232),
                        borderRadius: BorderRadius.circular(33),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: provider.commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Write a comment...",
                                hintStyle: TextStyle(color: Colors.white54),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) async {
                                final success = await provider.postComment(
                                  context: context,
                                  questionId: widget.questionId,
                                  content: provider.commentController.text
                                      .trim(),
                                  commentedBy: widget.userName ?? "",
                                  userRole: widget.userRole ?? "",
                                  phone: widget.userPhone ?? "",
                                  profileImgUrl: widget.profileImgUrl ?? "",
                                );
                                if (success) {
                                  provider.commentController.clear();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: provider.isSending
                                ? null
                                : () async {
                                    final success = await provider.postComment(
                                      context: context,
                                      questionId: widget.questionId,
                                      content: provider.commentController.text
                                          .trim(),
                                      commentedBy: widget.userName ?? "",
                                      userRole: widget.userRole ?? "",
                                      phone: widget.userPhone ?? "",
                                      profileImgUrl: widget.profileImgUrl ?? "",
                                    );
                                    if (success) {
                                      provider.commentController.clear();
                                    }
                                  },
                            icon: provider.isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            /// HEADER

            // SizedBox(height: screenHeight * 0.02),
          ],
        );
      },
    );
  }
}

Widget buildAvatar(
  String? name,
  String? imageUrl,
  double size, {
  bool isLight = false,
  bool usingInComment = false,
}) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CircleAvatar(
      radius: size,
      backgroundImage: NetworkImage(
        "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}",
      ),
    );
  }

  /// 🔥 INITIALS LOGIC
  String initials = "";
  if (name != null && name.trim().isNotEmpty) {
    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      initials = parts[0][0];
    } else {
      initials = parts[0][0] + parts[1][0];
    }
  }

  return Container(
    width: size * 2,
    height: size * 2,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFD29F2A)),
      color: const Color.fromRGBO(210, 159, 42, 0.16),
    ),
    child: Text(
      initials.toUpperCase(),
      style: GoogleFonts.outfit(
        color: usingInComment
            ? Color(0xFF2D2319)
            : isLight
            ? Color(0xFF2D2319)
            : Color(0xFFFFFFFF),
        fontSize: size * 0.8,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
