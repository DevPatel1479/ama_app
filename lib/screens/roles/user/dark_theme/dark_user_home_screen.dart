import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/client_testimonial_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/image_slider.dart'
    show AutoScrollSlider;
import 'package:ama_legal_solutions/custom_widgets/team_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class DarkHomeScreen extends StatelessWidget {
  const DarkHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic sizes
    final avatarDiameter = screenWidth * 0.10;
    final fontSize = screenWidth * 0.06;
    final iconSize = screenWidth * 0.075;
    final dotSize = screenWidth * 0.025;

    // Card sizes
    final statCardHeight = screenHeight * 0.14;
    final videoCardHeight = screenHeight * 0.18;

    final statNumberFont = screenWidth * 0.05;
    final statLabelFont = screenWidth * 0.025;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Responsive button
    Widget fileDisputeButton(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      final buttonWidth = screenWidth * 0.9; // responsive width
      final buttonHeight = screenHeight * 0.06; // responsive height ~50px
      final horizontalPadding = buttonWidth * 0.05;
      final verticalPadding = buttonHeight * 0.25;

      return Container(
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
            SizedBox(width: screenWidth * 0.02), // very close to text
            Text(
              "File a Dispute",
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.05, // responsive ~20px
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      );
    }

    // Single stat widget
    Widget statItem(String number, String label) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.18,
            child: Text(
              number,
              style: GoogleFonts.outfit(
                fontSize: statNumberFont,
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
            width: screenWidth * 0.18,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: statLabelFont,
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
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Column(
          children: [
            /// Fixed AppBar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: avatarDiameter / 2,
                        backgroundImage: AssetImage(AppAssets.testProfile),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Hi, ",
                            style: GoogleFonts.outfit(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, 3),
                            child: Text(
                              "Zaib",
                              style: GoogleFonts.satisfy(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFD29F2A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: iconSize,
                        color: Colors.white,
                      ),
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

            // SizedBox(height: screenHeight * 0.04),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
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

                    SizedBox(height: screenHeight * 0.04),

                    /// Video card
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.145, // responsive height ~145px
                      decoration: BoxDecoration(
                        color: const Color(0xFFD29F2A), // background
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Video",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.095, // ~39px
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1, // ensures single line vertical alignment
                          letterSpacing:
                              0, // remove negative spacing to avoid overlap
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03), // spacing
                    fileDisputeButton(context),
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.03, // space below button
                        left: screenWidth * 0.01,
                        right: screenWidth * 0.04,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft, // ⬅ left align
                        child: Text(
                          "Providing Solutions To",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // spacing
                    const AutoScrollSlider(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.03, // space below button
                        left: screenWidth * 0.01,
                        right: screenWidth * 0.04,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft, // ⬅ left align
                        child: Text(
                          "Our Locations",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.04,
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
                        horizontal: screenWidth * 0.01,
                        vertical: screenHeight * 0.02,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final columnSpacing = screenWidth * 0.03;
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
                                          height: screenHeight * 0.015,
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
                                        SizedBox(height: screenHeight * 0.02),
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
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
                                fontSize: screenWidth * 0.035,
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
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.01,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Image with gradient border
                                Container(
                                  width: screenWidth * 0.4, // responsive width
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
                                        image: AssetImage(
                                          AppAssets.ourLegacyImg,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04), // spacing
                                // Right Text Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Late Adv. R.C. Malik",
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFD29F2A),
                                          height: 20 / 18,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(
                                        "Ex-Comptroller and Auditor General of India\nDirector General of Audit (Central-Receipt)",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          height: 16 / 14,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        "R.C. Malik started his professional journey as a "
                                        "gazetted officer at DGACR, progressing through "
                                        "different roles within the Income Tax Department "
                                        "before taking on administrative duties at the "
                                        "Office of the Comptroller and Auditor General "
                                        "(CAG) of India.",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          height: 14 / 12,
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
                    SizedBox(height: screenHeight * 0.02),
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
                            "Client Testimonials",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFD29F2A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Below the Padding containing "Our Team" and "See all"
                    SizedBox(height: screenHeight * 0.02),
                    TestimonialCard(),
                  ],
                ),
              ),

              /// Stats card
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
