import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class AutoScrollSlider extends StatefulWidget {
  const AutoScrollSlider({super.key});

  @override
  State<AutoScrollSlider> createState() => _AutoScrollSliderState();
}

class _AutoScrollSliderState extends State<AutoScrollSlider>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  final List<String> assets = [
    AppAssets.r1,
    AppAssets.r2,
    AppAssets.r3,
    AppAssets.r4,
    AppAssets.r5,
  ];

  // duplicated list for seamless looping
  late final List<String> loopedAssets = [...assets, ...assets];

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 15), // scroll speed
        )..addListener(() {
          if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final offset = _animationController.value * maxScroll;
            _scrollController.jumpTo(offset);
          }
        });

    _animationController.repeat(); // continuous infinite animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.20;
    final containerHeight = imageSize;

    return RepaintBoundary(
      child: SizedBox(
        height: containerHeight,
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: loopedAssets.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? screenWidth * 0.04 : 8,
                    right: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      loopedAssets[index],
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      cacheWidth: 300, // helps memory usage
                      cacheHeight: 300,
                    ),
                  ),
                );
              },
            ),

            // Optional subtle fade overlays (performance-friendly)
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Container(
            //     width: screenWidth * 0.10,
            //     decoration: const BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.centerLeft,
            //         end: Alignment.centerRight,
            //         colors: [Colors.transparent],
            //       ),
            //     ),
            //   ),
            // ),
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: Container(
            //     width: screenWidth * 0.10,
            //     decoration: const BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.centerRight,
            //         end: Alignment.centerLeft,
            //         colors: [Colors.transparent],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
