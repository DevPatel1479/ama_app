import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DarkGetStartedScreen extends StatefulWidget {
  const DarkGetStartedScreen({super.key});

  @override
  _DarkGetStartedScreen createState() => _DarkGetStartedScreen();
}

class _DarkGetStartedScreen extends State<DarkGetStartedScreen> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1107),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: h * 0.26,
              child: Image.asset(
                AppAssets.img1,
                width: w * 0.13, // reduced size
                fit: BoxFit.cover,
              ),
            ),

            /// RIGHT IMAGE – touches right edge, overlaps Sign In corner with glass effect
            Positioned(
              right: 0,
              bottom: h * 0.27,
              child: Stack(
                children: [
                  /// Normal image
                  Image.asset(
                    AppAssets.img2,
                    width: w * 0.18,
                    fit: BoxFit.cover,
                  ),
                ],
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

            // IMG4 – left, touching Continue Guest top-left radius
            Positioned(
              bottom: h * 0.11,
              left: w * 0.10,
              child: Image.asset(
                AppAssets.img4,
                width: w * 0.22,
                fit: BoxFit.contain,
              ),
            ),

            // IMG5 – right, touching Continue Guest top-right radius
            Positioned(
              bottom: h * 0.12,
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
                width: w * 0.15, // reduced size
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
              padding: EdgeInsets.fromLTRB(w * 0.08, 0, w * 0.08, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(height: h * 0.01),

                  /// LOGO
                  Center(
                    child: SizedBox(
                      width: w * 0.55,
                      child: Image.asset(
                        AppAssets.appLogoWithText2,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // SizedBox(height: h * 0.04),

                  /// TITLE
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: w * 0.02,
                    runSpacing: 10,
                    children: [
                      /// TITLE ROW: Your Legal + Solutions (same row)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Your Legal",
                                style: TextStyle(
                                  color: const Color(0xFFEAE6DB),
                                  fontFamily: 'Outfit',
                                  fontSize: w * 0.09, // responsive
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),

                              SizedBox(width: w * 0.01),

                              Image.asset(
                                width: w * 0.54,

                                AppAssets.solutionsTextImg,
                                fit: BoxFit.contain,
                              ),
                            ],
                          );
                        },
                      ),

                      /// SECOND LINE
                    ],
                  ),

                  SizedBox(height: h * 0.015),

                  Text(
                    "Made Simple",
                    style: TextStyle(
                      color: const Color(0xFFEAE6DB),
                      fontFamily: 'Outfit',
                      fontSize: w * 0.08, // responsive
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: h * 0.03),

                  /// SUBTITLE
                  SizedBox(
                    width: w * 0.85,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: w * 0.045,
                          height: 1.3,
                          color: const Color.fromRGBO(234, 230, 219, 0.70),
                        ),
                        children:
                            const [
                              TextSpan(text: "All-in-one legal support for "),
                              TextSpan(
                                text:
                                    "banking & finance, loan settlement, trademark registration, cyber law, drafting, and compliance.",
                              ),
                            ].map((span) {
                              if (![
                                "All-in-one legal support for ",
                              ].contains(span.text)) {
                                return TextSpan(
                                  text: span.text,
                                  style: const TextStyle(
                                    color: Color(0xFFD29F2A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }
                              return span;
                            }).toList(),
                      ),
                    ),
                  ),

                  // const Spacer(),
                  SizedBox(height: h * 0.05),

                  /// CREATE ACCOUNT BUTTON
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
                          color: const Color(0xFFD29F2A),
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
                  SizedBox(height: h * 0.18),
                  _continueAsGuestGlassButton(w, h),
                  // SizedBox(height: h * 0.04),
                ],
              ),
            ),
          ],
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: h * 0.018,
              horizontal: w * 0.08,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(57),
              color: Colors.white.withOpacity(0.49),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color.fromRGBO(234, 230, 219, 0.05),
                  blurRadius: 8.8,
                  offset: Offset(0, -4),
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
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: h * 0.017),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(37),
              // border: Border.all(color: const Color(0xFFD29F2A), width: 1.5),
              border: Border.all(color: Colors.yellow, width: 1.5),
              color: Colors.white.withOpacity(0.08), // IMPORTANT for glass
            ),
            child: Center(
              child: Text(
                "Sign In",
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
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
} // class DarkGetStartedScreen extends StatefulWidget {
//   const DarkGetStartedScreen({super.key});

//   @override
//   _DarkGetStartedScreen createState() => _DarkGetStartedScreen();
// }

// class _DarkGetStartedScreen extends State<DarkGetStartedScreen> {
//   double _scale = 1.0;

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent, // transparent status bar
//         statusBarIconBrightness: Brightness.light, // white icons
//         statusBarBrightness: Brightness.dark, // iOS: white icons
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
//       backgroundColor: const Color(0xFF171717),
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
//                                         Colors.transparent,
//                                         Color(0xFF171717),
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
//                       Color(0x00171717), // fully transparent

//                       Color(0xFF2D2319), // solid color from 30% to bottom
//                       // Color(0xFF2D2319), // solid color from 30% to bottom
//                     ],
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
//                               color: const Color(0xFFD29F2A),
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
//                               color: const Color(0xFFD29F2A),
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
//                                 GuestOrLoginSheet(isDarkTheme: true),
//                           );
//                           // final ctx = context;
//                           // await LocalStorageHelper.saveBool(
//                           //   "isGetStartedTapped",
//                           //   true,
//                           // );
//                           // ctx.go(AppPathsForScreen.userHomePath);
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
//                               gradient: const LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.centerRight,
//                                 colors: [Color(0xFFD29F2A), Colors.white],
//                               ),
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
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 SizedBox(width: screenWidth * 0.025),
//                                 Image.asset(
//                                   AppAssets.rightArrow,
//                                   width: screenWidth * 0.04,
//                                   height: screenWidth * 0.045,
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
//                                 color: Color(0xFFD29F2A),
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

class GuestOrLoginSheet extends StatelessWidget {
  final bool isDarkTheme;

  const GuestOrLoginSheet({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            Text(
              "Continue As",
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontFamily: "Outfit",
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // ⚡ Continue as Guest Button
            _buildButton(
              context,
              text: "Continue as Guest",
              isDarkTheme: isDarkTheme,
              onTap: () async {
                await LocalStorageHelper.saveBool("isGetStartedTapped", true);
                Provider.of<RealTimeRoleProvider>(
                  context,
                  listen: false,
                ).setGuestRole();
                if (!context.mounted) return;

                Navigator.pop(context);

                if (!context.mounted) return;

                context.go(AppPathsForScreen.userHomePath);
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            // ⚡ Login Button
            _buildButton(
              context,
              text: "Login",
              isDarkTheme: isDarkTheme,
              onTap: () async {
                await LocalStorageHelper.saveBool("isGetStartedTapped", true);
                await LocalStorageHelper.saveBool("isGuestLoggedOut", true);
                if (!context.mounted) return;

                Navigator.pop(context);

                if (!context.mounted) return;

                context.go(AppPathsForScreen.logInPath);
              },
            ),
            SizedBox(height: screenHeight * 0.02),

            // ⚡ Signup Button
            _buildButton(
              context,
              text: "Signup",
              isDarkTheme: isDarkTheme,
              onTap: () async {
                await LocalStorageHelper.saveBool("isGetStartedTapped", true);
                await LocalStorageHelper.saveBool("isGuestLoggedOut", true);
                if (!context.mounted) return;

                Navigator.pop(context);

                if (!context.mounted) return;

                context.go(AppPathsForScreen.signUpPath);
              },
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required bool isDarkTheme,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.85,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDarkTheme
            ? const LinearGradient(
                colors: [Color(0xFFD29F2A), Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF3E2723), Color(0xFF5D4037)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
                fontSize: screenWidth * 0.045,
                color: isDarkTheme ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
