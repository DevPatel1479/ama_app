import 'package:ama_legal_solutions/config/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                  _gradientBorderInput("Full Name", fieldWidth, fieldHeight),
                  const SizedBox(height: 16),
                  _gradientBorderInput("Email ID", fieldWidth, fieldHeight),
                  const SizedBox(height: 16),
                  _gradientBorderInput("Phone number", fieldWidth, fieldHeight),
                  const SizedBox(height: 16),
                  _gradientBorderDropdown(
                    "Select your State",
                    fieldWidth,
                    fieldHeight,
                  ),
                  const SizedBox(height: 16),
                  _gradientBorderInput("Queries", fieldWidth, fieldHeight),
                  const SizedBox(height: 16),
                  _gradientBorderInput(
                    "How did you hear about this?",
                    fieldWidth,
                    fieldHeight,
                  ),
                  const SizedBox(height: 16),
                  _gradientSignUpButton(fieldWidth, fieldHeight, () {
                    // Handle Sign Up button tap here
                  }),

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
  Widget _gradientBorderInput(String label, double width, double height) {
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // text spacing inside
            child: TextField(
              style: const TextStyle(color: Colors.white),
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
    );
  }

  // Dropdown Field with same gradient border
  Widget _gradientBorderDropdown(String label, double width, double height) {
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF171717),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                hint: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0x59FFFFFF),
                    fontFamily: "Outfit",
                  ),
                ),
                items: ["Gujarat", "Maharashtra", "Delhi", "Karnataka"]
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
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sign Up Button
  Widget _gradientSignUpButton(
    double width,
    double height,
    VoidCallback onPressed,
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
              child: const Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
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
