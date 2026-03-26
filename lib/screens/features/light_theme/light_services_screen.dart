// lib/screens/light_services_screen.dart
import 'dart:math';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_services_screen.dart'
    show showRaiseQueryBottomSheet;
import 'package:ama_legal_solutions/screens/roles/user/dark_theme/dark_user_home_screen.dart'
    show RealtimeImageCarousel;
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LightServicesScreen extends StatefulWidget {
  const LightServicesScreen({super.key});

  @override
  State<LightServicesScreen> createState() => _LightServicesScreenState();
}

class _LightServicesScreenState extends State<LightServicesScreen>
    with SingleTickerProviderStateMixin {
  final List<String> services = [
    "Banking & Finance",
    "Loan Settlement",
    "Intellectual Property Rights",
    "Entertainment Law",
    "Real Estate",
    "Criminal Law",
    "Corporate Law",
    "Arbitration Law",
    "IT & Cyber Law",
    "Civil Law",
    "Drafting",
    "Litigation",
  ];

  final Map<String, String> _preview = {
    "Banking & Finance":
        "Expert legal solutions for financial disputes, fraud cases, and banking compliance matters. We handle issues related to frozen accounts, regulatory actions, and financial litigation.",
    "Loan Settlement":
        "Get professional help to settle your loans legally - whether it’s a credit card, personal, business, or vehicle loan. We follow RBI guidelines to negotiate and resolve defaults with banks and NBFCs.",
    "Intellectual Property Rights":
        "Protect your ideas and brand legally. Our team handles trademark, copyright, and patent filings, IP infringement cases, and brand protection for startups and businesses.",
    "Entertainment Law":
        "Comprehensive legal support for film, music, and media professionals. We advise on contracts, licensing, and rights management for OTT and digital platforms.",
    "Real Estate":
        "End-to-end legal assistance for property disputes, RERA compliance, registration, land verification, and real estate fraud. Safeguard your property investments with expert due diligence.",
    "Criminal Law":
        "From FIR to trial, we provide full legal representation in criminal cases, including cybercrime, financial fraud, money laundering, and police investigations.",
    "Corporate Law":
        "Simplify your business’s legal journey. We assist with company incorporation, startup compliance, MSME registration, contracts, and partnership agreements.",
    "Arbitration Law":
        "Resolve disputes efficiently through arbitration. We draft agreements, handle arbitral awards, and represent clients in financial and commercial arbitration cases.",
    "IT & Cyber Law":
        "Protect your digital presence. We handle cyber fraud complaints, online defamation, social media harassment, and other IT-related legal matters.",
    "Civil Law":
        "Expert help for property, contract, and landlord-tenant disputes. Our team ensures fair resolutions in civil matters through strong legal representation.",
    "Drafting":
        "Professionally drafted legal documents including contracts, agreements, NDAs, deeds, and notices - customized for India and the UK.",
    "Litigation":
        "Comprehensive litigation support across civil, criminal, corporate, real estate, and financial disputes - representing clients in all major courts and tribunals.",
  };

  int? _focusedIndex;
  late final AnimationController _overlayController;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _cardScale;

  late final Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _overlayOpacity = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    );
    _cardScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeOutBack),
    );

    // Animate background color from golden to semi-transparent black
    _backgroundColor = ColorTween(
      begin: const Color(0xFFF8BD00),
      end: Colors.black.withOpacity(0.6),
    ).animate(_overlayOpacity);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  Future<void> _openCard(int index) async {
    setState(() => _focusedIndex = index);
    await _overlayController.forward(from: 0.0);
  }

  Future<void> _closeCard() async {
    await _overlayController.reverse();
    if (!mounted) return;
    setState(() => _focusedIndex = null);
  }

  Widget _buildGridCard(BuildContext context, int index) {
    final title = services[index];
    final preview = _preview[title] ?? "Quick summary about this service.";

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 200;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openCard(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFD29F2A), Color(0xFF3A2B1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(1.2),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D2319),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: isWide ? 17 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      preview,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        height: 1.25,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "View More",
                        style: TextStyle(
                          color: Color(0xFFD29F2A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: Color(0xFFD29F2A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFocusedCard(BuildContext context, int index) {
    final title = services[index];
    final description = _preview[title] ?? "Description not available.";
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Center(
      child: ScaleTransition(
        scale: _cardScale,
        child: FadeTransition(
          opacity: _overlayOpacity,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: min(screenWidth * 0.95, 760),
              maxHeight: min(
                MediaQuery.of(context).size.height * 0.85 - topPadding,
                820,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                padding: const EdgeInsets.all(1.4),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2319),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Raise a Query button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final userRole = await getUserRole();
                              if (userRole?.toLowerCase() == "guest") {
                                final isDark = Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).isDarkMode;
                                showDialog(
                                  context: context,
                                  builder: (_) => LoginRequiredDialog(
                                    isDarkTheme: isDark,

                                    onLoginPressed: () {
                                      Navigator.pop(context);
                                      context.goNamed(AppScreenNames.logIn);
                                      // context.pushNamed(AppScreenNames.l);
                                    },
                                  ),
                                );
                                return;
                              }
                              // Add your Raise a Query logic here
                              _closeCard();

                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  showRaiseQueryBottomSheet(context, title);
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD29F2A),
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    screenWidth * 0.035, // responsive height
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Raise a Query',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize:
                                    screenWidth * 0.045, // responsive font
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // status bar (golden header)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A), // you keep golden statusbar
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    const scaleFactor = 0.85;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final crossTopPadding = MediaQuery.of(context).padding.top + 12;
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;
    final headerVisualHeight = screenHeight * 0.03; // tweak if you need taller
    final appBarHeight =
        MediaQuery.of(context).padding.top + headerVisualHeight;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      // <-- IMPORTANT: make scaffold transparent so page background can extend under system UI/home indicator
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
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  onPressed: () => context.go(AppPathsForScreen.userHomePath),
                  splashRadius: 24, // optional, makes tap area bigger
                ),

                SizedBox(width: screenWidth * 0.001 * scaleFactor),

                Text(
                  'Services',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: (screenWidth / 100) * 6.5 * 0.85,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Positioned.fill(
            //   child: Container(
            //     decoration: BoxDecoration(color: Color(0xFFF8BD00)),
            //   ),
            // ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _overlayController,
                builder: (context, child) {
                  return Container(
                    color: _focusedIndex != null
                        ? _backgroundColor.value
                        : const Color(0xFFF8BD00),
                  );
                },
              ),
            ),
            // full-screen gradient background that actually fills entire screen
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(
                        0xFFFFE7B6,
                      ), // adjust to match your golden theme if needed
                      Color(0xFFD29F2A),
                      Color(0xFFFFFFFF),
                    ],
                  ),
                ),
              ),
            ),

            // your top golden layout (kept as-is). GradientTopLayout should not clip the bottom.
            GradientTopLayout(
              screenName: "home",
              keepExpanded: false,
              // headerContent: Container(
              //   width: double.infinity,
              //   padding: EdgeInsets.symmetric(
              //     horizontal: screenWidth * 0.04 * scaleFactor,
              //     vertical: screenWidth * 0.04 * scaleFactor,
              //   ),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFD29F2A),
              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(screenWidth * 0.07),
              //       bottomRight: Radius.circular(screenWidth * 0.07),
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           GestureDetector(
              //             onTap: () =>
              //                 context.go(AppPathsForScreen.userHomePath),
              //             child: Image.asset(
              //               AppAssets.backArrowIcon,
              //               width: screenWidth * 0.05 * scaleFactor,
              //               height: screenWidth * 0.05 * scaleFactor,
              //               fit: BoxFit.contain,
              //               color: Colors.black,
              //             ),
              //           ),
              //           SizedBox(width: screenWidth * 0.12 * scaleFactor),
              //           Text(
              //             'Services',
              //             style: GoogleFonts.outfit(
              //               color: Colors.black,
              //               fontSize: screenWidth * 0.065 * scaleFactor,
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text(
                    //       'Our Services',
                    //       style: GoogleFonts.outfit(
                    //         color: Colors.black87,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    RealtimeImageCarousel(type: "services"),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 2;
                          final w = constraints.maxWidth;
                          if (w > 1000)
                            crossAxisCount = 4;
                          else if (w > 700)
                            crossAxisCount = 3;

                          double childAspectRatio =
                              (constraints.maxWidth / crossAxisCount) / 170;
                          final safeAspect = childAspectRatio.clamp(0.9, 1.8);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RepaintBoundary(
                              child: GridView.builder(
                                padding: EdgeInsets.only(
                                  bottom: contentBottomPadding,
                                ),
                                physics: _focusedIndex == null
                                    ? const BouncingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: safeAspect,
                                    ),
                                itemCount: services.length,
                                itemBuilder: _buildGridCard,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // overlay when focused
            // if (_focusedIndex != null) ...[
            //   FadeTransition(
            //     opacity: _overlayOpacity,
            //     child: GestureDetector(
            //       onTap: _closeCard,
            //       child: Container(color: Colors.black.withOpacity(0.6)),
            //     ),
            //   ),
            //   Positioned.fill(
            //     child: IgnorePointer(
            //       ignoring: false,
            //       child: _buildFocusedCard(context, _focusedIndex!),
            //     ),
            //   ),
            //   Positioned(
            //     top: crossTopPadding,
            //     right: 18,
            //     child: SafeArea(
            //       child: IconButton(
            //         onPressed: _closeCard,
            //         icon: const CircleAvatar(
            //           radius: 18,
            //           backgroundColor: Color(0xFF3A2B1F),
            //           child: Icon(Icons.close, color: Colors.white, size: 18),
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
            Offstage(
              offstage: _focusedIndex == null,
              child: Stack(
                children: [
                  // Semi-transparent backdrop
                  FadeTransition(
                    opacity: _overlayOpacity,
                    child: GestureDetector(
                      onTap: _closeCard,
                      child: Container(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),

                  // Focused card
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: _focusedIndex == null,
                      child: _focusedIndex != null
                          ? _buildFocusedCard(context, _focusedIndex!)
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Close button
                  if (_focusedIndex != null)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 18,
                      child: SafeArea(
                        child: IconButton(
                          onPressed: _closeCard,
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF3A2B1F),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // bottom nav overlay
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNav(),
            ),
          ],
        ),
      ),
    );
  }
}
