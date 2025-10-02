import 'package:ama_legal_solutions/provider/auth/login_screen_provider.dart';
import 'package:ama_legal_solutions/screens/auth/dark_theme/dark_signup_screen.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DarkLoginScreen extends StatefulWidget {
  const DarkLoginScreen({super.key});

  @override
  State<DarkLoginScreen> createState() => _DarkLoginScreenState();
}

class _DarkLoginScreenState extends State<DarkLoginScreen> {
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
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
        statusBarIconBrightness: Brightness.light, // white icons
        statusBarBrightness: Brightness.dark, // iOS: white icons
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.9;
    final fieldHeight = 50.0;
    final loginProvider = context.watch<LoginProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                AppAssets.appLogoWithText,
                width: screenWidth * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              const Text(
                "Welcome",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              const Text(
                "To your 1:1 Legal Advisors",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                  color: Colors.white,
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
                  color: Colors.white,
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
              // _gradientLoginButton(fieldWidth, fieldHeight, () {}),
              loginProvider.otpSent
                  ? _gradientLoginButton(
                      fieldWidth,
                      fieldHeight,
                      () {
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
                    color: Colors.white, // Default style for non-clickable text
                  ),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
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
          painter: GradientBorderPainter(
            radius: 20,
            width: 2,
            gradient: const LinearGradient(
              colors: [Color(0xFFD29F2A), Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              maxLength: 10,
              controller: provider.phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // allow only digits
              ],

              decoration: InputDecoration(
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(vertical: 14),

                border: InputBorder.none,
                hintText: label,
                hintStyle: const TextStyle(
                  color: Color(0x59FFFFFF),
                  fontFamily: "Outfit",
                ),
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
            painter: GradientBorderPainter(
              radius: 16,
              width: 2,
              gradient: const LinearGradient(
                colors: [Color(0xFFD29F2A), Colors.white],
              ),
            ),
            child: Center(
              child: TextField(
                controller: provider.otpControllers[index],
                focusNode: otpFocusNodes[index],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
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
          gradient: const LinearGradient(
            colors: [Color(0xFFD29F2A), Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
