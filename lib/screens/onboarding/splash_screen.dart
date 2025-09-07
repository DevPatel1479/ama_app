import 'dart:math';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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
    Future.delayed(const Duration(seconds: 2), () {
      checkAuth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void checkAuth() async {
    bool? isLoggedIn = await LocalStorageHelper.getBool("isLoggedIn");
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (isLoggedIn != null && isLoggedIn == true) {
        context.go('/home');
      } else {
        context.go('/getStarted');
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
      backgroundColor: const Color(0xFF171717),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.appLogoWithText,
              width: size.width * 0.6,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 80,
              height: 80,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SweepingGradientSpinnerPainter(
                      rotation: rotationAnimation.value,
                      sweep: sweepAnimation.value,
                    ),
                  );
                },
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
