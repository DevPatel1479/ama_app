import 'dart:async';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/resolve_query_bottom_sheet.dart';
import 'package:ama_legal_solutions/custom_widgets/shimmer_widget.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/query_model.dart';
import 'package:ama_legal_solutions/provider/client/remarks_provider.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';

import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

String formatTimestamp(int ts) {
  // if ts looks like milliseconds already (> 1e12), use it, otherwise treat as seconds
  final millis = (ts > 1000000000000) ? ts : ts * 1000;
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
}

class DarkCasedeskScreen extends StatefulWidget {
  const DarkCasedeskScreen({super.key});

  @override
  State<DarkCasedeskScreen> createState() => _DarkCasedeskScreenState();
}

class _DarkCasedeskScreenState extends State<DarkCasedeskScreen> {
  bool isMyCaseActive = true;
  bool isPendingActive = true; // secondary toggle
  late ScrollController _scrollController;
  bool isFetchingMore = false;
  bool _userScrolled = false;
  String? userRole;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _queriesSubscription;
  String? _role;
  String? _phone;
  bool isExpanded = false;
  // Example list of bank details
  final List<Map<String, dynamic>> bankDetails = [
    {
      "bankName": "HDFC Bank",
      "accountNumber": "1111 2222 3333 4444",
      "type": "Credit Card",
      "typeColor": Color(0xFF337EFF),
      "amount": "\$211111",
      "amountColor": Color(0xFFFF5858),
    },
    {
      "bankName": "HDFC Bank",
      "accountNumber": "5555 6666 7777 8888",
      "type": "Personal Loan",
      "typeColor": Color(0xFF008C38),
      "amount": "\$500000",
      "amountColor": Color(0xFFFF5858),
    },
  ];
  String? _lastRole;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchUserRole();
    Future.microtask(() async {
      final provider = Provider.of<QueryProvider>(context, listen: false);
      // final role = await LocalStorageHelper.getString("userRole");
      // final phone = await LocalStorageHelper.getString("userPhone");

      if (_role != null && _phone != null) {
        provider.fetchQueries(
          context: context,
          role: _role ?? "",
          phone: _phone ?? "",
          status: isPendingActive ? 'pending' : 'resolved',
        );
        // attach realtime listener only if My Case active
        if (isMyCaseActive) {
          _attachFirestoreListener(
            context,
            _role ?? "",
            _phone ?? "",
            isMyCaseActive,
          );
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRole = context.watch<RealTimeRoleProvider>().role;

    // Only refetch if role has actually changed
    if (newRole != null && newRole != _lastRole) {
      _lastRole = newRole;
      _onRoleChanged(newRole);
    }
  }

  Future<void> _onRoleChanged(String newRole) async {
    print("🔄 Role changed to $newRole — refetching queries...");

    final provider = Provider.of<QueryProvider>(context, listen: false);

    // Keep local variables in sync with provider
    _role = newRole;
    setState(() {
      userRole = newRole;
    });

    // detach old listener first, clear caches, reset scroll state
    await _detachFirestoreListener();
    provider.clearAllCaches(); // keep your provider clearing logic

    // reset local pagination flags so scroll listener will work correctly
    _userScrolled = false;
    if (_scrollController.hasClients) {
      // move back to top safely
      _scrollController.jumpTo(0);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      });
    }

    final phone = await LocalStorageHelper.getString("userPhone");
    if (phone != null) {
      _phone = phone; // keep local phone in sync too

      await provider.fetchQueries(
        context: context,
        role: newRole,
        phone: phone,
        status: isPendingActive ? 'pending' : 'resolved',
        reset: true,
      );

      // attach a listener for the new role/phone
      _attachFirestoreListener(context, newRole, phone, isMyCaseActive);
    }
  }

  Future<void> fetchUserRole() async {
    _role = await LocalStorageHelper.getString("userRole");
    _phone = await LocalStorageHelper.getString("userPhone");
    setState(() {
      userRole = _role;
    });
    if (_phone != null) {
      // Use existing RemarksProvider. Its fetchRemarks signature used Endpoints internally,
      // it previously accepted a baseUrl param — pass empty string because provider uses Endpoints.
      final remarksProv = Provider.of<RemarksProvider>(context, listen: false);
      await remarksProv.fetchRemarks("", _phone!);
    }
  }

  // Attach Firestore realtime listener for document: queries/<role>_<phone>

  void _attachFirestoreListener(
    BuildContext context,
    String role,
    String phone,
    bool isMyCaseActive,
  ) {
    // always reattach only if no subscription present
    if (_queriesSubscription != null) return;

    final queryProvider = Provider.of<QueryProvider>(context, listen: false);

    // Prefer scoped listener if your documents have a user identifier:
    // final subcollectionRef = FirebaseFirestore.instance
    //     .collection('allQueries')
    //     .where('user_id', isEqualTo: '${role}_$phone');

    final subcollectionRef = FirebaseFirestore.instance.collection(
      'allQueries',
    );

    _queriesSubscription = subcollectionRef.snapshots().listen(
      (snapshot) {
        if (!mounted || !isMyCaseActive) return;

        for (final change in snapshot.docChanges) {
          final doc = change.doc;
          final raw = doc.data();
          if (raw == null) continue;

          // --- FILTER out docs not belonging to this user (important) ---
          // Try several common field names; adjust to your DB shape.
          final docPhone =
              (raw['phone'] ??
                      raw['userPhone'] ??
                      (raw['user_id'] is String
                          ? (raw['user_id'] as String).split('_').last
                          : null))
                  ?.toString();

          final docRole = (raw['role'] ?? raw['user_role'] ?? null)?.toString();

          if (docPhone == null) {
            // if there is no phone field, optionally skip — safer to skip
            continue;
          }

          if (docPhone != phone) continue;
          if (docRole != null && docRole != role) continue;

          // Build map and normalize
          final Map<String, dynamic> map = Map<String, dynamic>.from(
            raw as Map<String, dynamic>,
          );
          map['id'] = doc.id;

          final submittedRaw = map['submitted_at'] ?? map['submittedAt'];
          if (submittedRaw is int) {
            map['submitted_at'] = submittedRaw;
          } else if (submittedRaw is String) {
            map['submitted_at'] = int.tryParse(submittedRaw) ?? 0;
          } else if (submittedRaw is Map &&
              submittedRaw.containsKey('_seconds')) {
            map['submitted_at'] = (submittedRaw['_seconds'] is int)
                ? submittedRaw['_seconds']
                : int.tryParse(submittedRaw['_seconds'].toString()) ?? 0;
          }

          final qm = QueryModel.fromJson(map);

          if (change.type == DocumentChangeType.added ||
              change.type == DocumentChangeType.modified) {
            queryProvider.upsertQueryInCache(qm);
          } else if (change.type == DocumentChangeType.removed) {
            queryProvider.removeQueryById(doc.id);
          }
        }
      },
      onError: (err) {
        print('Firestore listener error: $err');
      },
    );
  }

  /// Call this in dispose() to clean up
  Future<void> _detachFirestoreListener() async {
    await _queriesSubscription?.cancel();
    _queriesSubscription = null;
  }

  void _scrollListener() async {
    final provider = Provider.of<QueryProvider>(context, listen: false);

    // mark that user has interacted by scrolling
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      _userScrolled = true;
    }

    // only trigger if:
    // - user has scrolled at least once (to mimic modern apps)
    // - there is some content left to scroll (extentAfter)
    // - provider reports there is a next page
    // - no fetch already in progress
    final shouldTrigger =
        _userScrolled &&
        _scrollController.position.extentAfter < 300 &&
        provider.nextPageCursor != null &&
        !provider.isFetchingMore;

    if (shouldTrigger) {
      provider.isFetchingMore = true; // will notify listeners and show loader
      final role = _role;
      final phone = _phone;

      if (role != null && phone != null) {
        await provider.fetchQueries(
          context: context,
          role: role,
          phone: phone,
          lastDocId: provider.nextPageCursor,
          append: true,
          status: isPendingActive ? 'pending' : 'resolved',
        );
      }
      provider.isFetchingMore = false; // hide loader
    }
  }

  // Helper when user toggles between My Case and Bank Details.
  // Make sure listener is only active for My Case.
  Future<void> _onToggleMyCase(bool value) async {
    setState(() => isMyCaseActive = value);

    if (isMyCaseActive) {
      // attach listener
      final role = _role;
      final phone = _phone;
      if (role != null && phone != null) {
        _attachFirestoreListener(context, role, phone, isMyCaseActive);
      }
    } else {
      // detach listener when leaving My Case
      await _detachFirestoreListener();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _detachFirestoreListener();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     final userInfoProvider = Provider.of<UserInfoProvider>(
  //       context,
  //       listen: false,
  //     );

  //     if (userInfoProvider.userInfo == null) {
  //       userInfoProvider.fetchUserInfo(context, true);
  //     }
  //     // Provider.of<UserInfoProvider>(
  //     //   context,
  //     //   listen: false,
  //     // ).fetchUserInfo(context, true);
  //   });
  // }
  Widget buildTimelineStep({
    required String remarks,
    required String dateTime,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final double dotSize = 12;
    final double lineWidth = 2;
    final double segmentHeight = 6;
    final double segmentGap = 4;
    final int segmentCount = 4;

    List<Widget> buildBrokenLine() {
      return List.generate(segmentCount, (index) {
        return Container(
          width: lineWidth,
          height: segmentHeight,
          margin: EdgeInsets.only(top: segmentGap),
          color: Color(0xFF04C527),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP ROW → DOT + REMARKS + DATE/TIME
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // DOT
            Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(
                color: Color(0xFFD29F2A),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            // REMARKS + DATE/TIME TOGETHER
            Flexible(
              child: Row(
                children: [
                  // REMARKS (flexible)
                  Flexible(
                    child: Text(
                      remarks,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // DATE + TIME (inline next to remarks)
                  Text(
                    dateTime,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // BROKEN LINE UNDER DOT — CONNECTED PERFECTLY
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: dotSize / 2 - lineWidth / 2),
            child: Column(children: buildBrokenLine()),
          ),
      ],
    );
  }

  Future<void> openCaseStatusSheet(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final phone = await LocalStorageHelper.getString("userPhone");
    if (phone != null) {
      final remarksProv = Provider.of<RemarksProvider>(context, listen: false);
      // fetch latest; backend returns reversed list (newest first)
      await remarksProv.fetchRemarks("", phone);
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
        final isDark = themeProvider.isDarkMode;

        return SizedBox(
          height: size.height * 0.80,
          width: size.width,
          child: Container(
            width: size.width,
            height: size.height * 0.80,

            /// ⭐ BACKGROUND CHANGES BASED ON THEME
            color: isDark ? const Color(0xFF2D2319) : Colors.white,

            child: Column(
              children: [
                /// TOP BAR 40px
                SizedBox(
                  height: 40,
                  width: size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// Title
                      Text(
                        "Live Status",
                        style: GoogleFonts.outfit(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD29F2A),
                        ),
                      ),

                      /// Close arrow
                      Positioned(
                        right: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: 0.5,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: isDark ? Colors.white : Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<RemarksProvider>(
                    builder: (context, remarksProv, _) {
                      // Loading skeleton: show shimmer-like placeholders while fetching
                      if (remarksProv.loading && remarksProv.remarks.isEmpty) {
                        return Column(
                          children: List.generate(
                            3,
                            (_) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // Error / no data cases
                      if (remarksProv.errorMessage != null &&
                          remarksProv.remarks.isEmpty) {
                        return Column(
                          children: [
                            SizedBox(height: 24),
                            Text(
                              remarksProv.errorMessage!,
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final phone =
                                    await LocalStorageHelper.getString(
                                      "userPhone",
                                    );
                                if (phone != null) {
                                  await remarksProv.fetchRemarks("", phone);
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Retry"),
                            ),
                          ],
                        );
                      }

                      if (remarksProv.remarks.isEmpty) {
                        // show no case found
                        return Column(
                          children: [
                            SizedBox(height: 24),
                            Text(
                              "No case found",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final phone =
                                    await LocalStorageHelper.getString(
                                      "userPhone",
                                    );
                                if (phone != null) {
                                  await remarksProv.fetchRemarks("", phone);
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Refresh"),
                            ),
                          ],
                        );
                      }

                      // If we have data use RefreshIndicator + ListView
                      return SizedBox(
                        height:
                            size.height * 0.60, // allow sheet to scroll inside
                        child: RefreshIndicator(
                          onRefresh: () async {
                            final phone = await LocalStorageHelper.getString(
                              "userPhone",
                            );
                            if (phone != null) {
                              await remarksProv.fetchRemarks("", phone);
                            }
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: remarksProv.remarks.length,
                            itemBuilder: (context, idx) {
                              final remarkItem = remarksProv.remarks[idx];
                              // provider already has reversed list (newest first)
                              final isLast =
                                  idx == remarksProv.remarks.length - 1;
                              return buildTimelineStep(
                                remarks: remarkItem.remarks,
                                dateTime: formatTimestamp(remarkItem.createdAt),
                                isFirst: idx == 0,
                                isLast: isLast,
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
        statusBarIconBrightness: Brightness.light, // white icons
        statusBarBrightness: Brightness.dark, // iOS: white icons
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // amount of extra space to reserve at bottom so the last item is fully visible
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;
    final role = context.watch<RealTimeRoleProvider>().role;
    userRole = role;
    final remarksProv = context.watch<RemarksProvider>();
    Widget liveStatusContent;

    if (remarksProv.loading) {
      // small loader while fetching the latest remark
      liveStatusContent = SizedBox(
        width: 120,
        height: 16,
        child: LinearProgressIndicator(
          minHeight: 12,
          color: Color(0xFFD29F2A),
          backgroundColor: Colors.white24,
        ),
      );
    } else if (remarksProv.errorMessage != null) {
      liveStatusContent = Text(
        "Error",
        style: GoogleFonts.outfit(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );
    } else if (remarksProv.remarks.isEmpty) {
      liveStatusContent = Text(
        "No case found",
        style: GoogleFonts.outfit(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );
    } else {
      // provider returns reversed list with newest first; use first element's remark
      final latest = remarksProv.remarks.first;
      liveStatusContent = Text(
        latest.remarks,
        style: GoogleFonts.outfit(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04 * scaleFactor,
                          vertical: screenHeight * 0.015 * scaleFactor,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  context.go(AppPathsForScreen.userHomePath),
                              child: Image.asset(
                                AppAssets.backArrowIcon,
                                width: screenWidth * 0.06 * scaleFactor,
                                height: screenWidth * 0.06 * scaleFactor,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02 * scaleFactor),
                            Text(
                              "My Casedesk",
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.065 * scaleFactor,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),

                            if (userRole?.toLowerCase() != "admin" &&
                                userRole?.toLowerCase() != "advocate")
                              SizedBox(
                                width: screenWidth * 0.35 * scaleFactor,
                                height: screenHeight * 0.05 * scaleFactor,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await context.pushNamed(
                                      AppScreenNames.raiseQuery,
                                      // you can pass extra if needed
                                    );

                                    // result could be true when new query created
                                    if (result == true) {
                                      final provider =
                                          Provider.of<QueryProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final role =
                                          await LocalStorageHelper.getString(
                                            "userRole",
                                          );
                                      final phone =
                                          await LocalStorageHelper.getString(
                                            "userPhone",
                                          );
                                      if (role != null && phone != null) {
                                        await provider.fetchQueries(
                                          context: context,
                                          role: role,
                                          phone: phone,
                                          status: isPendingActive
                                              ? 'pending'
                                              : 'resolved',
                                          reset: true,
                                        );
                                      }
                                    }
                                  },
                                  style:
                                      ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            41,
                                          ),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.black.withOpacity(
                                          0.3,
                                        ),
                                        elevation: 6,
                                      ).copyWith(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                              Colors.transparent,
                                            ),
                                      ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment(-1.0, 0.0),
                                        end: Alignment(1.0, 0.0),
                                        colors: [
                                          Color(0xFFD29F2A),
                                          Color(0xFFFFFFFF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(41),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Ask Query",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14 * scaleFactor,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (userRole?.toLowerCase() != "admin" &&
                          userRole?.toLowerCase() != "advocate")
                        SizedBox(height: screenHeight * 0.03 * scaleFactor),
                      if (userRole?.toLowerCase() != "admin" &&
                          userRole?.toLowerCase() != "advocate")
                        // Primary Toggle bar (My Case / Bank Details)
                        Center(
                          child: Container(
                            width: screenWidth * 0.8 * scaleFactor,
                            height: screenHeight * 0.06 * scaleFactor,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _onToggleMyCase(true),
                                    child: Container(
                                      margin: EdgeInsets.all(
                                        screenWidth * 0.01 * scaleFactor,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMyCaseActive
                                            ? const Color(0xFFD29F2A)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "My Case",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.04 * scaleFactor,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _onToggleMyCase(false);

                                      if (provider.userInfo != null) return;
                                      provider.fetchUserInfo(context, true);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(
                                        screenWidth * 0.01 * scaleFactor,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !isMyCaseActive
                                            ? const Color(0xFFD29F2A)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Bank Details",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.04 * scaleFactor,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (userRole?.toLowerCase() != "admin" &&
                          userRole?.toLowerCase() != "advocate") ...[
                        SizedBox(height: screenHeight * 0.025 * scaleFactor),

                        GestureDetector(
                          onTap: () async {
                            setState(() => isExpanded = true);
                            await openCaseStatusSheet(
                              context,
                            ); // wait until closed
                            setState(
                              () => isExpanded = false,
                            ); // reset icon when sheet closes
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2D2319),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Live Status: ",
                                      style: GoogleFonts.outfit(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.045,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFD29F2A),
                                      ),
                                    ),
                                    liveStatusContent,
                                  ],
                                ),
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 250),
                                  turns: isExpanded ? 0.5 : 0,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: screenHeight * 0.025 * scaleFactor),

                      // Secondary toggle row (Pending / Resolved) only for My Case
                      if (isMyCaseActive)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.15 * scaleFactor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Pending
                              GestureDetector(
                                onTap: () async {
                                  if (isPendingActive) return; // already active
                                  setState(() => isPendingActive = true);

                                  // reset scroll to top and pagination flags
                                  if (_scrollController.hasClients) {
                                    _scrollController.jumpTo(0);
                                  } else {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (_scrollController.hasClients) {
                                            _scrollController.jumpTo(0);
                                          }
                                        });
                                  }
                                  _userScrolled = false;

                                  final provider = Provider.of<QueryProvider>(
                                    context,
                                    listen: false,
                                  );
                                  final role =
                                      await LocalStorageHelper.getString(
                                        "userRole",
                                      );
                                  final phone =
                                      await LocalStorageHelper.getString(
                                        "userPhone",
                                      );
                                  if (role != null && phone != null) {
                                    // Replace list with first page of pending
                                    await provider.fetchQueries(
                                      context: context,
                                      role: role,
                                      phone: phone,
                                      status: 'pending',
                                      // reset: false (default) -> replace provider cache for that status
                                    );
                                  }
                                },

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.02 * scaleFactor,
                                      ),
                                      child: Text(
                                        "Pending",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.04 * scaleFactor,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6 * scaleFactor),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.03 * scaleFactor,
                                      ), // adjust as needed
                                      child: Container(
                                        width: screenWidth * 0.15 * scaleFactor,
                                        height: 2 * scaleFactor,
                                        color: isPendingActive
                                            ? const Color(0xFFD29F2A)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Resolved
                              GestureDetector(
                                onTap: () async {
                                  if (!isPendingActive)
                                    return; // already resolved
                                  setState(() => isPendingActive = false);

                                  // reset scroll to top and pagination flags
                                  if (_scrollController.hasClients) {
                                    _scrollController.jumpTo(0);
                                  } else {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (_scrollController.hasClients) {
                                            _scrollController.jumpTo(0);
                                          }
                                        });
                                  }
                                  _userScrolled = false;

                                  final provider = Provider.of<QueryProvider>(
                                    context,
                                    listen: false,
                                  );
                                  final role =
                                      await LocalStorageHelper.getString(
                                        "userRole",
                                      );
                                  final phone =
                                      await LocalStorageHelper.getString(
                                        "userPhone",
                                      );
                                  if (role != null && phone != null) {
                                    // Replace list with first page of resolved
                                    await provider.fetchQueries(
                                      context: context,
                                      role: role,
                                      phone: phone,
                                      status: 'resolved',
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: screenWidth * 0.02 * scaleFactor,
                                      ),
                                      child: Text(
                                        "Resolved",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.04 * scaleFactor,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6 * scaleFactor),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: screenWidth * 0.01 * scaleFactor,
                                      ),
                                      child: Container(
                                        width: screenWidth * 0.15 * scaleFactor,
                                        height: 2 * scaleFactor,
                                        color: !isPendingActive
                                            ? const Color(0xFFD29F2A)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: screenHeight * 0.03 * scaleFactor),

                      // Content Section - scrollable
                      Expanded(
                        child: isMyCaseActive
                            ? Consumer<QueryProvider>(
                                builder: (context, provider, _) {
                                  if (provider.isLoading &&
                                      provider.queries.isEmpty) {
                                    // Initial loading
                                    return ListView.builder(
                                      padding:
                                          EdgeInsets.symmetric(
                                            horizontal:
                                                screenWidth *
                                                0.04 *
                                                scaleFactor,
                                            vertical:
                                                screenHeight *
                                                0.015 *
                                                scaleFactor,
                                          ).copyWith(
                                            // ensure the scrollable content has extra bottom padding equal
                                            // to the visible nav footprint so last items can scroll above it
                                            bottom: contentBottomPadding,
                                          ),
                                      itemCount: 3,
                                      itemBuilder: (context, index) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              screenHeight * 0.02 * scaleFactor,
                                        ),
                                        child: const ShimmerBankCard(),
                                      ),
                                    );
                                  }

                                  // // Filter by Pending / Resolved
                                  // final filteredQueries = provider.queries
                                  //     .where(
                                  //       (q) => isPendingActive
                                  //           ? q.status == 'pending'
                                  //           : q.status == 'resolved',
                                  //     )
                                  //     .toList();

                                  // // Sort by submitted_at descending
                                  // filteredQueries.sort(
                                  //   (a, b) =>
                                  //       b.submittedAt.compareTo(a.submittedAt),
                                  // );
                                  final activeQueries = provider.queries;
                                  activeQueries.sort(
                                    (a, b) =>
                                        b.submittedAt.compareTo(a.submittedAt),
                                  );
                                  if (provider.isLoading) {
                                    // Show shimmer placeholders while switching between tabs
                                    return ListView.builder(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            screenWidth * 0.04 * scaleFactor,
                                        vertical:
                                            screenHeight * 0.015 * scaleFactor,
                                      ).copyWith(bottom: contentBottomPadding),
                                      itemCount: 3,
                                      itemBuilder: (context, index) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              screenHeight * 0.02 * scaleFactor,
                                        ),
                                        child: const ShimmerBankCard(),
                                      ),
                                    );
                                  }
                                  if (activeQueries.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No queries found",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.045 * scaleFactor,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                  final hasMoreData =
                                      provider.nextPageCursor != null;
                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      final role =
                                          await LocalStorageHelper.getString(
                                            "userRole",
                                          );
                                      final phone =
                                          await LocalStorageHelper.getString(
                                            "userPhone",
                                          );
                                      await provider.fetchQueries(
                                        context: context,
                                        role: role!,
                                        phone: phone!,
                                        status: isPendingActive
                                            ? 'pending'
                                            : 'resolved',
                                        // default behavior replaces the active status cache (do not use reset:true here)
                                      );
                                    },
                                    child: ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      controller: _scrollController,
                                      // padding: EdgeInsets.symmetric(
                                      //   horizontal:
                                      //       screenWidth * 0.05 * scaleFactor,
                                      // ),
                                      padding:
                                          EdgeInsets.symmetric(
                                            horizontal:
                                                screenWidth *
                                                0.04 *
                                                scaleFactor,
                                            vertical:
                                                screenHeight *
                                                0.015 *
                                                scaleFactor,
                                          ).copyWith(
                                            // ensure the scrollable content has extra bottom padding equal
                                            // to the visible nav footprint so last items can scroll above it
                                            bottom: contentBottomPadding,
                                          ),
                                      itemCount: hasMoreData
                                          ? activeQueries.length + 1
                                          : activeQueries.length,
                                      itemBuilder: (context, index) {
                                        if (index < activeQueries.length) {
                                          final query = activeQueries[index];
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  screenHeight *
                                                  0.02 *
                                                  scaleFactor,
                                            ),
                                            child: QueryCard(
                                              query: query,
                                              userRole: userRole,
                                            ),
                                          );
                                        } else {
                                          // only visible if pagination is happening
                                          return provider.isFetchingMore
                                              ? Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        screenHeight *
                                                        0.02 *
                                                        scaleFactor,
                                                  ),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.orange,
                                                        ),
                                                  ),
                                                )
                                              : const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  );
                                },
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await provider.fetchUserInfo(context, true);
                                },
                                child: provider.isLoading
                                    ? ListView.builder(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  screenWidth *
                                                  0.04 *
                                                  scaleFactor,
                                              vertical:
                                                  screenHeight *
                                                  0.015 *
                                                  scaleFactor,
                                            ).copyWith(
                                              // ensure the scrollable content has extra bottom padding equal
                                              // to the visible nav footprint so last items can scroll above it
                                              bottom: contentBottomPadding,
                                            ),
                                        itemCount:
                                            3, // show 3 shimmer cards while loading
                                        itemBuilder: (context, index) =>
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    screenHeight *
                                                    0.02 *
                                                    scaleFactor,
                                              ),
                                              child: const ShimmerBankCard(),
                                            ),
                                      )
                                    : (provider.userInfo == null ||
                                          provider.userInfo!.banks.isEmpty)
                                    ? ListView(
                                        children: [
                                          SizedBox(height: screenHeight * 0.3),
                                          Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.wifi_off,
                                                  color: Colors.grey,
                                                  size: 60,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "${provider.error ?? "No bank details found."}",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    await provider
                                                        .fetchUserInfo(
                                                          context,
                                                          true,
                                                        );
                                                  },
                                                  icon: Icon(Icons.refresh),
                                                  label: Text("Retry"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : ListView.builder(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  screenWidth *
                                                  0.04 *
                                                  scaleFactor,
                                              vertical:
                                                  screenHeight *
                                                  0.015 *
                                                  scaleFactor,
                                            ).copyWith(
                                              // ensure the scrollable content has extra bottom padding equal
                                              // to the visible nav footprint so last items can scroll above it
                                              bottom: contentBottomPadding,
                                            ),
                                        itemCount:
                                            provider.userInfo?.banks.length,
                                        itemBuilder: (context, index) {
                                          final bank =
                                              provider.userInfo?.banks[index];
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  screenHeight *
                                                  0.02 *
                                                  scaleFactor,
                                            ),
                                            child: BankCard(
                                              bankName: bank!.bankName,
                                              accountNumber: bank.accountNumber,
                                              type: bank.loanType,
                                              typeColor:
                                                  bank.loanType == "Credit Card"
                                                  ? Color(0xFF337EFF)
                                                  : Color(0xFF008C38),
                                              amount: bank.loanAmount,
                                              amountColor: Color(0xFFFF5858),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                      ),
                    ],
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
          );
        },
      ),
    );
  }
}

// Reusable Bank Card widget
class BankCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String type;
  final Color typeColor;
  final String amount;
  final Color amountColor;

  const BankCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.type,
    required this.typeColor,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2319),
        shape: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(210, 159, 42, 0.65),
              const Color.fromRGBO(255, 255, 255, 0.65),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          width: 2,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.025 * scaleFactor,
        horizontal: screenWidth * 0.05 * scaleFactor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Column
          // Left Column (Labels)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bankText("Bank Name"),
                _bankText("Account Number"),
                _bankText("Type"),
                _bankText("Amount"),
              ],
            ),
          ),

          // Right Column (Actual Values)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bankText(bankName, maxLines: 1, overflow: TextOverflow.ellipsis),
              _bankText(
                accountNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _bankText(
                type,
                color: typeColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _bankText(
                "₹$amount",
                color: amountColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bankText(
    String text, {
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
    Color color = Colors.white,
  }) {
    const scaleFactor = 0.85;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4 * scaleFactor),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}

// Gradient Border Shape
class GradientBoxBorder extends ShapeBorder {
  final Gradient gradient;
  final double width;
  final BorderRadius borderRadius;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(
      gradient: gradient,
      width: width * t,
      borderRadius: borderRadius * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect).deflate(width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final rrect = (borderRadius ?? this.borderRadius)
        .toRRect(rect)
        .deflate(width / 2);
    canvas.drawRRect(rrect, paint);
  }
}

class QueryCard extends StatefulWidget {
  final QueryModel query;
  final String? userRole;
  final VoidCallback? onSolve;

  const QueryCard({
    super.key,
    required this.query,
    this.onSolve,
    this.userRole,
  });

  @override
  State<QueryCard> createState() => _QueryCardState();
}

class _QueryCardState extends State<QueryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final query = widget.query;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;
    final submittedDate = DateTime.fromMillisecondsSinceEpoch(
      query.submittedAt * 1000,
    );
    final formattedDate =
        "${submittedDate.day.toString().padLeft(2, '0')}-${submittedDate.month.toString().padLeft(2, '0')}-${submittedDate.year} ${submittedDate.hour.toString().padLeft(2, '0')}:${submittedDate.minute.toString().padLeft(2, '0')}";

    const int previewLimit = 80;
    final isLongText = query.query.length > previewLimit;
    final displayedText = _isExpanded || !isLongText
        ? query.query
        : "${query.query.substring(0, previewLimit)}...";

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01 * scaleFactor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Outer thin gradient border
        gradient: const LinearGradient(
          colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        // ↓ This controls border thickness — make it 0.8 or 1 for a thin border
        margin: const EdgeInsets.all(1 * scaleFactor),
        decoration: ShapeDecoration(
          color: const Color(0xFF2D2319),
          shape: GradientBoxBorder(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(210, 159, 42, 0.65),
                const Color.fromRGBO(255, 255, 255, 0.65),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            width: 2,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Top Row: Avatar + Username + Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20 * scaleFactor,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22 * scaleFactor,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03 * scaleFactor),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          query.postedBy,
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.04 * scaleFactor,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (query.phone != null && query.phone!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.003),
                            child: Text(
                              query.phone!,
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.033 * scaleFactor,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03 * scaleFactor,
                    vertical: screenHeight * 0.005 * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: query.status == "pending"
                        ? Colors.orange
                        : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    query.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.032 * scaleFactor,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.015 * scaleFactor),

            /// --- Query Content ---
            Text(
              displayedText,
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.038 * scaleFactor,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),

            if (isLongText)
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.005 * scaleFactor,
                  ),
                  child: Text(
                    _isExpanded ? "Show less" : "Read more",
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.035 * scaleFactor,
                      color: const Color(0xFFD29F2A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            SizedBox(height: screenHeight * 0.02 * scaleFactor),

            ...[
              // 🟡 --- Resolved By Card ---
              if (query.resolvedBy != null)
                Container(
                  margin: EdgeInsets.only(
                    top: screenHeight * 0.012 * scaleFactor,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2D2319),
                    shape: GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromRGBO(210, 159, 42, 0.65),
                          const Color.fromRGBO(255, 255, 255, 0.65),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      width: 2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(
                      1 * scaleFactor,
                    ), // thin border
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2319),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.035 * scaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Resolved By",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.037 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.006 * scaleFactor),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                query.resolvedBy?.name ??
                                    (query.resolvedBy?.phone ?? 'Unknown'),
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.035 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03 * scaleFactor,
                                vertical: screenHeight * 0.004 * scaleFactor,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                query.resolvedBy?.role ?? 'Unknown',
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.032 * scaleFactor,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (query.resolvedBy?.phone != null &&
                            query.resolvedBy!.phone!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.004 * scaleFactor,
                            ),
                            child: Text(
                              query.resolvedBy!.phone!,
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.032 * scaleFactor,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (query.remarks != null)
                // 🟣 --- Remarks Card ---
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    top: screenHeight * 0.012 * scaleFactor,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF2D2319),
                    shape: GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromRGBO(210, 159, 42, 0.65),
                          const Color.fromRGBO(255, 255, 255, 0.65),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      width: 2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(
                      1 * scaleFactor,
                    ), // thin border
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2319),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.035 * scaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Remarks",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.037 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.006 * scaleFactor),
                        Text(
                          query.remarks!,
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.034 * scaleFactor,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],

            SizedBox(height: screenHeight * 0.02 * scaleFactor),

            /// --- Bottom Row: Date + Solve Button ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.032 * scaleFactor,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (query.status == "pending" && widget.userRole != null)
                  if (widget.userRole?.toLowerCase() == "admin" ||
                      widget.userRole?.toLowerCase() == "advocate")
                    GestureDetector(
                      onTap: () {
                        openResolveQueryBottomSheet(context, query);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05 * scaleFactor,
                          vertical: screenHeight * 0.01 * scaleFactor,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(-1.0, 0.0),
                            end: Alignment(1.0, 0.0),
                            colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
                          ),
                          borderRadius: BorderRadius.circular(41),
                        ),
                        child: Text(
                          "Solve Query",
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.035 * scaleFactor,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Gradient Border Container for BottomSheet
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Gradient gradient;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 25,
    this.borderWidth = 2,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    const scaleFactor = 0.85;
    return CustomPaint(
      painter: _GradientBorderPainter(
        radius: borderRadius * scaleFactor,
        width: borderWidth * scaleFactor,
        gradient: gradient,
      ),
      child: Container(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: child,
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double width;
  final Gradient gradient;

  _GradientBorderPainter({
    required this.radius,
    required this.width,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
