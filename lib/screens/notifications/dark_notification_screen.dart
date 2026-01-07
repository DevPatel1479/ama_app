import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart'
    show LocalStorageHelper;
import 'package:ama_legal_solutions/models/notification_model.dart'
    show NotificationModel;
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 244, 206, 83),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.07),
            bottomRight: Radius.circular(screenWidth * 0.07),
          ),
        ),

        titleSpacing: 0,

        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go(AppPathsForScreen.userHomePath),
                child: Image.asset(
                  AppAssets.backArrowIcon,
                  width: screenWidth * 0.06 * 0.85,
                  height: screenWidth * 0.06 * 0.85,
                  fit: BoxFit.contain,
                  color: Colors.black,
                ),
              ),

              SizedBox(width: screenWidth * 0.02 * 0.85),

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
    );
  }

  /// DARK THEME APPBAR (your original black one)
  PreferredSizeWidget _buildDarkAppBar(double screenWidth) {
    return AppBar(
      backgroundColor: Colors.black,
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
      backgroundColor: isDark ? Colors.black : Color(0xFFF8BD00),
      extendBody: !isDark,
      extendBodyBehindAppBar: !isDark,

      appBar: isDark
          ? _buildDarkAppBar(screenWidth)
          : _buildLightAppBar(screenWidth),
      body: isDark
          ? buildDarkThemeLayout(screenWidth, screenHeight)
          : buildLightThemeLayout(screenWidth, screenHeight),
    );
  }

  bool shouldShowDot(NotificationProvider provider, int notificationTimestamp) {
    final lastOpened = provider.lastOpenedNotificationTime;

    // First-time user → all unread
    if (lastOpened == null) return true;

    return notificationTimestamp > lastOpened;
  }

  Widget buildLightThemeLayout(double screenWidth, double screenHeight) {
    return SafeArea(
      child: GradientTopLayout(
        screenName: "home",
        keepExpanded: false,
        child:
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
                    padding: EdgeInsets.symmetric(
                      // horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    itemCount:
                        provider.notifications.length +
                        (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.notifications.length) {
                        // pagination loader
                        return const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }

                      final notif = provider.notifications[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(14),
                        // ),
                        child: Container(
                          // margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2319),
                            // borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.018,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LEFT ICON
                              Container(
                                margin: EdgeInsets.only(
                                  right: screenWidth * 0.03,
                                ),
                                child: Image.asset(
                                  AppAssets.notificationAppIcon,
                                  width: screenWidth * 0.10,
                                  height: screenWidth * 0.10,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              /// RIGHT CONTENT (takes remaining width)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// TOP ROW → title + timestamp
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// TITLE (expanded so it never overflows)
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                            style: GoogleFonts.outfit(
                                              fontSize:
                                                  screenWidth *
                                                  0.045, // Responsive based on width
                                              fontWeight: FontWeight
                                                  .w400, // 400 = Regular
                                              fontStyle:
                                                  FontStyle.normal, // Regular
                                              height:
                                                  (18 /
                                                  (screenWidth *
                                                      0.045)), // Responsive line-height
                                              letterSpacing: 0, // 0%
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: screenWidth * 0.02),

                                        /// TIMESTAMP (top-right)
                                        Text(
                                          _formatTimestamp(notif.timestamp),
                                          style: GoogleFonts.outfit(
                                            fontSize: screenWidth * 0.030,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight * 0.008),

                                    /// BODY TEXT – fully visible
                                    Text(
                                      notif.body,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: GoogleFonts.outfit(
                                        fontSize:
                                            screenWidth *
                                            0.038, // Responsive ~15px
                                        fontWeight:
                                            FontWeight.w400, // Regular (400)
                                        fontStyle: FontStyle.normal, // Regular
                                        height:
                                            15 /
                                            (screenWidth *
                                                0.038), // Responsive line-height
                                        letterSpacing: 0, // 0%
                                        color: Colors.white70,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.010),

                                    /// SEEN INDICATOR (bottom-right)
                                    if (shouldShowDot(
                                      provider,
                                      notif.timestamp,
                                    ))
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: screenWidth * 0.03,
                                          height: screenWidth * 0.03,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFD29F2A),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget buildDarkThemeLayout(double screenWidth, double screenHeight) {
    return SafeArea(
      child: Column(
        children: [
          // Main Content
          Expanded(
            child: Consumer<NotificationProvider>(
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
                    // padding: EdgeInsets.symmetric(
                    //   horizontal: screenWidth * 0.04,
                    //   vertical: screenHeight * 0.01,
                    // ),
                    itemCount:
                        provider.notifications.length +
                        (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.notifications.length) {
                        // pagination loader
                        return const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      final notif = provider.notifications[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(14),
                        // ),
                        child: Container(
                          // margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2319),
                            // borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.018,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LEFT ICON
                              Container(
                                margin: EdgeInsets.only(
                                  right: screenWidth * 0.03,
                                ),
                                child: Image.asset(
                                  AppAssets.notificationAppIcon,
                                  width: screenWidth * 0.10,
                                  height: screenWidth * 0.10,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              /// RIGHT CONTENT (takes remaining width)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// TOP ROW → title + timestamp
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// TITLE (expanded so it never overflows)
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                            style: GoogleFonts.outfit(
                                              fontSize:
                                                  screenWidth *
                                                  0.045, // Responsive based on width
                                              fontWeight: FontWeight
                                                  .w400, // 400 = Regular
                                              fontStyle:
                                                  FontStyle.normal, // Regular
                                              height:
                                                  (18 /
                                                  (screenWidth *
                                                      0.045)), // Responsive line-height
                                              letterSpacing: 0, // 0%
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: screenWidth * 0.02),

                                        /// TIMESTAMP (top-right)
                                        Text(
                                          _formatTimestamp(notif.timestamp),
                                          style: GoogleFonts.outfit(
                                            fontSize: screenWidth * 0.030,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight * 0.008),

                                    /// BODY TEXT – fully visible
                                    Text(
                                      notif.body,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: GoogleFonts.outfit(
                                        fontSize:
                                            screenWidth *
                                            0.038, // Responsive ~15px
                                        fontWeight:
                                            FontWeight.w400, // Regular (400)
                                        fontStyle: FontStyle.normal, // Regular
                                        height:
                                            15 /
                                            (screenWidth *
                                                0.038), // Responsive line-height
                                        letterSpacing: 0, // 0%
                                        color: Colors.white70,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.010),

                                    /// SEEN INDICATOR (bottom-right)

                                    // Align(
                                    //   alignment: Alignment.bottomRight,
                                    //   child: Container(
                                    //     width: screenWidth * 0.03,
                                    //     height: screenWidth * 0.03,
                                    //     decoration: const BoxDecoration(
                                    //       shape: BoxShape.circle,
                                    //       color: Color(
                                    //         0xFFD29F2A,
                                    //       ), // golden circle
                                    //     ),
                                    //   ),
                                    // ),
                                    if (shouldShowDot(
                                      provider,
                                      notif.timestamp,
                                    ))
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: screenWidth * 0.03,
                                          height: screenWidth * 0.03,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFD29F2A),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
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
