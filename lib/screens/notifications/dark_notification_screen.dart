import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart'
    show LocalStorageHelper;
// import 'package:ama_legal_solutions/models/notification_model.dart'
//     show NotificationModel;
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:ama_legal_solutions/provider/notifications/notification_provider.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationProvider _provider;
  final ScrollController _scrollController = ScrollController();
  String? _userRole;
  bool _isFetchingMore = false; // prevent multiple same fetches

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _provider = Provider.of<NotificationProvider>(context, listen: false);
      _provider.clearNotifications();
      final phone = await LocalStorageHelper.getString("userPhone");
      await _provider.fetchLastOpenedNotificationTime(phone: phone ?? "");
      _loadRoleAndFetch();

      /// Listen for scroll to bottom for lazy loading
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
            !_isFetchingMore &&
            !_provider.isLoading &&
            _provider.hasMore) {
          _fetchMore();
        }
      });
    });
  }

  Future<void> _loadRoleAndFetch() async {
    final role = await LocalStorageHelper.getString("userRole");

    setState(() => _userRole = role);

    if (role != null && role.isNotEmpty) {
      await _provider.fetchNotifications(context: context, role: role);
    }
  }

  Future<void> _fetchMore() async {
    if (_userRole == null || _userRole!.isEmpty) return;

    setState(() => _isFetchingMore = true);
    await _provider.fetchNotifications(
      context: context,
      role: _userRole!,
      loadMore: true,
    );
    setState(() => _isFetchingMore = false);
  }

  Future<void> _onRefresh() async {
    if (_userRole != null) {
      await _provider.fetchNotifications(context: context, role: _userRole!);
    }
  }

  /// LIGHT THEME APPBAR (your custom golden AppBar)
  PreferredSizeWidget _buildLightAppBar(double screenWidth) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(
              0xFFFFFBF1,
            ).withOpacity(0.85), // iOS-style frosted background
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go(AppPathsForScreen.userHomePath),
                  child: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),

                Text(
                  'Notifications',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: (screenWidth / 100) * 6.5 * 0.85,
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
    return AppBar(
      backgroundColor: Color(0xFF171717),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Image.asset(
          AppAssets.backArrowIcon,
          width: screenWidth * 0.06,
          height: screenWidth * 0.06,
          fit: BoxFit.contain,
          color: Colors.white,
        ),
        onPressed: () => context.go(AppPathsForScreen.userHomePath),
      ),
      title: Text(
        "Notifications",
        style: GoogleFonts.outfit(
          fontSize: screenWidth * 0.065,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF171717) : Color(0xFFFFFBF1),
      extendBody: !isDark,
      extendBodyBehindAppBar: !isDark,

      // appBar: isDark
      //     ? _buildDarkAppBar(screenWidth)
      //     : _buildLightAppBar(screenWidth),
      body: isDark
          ? buildDarkThemeLayout(screenWidth, screenHeight)
          : buildLightThemeLayout(screenWidth, screenHeight),
    );
  }

  String formatNotifDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatNotifTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
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

  bool shouldShowDot(NotificationProvider provider, int notificationTimestamp) {
    final lastOpened = provider.lastOpenedNotificationTime;

    // First-time user → all unread
    if (lastOpened == null) return true;

    return notificationTimestamp > lastOpened;
  }

  Widget buildLightThemeLayout(double screenWidth, double screenHeight) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Stack(
        children: [
          // Main Content
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              if (provider.notifications.isEmpty) {
                return const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.amber,
                backgroundColor: Colors.black,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top:
                        kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        screenHeight * 0.015, // ✅ top padding added
                    bottom: screenHeight * 0.015,
                  ),
                  itemCount:
                      provider.notifications.length +
                      (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.notifications.length &&
                        provider.hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      );
                    }

                    final notif = provider.notifications[index];
                    final DateTime notifDate = parseTimestamp(notif.timestamp);

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
                                color: Color(0xFF2D2319),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                fontSize: screenWidth * 0.030,
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
                                                fontSize: screenWidth * 0.028,
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
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  color: const Color(0xFFFFFBF1).withOpacity(0.45),
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.04,
                    top: screenHeight * 0.03,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppPathsForScreen.userHomePath),
                        child: Image.asset(
                          AppAssets.backArrowIcon,
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          fit: BoxFit.contain,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Notifications',
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
          ),
        ],
      ),
    );
  }

  Widget buildDarkThemeLayout(double screenWidth, double screenHeight) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Stack(
        children: [
          // Main Content
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (provider.notifications.isEmpty) {
                return const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.amber,
                backgroundColor: Colors.black,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top:
                        kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        screenHeight * 0.015, // ✅ top padding added
                    bottom: screenHeight * 0.015,
                  ),
                  itemCount:
                      provider.notifications.length +
                      (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.notifications.length &&
                        provider.hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }

                    final notif = provider.notifications[index];

                    final DateTime notifDate = parseTimestamp(notif.timestamp);

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
                            color: isUnread ? const Color(0xFF2D2319) : null,

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
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
                                                fontSize: screenWidth * 0.030,
                                                color: Colors.white70,
                                                height: 1.1,
                                              ),
                                            ),

                                            Text(
                                              notifTime,
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.028,
                                                color: Colors.white70,
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
              );
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  color: const Color(
                    0xFF171717,
                  ).withOpacity(0.45), // Dark frosted
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.04,
                    top: MediaQuery.of(context).padding.top,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppPathsForScreen.userHomePath),
                        child: Image.asset(
                          AppAssets.backArrowIcon,
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Notifications',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: (screenWidth / 100) * 6.5 * 0.85,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FIXED timestamp (handles seconds or milliseconds safely)
  String _formatTimestamp(int timestamp) {
    if (timestamp < 1000000000000) {
      timestamp *= 1000; // convert seconds → milliseconds
    }
    final date = DateTime.fromMillisecondsSinceEpoch(
      timestamp,
      isUtc: false,
    ).toLocal();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _markNotificationsSeen() async {
    final phone = await LocalStorageHelper.getString("userPhone");
    if (phone != null) {
      await _provider.updateLastOpenedNotificationTime(phone: phone);
    }
  }

  @override
  void dispose() {
    _markNotificationsSeen();

    _scrollController.dispose();

    super.dispose();
  }
}
