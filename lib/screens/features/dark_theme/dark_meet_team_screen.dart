import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ama_legal_solutions/provider/teams/team_provider.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class DarkMeetTeamScreen extends StatefulWidget {
  const DarkMeetTeamScreen({super.key});

  @override
  State<DarkMeetTeamScreen> createState() => _DarkMeetTeamScreenState();
}

class _DarkMeetTeamScreenState extends State<DarkMeetTeamScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).fetchTeam();
    });

    _scrollController.addListener(() {
      final provider = Provider.of<TeamProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const int crossAxisCount = 2;
    final double spacing = 16;
    final double itemWidth = (screenWidth - spacing * (crossAxisCount + 1)) / 2;
    final double itemHeight = itemWidth * 1.1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF171717), Color(0xFF171717)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<TeamProvider>(
          builder: (context, provider, _) {
            final members = provider.members;
            final hasMore = provider.hasMore;

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // iOS-style frosted AppBar
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 70,
                  automaticallyImplyLeading: false,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: const Color(0xFF171717).withOpacity(0.65),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Image.asset(
                                AppAssets.backArrowIcon,
                                width: 24,
                                height: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Meet the Team',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    spacing,
                    spacing,
                    spacing,
                    bottomPadding + spacing,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: members.length % 2 == 1
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      children: [
                        for (int i = 0; i < members.length; i++)
                          SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child: TeamMemberCard(member: members[i]),
                          ),

                        // Loader at the end if fetching more
                        if (hasMore)
                          SizedBox(
                            width: screenWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final dynamic member;
  final bool isLight;
  const TeamMemberCard({super.key, required this.member, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image container
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: member.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: member.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isLight ? const Color(0xFF2D2319) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          member.position,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isLight ? const Color(0xFF2D2319) : const Color(0xFFBFBFBF),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
