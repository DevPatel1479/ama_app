import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkRaiseQueryScreen extends StatefulWidget {
  const DarkRaiseQueryScreen({super.key});

  @override
  State<DarkRaiseQueryScreen> createState() => _DarkRaiseQueryScreenState();
}

class _DarkRaiseQueryScreenState extends State<DarkRaiseQueryScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Column(
          children: [
            /// Fixed Custom AppBar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      AppAssets.backArrowIcon,
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.12),
                  Text(
                    "Raise your Queries",
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            /// Scrollable content below
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Subtext
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: Text(
                        "If you have any inquiries, get in touch with Us.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.050,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    /// Query Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Query",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.045, // ~22px
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    /// Query Card
                    Container(
                      width: screenWidth * 0.92,
                      height: screenHeight * 0.28,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromRGBO(210, 159, 42, 0.65),
                            Color.fromRGBO(255, 255, 255, 0.65),
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2319),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          controller: _queryController,
                          maxLines: null,
                          expands: true,
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xBFFFFFFF),
                          ),
                          decoration: InputDecoration(
                            hintText: "Raise your Query...",
                            hintStyle: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xBFFFFFFF),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    /// Submit Button
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 6,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(-1.0, 0.0),
                              end: Alignment(1.0, 0.0),
                              colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "Submit",
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
