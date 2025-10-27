import 'package:ama_legal_solutions/screens/features/dark_theme/dark_casedesk_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBankCard extends StatelessWidget {
  const ShimmerBankCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFF2D2319),
          shape: GradientBoxBorder(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(210, 159, 42, 0.65),
                const Color.fromRGBO(255, 255, 255, 0.65),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            width: 2,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.025,
          horizontal: screenWidth * 0.05,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left placeholder lines
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: screenWidth * 0.25,
                  height: 14,
                  color: Colors.white,
                );
              }),
            ),
            // Right placeholder lines
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: screenWidth * 0.3,
                  height: 14,
                  color: Colors.white,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
