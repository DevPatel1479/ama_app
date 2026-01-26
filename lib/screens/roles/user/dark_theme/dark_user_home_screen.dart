import 'dart:async' show Timer;
import 'dart:ui' show ImageFilter;

import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/client_testimonial_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/image_slider.dart'
    show AutoScrollSlider;
import 'package:ama_legal_solutions/custom_widgets/login_required_dialog.dart';
import 'package:ama_legal_solutions/custom_widgets/our_legacy_widget.dart';
import 'package:ama_legal_solutions/custom_widgets/realtime_image_carousel.dart';
import 'package:ama_legal_solutions/custom_widgets/send_notification_sheet.dart';
import 'package:ama_legal_solutions/provider/images/realtime_image_provider.dart';

import 'package:ama_legal_solutions/provider/profile/profile_photo_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';

import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;
import 'package:url_launcher/url_launcher.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:video_player/video_player.dart';

Widget connectLawyerCard({
  required BuildContext context,
  required String icon,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
  bool isLight = false,
}) {
  final size = MediaQuery.of(context).size;

  // responsive spacing unit
  final double space = size.width * 0.07;

  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(15),

    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,

      child: Container(
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isLight
              ? const Color.fromARGB(255, 217, 188, 121)
              : const Color.fromRGBO(210, 159, 42, 0.06),
          boxShadow: const [
            BoxShadow(blurRadius: 12.5, color: Color.fromRGBO(0, 0, 0, 0.33)),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ICON
            Image.asset(
              icon,
              width: size.width * 0.11,
              fit: BoxFit.contain,
              color: isLight ? Colors.black : null,
            ),

            SizedBox(height: space),

            /// TITLE
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight ? const Color(0xFF2D2319) : Colors.white,
                fontFamily: "Outfit",
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w400,
                height: 1.1,
              ),
            ),

            SizedBox(height: space * 0.6),

            /// SUBTITLE
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF2D2319).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                fontFamily: "Outfit",
                fontSize: size.width * 0.025,
                fontWeight: FontWeight.w300,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget connectLawyerGrid(BuildContext context, {bool isLight = false}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 2,

    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: screenWidth * 0.04,
      mainAxisSpacing: screenHeight * 0.025,
      childAspectRatio: 1.10,
    ),

    itemBuilder: (context, index) {
      return connectLawyerCard(
        isLight: isLight,
        context: context,
        icon: index == 0 ? AppAssets.connectL : AppAssets.connectC,
        title: index == 0 ? "Connect to Lawyer" : "Track My Case",
        subtitle: index == 0
            ? "Trusted advice from verified experts"
            : "Live status & case progress",
        onTap: () {
          if (index == 0) {
            context.pushNamed(
              AppScreenNames.raiseQuery,
              queryParameters: {"isFilingDispute": "true"},
            );
          } else {
            context.pushNamed(AppScreenNames.overviewCaseDeskScreen);
          }
        },
      );
    },
  );
}

Widget statItem(
  BuildContext context,
  String number,
  String label, {
  bool isLight = false,
}) {
  final size = MediaQuery.of(context).size;

  final double numberFontSize = size.width * 0.062; // ≈ 25px
  final double labelFontSize = size.width * 0.03; // ≈ 12px
  final double spacing = size.height * 0.006;

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        number,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isLight ? const Color(0xFF2D2319) : Colors.white,
          fontFamily: "Outfit",
          fontSize: numberFontSize,
          fontWeight: FontWeight.w600,
          height: 1,
          letterSpacing: -0.475,
        ),
      ),

      SizedBox(height: spacing),

      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isLight
              ? const Color(0xFF2D2319).withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          fontFamily: "Outfit",
          fontSize: labelFontSize,
          fontWeight: FontWeight.w400,
          height: 1,
          letterSpacing: -0.228,
        ),
      ),
    ],
  );
}

Widget verticalDivider(
  BuildContext context,
  double height, {
  bool isLight = false,
}) {
  final size = MediaQuery.of(context).size;

  return Container(
    width: size.width * 0.004, // ≈ 2px
    height: height,

    decoration: isLight
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFDD00).withOpacity(0.0), // gold
                Colors.black, // gold

                Color(0xFFFFDD00).withOpacity(0.0), // gold
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          )
        : BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(149, 114, 35, 0.0), // top fade
                Color(0xFFFFDD00), // gold
                Color.fromRGBO(68, 53, 27, 0.0), // bottom fade
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
  );
}

Widget statOverviewCard(BuildContext context, {bool isLight = false}) {
  final size = MediaQuery.of(context).size;

  // final double horizontalPadding = size.width * 0.06;
  // final double verticalPadding = size.height * 0.018;

  final double dividerHeight = size.height * 0.085;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.06,
      vertical: MediaQuery.of(context).size.height * 0.02,
    ),

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15), // ✅ outer radius
      border: Border.all(
        color: isLight
            ? const Color(0xFF2D2319)
            : const Color(0xFFFFDD00), // #FD0
        width: 1,
      ),
      color: isLight
          ? const Color.fromARGB(255, 217, 188, 121)
          : const Color.fromRGBO(210, 159, 42, 0.06),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          offset: Offset(0, -4),
          blurRadius: 4,
        ),
      ],
    ),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statItem(context, "10k+", "Case\nHandled", isLight: isLight),
        verticalDivider(context, dividerHeight, isLight: isLight),
        statItem(context, "40+", "Year\nExperience", isLight: isLight),
        verticalDivider(context, dividerHeight, isLight: isLight),
        statItem(context, "5k+", "Client\nServed", isLight: isLight),
      ],
    ),
  );
}

final List<String> first10 = const [
  AppAssets.s1Icon,
  AppAssets.s2Icon,
  AppAssets.s3Icon,
  AppAssets.s4Icon,
  AppAssets.s5Icon,
  AppAssets.s6Icon,
  AppAssets.s7Icon,
  AppAssets.s8Icon,
  AppAssets.s9Icon,
  AppAssets.s10Icon,
];

final List<String> next10 = const [
  AppAssets.s11Icon,
  AppAssets.s12Icon,
  AppAssets.s13Icon,
  AppAssets.s14Icon,
  AppAssets.s15Icon,
  AppAssets.s16Icon,
  AppAssets.s17Icon,
  AppAssets.s18Icon,
  AppAssets.s19Icon,
  AppAssets.s20Icon,
];

class TeamCard extends StatelessWidget {
  final String topImage;
  final String bottomImage;
  final VoidCallback? onTap;
  final bool isLight;
  const TeamCard({
    super.key,
    required this.topImage,
    required this.bottomImage,
    this.onTap,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final cardWidth = size.width * 0.9;
    final cardHeight = size.height * 0.15;

    final topImageSize = cardHeight * 0.6;
    final bottomImageSize = cardHeight * 0.6;

    // ✅ responsive text padding
    final textLeftPadding = cardWidth * 0.055;
    final textSpacing = cardHeight * 0.08;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        child: Container(
          width: cardWidth,
          height: cardHeight,

          // 🔒 KEEPING YOUR PADDING EXACTLY
          padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.01),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isLight
                ? const Color.fromARGB(255, 217, 188, 121)
                : const Color.fromRGBO(210, 159, 42, 0.06),
            boxShadow: const [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
            ],
          ),
          child: Row(
            children: [
              /// LEFT TEXT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: textLeftPadding),
                      child: Text(
                        "Meet the Team Behind Your Legal Journey",
                        maxLines: 2,

                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF2D2319)
                              : Colors.white,
                          fontFamily: "Outfit",
                          fontSize: 20,
                          height: 1.25,
                        ),
                      ),
                    ),

                    SizedBox(height: textSpacing),

                    Padding(
                      padding: EdgeInsets.only(left: textLeftPadding),
                      child: Text(
                        "View Team",
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF2D2319)
                              : Color(0xFFD29F2A),
                          fontFamily: "Outfit",
                          fontSize: 16,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// RIGHT SIDE IMAGES
              SizedBox(
                width: cardHeight * 1.1,
                height: cardHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    /// TOP IMAGE
                    Positioned(
                      top: -cardHeight * 0.08,
                      right: cardHeight * 0.18,
                      child: Image.asset(
                        topImage,
                        width: topImageSize,
                        height: topImageSize,
                        fit: BoxFit.contain,
                      ),
                    ),

                    /// BOTTOM IMAGE — TOUCH RIGHT EDGE
                    Positioned(
                      bottom: 0,
                      right: -cardWidth * 0.04,
                      child: Image.asset(
                        bottomImage,
                        width: bottomImageSize,
                        height: bottomImageSize,
                        fit: BoxFit.contain,
                      ),
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

class CityGrid extends StatelessWidget {
  final List<String> row1 = ["New Delhi", "Mumbai", "Kolkata"];

  final List<String> row2 = ["Chennai", "Bengaluru"];

  final List<String> row3 = ["Jaipur", "Gurugram", "Hyderabad"];
  final bool isLight;
  CityGrid({super.key, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = size.width * 0.27;
    final double cardHeight = size.height * 0.05;
    final double spacing = size.width * 0.03;

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// ───────── ROW 1 (3 ITEMS)
        _buildRow(
          context,
          cities: row1,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          spacing: spacing,
          alignCenter: false,
          isLight: isLight,
        ),

        SizedBox(height: size.height * 0.015),

        /// ───────── ROW 2 (2 ITEMS CENTERED)
        _buildRow(
          context,
          cities: row2,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          spacing: spacing,
          alignCenter: true,
          isLight: isLight,
        ),

        SizedBox(height: size.height * 0.015),

        /// ───────── ROW 3 (3 ITEMS)
        _buildRow(
          context,
          cities: row3,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          spacing: spacing,
          alignCenter: false,
          isLight: isLight,
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required List<String> cities,
    required double cardWidth,
    required double cardHeight,
    required double spacing,
    required bool alignCenter,
    bool isLight = false,
  }) {
    return Row(
      mainAxisAlignment: alignCenter
          ? MainAxisAlignment.center
          : MainAxisAlignment.center,
      children: List.generate(cities.length * 2 - 1, (index) {
        if (index.isOdd) {
          return SizedBox(width: spacing);
        }

        final city = cities[index ~/ 2];

        return InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            if (city == "New Delhi") {
              LocationLauncher.launchByIndex(0);
            } else if (city == "Mumbai") {
              LocationLauncher.launchByIndex(1);
            } else if (city == "Kolkata") {
              LocationLauncher.launchByIndex(2);
            } else if (city == "Chennai") {
              LocationLauncher.launchByIndex(3);
            } else if (city == "Bengaluru") {
              LocationLauncher.launchByIndex(4);
            } else if (city == "Jaipur") {
              LocationLauncher.launchByIndex(5);
            } else if (city == "Gurugram") {
              LocationLauncher.launchByIndex(6);
            } else if (city == "Hyderabad") {
              LocationLauncher.launchByIndex(7);
            }
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFF2D2319) : Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.33),
                  blurRadius: 12.5,
                ),
              ],
            ),
            child: Text(
              city,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: cardWidth * 0.13,
                fontWeight: FontWeight.w500,
                color: isLight ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class LocationLauncher {
  // List of URLs
  static const List<String> urls = [
    'https://www.amalegalsolutions.com/locations/newdelhi',
    'https://www.amalegalsolutions.com/locations/mumbai',
    'https://www.amalegalsolutions.com/locations/kolkata',
    'https://www.amalegalsolutions.com/locations/chennai',
    'https://www.amalegalsolutions.com/locations/bengaluru',
    'https://www.amalegalsolutions.com/locations/jaipur',
    'https://www.amalegalsolutions.com/services/loan-settlement/Gurugram',
    'https://www.amalegalsolutions.com/services/loan-settlement/Hyderabad',
  ];

  // Launch URL by index
  static Future<void> launchByIndex(int index) async {
    if (index < 0 || index >= urls.length) {
      debugPrint('Invalid index: $index');
      return;
    }

    final Uri url = Uri.parse(urls[index]);

    try {
      // Use launchUrl with external application mode
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Could not launch ${urls[index]}');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}

class RealtimeImageCarousel extends StatefulWidget {
  final String type;
  final double? height; // Optional fixed height

  const RealtimeImageCarousel({
    super.key,
    required this.type,
    this.height, // Use null for dynamic height based on content
  });

  @override
  State<RealtimeImageCarousel> createState() => _RealtimeImageCarouselState();
}

class _RealtimeImageCarouselState extends State<RealtimeImageCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RealtimeImageProvider>().listenImages(widget.type);
    });

    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel(); // safety: stop timer if unmounted
        return;
      }

      final provider = context.read<RealtimeImageProvider>();
      if (provider.images.isEmpty) return;

      final nextPage = (_current + 1) % provider.images.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      setState(() => _current = nextPage);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // cancel auto-slide
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double itemWidth = MediaQuery.of(context).size.width * 0.9;
    final double itemHeight = itemWidth * 9 / 16; // keeps 16:9 ratio
    return Consumer<RealtimeImageProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return _shimmer();
        if (provider.error != null) return _errorBox(provider.error!);

        final images = provider.images;
        if (images.isEmpty) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Constrained carousel with proper aspect ratio
            SizedBox(
              height: itemHeight,
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _current = index; // <-- update the dot indicator
                  });
                },
                controller: _controller,
                itemCount: images.length,
                itemBuilder: (_, index) {
                  final img = images[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: itemWidth,
                        height: itemHeight,
                        color: Colors
                            .transparent, // background for letterbox effect
                        alignment: Alignment.center,

                        child: AspectRatio(
                          aspectRatio: 16 / 9, // 🔥 FIXED RATIO FOR ALL IMAGES
                          child: Image.network(
                            img.url,
                            fit: BoxFit.contain, // ✅ NO CROPPING EVER
                            alignment: Alignment.center,

                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade800,
                                highlightColor: Colors.grey.shade700,
                                child: Container(color: Colors.grey),
                              );
                            },

                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // DOT INDICATOR
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = _current == i;
                  final size = active ? 12.0 : 8.0; // diameter of circle
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // <-- this ensures a circle
                      color: active ? Colors.white : const Color(0xFF909090),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: widget.height ?? MediaQuery.of(context).size.width * 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }

  Widget _errorBox(String msg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: widget.height ?? MediaQuery.of(context).size.width * 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(
                msg,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class DarkHomeScreen extends StatefulWidget {
  const DarkHomeScreen({super.key});

  @override
  _DarkHomeScreenState createState() => _DarkHomeScreenState();
}

class _DarkHomeScreenState extends State<DarkHomeScreen> {
  String? userName;
  String? userRole;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    fetchUserNameAndRole();
  }

  Future<void> fetchUserNameAndRole() async {
    final fetchedName = await getUserName();
    final fetchedRole = await getUserRole();
    final fetchedEmail = await getUserEmail();
    final fetchedPhone = await getUserPhone();

    // print(fetchedRole);
    if (!mounted) return; // only return if widget is disposed

    setState(() {
      userName = fetchedName;
      userRole = fetchedRole;
      userEmail = fetchedEmail;
      userPhone = fetchedPhone;
    });
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (userRole != null && userEmail != null) {
      // replace with correct identifiers
      provider.fetchProfilePhoto(
        context,
        phone: fetchedPhone!, // or actual phone if available
        role: userRole!,
      );
      // print(provider.profilePhotoUrl);
    }
  }

  Widget _buildAppBarForHomeScreen({
    required BuildContext context,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userRole,
    required double avatarDiameter,
    required double fontSize,
    required double iconSize,
    required double dotSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04 * scaleFactor,
        vertical: screenHeight * 0.015 * scaleFactor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return InkWell(
                    onTap: () {
                      context.pushNamed(
                        AppScreenNames.userAccount,
                        queryParameters: {
                          "name": userName,
                          "email": userEmail,
                          "profile_photo": userRole == "guest"
                              ? AppAssets.userIcon
                              : provider.hasProfilePhoto
                              ? provider.profilePhotoUrl!
                              : AppAssets.userIcon,
                          "phone": userPhone,
                          "role": userRole,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(avatarDiameter / 2),
                    child: CircleAvatar(
                      radius: avatarDiameter / 2,
                      backgroundImage: userRole == "guest"
                          ? const AssetImage(AppAssets.userIcon)
                                as ImageProvider
                          : provider.hasProfilePhoto
                          ? NetworkImage(
                              "${provider.profilePhotoUrl}?v=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : const AssetImage(AppAssets.userIcon)
                                as ImageProvider,
                    ),
                  );
                },
              ),
              SizedBox(width: screenWidth * 0.03 * scaleFactor),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hi, ",
                    style: GoogleFonts.outfit(
                      fontSize: fontSize * scaleFactor,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: globalUserName,
                    builder: (context, name, _) => Text(
                      "$name",
                      style: GoogleFonts.outfit(
                        fontSize: fontSize * scaleFactor,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD29F2A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  final isDark = themeProvider.isDarkMode;

                  return GestureDetector(
                    onTap: () {
                      // Toggle theme
                      themeProvider.setTheme(!isDark);
                    },
                    behavior: HitTestBehavior
                        .opaque, // ensures the whole padding is tappable
                    child: Padding(
                      padding: const EdgeInsets.all(8), // enough touch area
                      child: Image.asset(
                        isDark
                            ? AppAssets.darkThemeIcon
                            : AppAssets.lightThemeIcon,

                        width: 20,
                        height: 20,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: screenWidth * 0.02 * scaleFactor),

              /// Notification History Icon
              if (userRole?.toLowerCase() == "admin")
                GestureDetector(
                  onTap: () {
                    context.pushNamed(AppScreenNames.notificationHistoryScreen);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: screenWidth * 0.03 * scaleFactor,
                    ),
                    child: Icon(
                      Icons
                          .history, // or Icons.notifications_outlined for a similar feel
                      size: iconSize,
                      color: Colors.green,
                    ),
                  ),
                ),

              /// Notification Icon with badge
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
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
                      if (userRole?.toLowerCase() == "admin") {
                        String userId = "${userRole}_${userPhone}";
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => SendNotificationSheet(userId: userId),
                        );
                      } else {
                        context.pushNamed(AppScreenNames.notificationScreen);
                      }
                    },
                    child: Icon(
                      Icons.notifications,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  if (userRole == "client" ||
                      userRole == "advocate" ||
                      userRole == "user" ||
                      userRole == "legal_expert")
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _img(String asset) {
  //   return Image.asset(
  //     asset,
  //     fit: BoxFit.cover,
  //     cacheWidth: 600, // decode smaller bitmap
  //     filterQuality: FilterQuality.low,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.light,
    //     statusBarBrightness: Brightness.dark,
    //   ),
    // );
    // Screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    // Dynamic sizes
    final avatarDiameter = screenWidth * 0.10 * scaleFactor;
    final fontSize = screenWidth * 0.06 * scaleFactor;
    final iconSize = screenWidth * 0.075 * scaleFactor;
    final dotSize = screenWidth * 0.025 * scaleFactor;

    // Card sizes
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // amount of extra space to reserve at bottom so the last item is fully visible
    final contentBottomPadding =
        navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0) + 12.0;
    // ----------------------------
    final role = context.watch<RealTimeRoleProvider>().role;
    userRole = role;
    // Responsive button

    // Single stat widget

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          automaticallyImplyLeading: false,

          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,

            /// ANDROID ICONS → white
            statusBarIconBrightness: Brightness.light,

            /// iOS ICONS → white
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF171717), Color(0xFF0F0F0F)],
                ),
              ),
            ),
          ),

          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    toolbarHeight: 63,
                    automaticallyImplyLeading: false,

                    flexibleSpace: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                          ),
                          color: const Color(0xFF171717).withOpacity(0.65),
                          child: _buildAppBarForHomeScreen(
                            context: context,
                            userName: userName,
                            userEmail: userEmail,
                            userPhone: userPhone,
                            userRole: userRole,
                            avatarDiameter: avatarDiameter,
                            fontSize: fontSize,
                            iconSize: iconSize,
                            dotSize: dotSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SafeArea(
              bottom: false,
              top: false,
              child: Builder(
                builder: (context) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      /// pushes content under appbar
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.045,
                          left: screenWidth * 0.04 * scaleFactor,
                          right: screenWidth * 0.04 * scaleFactor,
                          bottom: contentBottomPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            RealtimeImageCarousel(type: "home"),
                            SizedBox(height: screenHeight * 0.04 * scaleFactor),
                            if (userRole?.toLowerCase() == "client")
                              connectLawyerGrid(context),
                            statOverviewCard(context),
                            SizedBox(height: screenHeight * 0.02 * scaleFactor),

                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight *
                                    0.03 *
                                    scaleFactor, // space below button
                                left: screenWidth * 0.01 * scaleFactor,
                                right: screenWidth * 0.04 * scaleFactor,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft, // ⬅ left align
                                child: Text(
                                  "Trusted by Leading Organizations",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.02 * scaleFactor,
                            ), // spacing
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.20,
                              child: Stack(
                                children: [
                                  RepaintBoundary(
                                    child: AutoScrollSlider(
                                      assets: first10,
                                      reverse: false,
                                    ),
                                  ),
                                  // Left fade (opaque)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(
                                              0xFF171717,
                                            ), // full background color
                                            Color(
                                              0xFF171717,
                                            ).withOpacity(0.0), // fading
                                            // effectively "fading into image"
                                          ],
                                          stops: [0.0, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Right fade (opaque)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            Color(
                                              0xFF171717,
                                            ), // full background color
                                            Color(
                                              0xFF171717,
                                            ).withOpacity(0.0), // fading
                                          ],
                                          stops: [0.0, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * 0.03 * scaleFactor,
                            ), // spacing

                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.20,
                              child: Stack(
                                children: [
                                  RepaintBoundary(
                                    child: AutoScrollSlider(
                                      assets: next10,
                                      reverse: true,
                                    ),
                                  ),

                                  // Left fade (opaque)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(
                                              0xFF171717,
                                            ), // full background color
                                            Color(
                                              0xFF171717,
                                            ).withOpacity(0.0), // fading
                                            // effectively "fading into image"
                                          ],
                                          stops: [0.0, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Right fade (opaque)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            Color(
                                              0xFF171717,
                                            ), // full background color
                                            Color(
                                              0xFF171717,
                                            ).withOpacity(0.0), // fading
                                          ],
                                          stops: [0.0, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Below the Padding containing "Our Team" and "See all"
                            RepaintBoundary(
                              child: OurLegacySection(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                scaleFactor: scaleFactor,
                                isDark: true,
                              ),
                            ),

                            SizedBox(
                              height: screenHeight * 0.02,
                            ), // spacing between sections
                            // RepaintBoundary(child: const TeamSlider()),
                            TeamCard(
                              topImage: AppAssets.tmL2,
                              bottomImage: AppAssets.tmL1,
                              onTap: () {
                                context.pushNamed(
                                  AppScreenNames.meetTeamScreen,
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02 * scaleFactor),
                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight *
                                    0.0001 *
                                    scaleFactor, // space below button
                                left: screenWidth * 0.01 * scaleFactor,
                                right: screenWidth * 0.000015 * scaleFactor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "What Our Clients Say",
                                    style: GoogleFonts.outfit(
                                      fontSize:
                                          screenWidth * 0.04 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  // TextButton(
                                  //   onPressed: () {
                                  //     // Handle "See all" tap here
                                  //   },
                                  //   child: Text(
                                  //     "See all",
                                  //     style: GoogleFonts.outfit(
                                  //       fontSize: screenWidth * 0.035 * scaleFactor,
                                  //       fontWeight: FontWeight.w500,
                                  //       color: const Color(0xFFD29F2A),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            // Below the Padding containing "Our Team" and "See all"
                            SizedBox(height: screenHeight * 0.02 * scaleFactor),
                            TestimonialCard(
                              name: "Pratichi Pradhan",
                              testimonial:
                                  "Phenomenal services! Turnaround time was half day to get the papers in order, extend a reasonable price.",
                              clientImage: AppAssets.googleReviewImg,
                            ),
                            SizedBox(
                              height: screenHeight * 0.001 * scaleFactor,
                            ),
                            TestimonialCard(
                              name: "Sk Nazir",
                              testimonial:
                                  "Outstanding consultation! Ama Legal Solutions prioritizes client satisfaction and delivers quick, effective results.",
                              clientImage: AppAssets.googleReviewImg,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top:
                                    screenHeight *
                                    0.03 *
                                    scaleFactor, // space below button
                                left: screenWidth * 0.01 * scaleFactor,
                                right: screenWidth * 0.04 * scaleFactor,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft, // ⬅ left align
                                child: Text(
                                  "Our Locations",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.02 * scaleFactor,
                            ), // spacing
                            CityGrid(),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: ClipRect(
          //     child: BackdropFilter(
          //       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          //       child: Container(
          //         height: 63 + MediaQuery.of(context).padding.top,
          //         padding: EdgeInsets.only(
          //           top: MediaQuery.of(context).padding.top,
          //         ),
          //         color: const Color(0xFF171717).withOpacity(0.65),

          //         child: _buildAppBarForHomeScreen(
          //           context: context,
          //           userName: userName,
          //           userEmail: userEmail,
          //           userPhone: userPhone,
          //           userRole: userRole,
          //           avatarDiameter: avatarDiameter,
          //           fontSize: fontSize,
          //           iconSize: iconSize,
          //           dotSize: dotSize,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // ========== OVERLAY: CustomBottomNav (always on top) ==========
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: const CustomBottomNav(),
            ),
          ),
        ],
      ),

      // bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
