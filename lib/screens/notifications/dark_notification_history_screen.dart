import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
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

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUserAndFetch() async {
    final role = await getUserRole();
    final phone = await getUserPhone();

    if (role != null && phone != null) {
      setState(() {
        userId = "${role}_$phone";
      });

      final provider = Provider.of<NotificationHistoryProvider>(
        context,
        listen: false,
      );
      await provider.fetchUserNotificationHistory(userId!);
    }
  }

  void _onScroll() {
    final provider = Provider.of<NotificationHistoryProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        provider.hasMore &&
        !provider.isPaginating) {
      provider.fetchUserNotificationHistory(userId!, loadMore: true);
    }
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<NotificationHistoryProvider>(
      context,
      listen: false,
    );
    provider.reset();
    await provider.fetchUserNotificationHistory(userId!);
    // _scrollController.jumpTo(0);
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationHistoryProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Notification History",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: userId == null
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
                        horizontal: screenWidth * 0.04,
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color.fromRGBO(210, 159, 42, 0.65),
                                Color.fromRGBO(255, 255, 255, 0.65),
                              ],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.018,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.006),
                                Text(
                                  notif.body,
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.008),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTimestamp(notif.timestamp),
                                      style: GoogleFonts.outfit(
                                        fontSize: screenWidth * 0.032,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
