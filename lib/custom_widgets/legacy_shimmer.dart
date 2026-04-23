import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LegacyShimmer extends StatelessWidget {
  final double width;
  final double height;

  const LegacyShimmer({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Image shimmer (rounded like real UI)
            Container(
              width: width * 0.4,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(width: 12),

            // 🔥 Text shimmer (multiple lines instead of block)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width * 0.5, 14),
                  const SizedBox(height: 8),
                  _line(width * 0.4, 12),
                  const SizedBox(height: 12),
                  _line(width * 0.6, 10),
                  const SizedBox(height: 6),
                  _line(width * 0.55, 10),
                  const SizedBox(height: 6),
                  _line(width * 0.5, 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
