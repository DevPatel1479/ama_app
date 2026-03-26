import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/auth/login_screen_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';

import 'package:ama_legal_solutions/screens/auth/dark_theme/dark_signup_screen.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';

import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(AppAssets.appLogoWithText2), context);
    });
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
    final screenHeight = MediaQuery.of(context).size.height;
    final fieldWidth = screenWidth;
    final fieldHeight = 50.0;
    final loginProvider = context.watch<LoginProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, // 0deg
            end: Alignment.topCenter,
            colors: [Color(0xFF1A1107), Color(0xFF1A1107)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              // vertical: screenHeight * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.09),
                Center(
                  child: Image.asset(
                    AppAssets.newappLogoWithText2,
                    width: screenWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),
                SizedBox(
                  width: double.infinity, // align-self: stretch
                  child: Text(
                    "Welcome Back",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFFFF),
                      fontSize:
                          screenWidth *
                          0.095, // responsive (~40px on normal screens)
                      fontWeight: FontWeight.w500,
                      height: 1.0, // line-height: 40px (100%)
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                SizedBox(
                  width: double.infinity, // align-self: stretch
                  child: Text(
                    "Let’s reduce your legal stress.",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 38 / 25, // line-height: 38px
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // Phone Number Input
                _gradientBorderInput(
                  "Phone Number",
                  fieldWidth,
                  fieldHeight,
                  loginProvider,
                ),
                SizedBox(height: screenHeight * 0.02),
                // OTP Input Boxes
                if (loginProvider.otpSent &&
                    loginProvider.phoneController.text != "8734835064") ...[
                  _otpInputBoxes(screenWidth, loginProvider),

                  const SizedBox(height: 14),
                  // 🕒 Timer + Resend Button
                  SizedBox(
                    width: fieldWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!loginProvider.isResendAvailable)
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Resend OTP ",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      " in ${loginProvider.secondsRemaining} Seconds",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment
                                  .centerLeft, // align-self: stretch from left
                            ),
                            onPressed: loginProvider.isResendAvailable
                                ? () => loginProvider.resendOtp(context)
                                : null,
                            child: Text(
                              "Resend OTP",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1, // line-height: 100%
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else if (loginProvider.otpSent)
                  // SizedBox(height: screenHeight * 0.02),
                  _otpInputBoxes(screenWidth, loginProvider),
                SizedBox(height: screenHeight * 0.05),

                // Login Button
                // _gradientLoginButton(fieldWidth, fieldHeight, () {}),
                loginProvider.otpSent
                    ? _gradientLoginButton(
                        fieldWidth,
                        fieldHeight,
                        () async {
                          if (loginProvider.isLoading) return;

                          final phone = loginProvider.phoneController.text
                              .trim();
                          final enteredOtp = loginProvider.otpControllers
                              .map((c) => c.text)
                              .join()
                              .trim();
                          // ✅ Check for Google Play Test scenario
                          // print(phone);
                          // print(enteredOtp);
                          if (phone == "8734835064") {
                            // ✅ Show loading snackbar immediately
                            final messenger = ScaffoldMessenger.of(context);
                            // messenger
                            //   ..hideCurrentSnackBar()
                            //   ..showSnackBar(verifyingSnack);

                            const defaultOtp = "453423";

                            // If OTPs match, treat as verified
                            if (enteredOtp == defaultOtp) {
                              updateGlobalUserName("TestDp");
                              updateGlobalUserEmail("testdp@gmail.com");
                              await LocalStorageHelper.saveBool(
                                "isUserLoggedIn",
                                true,
                              );
                              await LocalStorageHelper.saveString(
                                "userPhone",
                                phone,
                              );
                              await LocalStorageHelper.saveString(
                                "userName",
                                "TestDp",
                              );
                              await LocalStorageHelper.saveString(
                                "userRole",
                                "client",
                              );
                              await LocalStorageHelper.saveString(
                                "userEmail",
                                "testdp@gmail.com",
                              );
                              await LocalStorageHelper.saveString(
                                "userWeekTopic",
                                "third_week",
                              );
                              final userProvider = context.read<UserProvider>();

                              Provider.of<RealTimeRoleProvider>(
                                context,
                                listen: false,
                              ).setTesterRole();
                              await userProvider.loadUserRole();
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  content: Text(
                                    "✅ Test OTP verified successfully!",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              loginProvider.resetLoginState();
                              // Proceed to home screen
                              context.go(AppPathsForScreen.userHomePath);
                              return;
                            } else {
                              messenger.hideCurrentSnackBar();

                              // Error message
                              messenger.showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  content: Text(
                                    "❗Please enter the test OTP: 453423",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                          }

                          await loginProvider.verifyOtp(context);

                          // print(loginProvider.loginSuccess);
                          if (loginProvider.loginSuccess) {
                            String userPhone = "91${phone}";
                            Provider.of<RealTimeRoleProvider>(
                              context,
                              listen: false,
                            ).startRoleListener(userPhone);
                            // if (loginProvider.weekTopicEnabled) {
                            //   await FirebaseMessagingService.instance
                            //       .subscribeToTopicFor(
                            //         weekEnabled: loginProvider.weekTopicEnabled,
                            //         weekEnabledValue:
                            //             loginProvider.weekTopic ?? "",
                            //       );
                            // } else {
                            //   await FirebaseMessagingService.instance
                            //       .subscribeToTopicFor();
                            // }
                            loginProvider.resetLoginState();
                            context.go(AppPathsForScreen.userHomePath);
                          }
                        },
                        "Log in",
                        loginProvider,
                      )
                    : _gradientLoginButton(
                        fieldWidth,
                        fieldHeight,
                        () {
                          if (loginProvider.isLoading) return;
                          // print("calling login side");
                          final phone = loginProvider.phoneController.text
                              .trim();
                          // ✅ Static check before sending OTP
                          if (phone == "8734835064") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "⚠️ Test mode detected. Use OTP 453423 for login.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.blueGrey,
                              ),
                            );
                            loginProvider.otpSent = true;
                            setState(() {});
                            return;
                          }

                          loginProvider.login(context);
                        },
                        "Continue",
                        loginProvider,
                      ),
                SizedBox(height: screenHeight * 0.035),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors
                            .white, // Default style for non-clickable text
                      ),
                      children: [
                        const TextSpan(
                          text: "New here? ",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: "Create an account",
                          style: const TextStyle(
                            color: Color(
                              0xFFD29F2A,
                            ), // Color for the clickable text
                            fontWeight: FontWeight
                                .w600, // Optional: make it slightly bolder
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
                ),

                SizedBox(height: screenHeight * 0.04),
                _guestModeButton(fieldWidth, fieldHeight, () async {
                  final ctx = context;
                  final userProvider = context.read<UserProvider>();
                  Provider.of<RealTimeRoleProvider>(
                    context,
                    listen: false,
                  ).setGuestRole();
                  await LocalStorageHelper.saveString("userRole", "guest");
                  await LocalStorageHelper.saveBool("isGuestLoggedOut", false);
                  await LocalStorageHelper.saveBool("isNormalUser", false);
                  await userProvider.loadUserRole();
                  updateGlobalUserName("Guest User");
                  updateGlobalUserEmail("guest@gmail.com");
                  loginProvider.resetLoginState();
                  ctx.pushReplacement(AppPathsForScreen.userHomePath);
                }, "Continue as Guest"),
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
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Text(
            "Enter your phone number",
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),

          SizedBox(height: height * 0.25),

          /// Input Field
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: height * 0.02,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromRGBO(210, 159, 42, 0.055),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.33),
                  offset: Offset(0, 0),
                  blurRadius: 12.5,
                  spreadRadius: 0,
                ),
              ],
            ),

            child: TextField(
              maxLength: 10,
              enabled: !provider.otpSent,
              controller: provider.phoneController,
              keyboardType: TextInputType.number,

              style: GoogleFonts.outfit(
                color: const Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1,
              ),

              inputFormatters: [FilteringTextInputFormatter.digitsOnly],

              decoration: InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: label,

                hintStyle: GoogleFonts.outfit(
                  color: const Color(0xFFFFFFFF).withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpInputBoxes(double screenWidth, LoginProvider provider) {
    final otpLength = provider.otpControllers.length;

    /// responsive box width
    final boxWidth = (screenWidth - (otpLength * 12)) / otpLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          "Enter OTP",
          style: GoogleFonts.outfit(
            color: const Color(0xFFFFFFFF),
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),

        const SizedBox(height: 13),

        /// OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            otpLength,
            (index) => Container(
              width: boxWidth,
              height: boxWidth * 1.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromRGBO(210, 159, 42, 0.055),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.33),
                    offset: Offset(0, 0),
                    blurRadius: 12.5,
                    spreadRadius: 0,
                  ),
                ], // rgba(210,159,42,0.50)
              ),
              child: Center(
                child: TextField(
                  controller: provider.otpControllers[index],
                  focusNode: otpFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,

                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFFFF),
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),

                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),

                  onChanged: (value) {
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
      ],
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
          borderRadius: BorderRadius.circular(37),
          color: const Color(0xFFD29F2A),
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

  Widget _guestModeButton(
    double width,
    double height,
    VoidCallback onPressed,
    String text,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: RepaintBoundary(
          child: Container(
            width: width * 0.5,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(57),
              color: const Color.fromRGBO(
                255,
                255,
                255,
                0.3,
              ), // semi-transparent
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x0DEAE6DB),
                  blurRadius: 8.8,
                  offset: Offset(0, -4),
                ),
                BoxShadow(
                  color: Color(0x0DEAE6DB),
                  blurRadius: 8.8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2D2319),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
