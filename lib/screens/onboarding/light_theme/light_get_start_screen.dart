import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LightGetStartScreen extends StatefulWidget {
  const LightGetStartScreen({super.key});

  @override
  _LightGetStartScreen createState() => _LightGetStartScreen();
}

class _LightGetStartScreen extends State<LightGetStartScreen> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
        statusBarIconBrightness: Brightness.dark, // white icons
        statusBarBrightness: Brightness.light, // iOS: white icons
      ),
    );
    final List<String> images = [
      AppAssets.img1,
      AppAssets.img2,
      AppAssets.img3,
      AppAssets.img4,
      AppAssets.img5,
      AppAssets.img6,
      AppAssets.img7,
      AppAssets.img8,
      AppAssets.img9,
      AppAssets.img10,
      AppAssets.img11,
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04; // ~16px on 400 width screen
    final imageWidth = ((screenWidth - horizontalPadding * 2 - 12 * 3) / 4)
        .clamp(0, double.infinity)
        .toDouble();

    final imageHeight = (imageWidth * 1.25)
        .clamp(0, double.infinity)
        .toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Grid background
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  for (int row = 0; row < 4; row++)
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (col) {
                          final index = row * 4 + col;
                          final imgPath = images[index % images.length];

                          // Last row gets subtle fade overlay
                          if (row == 3) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    imgPath,
                                    width: imageWidth,
                                    height: imageHeight,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  width: imageWidth,
                                  height: imageHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFD29F2A),
                                        Colors
                                            .transparent, // transparent at the top (keeps image visible)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                imgPath,
                                width: imageWidth,
                                height: imageHeight,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom layout
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  screenHeight * 0.03,
                  horizontalPadding,
                  MediaQuery.of(context).padding.bottom + screenHeight * 0.02,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00D29F2A), // fully transparent at top
                      Color(
                        0xFFD29F2A,
                      ), // full golden at bottom golden at bottom 20%ery light golden fade (~20% opacity)
                      Color(
                        0xFFD29F2A,
                      ), // full golden at bottom golden at bottom 20%
                      Color(
                        0xFFD29F2A,
                      ), // full golden at bottom golden at bottom 20%
                    ],
                    stops: [0.0, 0.1, 0.8, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // left align all
                  children: [
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.4,
                        height: screenWidth * 0.4,
                        child: Image.asset(
                          AppAssets.appLogoWithText,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.001),

                    // Title texts
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: screenWidth * 0.06,
                          height: 1.2,
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(text: "Law made "),
                          TextSpan(
                            text: "simple",
                            style: GoogleFonts.satisfy(
                              color: const Color(0xFF2D2319),
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: screenWidth * 0.06,
                          height: 1.2,
                          color: Colors.white,
                        ),
                        children: [
                          const TextSpan(text: "advice made "),
                          TextSpan(
                            text: "personal",
                            style: GoogleFonts.satisfy(
                              color: const Color(0xFF2D2319),
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Subtitle - LEFT ALIGNED
                    Text(
                      "From small queries to big decisions, our experts\nare here to guide you every step of the way.",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w300,
                        fontSize: screenWidth * 0.025,
                        height: 1.4,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Center(
                      child: GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _scale = 0.95; // Scale down on tap
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _scale = 1.0; // Return to normal
                          });
                          context.go("/signUp");
                        },
                        onTapCancel: () {
                          setState(() {
                            _scale = 1.0; // Reset if tap is canceled
                          });
                        },
                        child: AnimatedScale(
                          scale: _scale,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                          child: Container(
                            width: screenWidth * 0.85,
                            height: screenHeight * 0.06,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: const Color(0xFF2D2319),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Get Started",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth * 0.05,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.025),
                                Image.asset(
                                  AppAssets.rightArrow,
                                  width: screenWidth * 0.055,
                                  height: screenWidth * 0.055,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Login text
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: screenWidth * 0.045,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(text: "Have an account? "),
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: Color(0xFF2D2319),
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle login tap here

                                  context.go('/logIn');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
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
