// lib/custom_widgets/bottom_navigation.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/assets_constants.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;

  final List<String> _labels = ["Home", "Services", "AMA", "Casedesk"];
  final List<String> _activeIcons = [
    AppAssets.homeActive,
    AppAssets.servicesActive,
    AppAssets.amaActive,
    AppAssets.caseDeskActive,
  ];
  final List<String> _inactiveIcons = [
    AppAssets.homeInActive,
    AppAssets.servicesInActive,
    AppAssets.amaInActive,
    AppAssets.caseDeskInActive,
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // compute nav height relative to screen size but clamp reasonably
    final navHeight = (screenWidth * 0.14).clamp(56.0, 84.0);

    return SizedBox(
      height: navHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: navHeight * 0.08,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(navHeight * 0.45),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2319).withOpacity(0.85),
                borderRadius: BorderRadius.circular(navHeight * 0.45),
                border: GradientBoxBorder(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(210, 159, 42, 0.65),
                      Color.fromRGBO(255, 255, 255, 0.65),
                    ],
                  ),
                  width: (navHeight * 0.03).clamp(1.0, 3.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_labels.length, (index) {
                  final isActive = _selectedIndex == index;
                  final iconSize = (navHeight * 0.35).clamp(16.0, 28.0);
                  final labelSize = (navHeight * 0.18).clamp(10.0, 13.0);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      // If you want to navigate, send an event/callback here.
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          isActive
                              ? _activeIcons[index]
                              : _inactiveIcons[index],
                          width: iconSize,
                          height: iconSize,
                        ),
                        SizedBox(height: navHeight * 0.06),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w300,
                            fontSize: labelSize,
                            height: 1,
                            color: isActive
                                ? const Color(0xFFD29F2A)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient border implementation that subclasses BoxBorder.
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  Paint _createPaint(Rect rect) {
    return Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = _createPaint(rect);

    if (shape == BoxShape.rectangle) {
      if (borderRadius != null) {
        final rrect = borderRadius.toRRect(rect).deflate(width / 2);
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawRect(rect.deflate(width / 2), paint);
      }
    } else {
      final radius = rect.shortestSide / 2.0;
      canvas.drawCircle(rect.center, radius - (width / 2), paint);
    }
  }

  @override
  BorderSide get top => BorderSide(width: width, color: Colors.transparent);
  @override
  BorderSide get bottom => BorderSide(width: width, color: Colors.transparent);
  @override
  BorderSide get left => BorderSide(width: width, color: Colors.transparent);
  @override
  BorderSide get right => BorderSide(width: width, color: Colors.transparent);

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(gradient: gradient, width: width * t);
  }
}
