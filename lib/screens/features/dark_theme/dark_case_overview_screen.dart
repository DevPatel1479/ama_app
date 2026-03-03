import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/client/remarks_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';

import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/roles/user/dark_theme/dark_user_home_screen.dart'
    show RealtimeImageCarousel;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;
import 'package:url_launcher/url_launcher.dart';

String normalizeUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  if (url.startsWith('www.')) {
    return 'https://$url';
  }

  return 'https://$url';
}

Future<void> openBlog({String? matchedText}) async {
  final Uri blogUri = Uri.parse("https://www.amalegalsolutions.com/blog");
  if (matchedText != null) {
    final Uri matchedTextUri = Uri.parse(normalizeUrl(matchedText));

    if (!await launchUrl(
      matchedTextUri,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint("Could not open blog link");
    }
  } else if (!await launchUrl(blogUri, mode: LaunchMode.externalApplication)) {
    debugPrint("Could not open blog link");
  }
}

Future<void> openWhatsappContact() async {
  final Uri whatsappUri = Uri.parse(
    "https://wa.me/918700343611?text=I%20want%20legal%20help",
  );

  if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
    debugPrint("Could not open WhatsApp");
  }
}

class DarkOverViewCaseDeskScreen extends StatefulWidget {
  const DarkOverViewCaseDeskScreen({super.key});

  @override
  State<DarkOverViewCaseDeskScreen> createState() =>
      _DarkOverViewCaseDeskScreenState();
}

class _DarkOverViewCaseDeskScreenState
    extends State<DarkOverViewCaseDeskScreen> {
  String userName = "";
  String? userRole;
  String? _role;
  String? _phone;
  String? _lastRole;
  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchUserRole();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final role = context.watch<RealTimeRoleProvider>().role ?? "";

    // first time store role
    _lastRole ??= role;

    // role changed → navigate
    if (_lastRole != role) {
      _lastRole = role;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (role == "admin") {
          context.go(AppPathsForScreen.caseDeskPath);
        } else if (role == "advocate") {
          context.go(AppPathsForScreen.caseDeskPath);
        } else if (role == "client") {
          context.go(AppPathsForScreen.overviewCaseDeskPath);
        }
      });
    }
  }

  void _loadUserName() async {
    print("Loading username...");
    // Fetch username from LocalStorageHelper
    final name = await LocalStorageHelper.getString("userName");
    setState(() {
      userName = name ?? "User";
    });
  }

  Future<void> fetchUserRole() async {
    _role = await LocalStorageHelper.getString("userRole");
    _phone = await LocalStorageHelper.getString("userPhone");
    setState(() {
      userRole = _role;
      _lastRole = _role;
    });
    if (_phone != null) {
      // Use existing RemarksProvider. Its fetchRemarks signature used Endpoints internally,
      // it previously accepted a baseUrl param — pass empty string because provider uses Endpoints.
      final remarksProv = Provider.of<RemarksProvider>(context, listen: false);
      await remarksProv.fetchRemarks("", _phone!);
    }
  }

  Widget buildTimelineStep({
    required String remarks,
    required String dateTime,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final double dotSize = 12;
    final double lineWidth = 2;
    final double segmentHeight = 6;
    final double segmentGap = 4;
    final int segmentCount = 4;

    List<Widget> buildBrokenLine() {
      return List.generate(segmentCount, (index) {
        return Container(
          width: lineWidth,
          height: segmentHeight,
          margin: EdgeInsets.only(top: segmentGap),
          color: Color(0xFF04C527),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP ROW → DOT + REMARKS + DATE/TIME
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // DOT
            Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(
                color: Color(0xFFD29F2A),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            // REMARKS + DATE/TIME TOGETHER
            Flexible(
              child: Row(
                children: [
                  // REMARKS (flexible)
                  Flexible(
                    child: Text(
                      remarks,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // DATE + TIME (inline next to remarks)
                  Text(
                    dateTime,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // BROKEN LINE UNDER DOT — CONNECTED PERFECTLY
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: dotSize / 2 - lineWidth / 2),
            child: Column(children: buildBrokenLine()),
          ),
      ],
    );
  }

  Future<void> openCaseStatusScreen(BuildContext context) async {
    final phone = await LocalStorageHelper.getString("userPhone");

    if (phone != null) {
      final remarksProv = Provider.of<RemarksProvider>(context, listen: false);

      await remarksProv.fetchRemarks("", phone);
    }

    context.pushNamed(AppScreenNames.liveCaseStatusScreen);
  }

  Widget bankingDetailsCard(BuildContext context, {VoidCallback? onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04, // left ≈ 15px
          screenHeight * 0.02, // top ≈ 15px
          screenWidth * 0.05, // right ≈ 70px
          screenHeight * 0.02, // bottom ≈ 15px
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(45, 35, 25, 0.5),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Main Title
            Text(
              "My Details",
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.05, // responsive ~20px
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.0,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            /// Subtitle
            Text(
              "Your details safely stored here",
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.035, // responsive ~16px
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final bottomNavHeight = 60.0; // approx height of CustomBottomNav

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
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
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top:
                  kToolbarHeight +
                  MediaQuery.of(context).padding.top +
                  screenHeight * 0.04, // ❗ account for appbar + extra spacing
              left: screenWidth * 0.06,
              right: screenWidth * 0.06,
              bottom:
                  screenHeight * 0.09 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🖼️ LAZY LOADED HIGH QUALITY IMAGE
                // Image.asset(
                //   AppAssets.overviewImg,
                //   width: double.infinity,
                //   fit: BoxFit.contain,
                //   cacheWidth:
                //       (screenWidth * MediaQuery.of(context).devicePixelRatio)
                //           .round(),
                //   filterQuality: FilterQuality.high,
                //   gaplessPlayback: true,
                // ),
                RealtimeImageCarousel(type: "casedesk"),
                SizedBox(height: screenHeight * 0.05),

                /// 👋 Welcome <username>
                /// 👋 Welcome <username>
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome, ",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w300, // Light
                          fontSize: 25,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: userName,
                        style: GoogleFonts.dancingScript(
                          fontWeight: FontWeight.w400, // Regular
                          fontSize: 25,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                /// 📝 Existing "One secure desk..." text
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.11,
                      fontWeight: FontWeight.w300,
                      height: 1.0,
                    ),
                    children: [
                      const TextSpan(
                        text: "One ",
                        style: TextStyle(color: Color(0xffD29F2A)),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFD29F2A), Colors.white],
                            ).createShader(bounds);
                          },
                          child: Text(
                            "secure",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.11,
                              fontWeight: FontWeight.w300,
                              height: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: " desk for your cases",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.06),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.025,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromRGBO(45, 35, 25, 0.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.33),
                        blurRadius: 12.5,
                      ),
                    ],
                  ),
                  child: Consumer<RemarksProvider>(
                    builder: (context, remarksProv, _) {
                      final bool hasRemarks = remarksProv.remarks.isNotEmpty;
                      final bool loading = remarksProv.loading;
                      print("has remarks = $hasRemarks, loading = $loading");
                      // Compute last updated string if remarks exist
                      String? lastUpdatedText;
                      if (hasRemarks) {
                        final latest = remarksProv.remarks.first;

                        if (latest.createdAt != null) {
                          // Multiply by 1000 if createdAt is in seconds
                          final updatedAt = DateTime.fromMillisecondsSinceEpoch(
                            latest.createdAt * 1000,
                          );
                          final now = DateTime.now();
                          final difference = now.difference(updatedAt);

                          if (difference.inMinutes < 1) {
                            lastUpdatedText = "Last updated · just now";
                          } else if (difference.inMinutes < 60) {
                            lastUpdatedText =
                                "Last updated · ${difference.inMinutes} min ago";
                          } else if (difference.inHours < 24) {
                            lastUpdatedText =
                                "Last updated · ${difference.inHours} hrs ago";
                          } else {
                            lastUpdatedText =
                                "Last updated · ${difference.inDays} days ago";
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔶 TOP ROW
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const BlinkingDot(size: 10),
                              SizedBox(width: screenWidth * 0.02),

                              // Active / No Active Case or shimmer
                              if (loading)
                                Shimmer.fromColors(
                                  baseColor: Colors.white24,
                                  highlightColor: Colors.white54,
                                  child: Container(
                                    width: screenWidth * 0.25,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Text(
                                  hasRemarks ? "Active Case" : "No Active Case",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.040,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),

                              const Spacer(),

                              if (hasRemarks && lastUpdatedText != null)
                                Text(
                                  lastUpdatedText,
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.032,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          /// 🔶 STATUS ROW
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Status",
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.050,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),

                              // Dot
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xffD29F2A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),

                              // Live status or shimmer
                              if (loading)
                                Shimmer.fromColors(
                                  baseColor: Colors.white24,
                                  highlightColor: Colors.white54,
                                  child: Container(
                                    width: screenWidth * 0.25,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                )
                              else if (remarksProv.errorMessage != null)
                                Text(
                                  "Error",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.040,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                )
                              else if (!hasRemarks)
                                Text(
                                  "Pending",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.040,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                )
                              else
                                Text(
                                  remarksProv.remarks.first.remarks,
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.040,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.035),

                          // 🔶 BUTTON
                          SizedBox(
                            width: screenWidth * 0.55,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                await openCaseStatusScreen(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.012,
                                  horizontal: screenWidth * 0.08,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Case Status History",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w400,
                                    color: const Color.fromARGB(
                                      255,
                                      33,
                                      26,
                                      19,
                                    ),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Text(
                            "*Tap the case status to view details",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
                bankingDetailsCard(
                  context,
                  onTap: () {
                    context.pushNamed(AppScreenNames.bankDetailsScreen);
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                // SizedBox(height: screenHeight * 0.02),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenHeight * 0.025,

                  // 🔥 important — gives more vertical space
                  childAspectRatio: 0.85,

                  children: [
                    _gridCard(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      image: AppAssets.hg1Img,
                      title: "Ask your Lawyer",
                      subtitle: "Get your query resolved in 45 minutes",
                      onTap: () {
                        context.pushNamed(AppScreenNames.askLawyerScreen);
                      },
                    ),
                    _gridCard(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      image: AppAssets.hg5Img,
                      title: "Payment & Billing",
                      subtitle: "View invoices & payment history",
                      onTap: () {
                        context.pushNamed(AppScreenNames.paymentViewScreen);
                      },
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                supportHelpCard(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () async {
                    await openBlog();
                  },
                  child: courtHearingCard(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // downloadCaseDocsButton(context),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: const CustomBottomNav(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  color: const Color(0xFF171717).withOpacity(0.45),
                  padding: EdgeInsets.only(
                    // left: screenWidth * 0.04,
                    top: MediaQuery.of(context).padding.top,
                  ),
                  alignment: Alignment.centerLeft,
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
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Case Desk',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: screenWidth * 0.050,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget downloadCaseDocsButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        debugPrint("Download Case Documents tapped");
      },
      child: Container(
        width: double.infinity, // ✅ full width
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, // ✅ balanced
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFD29F2A),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
          ],
        ),
        child: Center(
          child: FittedBox(
            // ✅ THIS IS THE FIX
            fit: BoxFit.scaleDown,
            child: Text(
              "Download Your Case Documents",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget courtHearingCard({
    required double screenWidth,
    required double screenHeight,
  }) {
    final double cardHeight = screenHeight * 0.09;
    final double avatarSize = screenWidth * 0.085;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15), // ✅ clips everything
      child: Container(
        width: screenWidth * 0.90,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
          ],
        ),
        child: Stack(
          children: [
            /// ================= LEFT TEXT =================
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.32,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What happens during a court hearing?",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2D2319),
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ),

            /// ================= RIGHT IMAGE AREA =================
            Positioned(
              right: 0, // 🔥 IMPORTANT
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: screenWidth * 0.30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _avatarRow([
                      AppAssets.law1Img,
                      AppAssets.law2Img,
                    ], avatarSize),
                    _avatarRow(
                      [AppAssets.law3Img, AppAssets.law4Img],
                      avatarSize,
                      offset: screenWidth * 0.03,
                    ),
                    _avatarRow([
                      AppAssets.law5Img,
                      AppAssets.law6Img,
                    ], avatarSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarRow(List<String> images, double baseSize, {double offset = 0}) {
    final double imageSize = baseSize * 0.65;
    final double spacing = imageSize * 0.20;

    return Transform.translate(
      offset: Offset(-offset, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(images.length, (index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : spacing),
            child: Image.asset(
              images[index],
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          );
        }),
      ),
    );
  }

  Widget _gridCard({
    required double screenWidth,
    required double screenHeight,
    required String image,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromRGBO(45, 35, 25, 0.5),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ICON
            Image.asset(
              image,
              width: screenWidth * 0.11,
              height: screenWidth * 0.11,
              fit: BoxFit.contain,
            ),

            SizedBox(height: screenHeight * 0.015),

            /// TITLE
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            SizedBox(height: screenHeight * 0.008),

            /// SUBTITLE — FULLY VISIBLE ✅
            Text(
              subtitle,
              softWrap: true, // ✅ allows wrapping
              overflow: TextOverflow.visible, // ✅ no dots
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.034,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.9),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget supportHelpCard({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        color: const Color.fromRGBO(45, 35, 25, 0.5),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= TEXT =================
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Feeling stressed about your case?\n",
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.050, // ~20px
                    fontWeight: FontWeight.w400,
                    height: 1.05,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: "Our legal team is here to guide you step-by-step.",
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.040, // ~16px
                    fontWeight: FontWeight.w300,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          /// ================= SUPPORT ROW =================
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// WhatsApp Icon
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {},
                child: Image.asset(
                  AppAssets.whatshapSupportIcon,
                  width: screenWidth * 0.045,
                  height: screenWidth * 0.045,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(width: screenWidth * 0.025),

              /// Support text
              InkWell(
                onTap: () async {
                  await openWhatsappContact();
                },
                child: Text(
                  "Click here for support",
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.040,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BlinkingDot extends StatefulWidget {
  const BlinkingDot({super.key, this.size = 10});

  final double size;

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Color(0xffD29F2A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
