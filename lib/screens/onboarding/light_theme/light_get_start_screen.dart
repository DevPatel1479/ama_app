import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';

import 'package:ama_legal_solutions/screens/onboarding/dark_theme/dark_get_start_screen.dart'
    show GuestOrLoginSheet;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE6DB), // LIGHT BG
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: h * 0.28,
              child: Image.asset(
                AppAssets.img1,
                width: w * 0.13,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 0,
              bottom: h * 0.29,
              child: Image.asset(
                AppAssets.img2,
                width: w * 0.18,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: h * 0.23,
              left: w * 0.5 - (w * 0.12),
              child: Image.asset(
                AppAssets.img3,
                width: w * 0.22,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: h * 0.12,
              left: w * 0.10,
              child: Image.asset(
                AppAssets.img4,
                width: w * 0.22,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: h * 0.13,
              right: w * 0.14,
              child: Image.asset(
                AppAssets.img5,
                width: w * 0.22,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 0,
              bottom: h * 0.02,
              child: Image.asset(
                AppAssets.img6,
                width: w * 0.15,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: h * 0.02,
              left: w * 0.5 - (w * 0.12),
              child: Image.asset(
                AppAssets.img7,
                width: w * 0.22,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 0,
              bottom: h * 0.02,
              child: Image.asset(
                AppAssets.img8,
                width: w * 0.15,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: h * 0.07),
                  Center(
                    child: SizedBox(
                      width: w * 0.55,
                      child: Image.asset(
                        AppAssets.lightAppLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.06),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: w * 0.02,
                    runSpacing: 10,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Your Legal",
                                style: TextStyle(
                                  color: const Color(0xFF2D2319), // LIGHT TEXT
                                  fontFamily: 'Outfit',
                                  fontSize: w * 0.09,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              SizedBox(width: w * 0.01),

                              Image.asset(
                                width: w * 0.54,

                                AppAssets.solutionsTextLightImg,
                                fit: BoxFit.contain,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.015),
                  Text(
                    "Made Simple",
                    style: TextStyle(
                      color: Color(0xFF2D2319), // LIGHT TEXT
                      fontFamily: 'Outfit',
                      fontSize: w * 0.08,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: h * 0.03),

                  SizedBox(
                    width: w * 0.85,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: w * 0.045,
                          height: 1.3,
                          color: const Color.fromRGBO(45, 35, 25, 0.70),
                        ),
                        children: const [
                          TextSpan(text: "All-in-one legal support for "),
                          TextSpan(
                            text:
                                "banking & finance, loan settlement, trademark registration, cyber law, drafting, and compliance.",
                            style: TextStyle(color: Color(0xFFD29F2A)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.06),

                  GestureDetector(
                    onTapDown: (_) => setState(() => _scale = 0.95),
                    onTapUp: (_) async {
                      setState(() => _scale = 1.0);
                      await LocalStorageHelper.saveBool(
                        "isGetStartedTapped",
                        true,
                      );
                      await LocalStorageHelper.saveBool(
                        "isGuestLoggedOut",
                        true,
                      );
                      if (!mounted) return;
                      context.go(AppPathsForScreen.signUpPath);
                    },
                    onTapCancel: () => setState(() => _scale = 1.0),
                    child: AnimatedScale(
                      scale: _scale,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: h * 0.018),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(37),
                          color: const Color(0xFF2D2319), // DARK BTN
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create Account",
                              style: TextStyle(
                                color: Color(0xFFEAE6DB),
                                fontFamily: 'Outfit',
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: w * 0.04,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.02),
                  _signInGlassButton(w, h),
                  SizedBox(height: h * 0.2),
                  _continueAsGuestGlassButton(w, h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signInGlassButton(double w, double h) {
    return GestureDetector(
      onTap: () async {
        await LocalStorageHelper.saveBool("isGetStartedTapped", true);
        await LocalStorageHelper.saveBool("isGuestLoggedOut", true);
        if (!mounted) return;
        context.go(AppPathsForScreen.logInPath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.15, sigmaY: 5.15),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: h * 0.016),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(37),
              border: Border.all(color: const Color(0xFF2D2319), width: 1.5),
              color: Colors.white.withOpacity(0.01),
            ),
            child: Center(
              child: Text(
                "Sign In",
                style: TextStyle(
                  color: Color(0xFF2D2319),
                  fontFamily: 'Outfit',
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _continueAsGuestGlassButton(double w, double h) {
    return GestureDetector(
      onTap: () async {
        await LocalStorageHelper.saveBool("isGetStartedTapped", true);
        Provider.of<RealTimeRoleProvider>(
          context,
          listen: false,
        ).setGuestRole();

        if (!mounted) return;

        context.go(AppPathsForScreen.userHomePath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.55, sigmaY: 2.55),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: h * 0.018,
              horizontal: w * 0.08,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(57),
              color: Colors.white.withOpacity(0.79),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "Continue as Guest",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2D2319),
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class LightGetStartScreen extends StatefulWidget {
//   const LightGetStartScreen({super.key});

//   @override
//   _LightGetStartScreen createState() => _LightGetStartScreen();
// }

// class _LightGetStartScreen extends State<LightGetStartScreen> {
//   double _scale = 1.0;

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent, // transparent status bar
//         statusBarIconBrightness: Brightness.dark, // white icons
//         statusBarBrightness: Brightness.light, // iOS: white icons
//       ),
//     );
//     final List<String> images = [
//       AppAssets.img1,
//       AppAssets.img2,
//       AppAssets.img3,
//       AppAssets.img4,
//       AppAssets.img5,
//       AppAssets.img6,
//       AppAssets.img7,
//       AppAssets.img8,
//       AppAssets.img9,
//       AppAssets.img10,
//       AppAssets.img11,
//     ];
//     const scaleFactor = 0.95;
//     final screenWidth = MediaQuery.of(context).size.width * scaleFactor;
//     final screenHeight = MediaQuery.of(context).size.height * scaleFactor;
//     final horizontalPadding = screenWidth * 0.04; // ~16px on 400 width screen
//     final imageWidth = ((screenWidth - horizontalPadding * 2 - 12 * 3) / 4)
//         .clamp(0, double.infinity)
//         .toDouble();

//     final imageHeight = (imageWidth * 1.25)
//         .clamp(0, double.infinity)
//         .toDouble();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Grid background
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: screenHeight * 0.02,
//               ),
//               child: Column(
//                 children: [
//                   for (int row = 0; row < 4; row++)
//                     Padding(
//                       padding: EdgeInsets.only(bottom: screenHeight * 0.015),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: List.generate(4, (col) {
//                           final index = row * 4 + col;
//                           final imgPath = images[index % images.length];

//                           // Last row gets subtle fade overlay
//                           if (row == 3) {
//                             return Stack(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Image.asset(
//                                     imgPath,
//                                     width: imageWidth,
//                                     height: imageHeight,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Container(
//                                   width: imageWidth,
//                                   height: imageHeight,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     gradient: const LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                       colors: [
//                                         Color(0xFFD29F2A),
//                                         Colors
//                                             .transparent, // transparent at the top (keeps image visible)
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           } else {
//                             return ClipRRect(
//                               borderRadius: BorderRadius.circular(20),
//                               child: Image.asset(
//                                 imgPath,
//                                 width: imageWidth,
//                                 height: imageHeight,
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//                           }
//                         }),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // Bottom layout
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.fromLTRB(
//                   horizontalPadding,
//                   screenHeight * 0.03,
//                   horizontalPadding,
//                   MediaQuery.of(context).padding.bottom + screenHeight * 0.02,
//                 ),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0x00D29F2A), // fully transparent at top
//                       Color(
//                         0xFFD29F2A,
//                       ), // full golden at bottom golden at bottom 20%ery light golden fade (~20% opacity)
//                       Color(
//                         0xFFD29F2A,
//                       ), // full golden at bottom golden at bottom 20%
//                       Color(
//                         0xFFD29F2A,
//                       ), // full golden at bottom golden at bottom 20%
//                     ],
//                     stops: [0.0, 0.1, 0.8, 1.0],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start, // left align all
//                   children: [
//                     Center(
//                       child: SizedBox(
//                         width: screenWidth * 0.4,
//                         height: screenWidth * 0.4,
//                         child: Image.asset(
//                           AppAssets.appLogoWithText2,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: screenHeight * 0.001),

//                     // Title texts
//                     RichText(
//                       text: TextSpan(
//                         style: TextStyle(
//                           fontFamily: 'Outfit',
//                           fontSize: screenWidth * 0.06,
//                           height: 1.2,
//                           color: Colors.white,
//                         ),
//                         children: [
//                           const TextSpan(text: "Law made "),
//                           TextSpan(
//                             text: "simple",
//                             style: GoogleFonts.satisfy(
//                               color: const Color(0xFF2D2319),
//                               fontSize: screenWidth * 0.06,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.008),
//                     RichText(
//                       text: TextSpan(
//                         style: TextStyle(
//                           fontFamily: 'Outfit',
//                           fontSize: screenWidth * 0.06,
//                           height: 1.2,
//                           color: Colors.white,
//                         ),
//                         children: [
//                           const TextSpan(text: "advice made "),
//                           TextSpan(
//                             text: "personal",
//                             style: GoogleFonts.satisfy(
//                               color: const Color(0xFF2D2319),
//                               fontSize: screenWidth * 0.06,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: screenHeight * 0.015),

//                     // Subtitle - LEFT ALIGNED
//                     Text(
//                       "From small queries to big decisions, our experts\nare here to guide you every step of the way.",
//                       style: TextStyle(
//                         fontFamily: 'Outfit',
//                         fontWeight: FontWeight.w300,
//                         fontSize: screenWidth * 0.025,
//                         height: 1.4,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.left,
//                     ),

//                     SizedBox(height: screenHeight * 0.03),

//                     Center(
//                       child: GestureDetector(
//                         onTapDown: (_) {
//                           setState(() {
//                             _scale = 0.95; // Scale down on tap
//                           });
//                         },
//                         onTapUp: (_) async {
//                           setState(() {
//                             _scale = 1.0; // Return to normal
//                           });

//                           showModalBottomSheet(
//                             context: context,
//                             backgroundColor: Colors.transparent,
//                             isScrollControlled: true,
//                             builder: (_) =>
//                                 GuestOrLoginSheet(isDarkTheme: false),
//                           );
//                           // final ctx = context;
//                           // await LocalStorageHelper.saveBool(
//                           //   "isGetStartedTapped",
//                           //   true,
//                           // );
//                           // ctx.go(AppPathsForScreen.userHomePath);
//                           // context.go("/signUp");
//                         },
//                         onTapCancel: () {
//                           setState(() {
//                             _scale = 1.0; // Reset if tap is canceled
//                           });
//                         },
//                         child: AnimatedScale(
//                           scale: _scale,
//                           duration: const Duration(milliseconds: 100),
//                           curve: Curves.easeOut,
//                           child: Container(
//                             width: screenWidth * 0.85,
//                             height: screenHeight * 0.06,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(25),
//                               color: const Color(0xFF2D2319),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "Get Started",
//                                   style: TextStyle(
//                                     fontFamily: 'Outfit',
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: screenWidth * 0.05,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 SizedBox(width: screenWidth * 0.025),
//                                 Image.asset(
//                                   AppAssets.rightArrow,
//                                   width: screenWidth * 0.055,
//                                   height: screenWidth * 0.055,
//                                   color: Colors.white,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: screenHeight * 0.025),

//                     // Login text
//                     Center(
//                       child: RichText(
//                         text: TextSpan(
//                           style: TextStyle(
//                             fontFamily: 'Outfit',
//                             fontSize: screenWidth * 0.045,
//                             color: Colors.white,
//                           ),
//                           children: [
//                             const TextSpan(text: "Have an account? "),
//                             TextSpan(
//                               text: "Login",
//                               style: const TextStyle(
//                                 color: Color(0xFF2D2319),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () async {
//                                   // Handle login tap here
//                                   await LocalStorageHelper.saveBool(
//                                     "isGetStartedTapped",
//                                     true,
//                                   );
//                                   context.go('/logIn');
//                                 },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
