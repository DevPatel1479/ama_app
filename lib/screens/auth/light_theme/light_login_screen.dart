import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/solid_border_painter.dart';
import 'package:ama_legal_solutions/provider/auth/login_screen_provider.dart';
import 'package:ama_legal_solutions/screens/auth/dark_theme/dark_signup_screen.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LightLoginScreen extends StatefulWidget {
  const LightLoginScreen({super.key});

  @override
  State<LightLoginScreen> createState() => _LightLoginScreenState();
}

class _LightLoginScreenState extends State<LightLoginScreen> {
  final int otpLength = 6;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  @override
  void initState() {
    super.initState();
    otpControllers = List.generate(otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in otpControllers) c.dispose();
    for (var f in otpFocusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF8BD00), // status bar color matches layout
        statusBarIconBrightness: Brightness.dark, // for Android: dark icons
        statusBarBrightness: Brightness.light, // for iOS: dark icons
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fieldWidth = screenWidth * 0.9;
    final fieldHeight = 50.0;

    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GradientTopLayout(
          headerContent: Image.asset(
            AppAssets.appLogoWithText,
            width: screenWidth * 0.4,
            fit: BoxFit.contain,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                    color: Color(0xFF000000),
                  ),
                ),
                const Text(
                  "To your 1:1 Legal Advisors",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 24),

                // Phone Number Input
                _gradientBorderInput(
                  "Phone Number",
                  fieldWidth,
                  fieldHeight,
                  loginProvider,
                ),
                const SizedBox(height: 16),

                // OTP Input Boxes
                if (loginProvider.otpSent)
                  _otpInputBoxes(screenWidth, loginProvider),

                const SizedBox(height: 35),

                // Login Button
                loginProvider.otpSent
                    ? _gradientLoginButton(
                        fieldWidth,
                        fieldHeight,
                        () {
                          if (loginProvider.isLoading) return;
                          loginProvider.verifyOtp(context);
                        },
                        "Verify OTP",
                        loginProvider,
                      )
                    : _gradientLoginButton(
                        fieldWidth,
                        fieldHeight,
                        () {
                          print("calling login side");
                          if (loginProvider.isLoading) return;
                          loginProvider.login(context);
                        },
                        "Login",
                        loginProvider,
                      ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color:
                          Colors.white, // Default style for non-clickable text
                    ),
                    children: [
                      const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Color(0xFF2D2319)),
                      ),
                      TextSpan(
                        text: "Sign up",
                        style: const TextStyle(
                          color: Color(
                            0xFFD29F2A,
                          ), // Color for the clickable text
                          fontWeight: FontWeight
                              .w500, // Optional: make it slightly bolder
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle login tap here
                            context.go(AppPathsForScreen.signUpPath);
                            // Example: Navigate to login screen
                            // context.go('/login');
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientBorderInput(
    String label,
    double width,
    double height,
    LoginProvider provider,
  ) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2, color: Colors.transparent),
        ),
        child: CustomPaint(
          painter: SolidBorderPainter(
            radius: 20,
            width: 2,
            color: const Color(0xFF2D2319), // solid color
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              maxLength: 10,
              controller: provider.phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // allow only digits
              ],
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(color: Colors.black, fontFamily: "Outfit"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpInputBoxes(double screenWidth, LoginProvider provider) {
    final otpLength = provider.otpControllers.length;
    final boxWidth = (screenWidth - 80) / otpLength;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        otpLength,
        (index) => Container(
          width: boxWidth,
          height: boxWidth,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomPaint(
            painter: SolidBorderPainter(
              radius: 16,
              width: 2,
              color: const Color(0xFF2D2319), // solid color
            ),
            child: Center(
              child: TextField(
                controller: provider.otpControllers[index],
                focusNode: otpFocusNodes[index],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 20),
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // if (value.isNotEmpty && index < otpLength - 1) {
                  //   otpFocusNodes[index + 1].requestFocus();
                  // } else if (value.isEmpty && index > 0) {
                  //   otpFocusNodes[index - 1].requestFocus();
                  // }
                  if (value.isNotEmpty && index < otpLength - 1) {
                    FocusScope.of(
                      context,
                    ).requestFocus(otpFocusNodes[index + 1]);
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(
                      context,
                    ).requestFocus(otpFocusNodes[index - 1]);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientLoginButton(
    double width,
    double height,
    VoidCallback onPressed,
    String text,
    LoginProvider provider,
  ) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF2D2319),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Center(
              child: provider.isLoading
                  ? SizedBox(
                      width: 24, // 30% of button width
                      height: 24, // Keep it square
                      child: CircularProgressIndicator(
                        strokeWidth: 2, // 3% of width
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
