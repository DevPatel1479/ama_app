import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class TestimonialCard extends StatefulWidget {
  final String name;
  final String testimonial;
  final String clientImage;

  const TestimonialCard({
    super.key,
    required this.name,
    required this.testimonial,
    required this.clientImage,
  });

  @override
  State<TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<TestimonialCard> {
  final GlobalKey _textKey = GlobalKey();
  double _measuredTextHeight = 0;
  static const double _heightDiffThreshold = 0.5;

  void _measureTextHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _textKey.currentContext;
      if (ctx == null) return;
      final rb = ctx.findRenderObject();
      if (rb is RenderBox) {
        final newH = rb.size.height;
        if ((newH - _measuredTextHeight).abs() > _heightDiffThreshold) {
          setState(() => _measuredTextHeight = newH);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
    const scaleFactor = 0.85;

    final double iconWidth = screenWidth * 0.20 * scaleFactor;
    final double iconMinHeight = iconWidth * scaleFactor;
    final double horizontalPadding = screenWidth * 0.04 * scaleFactor;

    final double targetIconHeight = (_measuredTextHeight > 0)
        ? _measuredTextHeight
        : iconMinHeight;
    final double innerVerticalPadding = 13;
    final double clampedIconHeight = targetIconHeight.clamp(
      iconMinHeight,
      MediaQuery.of(context).size.height * 0.6,
    );

    _measureTextHeight();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01 * scaleFactor,
        vertical: 10 * scaleFactor,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2319),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(painter: _GradientBorderPainter()),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: innerVerticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: iconWidth,
                    height: clampedIconHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
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
                        widget.clientImage,
                        fit: BoxFit.cover,
                        width: iconWidth,
                        height: clampedIconHeight,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03 * scaleFactor),
                  Expanded(
                    child: Container(
                      key: _textKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.05 * scaleFactor,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6 * scaleFactor),
                          Text(
                            widget.testimonial,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w400,
                              fontSize: screenWidth * 0.035 * scaleFactor,
                              color: Colors.white,
                              height: 1.4 * scaleFactor,
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
