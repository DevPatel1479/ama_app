import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart'
    show LocalStorageHelper;
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, SystemChrome;
import 'package:go_router/go_router.dart';
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

  PreferredSizeWidget _buildLightAppBar(double screenWidth) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 247, 207, 78),
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
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                  fit: BoxFit.contain,
                  color: Colors.black,
                ),
              ),

              SizedBox(width: screenWidth * 0.02 * 0.85),

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
        "Notification Hstory",
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
    // final provider = Provider.of<NotificationHistoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Color(0xFFF8BD00),
      extendBody: !isDark,
      extendBodyBehindAppBar: !isDark,

      appBar: isDark
          ? _buildDarkAppBar(screenWidth)
          : _buildLightAppBar(screenWidth),

      body: isDark
          ? Consumer<NotificationHistoryProvider>(
              builder: (contex, provider, _) {
                return buildForDarkTheme(provider, screenWidth, screenHeight);
              },
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
    return userId == null
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : SafeArea(
            child: GradientTopLayout(
              keepExpanded: false,
              screenName: "home",

              child: RefreshIndicator(
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
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          // horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        itemCount:
                            provider.notifications.length +
                            (provider.isPaginating ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.notifications.length &&
                              provider.isPaginating) {
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
                            margin: EdgeInsets.only(
                              bottom: screenHeight * 0.015,
                            ),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(14),
                            //   // gradient: const LinearGradient(
                            //   //   begin: Alignment.centerLeft,
                            //   //   end: Alignment.centerRight,
                            //   //   colors: [
                            //   //     Color.fromRGBO(210, 159, 42, 0.65),
                            //   //     Color.fromRGBO(255, 255, 255, 0.65),
                            //   //   ],
                            //   // ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  fontStyle: FontStyle
                                                      .normal, // Regular
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
                                            fontWeight: FontWeight
                                                .w400, // Regular (400)
                                            fontStyle:
                                                FontStyle.normal, // Regular
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
                                                color: Color(
                                                  0xFFD29F2A,
                                                ), // golden circle
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
              ),
            ),
          );
  }

  Widget buildForDarkTheme(
    NotificationHistoryProvider provider,
    double screenWidth,
    double screenHeight,
  ) {
    return userId == null
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : RefreshIndicator(
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      // horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    itemCount:
                        provider.notifications.length +
                        (provider.isPaginating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.notifications.length &&
                          provider.isPaginating) {
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
                        //   gradient: const LinearGradient(
                        //     begin: Alignment.centerLeft,
                        //     end: Alignment.centerRight,
                        //     colors: [
                        //       Color.fromRGBO(210, 159, 42, 0.65),
                        //       Color.fromRGBO(255, 255, 255, 0.65),
                        //     ],
                        //   ),
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
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.w600,
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
                                        fontSize: screenWidth * 0.040,
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
                                            color: Color(
                                              0xFFD29F2A,
                                            ), // golden circle
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
  }
}
