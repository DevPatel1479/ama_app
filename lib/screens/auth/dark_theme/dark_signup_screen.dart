import 'dart:ui';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/config/constants/form_data.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/auth/signup_screen_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DarkSignupScreen extends StatefulWidget {
  const DarkSignupScreen({super.key});

  @override
  _DarkSignupScreenState createState() => _DarkSignupScreenState();
}

class _DarkSignupScreenState extends State<DarkSignupScreen> {
  double _scale = 1.0;

  // String? _otherReference; // For "Other" input
  final ValueNotifier<String?> _selectedState = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedCity = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedReference = ValueNotifier<String?>(
    null,
  );

  // Make unique lists
  final List<String> uniqueStates = FormData.indianStates.toSet().toList();
  final List<String> uniqueCities = FormData.indianCities.toSet().toList();
  final List<String> uniqueReferences = FormData.sourceReference
      .toSet()
      .toList();
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
    final fieldWidth = screenWidth; // all fields same width, responsive
    final fieldHeight = 50.0; // consistent height

    final signupProvider = context.watch<SignupProvider>();

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
                // App Logo
                SizedBox(height: screenHeight * 0.09),
                Center(
                  child: Image.asset(
                    AppAssets.newappLogoWithText2,
                    width: screenWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),
                // Welcome Section
                Text(
                  "Get Started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w600,
                    fontSize: 38 * (screenWidth / 375),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                SizedBox(
                  width: double.infinity, // align-self: stretch
                  child: Text(
                    "Legal assistance is just a step away.",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 21 * (screenWidth / 375),
                      fontWeight: FontWeight.w400,
                      height: 1, // line-height: 38px
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // Input Fields
                _gradientBorderInput(
                  "Full Name",
                  fieldWidth,
                  fieldHeight,
                  onChanged: (value) => signupProvider.setFullName(value),
                  errorText: signupProvider.fullNameError,
                ),
                const SizedBox(height: 16),
                _gradientBorderInput(
                  "Email ID",
                  fieldWidth,
                  fieldHeight,
                  onChanged: (value) => signupProvider.setEmail(value),
                  errorText: signupProvider.emailError,
                ),
                const SizedBox(height: 16),
                _gradientBorderInput(
                  "Phone number",
                  fieldWidth,
                  fieldHeight,
                  provider: signupProvider,
                  onChanged: (value) => signupProvider.setPhoneNumber(value),
                  keyboardType: TextInputType.phone,
                  errorText: signupProvider.phoneError,
                ),
                const SizedBox(height: 16),
                _gradientBorderDropdown(
                  "Select your State",
                  fieldWidth,
                  fieldHeight,
                  uniqueStates, // the unique items list
                  _selectedState, // ValueNotifier
                  isState: true, // named param
                  errorText: signupProvider.stateError,
                ),
                const SizedBox(height: 16),
                _gradientBorderInput(
                  "Tell us about your legal concern",
                  fieldWidth,
                  fieldHeight,
                  onChanged: (value) => signupProvider.setQueries(value),
                ),
                const SizedBox(height: 16),
                _gradientBorderDropdown(
                  "How did you hear about this?",
                  fieldWidth,
                  fieldHeight,
                  uniqueReferences,
                  _selectedReference,
                  isState: false,
                  errorText: signupProvider.sourceError,
                ),
                SizedBox(height: screenHeight * 0.03),
                _gradientSignUpButton(fieldWidth, fieldHeight - 5, () {
                  // print("callig this .. ");
                  // Handle Sign Up button tap here
                }),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final fontSize =
                          16 * (screenWidth / 375); // responsive font size
                      final underlineThickness =
                          fontSize * 0.125; // proportional thickness
                      final underlineOffset =
                          fontSize * 0.15; // distance below text

                      // Measure the width of the "Log in" text dynamically
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: "Log in",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize + 4, // slightly larger than base
                          ),
                        ),
                        textDirection: TextDirection.ltr,
                      )..layout();

                      final textWidth = textPainter.width;

                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w300,
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context.go(AppPathsForScreen.logInPath);
                                    },
                                    child: Text(
                                      "Log in",
                                      style: TextStyle(
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSize,
                                        color: Color(0xFFD29F2A),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: underlineOffset,
                                    child: Container(
                                      height: underlineThickness,
                                      width: textWidth,
                                      color: Color(0xFFD29F2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

                  ctx.pushReplacement(AppPathsForScreen.userHomePath);
                }, "Continue as Guest"),
                SizedBox(height: screenHeight * 0.04),
              ],
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

  // Input Field with transparent background and gradient border
  Widget _gradientBorderInput(
    String label,
    double width,
    double height, {
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    String? errorText, // Add this
    SignupProvider? provider,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.01;
    final labelFontSize = 15 * (screenWidth / 375);
    final inputFontSize = 20 * (screenWidth / 375);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                (label.startsWith("Tell us") || label.startsWith("Please "))
                    ? label
                    : "Enter your $label",
                style: GoogleFonts.outfit(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
            if (label.startsWith("Tell us"))
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.025),
                child: Text(
                  "(Optional)",
                  style: GoogleFonts.outfit(
                    fontSize: labelFontSize * 0.85,
                    fontWeight: FontWeight.w400,
                    color: Colors.white54,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: screenHeight * 0.025),
        Container(
          width: width,
          height: label.startsWith("Tell us")
              ? screenHeight * 0.15
              : screenHeight * 0.06,

          // padding: EdgeInsets.symmetric(
          //   horizontal: horizontalPadding,
          //   vertical: verticalPadding,
          // ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: label.startsWith("Tell us") ? screenHeight * 0.02 : 0,
          ),
          decoration: BoxDecoration(
            color: Color.fromRGBO(210, 159, 42, 0.055),
            borderRadius: BorderRadius.circular(15),
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
            style: GoogleFonts.outfit(
              fontSize: inputFontSize,
              fontWeight: FontWeight.w400,
              height: 1,
              color: Colors.white,
            ),
            keyboardType: label.startsWith("Tell us")
                ? TextInputType.multiline
                : keyboardType,
            minLines: label.startsWith("Tell us")
                ? 4
                : 1, // minimum visible lines
            maxLines: label.startsWith("Tell us") ? null : 1,
            onChanged: onChanged,
            inputFormatters: label.toLowerCase().contains("phone")
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ]
                : [],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: GoogleFonts.outfit(
                fontSize: inputFontSize,
                fontWeight: FontWeight.w400,
                height: 1,
                color: Colors.white.withOpacity(0.6),
              ),
              contentPadding: EdgeInsets.zero, // padding handled by container
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Center(
              child: Text(
                errorText,
                style: TextStyle(color: Color(0xFFD29F2A), fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // Dropdown Field with same gradient border

  Widget _gradientBorderDropdown(
    String label,
    double width,
    double height,
    List<String> items,
    ValueNotifier<String?> selectedValueNotifier, {
    bool isState = false,
    String? errorText,
  }) {
    final signupProvider = Provider.of<SignupProvider>(context);
    bool isOtherSelected = (!isState && selectedValueNotifier.value == "Other");
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final labelFontSize = 15 * (screenWidth / 375);
    final inputFontSize = 20 * (screenWidth / 375);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with optional text
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Flexible(
        //       child: Text(
        //         label,
        //         style: GoogleFonts.outfit(
        //           fontSize: labelFontSize,
        //           fontWeight: FontWeight.w400,
        //           height: 1,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //     if (label.startsWith("How did you hear about this?"))
        //       Padding(
        //         padding: EdgeInsets.only(right: screenWidth * 0.025),
        //         child: Text(
        //           "(Optional)",
        //           style: GoogleFonts.outfit(
        //             fontSize: labelFontSize * 0.85,
        //             fontWeight: FontWeight.w400,
        //             color: Colors.white54,
        //           ),
        //         ),
        //       ),
        //   ],
        // ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w400,
            height: 1,
            color: Colors.white,
          ),
        ),

        SizedBox(height: screenHeight * 0.025),
        Container(
          width: width,
          height: screenHeight * 0.08,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(210, 159, 42, 0.055),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.33),
                offset: Offset(0, 0),
                blurRadius: 12.5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ValueListenableBuilder<String?>(
            valueListenable: selectedValueNotifier,
            builder: (context, selectedValue, _) {
              return DropdownButton2<String>(
                items: items
                    .map(
                      (item) => DropdownItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                valueListenable: selectedValueNotifier,
                hint: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                onChanged: (newValue) {
                  selectedValueNotifier.value = newValue;
                  if (newValue != null) {
                    if (isState) {
                      signupProvider.setState(newValue);
                    } else {
                      signupProvider.setSourceReference(newValue);
                    }
                  }
                },
                isExpanded: true,
                underline: const SizedBox(),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: screenHeight * 0.4,
                  width: width,
                  decoration: BoxDecoration(
                    color: Color(0xFF171717),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                buttonStyleData: ButtonStyleData(height: height),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Show input field if "Other" is selected
        if (isOtherSelected)
          _gradientBorderInput(
            "Please type here",
            width,
            height,
            onChanged: (val) {
              signupProvider.setSourceReference(val); // save Other input
            },
          ),

        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Center(
              child: Text(
                errorText,
                style: TextStyle(color: Color(0xFFD29F2A), fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  // Sign Up Button
  Widget _gradientSignUpButton(
    double width,
    double height,
    VoidCallback onPressed,
  ) {
    final signupProvider = Provider.of<SignupProvider>(context, listen: false);
    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _scale = 0.95; // Scale down on tap
          });
        },
        onTapUp: (_) async {
          setState(() {
            _scale = 1.0; // Return to normal
          });

          if (signupProvider.isLoading) return;

          bool isValid = signupProvider.validateForm();

          if (isValid) {
            // Form is valid, proceed with submission
            // print("Form Data: ${signupProvider.getFormData()}");
            // String rawPhone = signupProvider.phoneNumber;
            // String countryCode = signupProvider.normalizeCountryCode(
            //   signupProvider.getSelectedCountryCode,
            // );
            // signupProvider.setPhoneNumber(countryCode + rawPhone);
            await signupProvider.submitSignup();
            // print(signupProvider.isError);

            if (signupProvider.resultMessage != null) {
              await showCustomMessage(
                context,
                signupProvider.resultMessage!,
                signupProvider.isError,
              );
              if (!signupProvider.isError) {
                Future.delayed(const Duration(seconds: 1), () {
                  context.go(AppPathsForScreen.logInPath);
                });
              }
            }
          } else {
            print("has error...");
            // Form has errors, rebuild UI to show them
            setState(() {});
          }
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
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(37),
              color: const Color(0xFFD29F2A),
            ),
            child: Center(
              child: signupProvider.isLoading
                  ? SizedBox(
                      width: 24, // 30% of button width
                      height: 24, // Keep it square
                      child: CircularProgressIndicator(
                        strokeWidth: 2, // 3% of width
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                        color: const Color(0xFF2D2319),
                        height: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// // Custom painter for gradient border
// class GradientBorderPainter extends CustomPainter {
//   final double width;
//   final double radius;
//   final Gradient gradient;

//   GradientBorderPainter({
//     required this.width,
//     required this.radius,
//     required this.gradient,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;
//     final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = width;
//     canvas.drawRRect(rrect, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
