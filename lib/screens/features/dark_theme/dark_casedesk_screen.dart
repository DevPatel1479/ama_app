import 'dart:async';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/resolve_query_bottom_sheet.dart';
import 'package:ama_legal_solutions/custom_widgets/shimmer_widget.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/query_model.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/resolve_query_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/screens/auth/dark_theme/dark_signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
        print("Firestore userQueries changes detected...");
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

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          return SafeArea(
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
                        onTap: () => context.go(AppPathsForScreen.userHomePath),
                        child: Image.asset(
                          AppAssets.backArrowIcon,
                          width: screenWidth * 0.05 * scaleFactor,
                          height: screenWidth * 0.05 * scaleFactor,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.12 * scaleFactor),
                      Text(
                        "My Casedesk",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.065 * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03 * scaleFactor),

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
                                  fontSize: screenWidth * 0.04 * scaleFactor,
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
                                  fontSize: screenWidth * 0.04 * scaleFactor,
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
                          onTap: () => setState(() => isPendingActive = true),
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
                                    fontSize: screenWidth * 0.04 * scaleFactor,
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
                          onTap: () => setState(() => isPendingActive = false),
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
                                    fontSize: screenWidth * 0.04 * scaleFactor,
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05 * scaleFactor,
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
                              (a, b) => b.submittedAt.compareTo(a.submittedAt),
                            );

                            if (filteredQueries.isEmpty) {
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
                                  reset: true,
                                );
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05 * scaleFactor,
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
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await provider.fetchUserInfo(context, true);
                          },
                          child: provider.isLoading
                              ? ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        screenWidth * 0.05 * scaleFactor,
                                  ),
                                  itemCount:
                                      3, // show 3 shimmer cards while loading
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.02 * scaleFactor,
                                    ),
                                    child: const ShimmerBankCard(),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        screenWidth * 0.05 * scaleFactor,
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
                                        accountNumber: bank!.accountNumber,
                                        type: bank!.loanType,
                                        typeColor:
                                            bank!.loanType == "Credit Card"
                                            ? Color(0xFF337EFF)
                                            : Color(0xFF008C38),
                                        amount: bank!.loanAmount,
                                        amountColor: Color(0xFFFF5858),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: const CustomBottomNav(),
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
                "\$$amount",
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
                          query.postedBy ?? "Unknown User",
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
