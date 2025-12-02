import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/solid_border_painter.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';

import 'package:ama_legal_solutions/provider/auth/login_screen_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';

import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart'
    show updateGlobalUserName, updateGlobalUserEmail;
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
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF8BD00), // status bar color matches layout
        statusBarIconBrightness: Brightness.dark, // for Android: dark icons
        statusBarBrightness: Brightness.light, // for iOS: dark icons
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    final fieldWidth = screenWidth * 0.9;
    final fieldHeight = 50.0;

    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // height becomes 0 → looks invisible
        elevation: 0, // no shadow
        backgroundColor: const Color(0xFFF8BD00),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GradientTopLayout(
          // headerContent: Image.asset(
          //   AppAssets.appLogoWithText2,
          //   width: screenWidth * 0.4,
          //   fit: BoxFit.contain,
          // ),
          headerContent: SizedBox(
            height: 140,
            child: Image.asset(AppAssets.appLogoWithText2, fit: BoxFit.contain),
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
                      color: Colors.black,
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
                            color: Colors.black,
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
                            // final verifyingSnack = SnackBar(
                            //   duration: const Duration(
                            //     days: 1,
                            //   ), // keep until manually hidden
                            //   backgroundColor: Colors.black87,
                            //   behavior:
                            //       SnackBarBehavior.floating, // allows more room
                            //   margin: const EdgeInsets.all(
                            //     12,
                            //   ), // lifts it slightly
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   content: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: const [
                            //       SizedBox(
                            //         width: 22,
                            //         height: 22,
                            //         child: CircularProgressIndicator(
                            //           strokeWidth: 2.3,
                            //           color: Colors.amber,
                            //         ),
                            //       ),
                            //       SizedBox(width: 16),
                            //       Text(
                            //         "Verifying...",
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 16,
                            //           fontFamily: "Outfit",
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // );

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
                        "Login",
                        loginProvider,
                      ),
                const SizedBox(height: 20),
                continueAsGuestButton(
                  fieldWidth, // same responsive width
                  fieldHeight, // same height you used for login
                  () async {
                    final ctx = context;
                    final userProvider = context.read<UserProvider>();
                    Provider.of<RealTimeRoleProvider>(
                      context,
                      listen: false,
                    ).setGuestRole();
                    await LocalStorageHelper.saveString("userRole", "guest");
                    await LocalStorageHelper.saveBool(
                      "isGuestLoggedOut",
                      false,
                    );
                    await LocalStorageHelper.saveBool("isNormalUser", false);
                    await userProvider.loadUserRole();
                    updateGlobalUserName("Guest User");
                    updateGlobalUserEmail("guest@gmail.com");

                    ctx.pushReplacement(AppPathsForScreen.userHomePath);
                  },
                  "Continue as Guest",
                ),

                const SizedBox(height: 16),
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
              enabled: !provider.otpSent,
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

  Widget continueAsGuestButton(
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
          color: const Color(0xFF505050), // SAME as login button
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
