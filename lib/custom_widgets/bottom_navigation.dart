import 'dart:io';
import 'dart:ui';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  final List<String> _labels = ["Home", "Services", "AMA", "Casedesk"];
  final List<String> _activeIcons = [
    'assets/icons/home_active.png',
    'assets/icons/services_active.png',
    'assets/icons/ama_active.png',
    'assets/icons/casedesk_active.png',
  ];
  final List<String> _inactiveIcons = [
    'assets/icons/home_inactive.png',
    'assets/icons/services_inactive.png',
    'assets/icons/ama_inactive.png',
    'assets/icons/casedesk_inactive.png',
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith(AppPathsForScreen.userHomePath)) return 0;
    if (location.startsWith(AppPathsForScreen.amaServicesPath)) return 1;
    if (location.startsWith(AppPathsForScreen.amaPath)) return 2;
    if (location.startsWith(AppPathsForScreen.caseDeskPath)) return 3;
    return 0;
  }

  // void _navigateToIndex(int index) {
  //   switch (index) {
  //     case 0:
  //       context.go(AppPathsForScreen.userHomePath);
  //       break;
  //     case 1:
  //       context.go(AppPathsForScreen.amaServicesPath);
  //       break;
  //     case 2:
  //       context.go(AppPathsForScreen.amaPath);
  //       break;
  //     case 3:
  //       context.go(AppPathsForScreen.caseDeskPath);
  //       break;
  //   }
  // }

  void _navigateToIndex(int index, List<String> labels) {
    final label = labels[index].toLowerCase();

    if (label == "home") {
      context.go(AppPathsForScreen.userHomePath);
    } else if (label == "services") {
      context.go(AppPathsForScreen.amaServicesPath);
    } else if (label == "ama") {
      context.go(AppPathsForScreen.amaPath);
    } else if (label == "casedesk") {
      context.go(AppPathsForScreen.caseDeskPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userRole = context.watch<UserProvider>().role ?? '';
    final userRole = context.watch<RealTimeRoleProvider>().role;
    print("found role of the user is $userRole");
    final isUser =
        userRole == 'user' ||
        userRole == 'users' ||
        userRole == 'guest' ||
        userRole == '';

    final filteredLabels = isUser
        ? _labels.where((label) => label.toLowerCase() != 'casedesk').toList()
        : _labels;
    final filteredActiveIcons = isUser
        ? _activeIcons.sublist(0, 3)
        : _activeIcons;
    final filteredInactiveIcons = isUser
        ? _inactiveIcons.sublist(0, 3)
        : _inactiveIcons;
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final bottomInset = mq.padding.bottom;

    // height of nav
    final navHeight = (screenWidth * 0.15).clamp(52.0, 76.0);

    // ✅ platform-aware bottom spacing
    final bottomSpacing = Platform.isIOS
        ? (bottomInset > 0
              ? bottomInset * 0.4 + 6.0
              : 10.0) // as before for iOS
        : (bottomInset > 0
              ? bottomInset + 10.0
              : 24.0); // more gap for Android nav buttons

    final activeColor = const Color(0xFFD29F2A);
    final inactiveColor = Colors.white70;
    final totalHeight = navHeight;
    final navCornerRadius = BorderRadius.circular(
      (navHeight * 0.45).clamp(10.0, 22.0),
    );

    final location = GoRouterState.of(context).uri.toString();
    // final activeIndex = _indexFromLocation(location);

    final activeIndex = _indexFromLocation(
      location,
    ).clamp(0, filteredLabels.length - 1);

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 18, bottomSpacing),
        child: ClipRRect(
          borderRadius: navCornerRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: totalHeight,
              decoration: BoxDecoration(
                borderRadius: navCornerRadius,
                border: GradientBoxBorder(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(210, 159, 42, 0.65),
                      Color.fromRGBO(255, 255, 255, 0.65),
                    ],
                  ),
                  width: 1.8,
                ),
                color: Colors.white.withOpacity(0.07),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(filteredLabels.length, (index) {
                  final isActive = activeIndex == index;
                  final iconSize = (navHeight * 0.32).clamp(20.0, 26.0);
                  final labelSize = (navHeight * 0.18).clamp(10.0, 13.0);

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        // if (!isActive) _navigateToIndex(index);
                        if (!isActive) _navigateToIndex(index, filteredLabels);
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: navHeight * 0.08,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              // isActive
                              //     ? _activeIcons[index]
                              //     : _inactiveIcons[index],
                              isActive
                                  ? filteredActiveIcons[index]
                                  : filteredInactiveIcons[index],
                              width: iconSize,
                              height: iconSize,
                              color: isActive ? activeColor : inactiveColor,
                            ),
                            SizedBox(height: navHeight * 0.05),
                            Text(
                              // _labels[index],
                              filteredLabels[index],
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w400,
                                fontSize: labelSize,
                                color: isActive ? activeColor : Colors.white,
                              ),
                            ),
                          ],
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

/// Gradient border painter
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
