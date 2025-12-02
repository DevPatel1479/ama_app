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
    final fieldWidth = screenWidth * 0.9;
    final fieldHeight = 50.0;
    final loginProvider = context.watch<LoginProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                AppAssets.appLogoWithText2,
                height: 140,
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
              if (loginProvider.otpSent &&
                  loginProvider.phoneController.text != "8734835064") ...[
                _otpInputBoxes(screenWidth, loginProvider),
                const SizedBox(height: 14),
                Text(
                  "Check your WhatsApp for OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                    fontSize:
                        screenWidth * 0.045, // auto adjusts with screen width
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                // 🕒 Timer + Resend Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!loginProvider.isResendAvailable)
                      Text(
                        "Resend OTP in ${loginProvider.secondsRemaining}s",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: "Outfit",
                          fontSize: 16,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: loginProvider.isResendAvailable
                            ? () => loginProvider.resendOtp(context)
                            : null,
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: Color(0xFFD29F2A),
                            fontSize: 16,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ] else if (loginProvider.otpSent)
                _otpInputBoxes(screenWidth, loginProvider),
              const SizedBox(height: 25),

              // Login Button
              // _gradientLoginButton(fieldWidth, fieldHeight, () {}),
              loginProvider.otpSent
                  ? _gradientLoginButton(
                      fieldWidth,
                      fieldHeight,
                      () async {
                        if (loginProvider.isLoading) return;

                        final phone = loginProvider.phoneController.text.trim();
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

                          context.go(AppPathsForScreen.userHomePath);
                        }
                      },
                      "Verify OTP",
                      loginProvider,
                    )
                  : _gradientLoginButton(
                      fieldWidth,
                      fieldHeight,
                      () {
                        if (loginProvider.isLoading) return;
                        // print("calling login side");
                        final phone = loginProvider.phoneController.text.trim();
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
                      "Login",
                      loginProvider,
                    ),
              const SizedBox(height: 20),
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

                ctx.pushReplacement(AppPathsForScreen.userHomePath);
              }, "Continue as Guest"),
              const SizedBox(height: 16),
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
              enabled: !provider.otpSent,
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

  Widget _guestModeButton(
    double width,
    double height,
    VoidCallback onPressed,
    String text,
  ) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB8860B), // Dark Goldenrod (premium)
              Color(0xFF3A3A3A), // Charcoal grey for contrast
            ],
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
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.white, // White fits this gradient best
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
