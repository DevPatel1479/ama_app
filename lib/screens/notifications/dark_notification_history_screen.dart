import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart'
    show LocalStorageHelper;
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ama_legal_solutions/provider/notifications/notification_history_provider.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String? userId;
  late NotificationHistoryProvider _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _provider = Provider.of<NotificationHistoryProvider>(
        context,
        listen: false,
      );
      // _provider.reset();
      final phone = await LocalStorageHelper.getString("userPhone");
      await _provider.adminFetchLastOpenedNotificationTime(phone: phone ?? "");
      _loadUserAndFetch(_provider);
      _scrollController.addListener(_onScroll);
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    //   final isDarkMode = themeProvider.isDarkMode;

    //   SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(
    //       statusBarColor: Color(0xFFD29F2A),
    //       statusBarIconBrightness: Brightness.dark,
    //       statusBarBrightness: Brightness.light,
    //     ),
    //   );
    // });
  }

  String formatNotifDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatNotifTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  Future<void> _markNotificationsSeen() async {
    final phone = await LocalStorageHelper.getString("userPhone");
    if (phone != null) {
      await _provider.adminUpdateLastOpenedNotificationTime(phone: phone);
    }
  }

  @override
  void dispose() {
    _markNotificationsSeen();

    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _loadUserAndFetch(NotificationHistoryProvider provider) async {
    final role = await getUserRole();
    final phone = await getUserPhone();

    if (role != null && phone != null) {
      setState(() {
        userId = "${role}_$phone";
      });

      // Use listen: false here
      provider = Provider.of<NotificationHistoryProvider>(
        context,
        listen: false,
      );
      await provider.fetchUserNotificationHistory(userId!);

      // Rebuild after fetch
      if (mounted) setState(() {});
    }
  }

  bool shouldShowDot(
    NotificationHistoryProvider provider,
    int notificationTimestamp,
  ) {
    final lastOpened = provider.adminLastOpenedNotificationTime;
    print("$lastOpened : $notificationTimestamp");
    // First-time user → all unread
    if (lastOpened == null) return true;
    print(lastOpened > notificationTimestamp);
    return notificationTimestamp > lastOpened;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final provider = Provider.of<NotificationHistoryProvider>(
      context,
      listen: false,
    );

    final position = _scrollController.position;

    if (position.pixels > 0 &&
        position.pixels >= position.maxScrollExtent - 200 &&
        provider.hasMore &&
        !provider.isPaginating &&
        !provider.isLoading) {
      provider.fetchUserNotificationHistory(userId!, loadMore: true);
    }
  }

  Future<void> _onRefresh() async {
    if (userId == null) return;

    final provider = Provider.of<NotificationHistoryProvider>(
      context,
      listen: false,
    );

    // Reset only the notifications, don't touch isLoading
    provider.notifications.clear();
    provider.hasMore = true;
    // provider._lastTimestamp = null;

    try {
      await provider.fetchUserNotificationHistory(userId!);
    } catch (e) {
      debugPrint("Refresh failed: $e");
    }
  }

  PreferredSizeWidget _buildLightAppBar(double screenWidth) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 10),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: const Color(
              0xFFFFFBF1,
            ).withOpacity(0.35), // iOS-style frosted background
            // padding: EdgeInsets.only(left: screenWidth * 0.04),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero, // remove default padding

                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                  onPressed: () => context.go(AppPathsForScreen.userHomePath),
                  splashRadius: 24, // optional, makes tap area bigger
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Notifications History',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// DARK THEME APPBAR (your original black one)
  PreferredSizeWidget _buildDarkAppBar(double screenWidth) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 10),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            color: const Color(0xFF2D2319).withOpacity(0.45), // Dark frosted
            padding: EdgeInsets.only(
              // left: screenWidth * 0.04,
              top: MediaQuery.of(context).padding.top,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero, // remove default padding

                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                  onPressed: () => context.go(AppPathsForScreen.userHomePath),
                  splashRadius: 24, // optional, makes tap area bigger
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Notifications History',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String notificationGroupLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final notifDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(notifDate).inDays;

    if (difference == 0) {
      return "Today";
    }

    if (difference == 1) {
      return "Yesterday";
    }

    if (difference <= 7) {
      return "Last 7 days";
    }

    return DateFormat('MMMM yyyy').format(date);
  }

  DateTime parseTimestamp(int timestamp) {
    // supports seconds or milliseconds
    if (timestamp.toString().length == 10) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<NotificationHistoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF2D2319) : Color(0xFFFFFBF1),
      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: isDark
          ? _buildDarkAppBar(screenWidth)
          : _buildLightAppBar(screenWidth),

      body: isDark
          ? SafeArea(
              top: false,
              bottom: false,
              child: Consumer<NotificationHistoryProvider>(
                builder: (contex, provider, _) {
                  return buildForDarkTheme(provider, screenWidth, screenHeight);
                },
              ),
            )
          : Consumer<NotificationHistoryProvider>(
              builder: (contex, provider, _) {
                return buildForLightTheme(provider, screenWidth, screenHeight);
              },
            ),
    );
  }

  Widget buildForLightTheme(
    NotificationHistoryProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    return userId == null
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : SafeArea(
            top: false,
            bottom: false,
            child: RefreshIndicator(
              edgeOffset: topPadding,

              color: Colors.amber,
              backgroundColor: Colors.black,
              onRefresh: _onRefresh,
              child: provider.isLoading && provider.notifications.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : provider.notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: screenHeight * 0.35),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: Colors.black,
                                size: screenWidth * 0.18,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "No notifications yet",
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        0,
                        // screenWidth * 0.01, // left padding (optional)
                        topPadding, // top padding to avoid app bar
                        0,
                        screenHeight * 0.015, // bottom padding
                      ),
                      itemCount:
                          provider.notifications.length +
                          (provider.isPaginating ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.notifications.length &&
                            provider.isPaginating) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }

                        final notif = provider.notifications[index];
                        final DateTime notifDate = parseTimestamp(
                          notif.timestamp,
                        );

                        final String notifDay = formatNotifDate(notifDate);

                        final String notifTime = formatNotifTime(notifDate);
                        final currentLabel = notificationGroupLabel(
                          parseTimestamp(notif.timestamp),
                        );

                        String? previousLabel;
                        if (index > 0) {
                          previousLabel = notificationGroupLabel(
                            parseTimestamp(
                              provider.notifications[index - 1].timestamp,
                            ),
                          );
                        }

                        final bool showHeader = currentLabel != previousLabel;

                        final bool isUnread = shouldShowDot(
                          provider,
                          notif.timestamp,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 SECTION HEADER (Today / Yesterday / Earlier)
                            if (showHeader)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: screenWidth * 0.04,
                                  bottom: screenHeight * 0.01,
                                  top: screenHeight * 0.02,
                                ),
                                child: Text(
                                  currentLabel,
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.050,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,

                                    color: Colors.black,
                                  ),
                                ),
                              ),

                            /// 🔔 NOTIFICATION CARD
                            Container(
                              margin: EdgeInsets.only(
                                bottom: screenHeight * 0.014,
                                left: screenWidth * 0.035,
                                right: screenWidth * 0.035,
                              ),
                              decoration: BoxDecoration(
                                color: isUnread
                                    ? const Color.fromARGB(
                                        10, // 4%
                                        210,
                                        159,
                                        42,
                                      )
                                    // const Color.fromARGB(210, 197, 219, 87)
                                    : null,

                                /// ✅ UNREAD BORDER
                                border: isUnread
                                    ? Border.all(
                                        color: const Color(0x802D2319),
                                        width: 2,
                                      )
                                    : null,

                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.018,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// ICON
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: screenWidth * 0.03,
                                    ),
                                    child: Image.asset(
                                      AppAssets.amaNotificationIcon,
                                      width: screenWidth * 0.10,
                                      height: screenWidth * 0.10,
                                    ),
                                  ),

                                  /// CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// TITLE
                                        // Text(
                                        //   notif.title,
                                        //   style: GoogleFonts.outfit(
                                        //     fontSize: screenWidth * 0.045,
                                        //     fontWeight: FontWeight.w400,
                                        //     color: Color(0xFF2D2319),
                                        //     height: 1.3,
                                        //   ),
                                        // ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// TITLE
                                            Expanded(
                                              child: Text(
                                                notif.title,
                                                style: GoogleFonts.outfit(
                                                  fontSize: screenWidth * 0.045,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF2D2319),
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: screenWidth * 0.02),

                                            /// DATE + TIME (top-right)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  notifDay,
                                                  style: GoogleFonts.outfit(
                                                    fontSize:
                                                        screenWidth * 0.030,
                                                    color: const Color.fromARGB(
                                                      219,
                                                      45,
                                                      35,
                                                      25,
                                                    ),
                                                    height: 1.1,
                                                  ),
                                                ),

                                                Text(
                                                  notifTime,
                                                  style: GoogleFonts.outfit(
                                                    fontSize:
                                                        screenWidth * 0.028,
                                                    color: const Color.fromARGB(
                                                      219,
                                                      45,
                                                      35,
                                                      25,
                                                    ),
                                                    height: 1.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.008),

                                        /// BODY
                                        Text(
                                          notif.body,
                                          style: GoogleFonts.outfit(
                                            fontSize: screenWidth * 0.038,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromARGB(
                                              178, // 70%
                                              45,
                                              35,
                                              25,
                                            ),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          );
  }

  Widget buildForDarkTheme(
    NotificationHistoryProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    return userId == null
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : Stack(
            children: [
              RefreshIndicator(
                color: Colors.amber,
                backgroundColor: Colors.black,
                onRefresh: _onRefresh,
                child: provider.isLoading && provider.notifications.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : provider.notifications.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: screenHeight * 0.35),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  color: Colors.white54,
                                  size: screenWidth * 0.18,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  "No notifications yet",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          0,
                          // screenWidth * 0.01, // left padding (optional)
                          topPadding, // top padding to avoid app bar
                          0,
                          screenHeight * 0.015, // bottom padding
                        ),
                        itemCount:
                            provider.notifications.length +
                            (provider.isPaginating ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.notifications.length &&
                              provider.isPaginating) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              ),
                            );
                          }

                          final notif = provider.notifications[index];

                          final DateTime notifDate = parseTimestamp(
                            notif.timestamp,
                          );

                          final String notifDay = formatNotifDate(notifDate);

                          final String notifTime = formatNotifTime(notifDate);
                          final currentLabel = notificationGroupLabel(
                            parseTimestamp(notif.timestamp),
                          );

                          String? previousLabel;
                          if (index > 0) {
                            previousLabel = notificationGroupLabel(
                              parseTimestamp(
                                provider.notifications[index - 1].timestamp,
                              ),
                            );
                          }

                          final bool showHeader = currentLabel != previousLabel;

                          final bool isUnread = shouldShowDot(
                            provider,
                            notif.timestamp,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔹 SECTION HEADER (Today / Yesterday / Earlier)
                              if (showHeader)
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.04,
                                    bottom: screenHeight * 0.01,
                                    top: screenHeight * 0.02,
                                  ),
                                  child: Text(
                                    currentLabel,
                                    style: GoogleFonts.outfit(
                                      fontSize: screenWidth * 0.050,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                              /// 🔔 NOTIFICATION CARD
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: screenHeight * 0.014,
                                  left: screenWidth * 0.035,
                                  right: screenWidth * 0.035,
                                ),
                                decoration: BoxDecoration(
                                  color: isUnread
                                      ? const Color(0xFF2D2319)
                                      : null,

                                  /// ✅ UNREAD BORDER
                                  border: isUnread
                                      ? Border.all(
                                          color: const Color(0x80D29F2A),
                                          width: 2,
                                        )
                                      : null,

                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenHeight * 0.018,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// ICON
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: screenWidth * 0.03,
                                      ),
                                      child: Image.asset(
                                        AppAssets.notificationAppIcon,
                                        width: screenWidth * 0.10,
                                        height: screenWidth * 0.10,
                                      ),
                                    ),

                                    /// CONTENT
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// TITLE
                                          // Text(
                                          //   notif.title,
                                          //   style: GoogleFonts.outfit(
                                          //     fontSize: screenWidth * 0.045,
                                          //     fontWeight: FontWeight.w400,
                                          //     color: Colors.white,
                                          //     height: 1.3,
                                          //   ),
                                          // ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// TITLE
                                              Expanded(
                                                child: Text(
                                                  notif.title,
                                                  style: GoogleFonts.outfit(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width: screenWidth * 0.02,
                                              ),

                                              /// DATE + TIME (top-right)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    notifDay,
                                                    style: GoogleFonts.outfit(
                                                      fontSize:
                                                          screenWidth * 0.030,
                                                      color: Colors.white70,
                                                      height: 1.1,
                                                    ),
                                                  ),

                                                  Text(
                                                    notifTime,
                                                    style: GoogleFonts.outfit(
                                                      fontSize:
                                                          screenWidth * 0.028,
                                                      color: Colors.white70,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.008,
                                          ),

                                          /// BODY
                                          Text(
                                            notif.body,
                                            style: GoogleFonts.outfit(
                                              fontSize: screenWidth * 0.038,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white70,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
  }
}
