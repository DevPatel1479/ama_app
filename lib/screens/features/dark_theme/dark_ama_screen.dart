import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkAmaScreen extends StatefulWidget {
  const DarkAmaScreen({super.key});
  @override
  _DarkAmaScreenState createState() => _DarkAmaScreenState();
}

class _DarkAmaScreenState extends State<DarkAmaScreen>
    with SingleTickerProviderStateMixin {
  bool _expanded = false; // for view more/less toggle
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget buildDoubtItem({
    required BuildContext context,
    required double screenWidth,
    required double screenHeight,
    required String userName,
    required String askedTime,
    required String fromTag,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row with user info and "From User" badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AppAssets.userIcon,
                width: screenWidth * 0.10,
                height: screenWidth * 0.10,
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      askedTime,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenHeight * 0.025,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.003,
                  horizontal: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 70, 70, 70),
                  border: fromTag == "From User"
                      ? Border.all(color: const Color(0xFF8383F6), width: 1)
                      : Border.all(color: const Color(0xFF04C527), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  fromTag,
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w400,
                    color: fromTag == "From User"
                        ? const Color(0xFF8383F6)
                        : const Color(0xFF04C527),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          // Description text
          Text(
            description,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Like and Answer row
          Row(
            children: [
              Image.asset(
                AppAssets.likeHeartIcon,
                width: screenWidth * 0.04,
                height: screenWidth * 0.04,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Like",
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: screenWidth * 0.05),
              Image.asset(
                AppAssets.answerIcon,
                width: screenWidth * 0.04,
                height: screenWidth * 0.04,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Answer",
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showAskDoubtBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight * 0.8, // Adjust according to your need
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        AppAssets.backArrowIcon,
                        width: screenWidth * 0.05,
                        height: screenWidth * 0.05,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Answer Doubts",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.05,
                    ), // Space equal to back icon width
                  ],
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    children: [
                      buildDoubtItem(
                        context: context,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        userName: "Dev",
                        askedTime: "Asked 1 day ago",
                        fromTag: "From User",
                        description:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, purus at facilisis gravida, mauris nulla dapibus lectus, sed ultricies magna elit nec purus.",
                      ),
                      buildDoubtItem(
                        context: context,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        userName: "Alice",
                        askedTime: "Asked 2 days ago",
                        fromTag: "From Client",
                        description:
                            "Sed euismod, purus at facilisis gravida, mauris nulla dapibus lectus, sed ultricies magna elit nec purus. Nullam id neque sit amet nibh bibendum porttitor.",
                      ),
                      // Add more items as needed
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
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
            /// fixed header + search area
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppPathsForScreen.userHomePath),
                        child: Image.asset(
                          AppAssets.backArrowIcon,
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.12),
                      Text(
                        "AMA",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.065,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),

                      /// Ask Doubt Button at top-right
                      SizedBox(
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.05,
                        child: ElevatedButton(
                          onPressed: () {
                            showAskDoubtBottomSheet(context);
                          },

                          style:
                              ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(41),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.black.withOpacity(0.3),
                                elevation: 6,
                              ).copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(-1.0, 0.0),
                                end: Alignment(1.0, 0.0),
                                colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
                              ),
                              borderRadius: BorderRadius.circular(41),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Ask Doubt",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
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
                  SizedBox(height: screenHeight * 0.03),

                  /// Search bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xCCFFFFFF),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.search,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search any question...",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontWeight: FontWeight.w300,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment(-1.0, -0.0),
                                end: Alignment(1.0, 0.0),
                                colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Search",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// scrollable list below the fixed search
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      "Your Questions",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  /// Custom Question Card with gradient border
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2319),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: user info + close icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    AppAssets.userIcon,
                                    width: screenWidth * 0.08,
                                    height: screenWidth * 0.08,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Username",
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Asked 1 day ago",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Image.asset(
                                AppAssets.closeBtnIcon,
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          /// Animated expandable question text with bottom fade overlay
                          Stack(
                            children: [
                              // The actual text
                              ClipRect(
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: _expanded
                                        ? const BoxConstraints()
                                        : const BoxConstraints(maxHeight: 54),
                                    child: Text(
                                      "Lorem ipsum dolor sit amet, consectetur adipiscing "
                                      "elit. Sed euismod, purus at facilisis gravida, mauris "
                                      "nulla dapibus lectus, sed ultricies magna elit nec "
                                      "purus. Nullam id neque sit amet nibh bibendum porttitor.",
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom fade overlay (only when collapsed)
                              if (!_expanded)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  height: 20, // height of the fading overlay
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(
                                            0xFF2D2319,
                                          ).withOpacity(0.3),
                                          const Color(
                                            0xFF2D2319,
                                          ), // fade color at bottom
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// Author info section - always in widget tree but collapsed when not expanded
                          /// Author info section with SizeTransition animation
                          SizeTransition(
                            sizeFactor: _animation,
                            axisAlignment: 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.015),
                                Row(
                                  children: [
                                    Image.asset(
                                      AppAssets.appLogoIcon2,
                                      width: screenWidth * 0.15,
                                      height: screenHeight * 0.05,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.005,
                                        horizontal: screenWidth * 0.045,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33FFFFFF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        "From Admin",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFFD29F2A),
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing "
                                  "elit. Sed euismod, purus at facilisis gravida, mauris "
                                  "nulla dapibus lectus, sed ultricies magna elit nec "
                                  "purus. Nullam id neque sit amet nibh bibendum porttitor.",
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFD29F2A),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // View More / View all 20 Replies row
                          SizedBox(
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Centered text + expand_more (only when collapsed)
                                GestureDetector(
                                  onTap: _toggleExpansion,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _expanded
                                            ? "View all 20 Replies"
                                            : "View More",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (!_expanded) // show expand_more only in collapsed state
                                        const SizedBox(width: 4),

                                      const Icon(
                                        Icons.expand_more,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),

                                // Right aligned unexpand icon (only when expanded)
                                if (_expanded)
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _toggleExpansion,
                                      child: Image.asset(
                                        AppAssets.unExpandedIcon,
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
