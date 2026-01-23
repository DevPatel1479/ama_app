import 'dart:async';
import 'dart:ui';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/shimmer_widget.dart'
    show ShimmerBankCard;
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/query_model.dart';
import 'package:ama_legal_solutions/provider/client/remarks_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_casedesk_screen.dart'
    show QueryCard;
import 'package:cloud_firestore/cloud_firestore.dart'
    show QuerySnapshot, DocumentChangeType, FirebaseFirestore;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DarkAskLaywerScreen extends StatefulWidget {
  const DarkAskLaywerScreen({super.key});

  @override
  State<DarkAskLaywerScreen> createState() => _DarkAskLaywerScreenState();
}

class _DarkAskLaywerScreenState extends State<DarkAskLaywerScreen> {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
    final topContentHeight =
        size.width * 0.90 * 0.65 + // image height (approx 65% of width)
        16 + // top padding of image
        screenHeight * 0.04 + // spacing after image
        50; // approx tab height + underline + spacing

    final listHeight =
        screenHeight - topContentHeight - MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: Colors.transparent,

        body: Stack(
          children: [
            /// ============================
            /// BACKGROUND GRADIENT
            /// ============================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromRGBO(45, 35, 25, 0.85), Color(0xFF0F0F0F)],
                ),
              ),
            ),

            /// ============================
            /// CONTENT
            /// ============================
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 80,
                  bottom: 40,
                ),
                child: SizedBox(
                  width: double.infinity, // 🔥 THIS FIXES EVERYTHING
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// ============================
                      /// ASK LAWYER IMAGE
                      /// ============================
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // The Image
                              Image.asset(
                                AppAssets.askLawyerImg,
                                width: size.width * 0.90,
                                fit: BoxFit.contain,
                              ),

                              // Text overlay
                              Positioned(
                                left:
                                    size.width *
                                    0.05, // horizontal padding from left
                                top:
                                    size.height *
                                    0.04, // vertical padding from top
                                child: Container(
                                  width: size.width * 0.8, // prevent overflow
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Trusted\n",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF2D2319),
                                            fontSize: 30,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "answers,\n",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF2D2319),
                                            fontSize: 30,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "anytime",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFD29F2A),
                                            fontSize: 30,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ), // align with your image
                        child: Column(
                          children: [
                            /// ============================
                            /// TAB TEXT ROW
                            /// ============================
                            Row(
                              children: [
                                /// Pending
                                Expanded(
                                  child: GestureDetector(
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

                                    child: Center(
                                      child: Text(
                                        "Pending",
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// Resolved
                                Expanded(
                                  child: GestureDetector(
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
                                    child: Center(
                                      child: Text(
                                        "Resolved",
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 6,
                            ), // spacing between text and line
                            /// ============================
                            /// UNDERLINE INDICATOR
                            /// ============================
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    color: isPendingActive
                                        ? const Color(0xFFD29F2A)
                                        : Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    color: !isPendingActive
                                        ? const Color(0xFFD29F2A)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: listHeight,
                        child: Consumer<QueryProvider>(
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
                              (a, b) => b.submittedAt.compareTo(a.submittedAt),
                            );
                            if (provider.isLoading) {
                              // Show shimmer placeholders while switching between tabs
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04 * scaleFactor,
                                  vertical: screenHeight * 0.015 * scaleFactor,
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
                                    fontSize: screenWidth * 0.045 * scaleFactor,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                            final hasMoreData = provider.nextPageCursor != null;
                            return RefreshIndicator(
                              onRefresh: () async {
                                final role = await LocalStorageHelper.getString(
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
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                // padding: EdgeInsets.symmetric(
                                //   horizontal:
                                //       screenWidth * 0.05 * scaleFactor,
                                // ),
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
                                        isDark: true,
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
                                              child: CircularProgressIndicator(
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
                        ),
                      ),

                      /// next widgets...
                    ],
                  ),
                ),
              ),
            ),

            /// ============================
            /// GLASS APPBAR (CRITICAL)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Ask your Lawyer",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await context.pushNamed(
                            AppScreenNames.raiseQuery,
                            // you can pass extra if needed
                          );

                          // result could be true when new query created
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

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD29F2A),
                            borderRadius: BorderRadius.circular(41),
                          ),
                          child: const Text(
                            "Ask Query",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
