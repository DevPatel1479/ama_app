import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/assets_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      AppAssets.img1,
      AppAssets.img2,
      AppAssets.img3,
      AppAssets.img4,
      AppAssets.img5,
      AppAssets.img6,
      AppAssets.img7,
      AppAssets.img8,
      AppAssets.img9,
      AppAssets.img10,
      AppAssets.img11,
    ];

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Stack(
        children: [
          // Grid background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                for (int row = 0; row < 4; row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (col) {
                        final index = row * 4 + col;
                        final imgPath = images[index % images.length];

                        // Only last row images get subtle fade overlay
                        if (row == 3) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  imgPath,
                                  width: 80,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Fade overlay using background color 171717
                              Container(
                                width: 80,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF171717), // fade effect
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              imgPath,
                              width: 80,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom layout overlapping last row with vertical gradient
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00171717), // fully transparent at top
                    Color(0xFF2D2319), // bottom layout color
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100), // extra space above logo
                  // Centered Logo Box (moved down)
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        AppAssets.appLogoWithText,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Title texts
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 25,
                        height: 1.2,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: "Law made "),
                        TextSpan(
                          text: "simple",
                          style: GoogleFonts.satisfy(
                            color: const Color(0xFFD29F2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 25,
                        height: 1.2,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: "advice made "),
                        TextSpan(
                          text: "personal",
                          style: GoogleFonts.satisfy(
                            color: const Color(0xFFD29F2A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Subtitle
                  const Text(
                    "From small queries to big decisions, our experts\nare here to guide you every step of the way.",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w300,
                      fontSize: 10,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Get Started Button
                  Center(
                    child: Container(
                      width: screenWidth * 0.9,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFD29F2A), Colors.white],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Get Started",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            AppAssets.rightArrow,
                            width: 17,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login text
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: "Have an account? "),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Color(0xFFD29F2A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
