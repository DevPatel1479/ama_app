import 'dart:math';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/notifications/realtime_notification_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:provider/provider.dart';

class LightSplashScreen extends StatefulWidget {
  const LightSplashScreen({super.key});

  @override
  State<LightSplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<LightSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> rotationAnimation;
  late Animation<double> sweepAnimation;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Rotation from 0 to 2π continuously
    rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Sweep angle from small to large and back, creating a breathing effect
    sweepAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.1,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      checkAuth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    // get role from local storage or auth provider
    bool? isLoggedIn =
        await LocalStorageHelper.getBool("isUserLoggedIn") ?? false;

    if (isLoggedIn == false) return;

    final userRole = await LocalStorageHelper.getString("userRole") ?? "guest";
    if (userRole == "guest") return;
    if (!mounted) return;
    final provider = Provider.of<RealtimeNotificationProvider>(
      context,
      listen: false,
    );
    print("started listening at splash ... ");
    // Restore local unread flag
    await provider.restoreUnreadState();

    // Start Firestore listener
    provider.startListening(userRole);
  }

  void checkAuth() async {
    bool? isLoggedIn = await LocalStorageHelper.getBool("isUserLoggedIn");
    bool? isGuestLoggedOut = await LocalStorageHelper.getBool(
      "isGuestLoggedOut",
    );
    bool? isNormalUser = await LocalStorageHelper.getBool("isNormalUser");
    bool? isGetStartedTapped = await LocalStorageHelper.getBool(
      "isGetStartedTapped",
    );
    bool? isPolicyAccepted = await LocalStorageHelper.getBool(
      "isAcceptedPolicy",
    );
    // print(isLoggedIn);
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final ctx = context;
      if (isLoggedIn != null && isLoggedIn == true) {
        ctx.go(AppPathsForScreen.userHomePath);
      } else if (isPolicyAccepted == null) {
        ctx.go(AppPathsForScreen.acceptPolicyPath);
      } else if ((isGuestLoggedOut != null && isGuestLoggedOut == true) ||
          (isNormalUser != null && isNormalUser == true)) {
        ctx.go(AppPathsForScreen.logInPath);
      } else {
        // context.go(AppPathsForScreen.getStartedPath);
        await LocalStorageHelper.saveString("userRole", "guest");
        final userProvider = ctx.read<UserProvider>();
        await userProvider.loadUserRole();
        updateGlobalUserName("Guest User");
        updateGlobalUserEmail("guest@gmail.com");

        if (isGetStartedTapped == null || isGetStartedTapped == false) {
          ctx.go(AppPathsForScreen.getStartedPath);
        } else {
          ctx.go(AppPathsForScreen.userHomePath);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: GradientTopLayout(
        screenName: "home",
        keepExpanded: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center GIF
            Center(
              child: Image.asset(
                AppAssets.launchLightImg, // GIF
                width: size.width * 0.65,
                height: size.height * 0.65,
                fit: BoxFit.contain,
              ),
            ),

            // ⭐ Bottom Responsive Text
            Positioned(
              bottom: size.height * 0.07, // responsive bottom spacing
              left: 0,
              right: 0,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      // "Get"
                      TextSpan(
                        text: "Get ",
                        style: TextStyle(
                          fontFamily: "Cormorant",
                          fontSize: size.width * 0.055, // responsive
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF000000), // Black for light theme
                        ),
                      ),

                      // "Legally Insured"
                      TextSpan(
                        text: "Legally Insured",
                        style: TextStyle(
                          fontFamily: "Cormorant",
                          fontSize: size.width * 0.055, // responsive
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFD29F2A), // Gold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SweepingGradientSpinnerPainter extends CustomPainter {
  final double rotation;
  final double sweep;

  SweepingGradientSpinnerPainter({required this.rotation, required this.sweep});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 3.0; // Reduced from 6.0 to 3.0
    final radius = (size.width / 2) - strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF), Color(0xFFD29F2A)],
      stops: [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          strokeWidth // Apply thinner stroke width here
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.drawArc(rect, rotation, sweep * 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant SweepingGradientSpinnerPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.sweep != sweep;
  }
}
