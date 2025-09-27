import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/config/constants/form_data.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/sign_up_message.dart';
import 'package:ama_legal_solutions/provider/auth/signup_screen_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DarkSignupScreen extends StatefulWidget {
  const DarkSignupScreen({super.key});

  @override
  _DarkSignupScreenState createState() => _DarkSignupScreenState();
}

class _DarkSignupScreenState extends State<DarkSignupScreen> {
  double _scale = 1.0;
  String? _selectedState;
  String? _selectedReference;
  String? _otherReference; // For "Other" input

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
    final fieldWidth = screenWidth * 0.9; // all fields same width, responsive
    final fieldHeight = 50.0; // consistent height

    final signupProvider = context.watch<SignupProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10), // Reduced top spacing
              // App Logo
              Image.asset(
                "assets/icons/app_logo_with_text.png",
                width: screenWidth * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 5), // Small spacing before Welcome
              // Welcome Section
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
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Input Fields
              Column(
                children: [
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
                    onChanged: (value) => signupProvider.setPhoneNumber(value),
                    keyboardType: TextInputType.phone,
                    errorText: signupProvider.phoneError,
                  ),
                  const SizedBox(height: 16),
                  _gradientBorderDropdown(
                    "Select your State",
                    fieldWidth,
                    fieldHeight,
                    FormData.indianStates,

                    true,
                    errorText: signupProvider.stateError,
                  ),
                  const SizedBox(height: 16),
                  _gradientBorderInput(
                    "Queries",
                    fieldWidth,
                    fieldHeight,
                    onChanged: (value) => signupProvider.setQueries(value),
                  ),
                  const SizedBox(height: 16),
                  _gradientBorderDropdown(
                    "How did you hear about this?",
                    fieldWidth,
                    fieldHeight,
                    FormData.sourceReference,
                    false,
                    errorText: signupProvider.sourceError,
                  ),
                  const SizedBox(height: 16),
                  _gradientSignUpButton(fieldWidth, fieldHeight - 5, () {
                    print("callig this .. ");
                    // Handle Sign Up button tap here
                  }),
                  const SizedBox(height: 10),
                  RichText(
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
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Login",
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
                              context.go(AppPathsForScreen.logInPath);
                              // Example: Navigate to login screen
                              // context.go('/login');
                            },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
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
                  style: const TextStyle(color: Colors.white),
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  inputFormatters: label.toLowerCase().contains("phone")
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ]
                      : [],
                  decoration: InputDecoration(
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
        ),
        if (errorText != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                errorText,
                style: const TextStyle(color: Color(0xFFD29F2A), fontSize: 12),
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
    bool isState, {
    String? errorText,
  }) {
    final signupProvider = Provider.of<SignupProvider>(context);
    bool isOtherSelected = (!isState && _selectedReference == "Other");

    return Column(
      children: [
        Container(
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: isState ? _selectedState : _selectedReference,
                  dropdownColor: const Color(0xFF171717),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  hint: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0x59FFFFFF),
                      fontFamily: "Outfit",
                    ),
                  ),
                  items: items
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value == null) return;

                      if (isState) {
                        _selectedState = value;
                        signupProvider.setState(value);
                      } else {
                        _selectedReference = value;
                        signupProvider.setSourceReference(value);
                        // if (value != "Other")
                        //   signupProvider.setSourceReference("");
                      }
                    });
                  },
                ),
              ),
            ),
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
        // Show error below dropdown
        if (errorText != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                errorText,
                style: const TextStyle(color: Color(0xFFD29F2A), fontSize: 12),
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

          bool isValid = signupProvider.validateForm();

          if (isValid) {
            // Form is valid, proceed with submission
            print("Form Data: ${signupProvider.getFormData()}");
            await signupProvider.submitSignup();
            print(signupProvider.isError);

            if (signupProvider.resultMessage != null) {
              await showSignupMessage(
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
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFD29F2A), Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
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
                      "Sign Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black,
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

// Custom painter for gradient border
class GradientBorderPainter extends CustomPainter {
  final double width;
  final double radius;
  final Gradient gradient;

  GradientBorderPainter({
    required this.width,
    required this.radius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
