import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class AutoScrollSlider extends StatefulWidget {
  const AutoScrollSlider({super.key});

  @override
  State<AutoScrollSlider> createState() => _AutoScrollSliderState();
}

class _AutoScrollSliderState extends State<AutoScrollSlider> {
  final ScrollController _scrollController = ScrollController();
  double scrollPosition = 0;
  late Timer _timer;

  final List<String> assets = [
    AppAssets.r1,
    AppAssets.r2,
    AppAssets.r3,
    AppAssets.r4,
    AppAssets.r5,
  ];

  @override
  void initState() {
    super.initState();
    // Start auto-scrolling
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        scrollPosition += 1; // scroll speed
        if (scrollPosition >= _scrollController.position.maxScrollExtent) {
          scrollPosition = 0; // loop back
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Keep image size same
    final imageSize = screenWidth * 0.20;
    final containerHeight = imageSize;

    return SizedBox(
      height: containerHeight,
      child: Stack(
        children: [
          // Slider
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: assets.length,
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
                    assets[index],
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Left fade (increased width)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: screenWidth * 0.25, // ← increased from 12% → 25%
            ),
          ),

          // Right fade (increased width)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: screenWidth * 0.25, // ← increased from 12% → 25%
            ),
          ),
        ],
      ),
    );
  }
}
