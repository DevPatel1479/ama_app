import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class TestimonialCard extends StatefulWidget {
  const TestimonialCard({super.key});

  @override
  State<TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<TestimonialCard> {
  final GlobalKey _textKey = GlobalKey();
  double _measuredTextHeight = 0;

  // Small threshold to avoid repeated setState on tiny diffs
  static const double _heightDiffThreshold = 0.5;

  // Measure after each frame to pick up text wrapping changes
  void _measureTextHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _textKey.currentContext;
      if (ctx == null) return;
      final rb = ctx.findRenderObject();
      if (rb is RenderBox) {
        final newH = rb.size.height;
        if ((newH - _measuredTextHeight).abs() > _heightDiffThreshold) {
          setState(() {
            _measuredTextHeight = newH;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // initial measure on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTextHeight());
  }

  @override
  void didUpdateWidget(covariant TestimonialCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _measureTextHeight();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizes / fallbacks
    final double iconWidth = screenWidth * 0.20; // typical icon width
    final double iconMinHeight = iconWidth; // keep icon square at minimum
    final double horizontalPadding = screenWidth * 0.04;

    // Use measured text height if available, otherwise fallback to min size
    final double targetIconHeight = (_measuredTextHeight > 0)
        ? _measuredTextHeight
        : iconMinHeight;

    // Slight padding inside the card so icon doesn't touch edges
    final double innerVerticalPadding = 13;

    // Finally clamp the icon height to avoid huge values if user has extremely long text
    final double clampedIconHeight = targetIconHeight.clamp(
      iconMinHeight,
      MediaQuery.of(context).size.height * 0.6,
    );

    // Keep measuring each build (safe: setState only when value changes)
    _measureTextHeight();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
        vertical: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2319),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Gradient border
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(painter: _GradientBorderPainter()),
              ),
            ),

            // Content row
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: innerVerticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated icon container - height follows measured text height
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: iconWidth,
                    height: clampedIconHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // optional subtle shadow to separate from background
                      boxShadow: [
                        if (true)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        AppAssets.clientIcon,
                        fit: BoxFit.cover,
                        width: iconWidth,
                        height: clampedIconHeight,
                      ),
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  // Text column that we measure using _textKey
                  Expanded(
                    child: Container(
                      key: _textKey, // measure this container's height
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Pratichi Pradhan",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            // your testimonial text (wraps to multiple lines as needed)
                            "Phenomenal services! Turnaround time was half day to get the papers in order, extend a reasonable price,",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w400,
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// Gradient border painter (keeps your previous styling)
class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromRGBO(210, 159, 42, 0.65),
          Color.fromRGBO(255, 255, 255, 0.65),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
