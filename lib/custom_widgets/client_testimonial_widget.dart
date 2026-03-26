import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestimonialCard extends StatelessWidget {
  final String name;
  final String testimonial;
  final String clientImage;
  final bool isLight;
  const TestimonialCard({
    super.key,
    required this.name,
    required this.testimonial,
    required this.clientImage,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double imageSize = size.width * 0.09;
    final double nameFontSize = size.width * 0.032;
    final double testimonialFontSize = size.width * 0.033;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.007,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.025,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isLight
              ? const Color.fromARGB(255, 217, 188, 121)
              : const Color.fromRGBO(210, 159, 42, 0.06),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.33), blurRadius: 12.5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ⭐ TESTIMONIAL
            Text(
              testimonial,
              // textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: testimonialFontSize,
                fontWeight: FontWeight.w400,
                color: isLight ? const Color(0xFF2D2319) : Colors.white,
                height: 1.45,
              ),
            ),

            SizedBox(height: size.height * 0.025),

            /// 👤 IMAGE + NAME SAME LINE
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// IMAGE
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // BoxShadow(
                      //   color: Colors.black.withOpacity(0.25),
                      //   blurRadius: 6,
                      //   offset: const Offset(0, 3),
                      // ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(clientImage, fit: BoxFit.cover),
                  ),
                ),

                SizedBox(width: size.width * 0.035),

                /// NAME
                Flexible(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w500,
                      color: isLight ? const Color(0xFF2D2319) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
}
