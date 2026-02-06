import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_payment_view_screen.dart'
    show openEmail;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class LightPaymentViewScreen extends StatelessWidget {
  const LightPaymentViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF8BD00),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 244, 206, 83),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),

        // ⭐ NATIVE WAY TO ROUND ONLY BOTTOM
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.07),
            bottomRight: Radius.circular(screenWidth * 0.07),
          ),
        ),

        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero, // remove default padding

                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                  onPressed: () => context.pop(),
                  splashRadius: 24, // optional, makes tap area bigger
                ),

                Text(
                  'Payment & Billing',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: screenWidth * 0.050,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: GradientTopLayout(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: screenHeight * 0.15,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            bottom: screenHeight * 0.06,
          ),
          child: Column(
            children: [
              /// 🔶 PAYMENT CARD
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.035,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 217, 188, 121),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.33),
                      blurRadius: 12.5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// QR IMAGE
                    Image.asset(
                      AppAssets.qrImg,
                      width: screenWidth * 0.55,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: screenHeight * 0.035),

                    /// ACCOUNT DETAILS TITLE
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account Details:-",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff2D2319),
                          height: 1,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    /// DETAILS ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LEFT LABELS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _LeftText("Bank Name"),
                            _LeftText("A/C Name"),
                            _LeftText("A/C No."),
                            _LeftText("IFSC Code"),
                            _LeftText("UPI ID"),
                          ],
                        ),

                        const Spacer(),

                        /// RIGHT VALUES
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            _RightText("Axis bank"),
                            _RightText("AMA LEGAL SOLUTIONS"),
                            _RightText("920020057568930"),
                            _RightText("UTIB0004550"),
                            _RightText("amalegalsolution@upi"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              /// 🔶 FOOTER TEXT
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(
                      text: "For payment-related queries, contact us at ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: "finance@amalegalsolutions.com",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD29F2A),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w300,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          openEmail("finance@amalegalsolutions.com");
                          // TODO: open email intent
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
}

class _LeftText extends StatelessWidget {
  final String text;
  const _LeftText(this.text);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: w * 0.03),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: w * 0.045,
          fontWeight: FontWeight.w400,
          color: const Color.fromRGBO(45, 35, 25, 0.70),
          height: 1,
        ),
      ),
    );
  }
}

class _RightText extends StatelessWidget {
  final String text;
  const _RightText(this.text);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: w * 0.03),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: GoogleFonts.outfit(
          fontSize: w * 0.045,
          fontWeight: FontWeight.w400,
          color: const Color(0xff2D2319),
          height: 1,
        ),
      ),
    );
  }
}
