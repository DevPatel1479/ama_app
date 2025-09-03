import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/image_slider.dart'
    show AutoScrollSlider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/assets_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
              
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Greeting row
                Row(
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

                SizedBox(height: screenHeight * 0.04),

                /// Stats card
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
