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
  // core logic unchanged
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

    final activeIndex = _indexFromLocation(location);

    // safe area insets from device (home indicator, notches, corner shape)
    final mq = MediaQuery.of(context);
    final leftInset = mq.padding.left;
    final rightInset = mq.padding.right;
    final bottomInset = mq.padding.bottom;

    // ensure the nav doesn't sit flush into the rounded corners:
    // prefer your existing horizontal margin (screenWidth * 0.04) but make sure
    // it's at least the device side inset + a small gap (12px).
    final baseHorizontalMargin = screenWidth * 0.04;
    final horizontalMargin = baseHorizontalMargin < (leftInset + 12)
        ? (leftInset + 12)
        : baseHorizontalMargin;
    // if rightInset is larger (rare), keep symmetric - use max(left,right)
    final symmetricHorizontalMargin = horizontalMargin < (rightInset + 12)
        ? (rightInset + 12)
        : horizontalMargin;

    // total height includes a small portion of bottom inset so it floats above
    // the home-indicator area
    final totalHeight = navHeight + (bottomInset > 0 ? bottomInset * 0.6 : 0.0);

    // cap corner radius so it doesn't become exaggerated on some screens
    final navCornerRadius = BorderRadius.circular(
      // keep the look but cap at 22 px (tweak if you want)
      (navHeight * 0.45).clamp(8.0, 22.0),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFFD29F2A);
    final inactiveTextColor = isDark ? Colors.white70 : Colors.black87;
    final inactiveIconColor = isDark ? Colors.white70 : Colors.black87;

    // Use SafeArea(top:false, bottom:false) so parent controls spacing precisely.
    // The widget will itself use the horizontal margin computed above to avoid
    // device corner clipping.
    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: totalHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: symmetricHorizontalMargin,
            vertical:
                navHeight * 0.08 + (bottomInset > 0 ? bottomInset * 0.08 : 0.0),
          ),
          child: ClipRRect(
            borderRadius: navCornerRadius,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: navCornerRadius,
                    border: GradientBoxBorder(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(210, 159, 42, 0.65),
                          Color.fromRGBO(255, 255, 255, 0.65),
                        ],
                      ),
                      width: (navHeight * 0.03).clamp(1.0, 3.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_labels.length, (index) {
                      final isActive = activeIndex == index;
                      final iconSize = (navHeight * 0.35).clamp(16.0, 28.0);
                      final labelSize = (navHeight * 0.18).clamp(10.0, 13.0);

                      final imageTint = isActive
                          ? activeColor
                          : inactiveIconColor;

                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isActive) return;
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
                                    color: !isActive ? Colors.white : imageTint,
                                    colorBlendMode: BlendMode.srcIn,
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
                                          ? activeColor
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
              ],
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
  ShapeBorder scale(double t) {
    return GradientBoxBorder(gradient: gradient, width: width * t);
  }
}
