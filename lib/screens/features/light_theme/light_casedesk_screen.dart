import 'dart:async';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/shimmer_widget.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchUserRole();
    Future.microtask(() async {
      final provider = Provider.of<QueryProvider>(context, listen: false);
      final role = await LocalStorageHelper.getString("userRole");
      final phone = await LocalStorageHelper.getString("userPhone");

      if (role != null && phone != null) {
        provider.fetchQueries(context: context, role: role, phone: phone);
        // attach realtime listener only if My Case active
        if (isMyCaseActive) {
          _attachFirestoreListener(context, role, phone, isMyCaseActive);
        }
      }
    });
  }

  Future<void> fetchUserRole() async {
    final role = await LocalStorageHelper.getString("userRole");
    setState(() {
      userRole = role;
    });
  }

  // Attach Firestore realtime listener for document: queries/<role>_<phone>

  void _attachFirestoreListener(
    BuildContext context,
    String role,
    String phone,
    bool isMyCaseActive,
  ) {
    if (_queriesSubscription != null) return;
    // Get the provider reference NOW, while widget is still mounted
    final queryProvider = Provider.of<QueryProvider>(context, listen: false);

    final subcollectionRef = FirebaseFirestore.instance.collection(
      'allQueries',
    );

    _queriesSubscription = subcollectionRef.snapshots().listen(
      (querySnap) async {
        // print("Firestore userQueries changes detected...");
        if (!mounted || !isMyCaseActive) return;

        // final queryProvider = Provider.of<QueryProvider>(
        //   context,
        //   listen: false,
        // );

        // refetch queries for this user
        await queryProvider.fetchQueries(
          context: context,
          role: role,
          phone: phone,
          reset: true,
        );
      },
      onError: (err) {
        print("Firestore listener error: $err");
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
      final role = await LocalStorageHelper.getString("userRole");
      final phone = await LocalStorageHelper.getString("userPhone");

      if (role != null && phone != null) {
        await provider.fetchQueries(
          context: context,
          role: role,
          phone: phone,
          // lastDocId: provider.nextPageCursor,
          append: true,
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
      final role = await LocalStorageHelper.getString("userRole");
      final phone = await LocalStorageHelper.getString("userPhone");
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
    super.dispose();
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
    const scaleFactor = 0.81;
    final screenWidth = MediaQuery.of(context).size.width * scaleFactor;
    final screenHeight = MediaQuery.of(context).size.height * scaleFactor;
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // amount of extra space to reserve at bottom so the last item is fully visible
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  child: GradientTopLayout(
                    keepExpanded: false,
                    screenName: "home",
                    headerContent: Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: const Color(0xFFD29F2A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            screenWidth * 0.07,
                          ), // ~responsive
                          bottomRight: Radius.circular(
                            screenWidth * 0.07,
                          ), // ~responsive
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Bar
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04 * scaleFactor,
                              vertical: screenHeight * 0.025 * scaleFactor,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.go(
                                    AppPathsForScreen.userHomePath,
                                  ),
                                  child: Image.asset(
                                    AppAssets.backArrowIcon,
                                    width: screenWidth * 0.05,
                                    height: screenWidth * 0.05,
                                    fit: BoxFit.contain,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.12),
                                Text(
                                  "My Casedesk",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.065,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    fixedPositionWidget:
                        // SizedBox(height: screenHeight * 0.03),
                        Column(
                          children: [
                            // Primary Toggle bar (My Case / Bank Details)
                            SizedBox(height: screenHeight * 0.05),
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                          if (provider.userInfo != null) return;
                                          provider.fetchUserInfo(context, true);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(
                                            screenWidth * 0.01,
                                          ),
                                          decoration: BoxDecoration(
                                            color: !isMyCaseActive
                                                ? const Color(0xFFD29F2A)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                      onTap: () => setState(
                                        () => isPendingActive = true,
                                      ),
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
                                      onTap: () => setState(
                                        () => isPendingActive = false,
                                      ),
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
                              final filteredQueries = provider.queries
                                  .where(
                                    (q) => isPendingActive
                                        ? q.status == 'pending'
                                        : q.status == 'resolved',
                                  )
                                  .toList();

                              // Sort by submitted_at descending
                              filteredQueries.sort(
                                (a, b) =>
                                    b.submittedAt.compareTo(a.submittedAt),
                              );

                              if (filteredQueries.isEmpty) {
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
                                    reset: true,
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
                                  itemCount:
                                      filteredQueries.length +
                                      1, // +1 for loader placeholder
                                  itemBuilder: (context, index) {
                                    if (index < filteredQueries.length) {
                                      final query = filteredQueries[index];
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
                                      // Show bottom loader ONLY while fetching more
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
