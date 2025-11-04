import 'dart:math';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkServicesScreen extends StatefulWidget {
  const DarkServicesScreen({super.key});

  @override
  State<DarkServicesScreen> createState() => _DarkServicesScreenState();
}

class _DarkServicesScreenState extends State<DarkServicesScreen>
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
        "Get professional help to settle your loans legally — whether it's a credit card, personal, business, or vehicle loan. We follow RBI guidelines to negotiate and resolve defaults with banks and NBFCs.",
    "Intellectual Property Rights":
        "Protect your ideas and brand legally. Our team handles trademark, copyright, and patent filings, IP infringement cases, and brand protection for startups and businesses.",
    "Entertainment Law":
        "Comprehensive legal support for film, music, and media professionals. We advise on contracts, licensing, and rights management for OTT and digital platforms.",
    "Real Estate":
        "End-to-end legal assistance for property disputes, RERA compliance, registration, land verification, and real estate fraud. Safeguard your property investments with expert due diligence.",
    "Criminal Law":
        "From FIR to trial, we provide full legal representation in criminal cases, including cybercrime, financial fraud, money laundering, and police investigations.",
    "Corporate Law":
        "Simplify your business's legal journey. We assist with company incorporation, startup compliance, MSME registration, contracts, and partnership agreements.",
    "Arbitration Law":
        "Resolve disputes efficiently through arbitration. We draft agreements, handle arbitral awards, and represent clients in financial and commercial arbitration cases.",
    "IT & Cyber Law":
        "Protect your digital presence. We handle cyber fraud complaints, online defamation, social media harassment, and other IT-related legal matters.",
    "Civil Law":
        "Expert help for property, contract, and landlord-tenant disputes. Our team ensures fair resolutions in civil matters through strong legal representation.",
    "Drafting":
        "Professionally drafted legal documents including contracts, agreements, NDAs, deeds, and notices — customized for India and the UK.",
    "Litigation":
        "Comprehensive litigation support across civil, criminal, corporate, real estate, and financial disputes — representing clients in all major courts and tribunals.",
  };

  int? _focusedIndex; // when non-null show the overlay with focused card
  late final AnimationController _overlayController;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _cardScale;

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
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _openCard(int index) async {
    setState(() => _focusedIndex = index);
    await _overlayController.forward(from: 0.0);
  }

  void _closeCard() async {
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
                  offset: const Offset(0, 3),
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
                    children: [
                      Text(
                        "View More",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD29F2A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
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
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Center(
      child: ScaleTransition(
        scale: _cardScale,
        child: FadeTransition(
          opacity: _overlayOpacity,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: min(screenWidth * 0.95, 760),
              maxHeight: min(screenHeight * 0.85 - topPadding, 820),
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
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
    return Scaffold(
      extendBody: true, // This is crucial for overlay effect
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2319), Color(0xFF1A1A1A)],
          ),
        ),
        child: Stack(
          children: [
            // Main content - EXTEND TO BOTTOM
            SafeArea(
              bottom: false, // Allow content to extend behind bottom nav
              child: Column(
                children: [
                  // Header row
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04 * scaleFactor,
                      vertical: screenHeight * 0.015 * scaleFactor,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              context.go(AppPathsForScreen.userHomePath),
                          child: Image.asset(
                            AppAssets.backArrowIcon,
                            width: screenWidth * 0.05 * scaleFactor,
                            height: screenWidth * 0.05 * scaleFactor,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.12 * scaleFactor),
                        Text(
                          'Services',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: screenWidth * 0.065 * scaleFactor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Our Services label
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Our Services',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Grid of cards - EXTEND ALL THE WAY TO BOTTOM
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        final w = constraints.maxWidth;
                        if (w > 1000) {
                          crossAxisCount = 4;
                        } else if (w > 700) {
                          crossAxisCount = 3;
                        }

                        double childAspectRatio =
                            (constraints.maxWidth / crossAxisCount) / 170;

                        return Padding(
                          // REDUCE bottom padding to allow content behind nav
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric().copyWith(
                              // ensure the scrollable content has extra bottom padding equal
                              // to the visible nav footprint so last items can scroll above it
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
                                  childAspectRatio: childAspectRatio.clamp(
                                    0.9,
                                    1.8,
                                  ),
                                ),
                            itemCount: services.length,
                            itemBuilder: _buildGridCard,
                          ),
                        );
                      },
                    ),
                  ),

                  // Add space at bottom so content flows behind nav
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),

            // Overlay (when a card is focused)
            if (_focusedIndex != null) ...[
              FadeTransition(
                opacity: _overlayOpacity,
                child: GestureDetector(
                  onTap: _closeCard,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: _buildFocusedCard(context, _focusedIndex!),
                ),
              ),
              Positioned(
                top: crossTopPadding,
                right: 18,
                child: SafeArea(
                  child: IconButton(
                    onPressed: _closeCard,
                    icon: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF3A2B1F),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],

            // Bottom nav (transparent overlay)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const CustomBottomNav(),
            ),
          ],
        ),
      ),
    );
  }
}
