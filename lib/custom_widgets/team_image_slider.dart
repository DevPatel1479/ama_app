import 'dart:math';
import 'package:ama_legal_solutions/config/constants/team_data_constants.dart';
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

  // allow multiple selected indices
  final Set<int> _selectedIndices = <int>{};

  // detect if user is actively dragging the scroller
  bool _isUserDragging = false;

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
    AppAssets.teamMemberImg2,
    AppAssets.teamMemberImg3,
    AppAssets.teamMemberImg4,
    AppAssets.teamMemberImg5,
    AppAssets.teamMemberImg6,
    AppAssets.teamMemberImg7,
    AppAssets.teamMemberImg8,
    AppAssets.teamMemberImg9,
    AppAssets.teamMemberImg10,
    AppAssets.teamMemberImg11,
    AppAssets.teamMemberImg12,
    AppAssets.teamMemberImg13,
    AppAssets.teamMemberImg14,
    AppAssets.teamMemberImg15,
    AppAssets.teamMemberImg16,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // compute precise scroll target for index (treating tappedIndex as expanded if expandTappedAsTrue)
  double _computeScrollTargetForIndex({
    required int index,
    required double screenWidth,
    required double itemSpacing,
    required bool expandTappedAsTrue,
  }) {
    final leftPadding = screenWidth * 0.02;
    double offset = leftPadding;

    // sum widths of items before `index`
    for (int i = 0; i < index; i++) {
      final bool isExpanded = _selectedIndices.contains(i);
      offset += (isExpanded ? _expandedWidth : _imageSize);
      // add spacing between items
      offset += itemSpacing;
    }

    // width of the tapped item after selection (center against this width)
    final double tappedWidth =
        (expandTappedAsTrue || _selectedIndices.contains(index))
        ? _expandedWidth
        : _imageSize;

    // desired left so the tapped item sits centered in available viewport
    final double desiredLeft = offset - (screenWidth - tappedWidth) / 2;

    // clamp later when using animateTo
    return desiredLeft;
  }

  // custom scroll helper: computes correct target using actual widths and animates only if needed
  void _scrollToCenterAccurate(
    int index,
    double screenWidth,
    double itemSpacing,
  ) {
    if (!_scrollController.hasClients) return;

    // Avoid auto-scrolling while the user is actively dragging.
    if (_isUserDragging) return;

    final double rawTarget = _computeScrollTargetForIndex(
      index: index,
      screenWidth: screenWidth,
      itemSpacing: itemSpacing,
      expandTappedAsTrue: true, // we want to center as if tapped item expands
    );

    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = rawTarget.clamp(0.0, maxScroll);

    // avoid tiny jumps if already near the target
    final double current = _scrollController.position.pixels;
    if ((current - target).abs() < 6.0) return;

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
    final bool anySelected = _selectedIndices.isNotEmpty;
    final double sliderHeight = anySelected ? finalExpandedHeight : _imageSize;

    return AnimatedSize(
      duration: _animDur,
      curve: Curves.easeInOut,
      child: SizedBox(
        height: sliderHeight + 12, // small extra padding
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // detect user drag start / end
            if (notification is ScrollStartNotification) {
              // only mark dragging if it was a user drag (dragDetails != null)
              if (notification.dragDetails != null) {
                _isUserDragging = true;
              }
            } else if (notification is ScrollEndNotification ||
                notification is UserScrollNotification) {
              // end of scrolling - mark not dragging
              _isUserDragging = false;
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: leftPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(images.length, (index) {
                  final bool isSelected = _selectedIndices.contains(index);

                  // when any item is selected, every item container height becomes sliderHeight
                  final double containerHeight = anySelected
                      ? sliderHeight
                      : _imageSize;

                  // selected item gets expanded width else keep image width
                  final double containerWidth = isSelected
                      ? _expandedWidth
                      : _imageSize;

                  // For non-selected items, center the thumbnail vertically in the container
                  final double nonSelectedTopPadding =
                      (anySelected && !isSelected)
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

                  // scale non-selected thumbnails while one (or more) is expanded
                  final double scale = !anySelected
                      ? 1.0
                      : (isSelected ? 1.0 : 0.86);

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == images.length - 1 ? 0 : itemSpacing,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        // Toggle selection
                        if (isSelected) {
                          setState(() {
                            _selectedIndices.remove(index);
                          });
                          return;
                        }

                        // If selecting, try to center tapped item (accurately), then add to selected set and expand.
                        // But do not auto-scroll if user is actively dragging.
                        _scrollToCenterAccurate(
                          index,
                          screenWidth,
                          itemSpacing,
                        );
                        await Future.delayed(const Duration(milliseconds: 120));
                        if (mounted) {
                          setState(() {
                            _selectedIndices.add(index);
                          });
                        }
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
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          isSelected ? 20 : 25,
                                        ),
                                        topRight: Radius.circular(
                                          isSelected ? 20 : 25,
                                        ),
                                        bottomLeft: Radius.circular(
                                          isSelected ? 20 : 25,
                                        ),
                                        bottomRight: Radius.circular(
                                          isSelected ? 20 : 25,
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
                                            TeamData.names[index],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            TeamData.roles[index],
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
                                                    padding:
                                                        const EdgeInsets.all(
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
                                                    padding:
                                                        const EdgeInsets.all(
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
      ),
    );
  }
}
