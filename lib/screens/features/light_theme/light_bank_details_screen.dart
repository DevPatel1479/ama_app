import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/custom_widgets/shimmer_widget.dart'
    show ShimmerBankCard;
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_casedesk_screen.dart'
    show BankCard;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:provider/provider.dart';

class LightBankDetailsScreen extends StatefulWidget {
  const LightBankDetailsScreen({super.key});

  @override
  State<LightBankDetailsScreen> createState() => _LightBankDetailsScreenState();
}

class _LightBankDetailsScreenState extends State<LightBankDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserInfoProvider>(context, listen: false);
      provider.fetchUserInfo(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    final contentBottomPadding = 80.0;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 64.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF8BD00),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 244, 206, 83),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),

        // ⭐ NATIVE WAY TO ROUND ONLY BOTTOM
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(screenWidth * 0.07),
            bottomRight: Radius.circular(screenWidth * 0.07),
          ),
        ),

        titleSpacing: 0,
        toolbarHeight: kToolbarHeight,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero, // remove default padding

                  icon: Image.asset(
                    AppAssets.backArrowIcon,
                    width: screenWidth * 0.06,
                    height: screenWidth * 0.06,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                  onPressed: () => context.pop(),
                  splashRadius: 24, // optional, makes tap area bigger
                ),

                Text(
                  'Banking Details',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: screenWidth * 0.050,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: GradientTopLayout(
        keepExpanded: false,
        screenName: "home",
        child: Consumer<UserInfoProvider>(
          builder: (context, provider, _) {
            final isLoading = provider.userInfo == null || provider.isLoading;

            return RefreshIndicator(
              edgeOffset:
                  MediaQuery.of(context).padding.top +
                  screenHeight * 0.02 + // same as ListView top padding
                  8,
              color: const Color(0xFFD29F2A),
              backgroundColor: const Color(0xFF171717),
              onRefresh: () async {
                provider.fetchUserInfo(context, true);
              },
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top:
                      statusBarHeight + appBarHeight + 16, // enough top padding
                  left: screenWidth * 0.04 * scaleFactor,
                  right: screenWidth * 0.04 * scaleFactor,
                  bottom: contentBottomPadding,
                ),
                itemCount: isLoading ? 3 : provider.userInfo?.banks.length ?? 0,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.02 * scaleFactor,
                      ),
                      child: const ShimmerBankCard(),
                    );
                  }

                  final bank = provider.userInfo!.banks[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: screenHeight * 0.02 * scaleFactor,
                    ),
                    child: BankCard(
                      isLight: true,
                      bankName: bank.bankName,
                      accountNumber: bank.accountNumber,
                      type: bank.loanType,
                      typeColor: bank.loanType == "Credit Card"
                          ? const Color(0xFF337EFF)
                          : const Color(0xFF008C38),
                      amount: bank.loanAmount,
                      amountColor: const Color(0xFFFF5858),
                      settled: bank.settled,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
