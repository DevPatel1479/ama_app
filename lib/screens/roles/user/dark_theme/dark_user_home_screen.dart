import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/client_testimonial_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/image_slider.dart'
    show AutoScrollSlider;
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/custom_widgets/our_legacy_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/send_notification_sheet.dart';
import 'package:ama_legal_solutions/custom_widgets/team_image_slider.dart';
import 'package:ama_legal_solutions/custom_widgets/video_lazy_loading_widget.dart';

import 'package:ama_legal_solutions/provider/profile/profile_photo_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:video_player/video_player.dart';

class DarkHomeScreen extends StatefulWidget {
  const DarkHomeScreen({super.key});

  @override
  _DarkHomeScreenState createState() => _DarkHomeScreenState();
}

class _DarkHomeScreenState extends State<DarkHomeScreen> {
  String? userName;
  String? userRole;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    fetchUserNameAndRole();
  }

  Future<void> fetchUserNameAndRole() async {
    final fetchedName = await getUserName();
    final fetchedRole = await getUserRole();
    final fetchedEmail = await getUserEmail();
    final fetchedPhone = await getUserPhone();

    // print(fetchedRole);
    if (!mounted) return; // only return if widget is disposed

    setState(() {
      userName = fetchedName;
      userRole = fetchedRole;
      userEmail = fetchedEmail;
      userPhone = fetchedPhone;
    });
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (userRole != null && userEmail != null) {
      // replace with correct identifiers
      provider.fetchProfilePhoto(
        context,
        phone: fetchedPhone!, // or actual phone if available
        role: userRole!,
      );
      // print(provider.profilePhotoUrl);
    }
  }

  Widget _buildAppBarForHomeScreen({
    required BuildContext context,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userRole,
    required double avatarDiameter,
    required double fontSize,
    required double iconSize,
    required double dotSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04 * scaleFactor,
        vertical: screenHeight * 0.015 * scaleFactor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return InkWell(
                    onTap: () {
                      context.pushNamed(
                        AppScreenNames.userAccount,
                        queryParameters: {
                          "name": userName,
                          "email": userEmail,
                          "profile_photo": userRole == "guest"
                              ? AppAssets.userIcon
                              : provider.hasProfilePhoto
                              ? provider.profilePhotoUrl!
                              : AppAssets.userIcon,
                          "phone": userPhone,
                          "role": userRole,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(avatarDiameter / 2),
                    child: CircleAvatar(
                      radius: avatarDiameter / 2,
                      backgroundImage: userRole == "guest"
                          ? const AssetImage(AppAssets.userIcon)
                                as ImageProvider
                          : provider.hasProfilePhoto
                          ? NetworkImage(
                              "${provider.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : const AssetImage(AppAssets.userIcon)
                                as ImageProvider,
                    ),
                  );
                },
              ),
              SizedBox(width: screenWidth * 0.03 * scaleFactor),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Hi, ",
                    style: GoogleFonts.outfit(
                      fontSize: fontSize * scaleFactor,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: globalUserName,
                    builder: (context, name, _) => Text(
                      "$name",
                      style: GoogleFonts.outfit(
                        fontSize: fontSize * scaleFactor,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD29F2A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              /// Notification History Icon
              if (userRole?.toLowerCase() == "admin")
                GestureDetector(
                  onTap: () {
                    context.pushNamed(AppScreenNames.notificationHistoryScreen);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: screenWidth * 0.03 * scaleFactor,
                    ),
                    child: Icon(
                      Icons
                          .history, // or Icons.notifications_outlined for a similar feel
                      size: iconSize,
                      color: Colors.green,
                    ),
                  ),
                ),

              /// Notification Icon with badge
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (userRole?.toLowerCase() == "guest") {
                        final isDark = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).isDarkMode;
                        showDialog(
                          context: context,
                          builder: (_) => LoginRequiredDialog(
                            isDarkTheme: isDark,

                            onLoginPressed: () {
                              Navigator.pop(context);
                              context.goNamed(AppScreenNames.logIn);
                              // context.pushNamed(AppScreenNames.l);
                            },
                          ),
                        );
                        return;
                      }
                      if (userRole?.toLowerCase() == "admin") {
                        String userId = "${userRole}_${userPhone}";
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => SendNotificationSheet(userId: userId),
                        );
                      } else {
                        context.pushNamed(AppScreenNames.notificationScreen);
                      }
                    },
                    child: Icon(
                      Icons.notifications,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  if (userRole == "client" ||
                      userRole == "advocate" ||
                      userRole == "user")
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.light,
    //     statusBarBrightness: Brightness.dark,
    //   ),
    // );
    // Screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    // Dynamic sizes
    final avatarDiameter = screenWidth * 0.10 * scaleFactor;
    final fontSize = screenWidth * 0.06 * scaleFactor;
    final iconSize = screenWidth * 0.075 * scaleFactor;
    final dotSize = screenWidth * 0.025 * scaleFactor;

    // Card sizes
    final statCardHeight = screenHeight * 0.14;

    final statNumberFont = screenWidth * 0.06;
    final statLabelFont = screenWidth * 0.035;
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // amount of extra space to reserve at bottom so the last item is fully visible
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;
    // ----------------------------
    final role = context.watch<RealTimeRoleProvider>().role;
    userRole = role;
    // Responsive button
    Widget fileDisputeButton(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      final buttonWidth = screenWidth; // responsive width
      final buttonHeight =
          screenHeight * 0.06 * scaleFactor; // responsive height ~50px
      final horizontalPadding = buttonWidth * 0.05 * scaleFactor;
      final verticalPadding = buttonHeight * 0.25 * scaleFactor;

      return GestureDetector(
        onTap: () {
          if (userRole?.toLowerCase() == "guest") {
            final isDark = Provider.of<ThemeProvider>(
              context,
              listen: false,
            ).isDarkMode;
            showDialog(
              context: context,
              builder: (_) => LoginRequiredDialog(
                isDarkTheme: isDark,

                onLoginPressed: () {
                  Navigator.pop(context);
                  context.goNamed(AppScreenNames.logIn);
                  // context.pushNamed(AppScreenNames.l);
                },
              ),
            );
            return;
          }

          context.pushNamed(
            AppScreenNames.raiseQuery,
            queryParameters: {"isFilingDispute": "true"},
          );
        },
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              begin: Alignment(-1.0, -0.1),
              end: Alignment(1.0, 0.1),
              colors: [Color(0xFFD29F2A), Colors.white],
              stops: [0.0155, 1.2282],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // center everything
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.fileDispute,
                width: buttonHeight * 0.6,
                height: buttonHeight * 0.6,
              ),
              SizedBox(
                width: screenWidth * 0.02 * scaleFactor,
              ), // very close to text
              Text(
                "Raise a Query",
                style: GoogleFonts.outfit(
                  fontSize:
                      screenWidth * 0.05 * scaleFactor, // responsive ~20px
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Single stat widget
    Widget statItem(String number, String label) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.18 * scaleFactor,
            child: Text(
              number,
              style: GoogleFonts.outfit(
                fontSize: statNumberFont * scaleFactor,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1,
                letterSpacing: -0.019 * statNumberFont,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: screenWidth * 0.18 * scaleFactor,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: statLabelFont * scaleFactor,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1,
                letterSpacing: -0.019 * statLabelFont,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    // Vertical separator
    Widget verticalLine(double height) {
      return Container(
        width: 2,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF957223), Colors.white, Color(0xFF44351B)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          automaticallyImplyLeading: false,

          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,

            /// ANDROID ICONS → white
            statusBarIconBrightness: Brightness.light,

            /// iOS ICONS → white
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              pinned: true,
              elevation: 0,
              toolbarHeight: 70,

              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    color: Colors.black.withOpacity(0.20), // frosted effect
                    child: _buildAppBarForHomeScreen(
                      context: context,
                      userName: userName,
                      userEmail: userEmail,
                      userPhone: userPhone,
                      userRole: userRole,
                      avatarDiameter: avatarDiameter,
                      fontSize: fontSize,
                      iconSize: iconSize,
                      dotSize: dotSize,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                top: false,
                child: Column(
                  children: [
                    /// Fixed AppBar

                    // SizedBox(height: screenHeight * 0.04),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04 * scaleFactor,
                              vertical: screenHeight * 0.015 * scaleFactor,
                            ).copyWith(
                              // ensure the scrollable content has extra bottom padding equal
                              // to the visible nav footprint so last items can scroll above it
                              bottom: contentBottomPadding,
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: statCardHeight * 0.15,
                                horizontal: screenWidth * 0.05,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(210, 159, 42, 0.7),
                                    Color.fromRGBO(45, 35, 25, 0.7),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    offset: Offset(0, -4),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0x26FFFFFF),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  statItem("10k+", "Case\nhandled"),
                                  verticalLine(statCardHeight * 0.6),
                                  statItem("40+", "Year\nExperience"),
                                  verticalLine(statCardHeight * 0.6),
                                  statItem("5k+", "Client\nServed"),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.04 * scaleFactor),

                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF262626),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isTablet = constraints.maxWidth > 600;
                                  final aspectRatio = isTablet
                                      ? 21 / 9
                                      : 16 / 9; // adaptive

                                  return AspectRatio(
                                    aspectRatio: aspectRatio,
                                    // child: _VideoPlayerWidget(),
                                    child: const LazyVideoPlayer(),
                                  );
                                },
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * 0.03 * scaleFactor,
                            ), // spacing

                            if (userRole?.toLowerCase() != "admin")
                              fileDisputeButton(context),
                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight *
                                    0.03 *
                                    scaleFactor, // space below button
                                left: screenWidth * 0.01 * scaleFactor,
                                right: screenWidth * 0.04 * scaleFactor,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft, // ⬅ left align
                                child: Text(
                                  "Providing Solutions To",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.02 * scaleFactor,
                            ), // spacing
                            const AutoScrollSlider(),
                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight *
                                    0.03 *
                                    scaleFactor, // space below button
                                left: screenWidth * 0.01 * scaleFactor,
                                right: screenWidth * 0.04 * scaleFactor,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft, // ⬅ left align
                                child: Text(
                                  "Our Locations",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.01 * scaleFactor,
                                vertical: screenHeight * 0.02 * scaleFactor,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final totalWidth = constraints.maxWidth;
                                  final columnSpacing =
                                      screenWidth * 0.04 * scaleFactor;
                                  final columnWidth =
                                      (totalWidth - 2 * columnSpacing) / 3;

                                  return Stack(
                                    children: [
                                      // The main row with images
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // First column
                                          SizedBox(
                                            width: columnWidth,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  AppAssets.locationImg1,
                                                  fit: BoxFit.cover,
                                                ),
                                                SizedBox(
                                                  height:
                                                      screenHeight *
                                                      0.025 *
                                                      scaleFactor,
                                                ), // reduced space
                                                Image.asset(
                                                  AppAssets.locationImg4,
                                                  fit: BoxFit.cover,
                                                ),
                                                // Removed extra space here; locationImg5 will overlap
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: columnSpacing),

                                          // Second column
                                          SizedBox(
                                            width: columnWidth,
                                            child: Image.asset(
                                              AppAssets.locationImg2,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: columnSpacing),

                                          // Third column
                                          SizedBox(
                                            width: columnWidth,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  AppAssets.locationImg3,
                                                  fit: BoxFit.cover,
                                                ),
                                                SizedBox(
                                                  height:
                                                      screenHeight *
                                                      0.025 *
                                                      scaleFactor,
                                                ),
                                                Image.asset(
                                                  AppAssets.locationImg6,
                                                  fit: BoxFit.cover,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Positioned locationImg5 stretched as required
                                      Positioned(
                                        left: 0,
                                        top: null,
                                        bottom: 0,
                                        child: Container(
                                          width:
                                              columnWidth * 2 + columnSpacing,
                                          // Position it just below locationImg4
                                          margin: EdgeInsets.only(
                                            top:
                                                screenHeight *
                                                    0.015 + // space below locationImg1
                                                // assume locationImg1 height + spacing
                                                // plus locationImg4 height (approximated or static if possible)
                                                150, // adjust this based on actual image heights
                                          ),
                                          height: null, // stretch to the bottom
                                          child: Image.asset(
                                            AppAssets.locationImg5,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight * 0.0001, // space below button
                                left: screenWidth * 0.01,
                                right: screenWidth * 0.000015,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Our Team",
                                    style: GoogleFonts.outfit(
                                      fontSize:
                                          screenWidth * 0.04 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  // TextButton(
                                  //   onPressed: () {
                                  //     // Handle "See all" tap here
                                  //   },
                                  //   child: Text(
                                  //     "See all",
                                  //     style: GoogleFonts.outfit(
                                  //       fontSize: screenWidth * 0.035 * scaleFactor,
                                  //       fontWeight: FontWeight.w500,
                                  //       color: const Color(0xFFD29F2A),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            // Below the Padding containing "Our Team" and "See all"
                            SizedBox(
                              height: screenHeight * 0.02,
                            ), // spacing between sections
                            const TeamSlider(),
                            // Padding(
                            //   padding: EdgeInsets.only(
                            //     top: screenHeight * 0.03, // space below button
                            //     left: screenWidth * 0.01,
                            //     right: screenWidth * 0.04,
                            //   ),
                            //   child: Align(
                            //     alignment: Alignment.centerLeft, // ⬅ left align
                            //     child: Text(
                            //       "Our Legacy",
                            //       style: GoogleFonts.outfit(
                            //         fontSize: screenWidth * 0.04 * scaleFactor,
                            //         fontWeight: FontWeight.w500,
                            //         color: Colors.white,
                            //         height: 1,
                            //         letterSpacing: 0,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(height: screenHeight * 0.02 * scaleFactor),

                            // Padding(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: screenWidth * 0.01 * scaleFactor,
                            //   ),
                            //   child: LayoutBuilder(
                            //     builder: (context, constraints) {
                            //       return IntrinsicHeight(
                            //         child: Row(
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.stretch,
                            //           children: [
                            //             // Left Image with gradient border
                            //             Container(
                            //               width:
                            //                   screenWidth *
                            //                   0.4 *
                            //                   scaleFactor, // responsive width
                            //               decoration: BoxDecoration(
                            //                 borderRadius: BorderRadius.circular(
                            //                   25,
                            //                 ),
                            //                 gradient: const LinearGradient(
                            //                   colors: [
                            //                     Color.fromRGBO(
                            //                       210,
                            //                       159,
                            //                       42,
                            //                       0.65,
                            //                     ),
                            //                     Color.fromRGBO(
                            //                       255,
                            //                       255,
                            //                       255,
                            //                       0.65,
                            //                     ),
                            //                   ],
                            //                   begin: Alignment.centerLeft,
                            //                   end: Alignment.centerRight,
                            //                 ),
                            //               ),
                            //               padding: const EdgeInsets.all(
                            //                 2,
                            //               ), // border thickness
                            //               child: Container(
                            //                 decoration: BoxDecoration(
                            //                   borderRadius: BorderRadius.circular(
                            //                     25,
                            //                   ), // slightly smaller for inner image
                            //                   image: DecorationImage(
                            //                     image: AssetImage(
                            //                       AppAssets.ourLegacyImg,
                            //                     ),
                            //                     fit: BoxFit.cover,
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //             SizedBox(
                            //               width: screenWidth * 0.04 * scaleFactor,
                            //             ), // spacing
                            //             // Right Text Column
                            //             Expanded(
                            //               child: Column(
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.start,
                            //                 children: [
                            //                   Text(
                            //                     "Late Adv. R.C. Malik",
                            //                     style: GoogleFonts.outfit(
                            //                       fontSize: 15,
                            //                       fontWeight: FontWeight.w500,
                            //                       color: Color(0xFFD29F2A),
                            //                       height: 20 / 15,
                            //                     ),
                            //                   ),
                            //                   SizedBox(
                            //                     height:
                            //                         screenHeight *
                            //                         0.005 *
                            //                         scaleFactor,
                            //                   ),
                            //                   Text(
                            //                     "Ex-Comptroller and Auditor General of India\nDirector General of Audit (Central-Receipt)",
                            //                     style: GoogleFonts.outfit(
                            //                       fontSize: 12,
                            //                       fontWeight: FontWeight.w400,
                            //                       color: Colors.white,
                            //                       height: 16 / 12,
                            //                     ),
                            //                   ),
                            //                   SizedBox(
                            //                     height:
                            //                         screenHeight *
                            //                         0.01 *
                            //                         scaleFactor,
                            //                   ),
                            //                   Text(
                            //                     "R.C. Malik started his professional journey as a "
                            //                     "gazetted officer at DGACR, progressing through "
                            //                     "different roles within the Income Tax Department "
                            //                     "before taking on administrative duties at the "
                            //                     "Office of the Comptroller and Auditor General "
                            //                     "(CAG) of India.",
                            //                     style: GoogleFonts.outfit(
                            //                       fontSize: 10,
                            //                       fontWeight: FontWeight.w400,
                            //                       color: Colors.white,
                            //                       height: 14 / 10,
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                            OurLegacySection(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              scaleFactor: scaleFactor,
                              isDark: true,
                            ),
                            SizedBox(height: screenHeight * 0.02 * scaleFactor),
                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight *
                                    0.0001 *
                                    scaleFactor, // space below button
                                left: screenWidth * 0.01 * scaleFactor,
                                right: screenWidth * 0.000015 * scaleFactor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Client Testimonials",
                                    style: GoogleFonts.outfit(
                                      fontSize:
                                          screenWidth * 0.04 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  // TextButton(
                                  //   onPressed: () {
                                  //     // Handle "See all" tap here
                                  //   },
                                  //   child: Text(
                                  //     "See all",
                                  //     style: GoogleFonts.outfit(
                                  //       fontSize: screenWidth * 0.035 * scaleFactor,
                                  //       fontWeight: FontWeight.w500,
                                  //       color: const Color(0xFFD29F2A),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            // Below the Padding containing "Our Team" and "See all"
                            SizedBox(
                              height: screenHeight * 0.001 * scaleFactor,
                            ),
                            TestimonialCard(
                              name: "Pratichi Pradhan",
                              testimonial:
                                  "Phenomenal services! Turnaround time was half day to get the papers in order, extend a reasonable price.",
                              clientImage: AppAssets.clientImage1,
                            ),
                            SizedBox(
                              height: screenHeight * 0.001 * scaleFactor,
                            ),
                            TestimonialCard(
                              name: "Sk Nazir",
                              testimonial:
                                  "Outstanding consultation! Ama Legal Solutions prioritizes client satisfaction and delivers quick, effective results.",
                              clientImage: AppAssets.clientImage2,
                            ),
                          ],
                        ),
                      ),

                      /// Stats card
                    ),
                  ],
                ),
              ),
            ),
            // ========== OVERLAY: CustomBottomNav (always on top) ==========
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
        ),

        // bottomNavigationBar: const CustomBottomNav(),
      ),
    );
  }
}
