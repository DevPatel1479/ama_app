import 'dart:async';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
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
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_casedesk_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LightMyCasedeskScreen extends StatefulWidget {
  const LightMyCasedeskScreen({super.key});

  @override
  State<LightMyCasedeskScreen> createState() => _LightMyCasedeskScreenState();
}

class _LightMyCasedeskScreenState extends State<LightMyCasedeskScreen> {
  bool isMyCaseActive = true;
  bool isPendingActive = true; // secondary toggle
  late ScrollController _scrollController;
  bool isFetchingMore = false;
  bool _userScrolled = false;
  String? userRole;
  String? _role;
  String? _phone;
  bool isExpanded = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _queriesSubscription;

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
                        color: Colors.black,
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
                      color: Colors.black,
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
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    const scaleFactor = 0.85;
    final screenWidth = MediaQuery.of(context).size.width * scaleFactor;
    final screenHeight = MediaQuery.of(context).size.height * scaleFactor;
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

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04 * scaleFactor,
                vertical: screenHeight * 0.020 * scaleFactor,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppPathsForScreen.userHomePath),
                    child: Image.asset(
                      AppAssets.backArrowIcon,
                      width: screenWidth * 0.07 * scaleFactor,
                      height: screenWidth * 0.07 * scaleFactor,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02 * scaleFactor),
                  Text(
                    "My Casedesk",
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  if (userRole?.toLowerCase() != "admin" &&
                      userRole?.toLowerCase() != "advocate")
                    /// Ask Doubt Button at top-right
                    SizedBox(
                      width: screenWidth * 0.35 * scaleFactor,
                      height: screenHeight * 0.05 * scaleFactor,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await context.pushNamed(
                            AppScreenNames.raiseQuery,
                          );
                          if (result == true) {
                            final provider = Provider.of<QueryProvider>(
                              context,
                              listen: false,
                            );
                            final role = await LocalStorageHelper.getString(
                              "userRole",
                            );
                            final phone = await LocalStorageHelper.getString(
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
                              "Ask Query",
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
            ),
          ],
        ),
      ),

      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: GradientTopLayout(
                    keepExpanded: false,
                    screenName: "home",

                    // headerContent: Container(
                    //   width: double.infinity,

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
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       // Top Bar
                    //       Padding(
                    //         padding: EdgeInsets.symmetric(
                    //           horizontal: screenWidth * 0.04 * scaleFactor,
                    //           vertical: screenHeight * 0.020 * scaleFactor,
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             GestureDetector(
                    //               onTap: () => context.go(
                    //                 AppPathsForScreen.userHomePath,
                    //               ),
                    //               child: Image.asset(
                    //                 AppAssets.backArrowIcon,
                    //                 width: screenWidth * 0.06 * scaleFactor,
                    //                 height: screenWidth * 0.06 * scaleFactor,
                    //                 fit: BoxFit.contain,
                    //                 color: Colors.black,
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               width: screenWidth * 0.12 * scaleFactor,
                    //             ),
                    //             Text(
                    //               "My Casedesk",
                    //               style: GoogleFonts.outfit(
                    //                 fontSize: screenWidth * 0.065,
                    //                 fontWeight: FontWeight.w600,
                    //                 color: Colors.black,
                    //               ),
                    //             ),
                    //             Spacer(),
                    //             if (userRole?.toLowerCase() != "admin")
                    //               /// Ask Doubt Button at top-right
                    //               SizedBox(
                    //                 width: screenWidth * 0.35 * scaleFactor,
                    //                 height: screenHeight * 0.05 * scaleFactor,
                    //                 child: ElevatedButton(
                    //                   onPressed: () {
                    //                     context.pushNamed(
                    //                       AppScreenNames.raiseQuery,
                    //                     );
                    //                   },

                    //                   style:
                    //                       ElevatedButton.styleFrom(
                    //                         padding: EdgeInsets.zero,
                    //                         shape: RoundedRectangleBorder(
                    //                           borderRadius:
                    //                               BorderRadius.circular(41),
                    //                         ),
                    //                         backgroundColor: Colors.transparent,
                    //                         shadowColor: Colors.black
                    //                             .withOpacity(0.3),
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
                    //                       borderRadius: BorderRadius.circular(
                    //                         41,
                    //                       ),
                    //                     ),
                    //                     child: Container(
                    //                       alignment: Alignment.center,
                    //                       child: Text(
                    //                         "Ask Query",
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
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    fixedPositionWidget:
                        // SizedBox(height: screenHeight * 0.03),
                        Column(
                          children: [
                            // Primary Toggle bar (My Case / Bank Details)
                            if (userRole?.toLowerCase() != "admin" &&
                                userRole?.toLowerCase() != "advocate")
                              SizedBox(height: screenHeight * 0.03),

                            if (userRole?.toLowerCase() != "admin" &&
                                userRole?.toLowerCase() != "advocate")
                              Center(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.06,
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
                                              screenWidth * 0.01,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isMyCaseActive
                                                  ? const Color(0xFFD29F2A)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "My Case",
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.04,
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
                                            if (provider.userInfo != null)
                                              return;
                                            provider.fetchUserInfo(
                                              context,
                                              true,
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(
                                              screenWidth * 0.01,
                                            ),
                                            decoration: BoxDecoration(
                                              color: !isMyCaseActive
                                                  ? const Color(0xFFD29F2A)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Bank Details",
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.04,
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
                              SizedBox(
                                height: screenHeight * 0.025 * scaleFactor,
                              ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2D2319),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Live Status: ",
                                            style: GoogleFonts.outfit(
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.045,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFD29F2A),
                                            ),
                                          ),
                                          liveStatusContent,
                                        ],
                                      ),
                                      AnimatedRotation(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
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
                            SizedBox(height: screenHeight * 0.025),

                            // Secondary toggle row (Pending / Resolved) only for My Case
                            if (isMyCaseActive)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.15,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Pending
                                    GestureDetector(
                                      onTap: () async {
                                        if (isPendingActive)
                                          return; // already active
                                        setState(() => isPendingActive = true);

                                        // reset scroll to top and pagination flags
                                        if (_scrollController.hasClients) {
                                          _scrollController.jumpTo(0);
                                        } else {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                if (_scrollController
                                                    .hasClients) {
                                                  _scrollController.jumpTo(0);
                                                }
                                              });
                                        }
                                        _userScrolled = false;

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth * 0.02,
                                            ),
                                            child: Text(
                                              "Pending",
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth * 0.03,
                                            ), // adjust as needed
                                            child: Container(
                                              width: screenWidth * 0.15,
                                              height: 2,
                                              color: isPendingActive
                                                  ? Colors.black
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
                                                if (_scrollController
                                                    .hasClients) {
                                                  _scrollController.jumpTo(0);
                                                }
                                              });
                                        }
                                        _userScrolled = false;

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: screenWidth * 0.02,
                                            ),
                                            child: Text(
                                              "Resolved",
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: screenWidth * 0.01,
                                            ),
                                            child: Container(
                                              width: screenWidth * 0.15,
                                              height: 2,
                                              color: !isPendingActive
                                                  ? Colors.black
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.03),
                          ],
                        ),

                    child:
                        // Content Section - scrollable
                        isMyCaseActive
                        ? Consumer<QueryProvider>(
                            builder: (context, provider, _) {
                              if (provider.isLoading &&
                                  provider.queries.isEmpty) {
                                // Initial loading
                                return ListView.builder(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal:
                                            screenWidth * 0.04 * scaleFactor,
                                        vertical:
                                            screenHeight * 0.015 * scaleFactor,
                                      ).copyWith(
                                        // ensure the scrollable content has extra bottom padding equal
                                        // to the visible nav footprint so last items can scroll above it
                                        bottom: contentBottomPadding,
                                      ),
                                  itemCount: 3,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.02 * scaleFactor,
                                    ),
                                    child: const ShimmerBankCard(),
                                  ),
                                );
                              }

                              // Filter by Pending / Resolved
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
                                      bottom: screenHeight * 0.02 * scaleFactor,
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
                                      color: Colors.black,
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
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal:
                                            screenWidth * 0.04 * scaleFactor,
                                        vertical:
                                            screenHeight * 0.015 * scaleFactor,
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
                                              screenHeight * 0.02 * scaleFactor,
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
                                              screenWidth * 0.04 * scaleFactor,
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
                                    itemBuilder: (context, index) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            screenHeight * 0.02 * scaleFactor,
                                      ),
                                      child: const ShimmerBankCard(),
                                    ),
                                  )
                                : (provider.userInfo == null ||
                                      provider.userInfo!.banks.isEmpty)
                                ? ListView(
                                    children: [
                                      Padding(
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
                                      ),
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
                                                await provider.fetchUserInfo(
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
                                              screenWidth * 0.04 * scaleFactor,
                                          vertical:
                                              screenHeight *
                                              0.015 *
                                              scaleFactor,
                                        ).copyWith(
                                          // ensure the scrollable content has extra bottom padding equal
                                          // to the visible nav footprint so last items can scroll above it
                                          bottom: contentBottomPadding,
                                        ),
                                    itemCount: provider.userInfo?.banks.length,
                                    itemBuilder: (context, index) {
                                      final bank =
                                          provider.userInfo?.banks[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              screenHeight * 0.02 * scaleFactor,
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

                    // Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       SizedBox(height: screenHeight * 0.03),
                    //       Center(
                    //         child: Text(
                    //           isPendingActive
                    //               ? "Pending Content"
                    //               : "Resolved Content",
                    //           style: GoogleFonts.outfit(
                    //             fontSize: screenWidth * 0.05,
                    //             color: Colors.black,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   )
                    // : ListView.builder(
                    //     shrinkWrap: true,
                    //     physics:
                    //         const NeverScrollableScrollPhysics(), // let parent scroll
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: screenWidth * 0.05,
                    //     ),
                    //     itemCount: bankDetails.length,
                    //     itemBuilder: (context, index) {
                    //       final bank = bankDetails[index];
                    //       return Padding(
                    //         padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                    //         child: BankCard(
                    //           bankName: bank["bankName"],
                    //           accountNumber: bank["accountNumber"],
                    //           type: bank["type"],
                    //           typeColor: bank["typeColor"],
                    //           amount: bank["amount"],
                    //           amountColor: bank["amountColor"],
                    //         ),
                    //       );
                    //     },
                    //   ),
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
