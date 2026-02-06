import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/shimmer_widget.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_casedesk_screen.dart';

class DarkBankDetailsScreen extends StatefulWidget {
  const DarkBankDetailsScreen({super.key});

  @override
  State<DarkBankDetailsScreen> createState() => _DarkBankDetailsScreenState();
}

class _DarkBankDetailsScreenState extends State<DarkBankDetailsScreen> {
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // ========== GRADIENT BACKGROUND ==========
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromRGBO(45, 35, 25, 0.8), Color(0xFF0F0F0F)],
                ),
              ),
            ),

            // ========== CONTENT ==========
            Consumer<UserInfoProvider>(
              builder: (context, provider, _) {
                final isLoading =
                    provider.userInfo == null || provider.isLoading;

                return RefreshIndicator(
                  edgeOffset:
                      MediaQuery.of(context).padding.top +
                      screenHeight * 0.10 + // same as ListView top padding
                      8,
                  color: const Color(0xFFD29F2A),
                  backgroundColor: const Color(0xFF171717),
                  onRefresh: () async {
                    provider.fetchUserInfo(context, true);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top:
                          statusBarHeight +
                          appBarHeight +
                          16, // enough top padding
                      left: screenWidth * 0.04 * scaleFactor,
                      right: screenWidth * 0.04 * scaleFactor,
                      bottom: contentBottomPadding,
                    ),
                    itemCount: isLoading
                        ? 3
                        : provider.userInfo?.banks.length ?? 0,
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

            // ========== FLOATING APPBAR ==========
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                    color: const Color(0xFF171717).withOpacity(0.45),
                    padding: EdgeInsets.only(
                      // left: screenWidth * 0.04,
                      top: MediaQuery.of(context).padding.top,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero, // remove default padding

                          icon: Image.asset(
                            AppAssets.backArrowIcon,
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.06,
                            fit: BoxFit.contain,
                          ),
                          onPressed: () => context.pop(),
                          splashRadius: 24, // optional, makes tap area bigger
                        ),
                        // SizedBox(width: screenWidth * 0.07),
                        const Text(
                          "Banking Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
