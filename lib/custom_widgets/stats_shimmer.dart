import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StatsShimmerCard extends StatelessWidget {
  const StatsShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Shimmer.fromColors(
      baseColor: const Color(0xFF3A2B1F),
      highlightColor: const Color(0xFF5A4632),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.02,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFFFDD00)),
          color: const Color.fromRGBO(210, 159, 42, 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _shimmerItem(context),
            _divider(context),
            _shimmerItem(context),
            _divider(context),
            _shimmerItem(context),
          ],
        ),
      ),
    );
  }

  Widget _shimmerItem(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          width: size.width * 0.12,
          height: size.height * 0.025,
          color: Colors.white,
        ),
        SizedBox(height: size.height * 0.008),
        Container(
          width: size.width * 0.1,
          height: size.height * 0.015,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 2,
      height: MediaQuery.of(context).size.height * 0.07,
      color: Colors.white,
    );
  }
}
