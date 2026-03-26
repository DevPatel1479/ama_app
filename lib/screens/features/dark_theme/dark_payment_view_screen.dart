import 'dart:ui';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/provider/qr/qr_provider.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;

Future<void> openEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    // query: Uri.encodeFull(
    //   'subject=Payment Query&body=Hello AMA Legal Solutions,',
    // ),
  );

  if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
    debugPrint("Could not open mail app");
  }
}

class QrSkeleton extends StatefulWidget {
  final double width;

  const QrSkeleton({super.key, required this.width});

  @override
  State<QrSkeleton> createState() => _QrSkeletonState();
}

class _QrSkeletonState extends State<QrSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, -0.3),
              end: Alignment(_animation.value, 0.3),
              colors: const [
                Color(0xFF2A2A2A),
                Color(0xFF3A3A3A),
                Color(0xFF2A2A2A),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DarkPaymentViewScreen extends StatelessWidget {
  const DarkPaymentViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF171717),

      /// ✅ iOS-style floating appbar
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.11),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.2, sigmaY: 18.2),
            child: AppBar(
              backgroundColor: const Color.fromRGBO(45, 35, 25, 0.17),
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,

              leading: IconButton(
                icon: Image.asset(
                  AppAssets.backArrowIcon,
                  width: screenWidth * 0.03,
                ),
                onPressed: () => context.pop(),
              ),

              title: Text(
                "Payment & Billing",
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: screenHeight * 0.15,
          left: screenWidth * 0.06,
          right: screenWidth * 0.06,
          bottom: screenHeight * 0.06,
        ),
        child: Column(
          children: [
            /// 🔶 PAYMENT CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.035,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromRGBO(210, 159, 42, 0.07),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.33),
                    blurRadius: 12.5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// QR IMAGE
                  Consumer<QrProvider>(
                    builder: (context, qrProvider, _) {
                      final size = screenWidth * 0.55;

                      /// 🔹 LOADING
                      if (qrProvider.isLoading) {
                        return QrSkeleton(width: size);
                      }

                      /// 🔹 ERROR
                      if (qrProvider.error != null) {
                        return Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: screenWidth * 0.1,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              "Failed to load QR",
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<QrProvider>().fetchQr(),
                              child: const Text("Retry"),
                            ),
                          ],
                        );
                      }

                      /// 🔹 SUCCESS
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              /// Skeleton stays visible until image fully loads
                              QrSkeleton(width: size),

                              Image.network(
                                qrProvider.qrUrl!,
                                width: size,
                                height: size,
                                fit: BoxFit.contain,

                                /// Smooth fade when loaded
                                frameBuilder:
                                    (context, child, frame, wasSyncLoaded) {
                                      if (wasSyncLoaded) return child;

                                      return AnimatedOpacity(
                                        opacity: frame == null ? 0 : 1,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: child,
                                      );
                                    },

                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.white70,
                                        size: screenWidth * 0.1,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Image load failed",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.035),

                  /// ACCOUNT DETAILS TITLE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Account Details:-",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  /// DETAILS ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT LABELS
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _LeftText("Bank Name"),
                          _LeftText("A/C Name"),
                          _LeftText("A/C No."),
                          _LeftText("IFSC Code"),
                          _LeftText("UPI ID"),
                        ],
                      ),

                      const Spacer(),

                      /// RIGHT VALUES
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          _RightText("Axis bank"),
                          _RightText("AMA LEGAL SOLUTIONS"),
                          _RightText("920020057568930"),
                          _RightText("UTIB0004550"),
                          _RightText("amalegalsolution@upi"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            /// 🔶 FOOTER TEXT
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.2,
                ),
                children: [
                  const TextSpan(
                    text: "For payment-related queries, contact us at ",
                  ),
                  TextSpan(
                    text: "finance@amalegalsolutions.com",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD29F2A),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w300,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        openEmail("finance@amalegalsolutions.com");
                        // TODO: open email intent
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// SMALL TEXT WIDGETS
/// =======================

class _LeftText extends StatelessWidget {
  final String text;
  const _LeftText(this.text);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: w * 0.03),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: w * 0.045,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          height: 1,
        ),
      ),
    );
  }
}

class _RightText extends StatelessWidget {
  final String text;
  const _RightText(this.text);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: w * 0.03),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: GoogleFonts.outfit(
          fontSize: w * 0.045,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
