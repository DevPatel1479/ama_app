import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/client_testimonial_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
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
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
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

class LightHomeScreen extends StatefulWidget {
  const LightHomeScreen({super.key});
  @override
  _LightHomeScreen createState() => _LightHomeScreen();
}

class _LightHomeScreen extends State<LightHomeScreen> {
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
        phone: fetchedPhone ?? "", // or actual phone if available
        role: userRole!,
      );
      // print(provider.profilePhotoUrl);
    }
  }

  final lightGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8BD00), Color(0xFFFFFFFF)],
    stops: [0.0, 0.406],
  );

  Widget _img(String asset) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      cacheWidth: 600, // decode smaller bitmap
      filterQuality: FilterQuality.low,
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final headerVisualHeight = screenHeight * 0.03; // tweak if you need taller
    final appBarHeight =
        MediaQuery.of(context).padding.top + headerVisualHeight;
    final role = context.watch<RealTimeRoleProvider>().role;
    userRole = role;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

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
            color: const Color(0xFF2D2319),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // center everything
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.fileDispute,
                width: buttonHeight * 0.6,
                height: buttonHeight * 0.6,
                color: Colors.white,
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
                  color: Colors.white,
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
                color: Colors.black,
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
                color: Colors.black,
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

      backgroundColor: Color(0xFFF8BD00),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 244, 206, 83),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),

        // ⭐ NATIVE WAY TO ROUND ONLY BOTTOM
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.07),
            bottomRight: Radius.circular(screenWidth * 0.07),
          ),
        ),

        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,

        title: Container(
          decoration: BoxDecoration(color: Color.fromARGB(255, 244, 206, 83)),
          padding: EdgeInsets.only(
            //   top: MediaQuery.of(context).padding.top,
            left: screenWidth * 0.04 * scaleFactor,
            right: screenWidth * 0.04 * scaleFactor,
            //   bottom: screenHeight * 0.015 * scaleFactor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Avatar + "Hi, name"
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
                              "profile_photo": provider.hasProfilePhoto
                                  ? provider.profilePhotoUrl!
                                  : AppAssets.userIcon,
                              "phone": userPhone,
                              "role": userRole ?? "",
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
                      ValueListenableBuilder(
                        valueListenable: globalUserName,
                        builder: (context, name, _) => Text(
                          "$name",
                          style: GoogleFonts.outfit(
                            fontSize: fontSize * scaleFactor,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: History + Notification (with badge)
              Row(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      final isDark = themeProvider.isDarkMode;

                      return GestureDetector(
                        onTap: () {
                          // Toggle theme
                          themeProvider.setTheme(!isDark);
                        },
                        behavior: HitTestBehavior
                            .opaque, // ensures the whole padding is tappable
                        child: Padding(
                          padding: const EdgeInsets.all(8), // enough touch area
                          child: Image.asset(
                            isDark
                                ? AppAssets.darkThemeIcon
                                : AppAssets.lightThemeIcon,

                            width: 20,
                            height: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: screenWidth * 0.02 * scaleFactor),
                  if (userRole?.toLowerCase() == "admin")
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          AppScreenNames.notificationHistoryScreen,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: screenWidth * 0.03 * scaleFactor,
                        ),
                        child: Icon(
                          Icons.history,
                          size: iconSize,
                          color: Colors.black,
                        ),
                      ),
                    ),

                  // notification icon + dot
                  Stack(
                    clipBehavior: Clip.none,
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
                              builder: (_) =>
                                  SendNotificationSheet(userId: userId),
                            );
                          } else {
                            context.pushNamed(
                              AppScreenNames.notificationScreen,
                            );
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
                          right: -2,
                          top: -2,
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
        ),
      ),

      body: Stack(
        children: [
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(color: Color(0xFFF8BD00)),
          //   ),
          // ),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: GradientTopLayout(
                screenName: "home",
                // headerContent: Container(
                //   width: double.infinity,

                //   padding: EdgeInsets.symmetric(
                //     horizontal: screenWidth * 0.04 * scaleFactor,
                //     vertical: screenHeight * 0.015 * scaleFactor,
                //   ),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFD29F2A),
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(
                //         screenWidth * 0.07,
                //       ), // ~responsive
                //       bottomRight: Radius.circular(
                //         screenWidth * 0.07,
                //       ), // ~responsive
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Row(
                //         crossAxisAlignment: CrossAxisAlignment.end,
                //         children: [
                //           Consumer<ProfileProvider>(
                //             builder: (context, provider, child) {
                //               return InkWell(
                //                 onTap: () {
                //                   context.pushNamed(
                //                     AppScreenNames.userAccount,
                //                     queryParameters: {
                //                       "name": userName,
                //                       "email": userEmail,
                //                       "profile_photo": provider.hasProfilePhoto
                //                           ? provider.profilePhotoUrl!
                //                           : AppAssets.userIcon,
                //                       "phone": userPhone!,
                //                       "role": userRole!,
                //                     },
                //                   );
                //                 },
                //                 borderRadius: BorderRadius.circular(
                //                   avatarDiameter / 2,
                //                 ),
                //                 child: CircleAvatar(
                //                   radius: avatarDiameter / 2,
                //                   backgroundImage: provider.hasProfilePhoto
                //                       ? NetworkImage(
                //                           "${provider.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                //                         )
                //                       : const AssetImage(AppAssets.userIcon)
                //                             as ImageProvider,
                //                 ),
                //               );
                //             },
                //           ),

                //           SizedBox(width: screenWidth * 0.03 * scaleFactor),
                //           Row(
                //             crossAxisAlignment: CrossAxisAlignment.end,
                //             children: [
                //               Text(
                //                 "Hi, ",
                //                 style: GoogleFonts.outfit(
                //                   fontSize: fontSize * scaleFactor,
                //                   fontWeight: FontWeight.w500,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //               ValueListenableBuilder(
                //                 valueListenable: globalUserName,
                //                 builder: (context, name, _) => Text(
                //                   "$name",
                //                   style: GoogleFonts.outfit(
                //                     fontSize: fontSize * scaleFactor,
                //                     fontWeight: FontWeight.w500,
                //                     color: const Color(0xFF000000),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       Row(
                //         children: [
                //           /// Notification History Icon
                //           ///
                //           if (userRole?.toLowerCase() == "admin")
                //             GestureDetector(
                //               onTap: () {
                //                 context.pushNamed(
                //                   AppScreenNames.notificationHistoryScreen,
                //                 );
                //               },
                //               child: Padding(
                //                 padding: EdgeInsets.only(
                //                   right: screenWidth * 0.03 * scaleFactor,
                //                 ),
                //                 child: Icon(
                //                   Icons
                //                       .history, // or Icons.notifications_outlined for a similar feel
                //                   size: iconSize,
                //                   color: Colors.black,
                //                 ),
                //               ),
                //             ),

                //           /// Notification Icon with badge
                //           Stack(
                //             children: [
                //               GestureDetector(
                //                 onTap: () {
                //                   if (userRole?.toLowerCase() == "admin") {
                //                     String userId = "${userRole}_${userPhone}";
                //                     showModalBottomSheet(
                //                       context: context,
                //                       isScrollControlled: true,
                //                       backgroundColor: Colors.transparent,
                //                       builder: (_) =>
                //                           SendNotificationSheet(userId: userId),
                //                     );
                //                   } else {
                //                     context.pushNamed(
                //                       AppScreenNames.notificationScreen,
                //                     );
                //                   }
                //                 },
                //                 child: Icon(
                //                   Icons.notifications,
                //                   size: iconSize,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //               if (userRole == "client" ||
                //                   userRole == "advocate" ||
                //                   userRole == "user")
                //                 Positioned(
                //                   right: 2,
                //                   top: 2,
                //                   child: Container(
                //                     width: dotSize,
                //                     height: dotSize,
                //                     decoration: const BoxDecoration(
                //                       color: Colors.red,
                //                       shape: BoxShape.circle,
                //                     ),
                //                   ),
                //                 ),
                //             ],
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04 * scaleFactor,
                          vertical: screenHeight * 0.015 * scaleFactor,
                        ).copyWith(
                          // ensure the scrollable content has extra bottom padding equal
                          // to the visible nav footprint so last items can scroll above it
                          bottom: contentBottomPadding,
                        ),

                    // SizedBox(height: screenHeight * 0.04),
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
                                Color(0xFFFFFFFF),
                                Color.fromRGBO(210, 159, 42, 0.7),
                              ],
                              stops: [0.001, 1.0],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(64, 16, 16, 16),
                                offset: Offset(0, 4),
                                blurRadius: 1,
                                spreadRadius: 0,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0x26FFFFFF),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

                        /// Video card
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
                                child: const LazyVideoPlayer(),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.03 * scaleFactor,
                        ), // spacing
                        if (userRole?.toLowerCase() != "admin" &&
                            userRole?.toLowerCase() != "advocate")
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
                                color: Colors.black,
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
                                color: Colors.black,
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

                              return RepaintBoundary(
                                child: Stack(
                                  children: [
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
                                              _img(AppAssets.locationImg1),
                                              SizedBox(
                                                height:
                                                    screenHeight *
                                                    0.025 *
                                                    scaleFactor,
                                              ),
                                              _img(AppAssets.locationImg4),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: columnSpacing),

                                        // Second column
                                        SizedBox(
                                          width: columnWidth,
                                          child: _img(AppAssets.locationImg2),
                                        ),
                                        SizedBox(width: columnSpacing),

                                        // Third column
                                        SizedBox(
                                          width: columnWidth,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _img(AppAssets.locationImg3),
                                              SizedBox(
                                                height:
                                                    screenHeight *
                                                    0.025 *
                                                    scaleFactor,
                                              ),
                                              _img(AppAssets.locationImg6),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Overlapping image — EXACT SAME POSITIONING
                                    Positioned(
                                      left: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: columnWidth * 2 + columnSpacing,
                                        margin: EdgeInsets.only(
                                          top:
                                              screenHeight * 0.015 +
                                              150, // unchanged
                                        ),
                                        child: _img(AppAssets.locationImg5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Below the Padding containing "Our Team" and "See all"
                        OurLegacySection(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          scaleFactor: scaleFactor,
                          isDark: false,
                        ),

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
                        //         color: Colors.black,
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
                        //                 borderRadius: BorderRadius.circular(25),
                        //                 gradient: const LinearGradient(
                        //                   colors: [
                        //                     Color.fromRGBO(210, 159, 42, 0.65),
                        //                     Color.fromRGBO(255, 255, 255, 0.65),
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
                        //                       color: Colors.black,
                        //                       height: 16 / 12,
                        //                     ),
                        //                   ),
                        //                   SizedBox(
                        //                     height:
                        //                         screenHeight *
                        //                         0.005 *
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
                        //                       color: Colors.black,
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
                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // spacing between sections
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.0001, // space below button
                            left: screenWidth * 0.01,
                            right: screenWidth * 0.000015,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Our Team",
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.04 * scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
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
                        SizedBox(
                          height: screenHeight * 0.02,
                        ), // spacing between sections
                        const TeamSlider(),

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Client Testimonials",
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.04 * scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
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
                        SizedBox(height: screenHeight * 0.001 * scaleFactor),
                        TestimonialCard(
                          name: "Pratichi Pradhan",
                          testimonial:
                              "Phenomenal services! Turnaround time was half day to get the papers in order, extend a reasonable price.",
                          clientImage: AppAssets.clientImage1,
                        ),
                        SizedBox(height: screenHeight * 0.001 * scaleFactor),
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
      ),

      // bottomNavigationBar: CustomBottomNav(),
    );
  }
}

// class _VideoPlayerWidget extends StatefulWidget {
//   const _VideoPlayerWidget({Key? key}) : super(key: key);

//   @override
//   State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
//   late VideoPlayerController _videoController;
//   ChewieController? _chewieController;
//   bool _isLoading = true;

//   final videoUrl = dotenv.env['VIDEO_URL']!;
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       // ✅ Load cached video if exists
//       final file = await DefaultCacheManager().getSingleFile(videoUrl);

//       _videoController = VideoPlayerController.file(file);
//       await _videoController.initialize();

//       _chewieController = ChewieController(
//         videoPlayerController: _videoController,
//         autoPlay: false, // user must tap play
//         looping: true,
//         allowFullScreen: false,

//         allowMuting: true,
//         showControlsOnInitialize: false,
//         autoInitialize: true,
//         materialProgressColors: ChewieProgressColors(
//           playedColor: Colors.blueAccent,
//           handleColor: Colors.white,
//           backgroundColor: Colors.grey.shade800,
//           bufferedColor: Colors.grey.shade500,
//         ),
//       );

//       setState(() => _isLoading = false);
//     } catch (e) {
//       debugPrint("Video init error: $e");
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _videoController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Shimmer.fromColors(
//         baseColor: Colors.grey.shade800,
//         highlightColor: Colors.grey.shade700,
//         child: Container(
//           width: double.infinity,
//           height: 200,
//           color: Colors.grey.shade900,
//         ),
//       );
//     }

//     if (_chewieController == null) {
//       return const Center(
//         child: Text(
//           "Failed to load video",
//           style: TextStyle(color: Colors.white70),
//         ),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: _videoController.value.aspectRatio,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(25),
//         child: Chewie(controller: _chewieController!),
//       ),
//     );
//   }
// }
