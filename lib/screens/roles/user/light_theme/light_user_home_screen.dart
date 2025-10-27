import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/client_testimonial_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/image_slider.dart'
    show AutoScrollSlider;
import 'package:ama_legal_solutions/custom_widgets/send_notification_sheet.dart';
import 'package:ama_legal_solutions/custom_widgets/team_image_slider.dart';
import 'package:ama_legal_solutions/provider/profile/profile_photo_provider.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:provider/provider.dart';

class LightHomeScreen extends StatefulWidget {
  const LightHomeScreen({super.key});
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

    print(fetchedRole);
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
      print(provider.profilePhotoUrl);
    }
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
    final videoCardHeight = screenHeight * 0.18;

    final statNumberFont = screenWidth * 0.05;
    final statLabelFont = screenWidth * 0.025;

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
          context.pushNamed(AppScreenNames.raiseQuery);
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
                "File a Dispute",
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
      backgroundColor: Colors.white,

      body: SafeArea(
        child: GradientTopLayout(
          screenName: "home",
          headerContent: Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04 * scaleFactor,
              vertical: screenHeight * 0.015 * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD29F2A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(screenWidth * 0.07), // ~responsive
                bottomRight: Radius.circular(screenWidth * 0.07), // ~responsive
              ),
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
                                "profile_photo": provider.hasProfilePhoto
                                    ? provider.profilePhotoUrl!
                                    : AppAssets.userIcon,
                                "phone": userPhone!,
                                "role": userRole!,
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(
                            avatarDiameter / 2,
                          ),
                          child: CircleAvatar(
                            radius: avatarDiameter / 2,
                            backgroundImage: provider.hasProfilePhoto
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
                        Transform.translate(
                          offset: const Offset(0, 3),
                          child: Text(
                            "$userName",
                            style: GoogleFonts.satisfy(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
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
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04 * scaleFactor,
                vertical: screenHeight * 0.015 * scaleFactor,
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
                        statItem("200+", "Case\nhandled"),
                        verticalLine(statCardHeight * 0.5),
                        statItem("40+", "Year\nExperience"),
                        verticalLine(statCardHeight * 0.5),
                        statItem("200+", "Client\nServed"),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04 * scaleFactor),

                  /// Video card
                  Container(
                    width: double.infinity,
                    height:
                        screenHeight *
                        0.145 *
                        scaleFactor, // responsive height ~145px
                    decoration: BoxDecoration(
                      color: const Color(0xFFD29F2A), // background
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Video",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.095 * scaleFactor, // ~39px
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1, // ensures single line vertical alignment
                        letterSpacing:
                            0, // remove negative spacing to avoid overlap
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.03 * scaleFactor,
                  ), // spacing
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
                        final columnSpacing = screenWidth * 0.03 * scaleFactor;
                        final columnWidth =
                            (totalWidth - 2 * columnSpacing) / 3;

                        return Stack(
                          children: [
                            // The main row with images
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                            screenHeight * 0.015 * scaleFactor,
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
                                            screenHeight * 0.02 * scaleFactor,
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
                                width: columnWidth * 2 + columnSpacing,
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
                        TextButton(
                          onPressed: () {
                            // Handle "See all" tap here
                          },
                          child: Text(
                            "See all",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.035 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD29F2A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Below the Padding containing "Our Team" and "See all"
                  SizedBox(
                    height: screenHeight * 0.02,
                  ), // spacing between sections
                  const TeamSlider(),
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.03, // space below button
                      left: screenWidth * 0.01,
                      right: screenWidth * 0.04,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft, // ⬅ left align
                      child: Text(
                        "Our Legacy",
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
                  SizedBox(height: screenHeight * 0.02 * scaleFactor),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.01 * scaleFactor,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Image with gradient border
                              Container(
                                width:
                                    screenWidth *
                                    0.4 *
                                    scaleFactor, // responsive width
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(210, 159, 42, 0.65),
                                      Color.fromRGBO(255, 255, 255, 0.65),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                padding: const EdgeInsets.all(
                                  2,
                                ), // border thickness
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      25,
                                    ), // slightly smaller for inner image
                                    image: DecorationImage(
                                      image: AssetImage(AppAssets.ourLegacyImg),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.04 * scaleFactor,
                              ), // spacing
                              // Right Text Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Late Adv. R.C. Malik",
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFD29F2A),
                                        height: 20 / 15,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          screenHeight * 0.005 * scaleFactor,
                                    ),
                                    Text(
                                      "Ex-Comptroller and Auditor General of India\nDirector General of Audit (Central-Receipt)",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        height: 16 / 12,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          screenHeight * 0.005 * scaleFactor,
                                    ),
                                    Text(
                                      "R.C. Malik started his professional journey as a "
                                      "gazetted officer at DGACR, progressing through "
                                      "different roles within the Income Tax Department "
                                      "before taking on administrative duties at the "
                                      "Office of the Comptroller and Auditor General "
                                      "(CAG) of India.",
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        height: 14 / 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                        TextButton(
                          onPressed: () {
                            // Handle "See all" tap here
                          },
                          child: Text(
                            "See all",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.035 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD29F2A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Below the Padding containing "Our Team" and "See all"
                  SizedBox(height: screenHeight * 0.001 * scaleFactor),
                  TestimonialCard(),
                ],
              ),
            ),

            /// Stats card
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
