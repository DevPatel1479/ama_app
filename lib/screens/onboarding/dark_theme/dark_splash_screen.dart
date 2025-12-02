import 'dart:math';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:provider/provider.dart';

class DarkSplashScreen extends StatefulWidget {
  const DarkSplashScreen({super.key});

  @override
  State<DarkSplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<DarkSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> rotationAnimation;
  late Animation<double> sweepAnimation;

  @override
  void initState() {
    super.initState();

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

        // context.go(AppPathsForScreen.getStartedPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Image.asset(
          AppAssets.darkSplashLoader, // ✅ your GIF here
          width: size.width * 0.85, // slightly smaller than screen width
          height: size.height * 0.85, // maintain aspect ratio
          fit: BoxFit.contain,
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
