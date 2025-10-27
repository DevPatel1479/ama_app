import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart'
    show LocalStorageHelper;
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<NotificationProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppPathsForScreen.userHomePath),
                    child: Image.asset(
                      AppAssets.backArrowIcon,
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.12),
                  Text(
                    "Notifications",
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

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
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
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
                  );
                },
              ),
            ),
          ],
        ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
