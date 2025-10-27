import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LightServicesScreen extends StatefulWidget {
  const LightServicesScreen({super.key});

  @override
  State<LightServicesScreen> createState() => _LightServicesScreenState();
}

class _LightServicesScreenState extends State<LightServicesScreen>
    with TickerProviderStateMixin {
  // Services list drives how many cards we render.
  final List<String> services = [
    "Banking & Finance",
    "Legal & Compliance",
    "Banking & Finance",
    "Legal & Compliance",
    "Banking & Finance",
    "Legal & Compliance",
  ];

  // Each card gets its own state and controller/animation.
  late final List<bool> _isExpanded;
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    final int cardCount = services.length;

    // initialize expanded flags for every card
    _isExpanded = List<bool>.filled(cardCount, false);

    // create a controller + animation per card
    _controllers = List.generate(
      cardCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut))
        .toList();
  }

  // Toggle expand for a card at [index].
  // Opening: set flag true then forward the controller.
  // Closing: reverse the controller and only set flag false after reverse completes,
  // so the SizeTransition animates both ways with the same timing.
  void toggleExpand(int index) {
    if (!_isExpanded[index]) {
      setState(() {
        _isExpanded[index] = true;
      });
      _controllers[index].forward(from: 0);
    } else {
      _controllers[index].reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _isExpanded[index] = false;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget buildServiceCard(int index) {
    // Use per-card animation here
    final anim = _animations[index];
    final bool expanded = _isExpanded[index];
    final title = services[index];

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8 * 0.85),
          padding: const EdgeInsets.all(2 * 0.85),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(expanded ? 35 : 20),
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(210, 159, 42, 0.65),
                Color.fromRGBO(255, 255, 255, 0.65),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16 * 0.85),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2319),
              borderRadius: BorderRadius.circular(expanded ? 35 : 20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 25 * 0.85,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8 * 0.85),

                // SizeTransition driven by the per-card animation (anim)
                // expanded child remains present while reversing because we
                // only flip the expanded flag after reverse completes.
                SizeTransition(
                  sizeFactor: anim,
                  axisAlignment: 1,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16 * 0.85),
                          child: Container(
                            padding: const EdgeInsets.all(16 * 0.85),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(150, 102, 72, 5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "About the Service",
                                  style: GoogleFonts.outfit(
                                    fontSize: 20 * 0.85,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8 * 0.85),
                                Text(
                                  "Expert guidance on loans, investments, \ncompliance, and disputes with banks or \nfinancial institutions.",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16 * 0.85,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12 * 0.85),
                                Text(
                                  "Who Needs It?",
                                  style: GoogleFonts.outfit(
                                    fontSize: 20 * 0.85,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8 * 0.85),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "• Businesses managing finance or credit",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      "• Individuals in bank-related disputes",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      "• Startups & companies needing compliance",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      "• Investors securing safe agreements",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16 * 0.85),
                                Center(
                                  child: Container(
                                    width: 228 * 0.85,
                                    height: 38 * 0.85,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(29),
                                      gradient: const LinearGradient(
                                        begin: Alignment(-1.0, -0.0),
                                        end: Alignment(1.0, 0.0),
                                        colors: [
                                          Color(0xFFD29F2A),
                                          Color(0xFFFFFFFF),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Get Started",
                                      style: GoogleFonts.outfit(
                                        fontSize: 20 * 0.85,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 8 * 0.85),
                GestureDetector(
                  onTap: () => toggleExpand(index),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        expanded ? "View Less" : "View More",
                        style: GoogleFonts.outfit(
                          fontSize: 16 * 0.85,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xBFFFFFFF),
                        ),
                      ),
                      const SizedBox(width: 8 * 0.85),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xBFFFFFFF),
                        size: 18 * 0.85,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark, // white icons
        statusBarBrightness: Brightness.light, // iOS: white icons
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = 0.75;
    // Keep search bar + button fixed at the top; cards scroll below.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GradientTopLayout(
          screenName: "home",
          headerContent: Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04 * scaleFactor,
              vertical: screenHeight * 0.015 * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD29F2A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(screenWidth * 0.07), // ~responsive
                bottomRight: Radius.circular(screenWidth * 0.07), // ~responsive
              ),
            ),

            // fixed header + search area
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppPathsForScreen.userHomePath),
                      child: Image.asset(
                        AppAssets.backArrowIcon,
                        width: screenWidth * 0.05 * scaleFactor,
                        height: screenWidth * 0.05 * scaleFactor,
                        fit: BoxFit.contain,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.12 * scaleFactor),
                    Text(
                      "Services",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.065 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // Search bar stays fixed
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04 * scaleFactor,
              vertical: screenHeight * 0.015 * scaleFactor,
            ),
            child:
                // scrollable list below the fixed search: cards live here
                ListView(
                  shrinkWrap: true, // important
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      height:
                          MediaQuery.of(context).size.height *
                          0.08 *
                          scaleFactor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF2D2319),
                          width: 2,
                        ),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 18 * scaleFactor, height: 10),
                          Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 20 * scaleFactor,
                          ),
                          SizedBox(width: 10 * scaleFactor),
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search any Service...",
                                hintStyle: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.08 *
                                  scaleFactor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20 * scaleFactor,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment
                                      .topCenter, // <- start from top-left
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2D2319),
                                    Color.fromARGB(255, 116, 116, 116),
                                  ],
                                  stops: [0.2, 1.0],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Search",
                                style: GoogleFonts.outfit(
                                  fontSize: 14 * scaleFactor,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    // // Past Viewed header + first two cards
                    // Padding(
                    //   padding: EdgeInsets.only(left: 4 * scaleFactor),
                    //   child: Text(
                    //     "Past Viewed",
                    //     style: GoogleFonts.outfit(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w500,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    // if (services.length > 0) buildServiceCard(0),
                    // if (services.length > 1) buildServiceCard(1),

                    // Our Services header
                    // const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.only(left: 4 * scaleFactor),
                      child: Text(
                        "Our Services",
                        style: GoogleFonts.outfit(
                          fontSize: 16 * scaleFactor,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * scaleFactor),

                    // Remaining cards (from index 2 onward)
                    for (int i = 2; i < services.length; i++)
                      buildServiceCard(i),

                    SizedBox(height: 40 * scaleFactor),
                  ],
                ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
