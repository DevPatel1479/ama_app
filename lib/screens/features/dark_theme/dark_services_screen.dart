// lib/screens/dark_services_screen.dart
import 'dart:math';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/roles/user/dark_theme/dark_user_home_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
    // keep statusbar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final topInset = mq.padding.top;
    final bottomInset = mq.padding.bottom;

    // nav + paddings
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final contentBottomPadding = navHeight + bottomInset + 20.0;

    // header sizing — explicit fixed app bar height (adjust if needed)
    final double appBarHeight = 56.0;
    final double headerTotalHeight = topInset + appBarHeight;

    // colors
    const Color topBgColor = Colors.transparent;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF171717), Color(0xFF171717)],
                    ),
                  ),
                ),
              ),
              // -------------- Fixed header (topInset + appBarHeight) --------------
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerTotalHeight,
                child: Container(
                  color: topBgColor,
                  padding: EdgeInsets.only(top: topInset),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      // horizontal: screenWidth * 0.04 * 0.85,
                      vertical: screenWidth * 0.04 * 0.85,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero, // remove default padding

                          icon: Image.asset(
                            AppAssets.backArrowIcon,
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.06,
                            fit: BoxFit.contain,
                          ),
                          onPressed: () =>
                              context.go(AppPathsForScreen.userHomePath),
                          splashRadius: 24, // optional, makes tap area bigger
                        ),
                        SizedBox(width: screenWidth * 0.001 * 0.85),
                        Text(
                          'Services',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: (screenWidth / 100) * 6.5 * 0.85,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // -------------- Scrollable content starts BELOW the fixed header --------------
              Positioned.fill(
                top: headerTotalHeight,
                child: Column(
                  children: [
                    // "Our Services" label — now safe, won't be overlapped
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Our Services',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    RealtimeImageCarousel(type: "services"),
                    // SizedBox(height: screenHeight * 0.2),
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

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: RepaintBoundary(
                              child: GridView.builder(
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
                                padding: EdgeInsets.only(
                                  bottom: contentBottomPadding,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Overlay when a card is focused
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
              //     top: topInset + 12,
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
              // Overlay when a card is focused
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

              // Bottom nav (overlay)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showRaiseQueryBottomSheet(BuildContext context, String service) {
  final screenWidth = MediaQuery.of(context).size.width;
  final queryController = TextEditingController();

  final provider = Provider.of<QueryProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2319),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Raise a Query for $service",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: queryController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type your query here...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF3A2B1F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 16),

                // Buttons row
                Row(
                  children: [
                    Expanded(
                      child: Consumer<QueryProvider>(
                        builder: (context, provider, _) {
                          return ElevatedButton(
                            onPressed: provider.isFileDisputeLoading
                                ? null
                                : () async {
                                    final queryText = queryController.text
                                        .trim();
                                    if (queryText.isEmpty) {
                                      showCustomMessage(
                                        context,
                                        "Please enter query",
                                        true,
                                      );
                                      return;
                                    }

                                    final role = await getUserRole();
                                    final phone = await getUserPhone();
                                    final name = await getUserName();

                                    await provider.raiseQuery(
                                      context: context,
                                      role: role ?? "",
                                      phone: phone ?? "",
                                      name: name ?? "",
                                      queryText: queryText,
                                      fileDispute: true,
                                      selectedService: service,
                                    );
                                    await Future.delayed(Duration(seconds: 2));
                                    Navigator.of(
                                      context,
                                    ).pop(); // close bottom sheet
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD29F2A),
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: provider.isFileDisputeLoading
                                ? SizedBox(
                                    height: screenWidth * 0.05,
                                    width: screenWidth * 0.05,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Submit",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isFileDisputeLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A2B1F),
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.035,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFD29F2A)),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}
