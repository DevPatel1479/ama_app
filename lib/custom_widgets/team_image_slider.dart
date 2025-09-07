import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class TeamSlider extends StatefulWidget {
  const TeamSlider({super.key});

  @override
  State<TeamSlider> createState() => _TeamSliderState();
}

class _TeamSliderState extends State<TeamSlider> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int? _selectedIndex;

  // constants
  static const double _imageSize = 150.0; // image stays this size always
  static const double _expandedWidth = 240.0; // container width when expanded
  static const double _expandedHeightRaw =
      356.0; // maximum desired expanded height (clamped)
  static const double _minFooterHeight = 60.0; // minimum footer area for texts
  final Duration _animDur = const Duration(milliseconds: 350);

  // estimated footer content height (name + role + icons + paddings)
  // tweak this if your fonts/spacing change
  static const double _estimatedFooterContent = 150.0;

  final List<String> images = [
    AppAssets.teamMemberImg1,
    AppAssets.teamMemberImg1,
    AppAssets.teamMemberImg1,
    AppAssets.teamMemberImg1,
    AppAssets.teamMemberImg1,
    AppAssets.teamMemberImg1,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(int index, double screenWidth, double itemSpacing) {
    final leftPadding = screenWidth * 0.02;
    final itemStride = _imageSize + itemSpacing;
    final desiredLeft =
        leftPadding + index * itemStride - (screenWidth - _expandedWidth) / 2;

    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = desiredLeft.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      target,
      duration: _animDur,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeVerticalPadding =
        MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    final itemSpacing = max(8.0, screenWidth * 0.01);
    final leftPadding = screenWidth * 0.02;

    // Reserve some vertical space for other UI (header / bottom nav).
    const double reservedSpaceBelow = 160.0;

    // compute maximum allowed expanded height so it never exceeds screen space
    final double availableHeight = max(
      _imageSize + _minFooterHeight + 16,
      screenHeight - safeVerticalPadding - reservedSpaceBelow,
    );

    final double maxAllowedExpanded = min(_expandedHeightRaw, availableHeight);

    // chosen top padding for selected card (keeps image a bit lower)
    const double topPaddingWhenSelected = 12.0;

    // compute desired expanded height that tightly fits image + footer content
    final double desiredExpandedHeight =
        topPaddingWhenSelected + _imageSize + _estimatedFooterContent;

    // final expanded height is the smaller of our desired tight height and the maximum allowed
    final double finalExpandedHeight = min(
      maxAllowedExpanded,
      desiredExpandedHeight,
    );

    // slider height animates between image size and the clamped (tight) expanded height
    final double sliderHeight = _selectedIndex != null
        ? finalExpandedHeight
        : _imageSize;

    return AnimatedSize(
      duration: _animDur,
      curve: Curves.easeInOut,
      child: SizedBox(
        height: sliderHeight + 12, // small extra padding
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(images.length, (index) {
                final bool isSelected = _selectedIndex == index;

                // when any item is selected, every item container height becomes sliderHeight
                final double containerHeight = (_selectedIndex != null)
                    ? sliderHeight
                    : _imageSize;

                // selected item gets expanded width else keep image width
                final double containerWidth = isSelected
                    ? _expandedWidth
                    : _imageSize;

                // For non-selected items, center the thumbnail vertically in the container
                final double nonSelectedTopPadding =
                    (_selectedIndex != null && !isSelected)
                    ? (containerHeight - _imageSize) / 2
                    : 0.0;

                // choose actual top padding: selected uses fixed topPaddingWhenSelected, others are centered
                final double actualTopPadding = isSelected
                    ? topPaddingWhenSelected
                    : nonSelectedTopPadding;

                // footer height for selected (tight and clamped so no large empty space)
                final double footerHeight = isSelected
                    ? max(
                        _minFooterHeight,
                        containerHeight - actualTopPadding - _imageSize,
                      )
                    : 0.0;

                // scale non-selected thumbnails while one is expanded
                final double scale = _selectedIndex == null
                    ? 1.0
                    : (isSelected ? 1.0 : 0.86);

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == images.length - 1 ? 0 : itemSpacing,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (_selectedIndex == index) {
                        setState(() => _selectedIndex = null);
                        return;
                      }

                      // center tapped item, then expand
                      _scrollToCenter(index, screenWidth, itemSpacing);
                      await Future.delayed(const Duration(milliseconds: 120));
                      setState(() => _selectedIndex = index);
                    },
                    child: ClipRect(
                      // prevents scaled children from overflowing while animating
                      child: AnimatedScale(
                        scale: scale,
                        duration: _animDur,
                        curve: Curves.easeInOut,
                        child: AnimatedContainer(
                          duration: _animDur,
                          width: containerWidth,
                          height: containerHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              isSelected ? 20 : 12,
                            ),
                            color: isSelected ? Colors.white : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          // Use Stack to position image and footer precisely (no flex issues)
                          child: Stack(
                            children: [
                              // Image positioned with actualTopPadding, centered horizontally
                              Positioned(
                                top: actualTopPadding,
                                left: (containerWidth - _imageSize) / 2,
                                child: SizedBox(
                                  width: _imageSize,
                                  height: _imageSize,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        isSelected ? 20 : 12,
                                      ),
                                    ),
                                    child: Image.asset(
                                      images[index],
                                      fit: BoxFit.cover,
                                      width: _imageSize,
                                      height: _imageSize,
                                    ),
                                  ),
                                ),
                              ),

                              // footer area anchored to bottom when selected
                              if (isSelected)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  height: footerHeight,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(20),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Amit Srivastava",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Business Development Associate",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        // tappable social icons (small spacing)
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                onTap: () {
                                                  // TODO: open Instagram
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    6.0,
                                                  ),
                                                  child: Image.asset(
                                                    AppAssets.tmInstaImg,
                                                    width: 28,
                                                    height: 28,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                onTap: () {
                                                  // TODO: open LinkedIn
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    6.0,
                                                  ),
                                                  child: Image.asset(
                                                    AppAssets.tmLinkedInImg,
                                                    width: 28,
                                                    height: 28,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
