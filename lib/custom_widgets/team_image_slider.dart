import 'dart:math';
import 'package:ama_legal_solutions/provider/teams/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamSlider extends StatefulWidget {
  const TeamSlider({super.key});

  @override
  State<TeamSlider> createState() => _TeamSliderState();
}

class _TeamSliderState extends State<TeamSlider> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _selectedIndices = <int>{};
  bool _isUserDragging = false;

  static const double _imageSize = 150.0;
  static const double _expandedWidth = 240.0;
  static const double _expandedHeightRaw = 356.0;
  static const double _minFooterHeight = 60.0;
  final Duration _animDur = const Duration(milliseconds: 350);
  static const double _estimatedFooterContent = 150.0;
  static const double topPaddingWhenSelected = 12.0;

  @override
  void initState() {
    super.initState();

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TeamProvider>(context, listen: false);
      provider.fetchTeam();
    });

    // Pagination on scroll
    _scrollController.addListener(() {
      final provider = Provider.of<TeamProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !provider.isLoading &&
          provider.hasMore) {
        provider.fetchTeam();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _computeScrollTargetForIndex({
    required int index,
    required double screenWidth,
    required double itemSpacing,
    required bool expandTappedAsTrue,
  }) {
    final leftPadding = screenWidth * 0.02;
    double offset = leftPadding;
    for (int i = 0; i < index; i++) {
      final bool isExpanded = _selectedIndices.contains(i);
      offset += (isExpanded ? _expandedWidth : _imageSize);
      offset += itemSpacing;
    }
    final double tappedWidth =
        (expandTappedAsTrue || _selectedIndices.contains(index))
        ? _expandedWidth
        : _imageSize;
    return offset - (screenWidth - tappedWidth) / 2;
  }

  void _scrollToCenterAccurate(
    int index,
    double screenWidth,
    double itemSpacing,
  ) {
    if (!_scrollController.hasClients || _isUserDragging) return;

    final rawTarget = _computeScrollTargetForIndex(
      index: index,
      screenWidth: screenWidth,
      itemSpacing: itemSpacing,
      expandTappedAsTrue: true,
    );

    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = rawTarget.clamp(0.0, maxScroll);

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

    const double reservedSpaceBelow = 160.0;
    final double availableHeight = max(
      _imageSize + _minFooterHeight + 16,
      screenHeight - safeVerticalPadding - reservedSpaceBelow,
    );
    final double maxAllowedExpanded = min(_expandedHeightRaw, availableHeight);
    final double desiredExpandedHeight =
        topPaddingWhenSelected + _imageSize + _estimatedFooterContent;
    final double finalExpandedHeight = min(
      maxAllowedExpanded,
      desiredExpandedHeight,
    );
    final bool anySelected = _selectedIndices.isNotEmpty;
    final double sliderHeight = anySelected ? finalExpandedHeight : _imageSize;

    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        final members = provider.members;

        return RepaintBoundary(
          child: AnimatedSize(
            duration: _animDur,
            curve: Curves.easeInOut,
            child: SizedBox(
              height: sliderHeight + 12,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.dragDetails != null) {
                    _isUserDragging = true;
                  } else if (notification is ScrollEndNotification ||
                      notification is UserScrollNotification) {
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
                      children: List.generate(
                        provider.hasMore ? members.length + 1 : members.length,
                        (index) {
                          // Pagination loading indicator
                          if (index >= members.length) {
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == members.length
                                    ? 0
                                    : itemSpacing,
                              ),
                              child: SizedBox(
                                width: _imageSize,
                                height: sliderHeight,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            );
                          }

                          final member = members[index];
                          final bool isSelected = _selectedIndices.contains(
                            index,
                          );
                          final double containerHeight = anySelected
                              ? sliderHeight
                              : _imageSize;
                          final double containerWidth = isSelected
                              ? _expandedWidth
                              : _imageSize;
                          final double nonSelectedTopPadding =
                              (anySelected && !isSelected)
                              ? (containerHeight - _imageSize) / 2
                              : 0.0;
                          final double actualTopPadding = isSelected
                              ? topPaddingWhenSelected
                              : nonSelectedTopPadding;
                          final double footerHeight = isSelected
                              ? max(
                                  _minFooterHeight,
                                  containerHeight -
                                      actualTopPadding -
                                      _imageSize,
                                )
                              : 0.0;
                          final double scale = !anySelected
                              ? 1.0
                              : (isSelected ? 1.0 : 0.86);

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == members.length - 1
                                  ? 0
                                  : itemSpacing,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  setState(() {
                                    _selectedIndices.remove(index);
                                  });
                                  return;
                                }
                                _scrollToCenterAccurate(
                                  index,
                                  screenWidth,
                                  itemSpacing,
                                );
                                Future.delayed(
                                  const Duration(milliseconds: 120),
                                  () {
                                    if (mounted) {
                                      setState(() {
                                        _selectedIndices.add(index);
                                      });
                                    }
                                  },
                                );
                              },
                              child: ClipRect(
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
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: actualTopPadding,
                                          left:
                                              (containerWidth - _imageSize) / 2,
                                          child: SizedBox(
                                            width: _imageSize,
                                            height: _imageSize,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    isSelected ? 20 : 25,
                                                  ),
                                              child: member.image.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: member.image,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                    )
                                                  : Container(
                                                      color: Colors.grey[300],
                                                    ),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            height: footerHeight,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                        20,
                                                      ),
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 12,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    member.name,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    member.position,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black87,
                                                    ),
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
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
