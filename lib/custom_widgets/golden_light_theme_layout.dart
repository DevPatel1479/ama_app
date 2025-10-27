// import 'package:flutter/material.dart';

// /// Top header layout with linear gradient background
// /// followed by scrollable child content.
// class GradientTopLayout extends StatelessWidget {
//   final Widget? headerContent;
//   final Widget child;
//   final String? screenName;
//   final Widget? fixedPositionWidget;

//   const GradientTopLayout({
//     Key? key,
//     this.headerContent,
//     required this.child,
//     this.screenName,
//     this.fixedPositionWidget,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final sh = MediaQuery.of(context).size.height;

//     return Stack(
//       children: [
//         // Fixed gradient background
//         Container(
//           height: sh,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xFFF8BD00), Color(0xFFFFFFFF)],
//               stops: [0.0, 0.406],
//             ),
//           ),
//         ),
//         if (screenName == "home")
//           Column(
//             children: [
//               if (headerContent != null)
//                 SafeArea(child: Center(child: headerContent)),

//               if (fixedPositionWidget != null) fixedPositionWidget!,

//               Expanded(child: SingleChildScrollView(child: child)),
//             ],
//           )
//         else
//           // Scrollable header + content
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header section
//                 if (headerContent != null)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 24.0),
//                     child: SafeArea(child: Center(child: headerContent)),
//                   ),

//                 // Main content
//                 child,
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

class GradientTopLayout extends StatelessWidget {
  final Widget? headerContent;
  final Widget child;
  final String? screenName;
  final Widget? fixedPositionWidget;
  final bool? keepExpanded;

  const GradientTopLayout({
    Key? key,
    this.headerContent,
    required this.child,
    this.screenName,
    this.fixedPositionWidget,
    this.keepExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // Define gradient for light mode
    final lightGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF8BD00), Color(0xFFFFFFFF)],
      stops: [0.0, 0.406],
    );

    // Define color/gradient for dark mode
    final darkColor = const Color(0xFF171717);

    return Stack(
      children: [
        // Animated background (gradient or solid)
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: sh,
          decoration: BoxDecoration(
            gradient: isDarkMode ? null : lightGradient,
            color: isDarkMode ? darkColor : null,
          ),
        ),

        // Scrollable content
        if (screenName == "home")
          Column(
            children: [
              if (headerContent != null)
                SafeArea(child: Center(child: headerContent)),
              if (fixedPositionWidget != null) fixedPositionWidget!,
              if (keepExpanded == false)
                Expanded(child: child)
              else
                Expanded(child: SingleChildScrollView(child: child)),
            ],
          )
        else
          SingleChildScrollView(
            child: Column(
              children: [
                if (headerContent != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: SafeArea(child: Center(child: headerContent)),
                  ),
                child,
              ],
            ),
          ),
      ],
    );
  }
}
