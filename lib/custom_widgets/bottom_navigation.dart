// lib/custom_widgets/bottom_navigation.dart
import 'dart:ui';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  // keep a field if you need local tracking or animations; here we mostly
  // derive active tab from router, so this field is optional.
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

  int _indexFromLocation(String location) {
    if (location.startsWith(AppPathsForScreen.userHomePath)) return 0;
    if (location.startsWith(AppPathsForScreen.amaServicesPath)) return 1;
    if (location.startsWith(AppPathsForScreen.amaPath)) return 2;
    if (location.startsWith(AppPathsForScreen.caseDeskPath)) return 3;
    return 0;
  }

  void _navigateToIndex(int index) {
    switch (index) {
      case 0:
        context.go(AppPathsForScreen.userHomePath);
        break;
      case 1:
        context.go(AppPathsForScreen.amaServicesPath);
        break;
      case 2:
        context.go(AppPathsForScreen.amaPath);
        break;
      case 3:
        context.go(AppPathsForScreen.caseDeskPath);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navHeight = (screenWidth * 0.18).clamp(56.0, 84.0);
    final location = GoRouterState.of(context).uri.toString();

    // derive active index from current route (keeps UI in sync with navigation)
    final activeIndex = _indexFromLocation(location);

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
                color: const Color(0xFF2D23195C).withOpacity(0.25),
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
                children: List.generate(_labels.length, (index) {
                  final isActive = activeIndex == index;
                  final iconSize = (navHeight * 0.35).clamp(16.0, 28.0);
                  final labelSize = (navHeight * 0.18).clamp(10.0, 13.0);

                  // Make each tab expand equally so touch area is large and even.
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        // makes whole area tappable and shows ripple
                        onTap: () {
                          if (isActive) return; // already on this tab
                          // If you want a tiny instant feedback in UI you can setState
                          // but it's not required; routing will update the active index.
                          setState(() => _selectedIndex = index);
                          _navigateToIndex(index);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: navHeight * 0.08,
                          ),
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
                        ),
                      ),
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
