import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/provider/teams/team_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_meet_team_screen.dart'
    show TeamMemberCard;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:provider/provider.dart';

class LightMeetTeamScreen extends StatefulWidget {
  const LightMeetTeamScreen({super.key});

  @override
  State<LightMeetTeamScreen> createState() => _LightMeetTeamScreenState();
}

class _LightMeetTeamScreenState extends State<LightMeetTeamScreen> {
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
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final topPadding = media.padding.top;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const int crossAxisCount = 2;
    final double spacing = 16;
    final double itemWidth = (screenWidth - spacing * (crossAxisCount + 1)) / 2;
    final double itemHeight = itemWidth * 1.1;
    final appBarHeight = screenWidth * 0.22;
    return Scaffold(
      extendBody: true,

      // <-- IMPORTANT: make scaffold transparent so page background can extend under system UI/home indicator
      backgroundColor: Color(0xFFF8BD00),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(topPadding + appBarHeight),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 244, 206, 83),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(screenWidth * 0.07),
              bottomRight: Radius.circular(screenWidth * 0.07),
            ),
          ),
          child: SizedBox(
            height: appBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                  onPressed: () => context.pop(),
                  splashRadius: 24,
                ),

                SizedBox(width: screenWidth * 0.02),

                Expanded(
                  child: Text(
                    "Meet the Team",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GradientTopLayout(
        screenName: "home",
        keepExpanded: false,
        child: Consumer<TeamProvider>(
          builder: (context, provider, _) {
            final members = provider.members;
            final hasMore = provider.hasMore;

            return SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // iOS-style frosted AppBar
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
                              child: TeamMemberCard(
                                member: members[i],
                                isLight: true,
                              ),
                            ),

                          // Loader at the end if fetching more
                          if (hasMore)
                            SizedBox(
                              width: screenWidth,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
