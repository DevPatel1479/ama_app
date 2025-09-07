import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      AppAssets.backArrowIcon,
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.12),
                  Text(
                    "Account",
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // 🔹 Centered User Info Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: handle camera tap
                    },
                    child: Image.asset(
                      AppAssets.userCameraIcon,
                      width: screenWidth * 0.22,
                      height: screenWidth * 0.22,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    "Username",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "Xyz@gmail.com",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // 🔹 Scrollable Options List (Left aligned)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: QR + Text
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.qrIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          "Scan code",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Row: Portfolio + Text
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.portfolioIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          "Portfolio",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔹 Preference Header
                    Text(
                      "Preference",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Row: Email Settings
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.emailIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          "Email Settings",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Row: Notification Settings
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.notificationIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Text(
                            "Device and push notification settings",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.040,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔹 Feedback Header
                    Text(
                      "Feedback",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Row: Rate AMA Legal Solutions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.rateIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.040,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(text: "Rate "),
                              TextSpan(
                                text: "AMA Legal Solutions",
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.043,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFD29F2A), // gold color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Row: Contact Support
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.helpIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          "Contact support",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // 🔹 Contact Us Header
                    Text(
                      "Contact us",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Row: Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          AppAssets.locationIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Text(
                            "2493AP, Block G, Sushant Lok 2, Sector 57, Gurugram, Haryana, 122001",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.040,
                              fontWeight: FontWeight.w500,
                              height: 1.3, // line height
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Row: Phone
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.phoneIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          "+918700343611",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Row: Company Email
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.companyEmailIcon,
                          width: screenWidth * 0.04,
                          height: screenWidth * 0.04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Text(
                            "notify@amalegalsolutions.com",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.040,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // 🔹 Gradient Divider Line
                    Container(
                      width:
                          screenWidth *
                          0.9, // responsive width (~90% of screen)
                      height: 1.5, // line thickness
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(
                              0x1AD29F2A,
                            ), // rgba(210,159,42,0.1) = 10% opacity
                            const Color(0xFFD29F2A), // solid gold center
                            const Color(0x1AD29F2A), // 10% opacity again
                          ],
                          stops: const [0.0, 0.5, 1.0], // left → center → right
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    GestureDetector(
                      onTap: () {
                        // TODO: handle log out action
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: const Color(0xFFD29F2A),
                            size: screenWidth * 0.04, // responsive size
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Text(
                            "Log out",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.040,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFD29F2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
