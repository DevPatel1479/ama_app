import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/client/remarks_provider.dart';

import 'package:ama_legal_solutions/screens/features/dark_theme/dark_live_case_status_screen.dart'
    show buildTimelineStep;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LightLiveCaseStatusScreen extends StatelessWidget {
  const LightLiveCaseStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

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
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
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
                  'Case Status History',
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

        fixedPositionWidget: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: size.width * 0.11,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                    children: const [
                      TextSpan(
                        text: "Track Your Legal Journey in ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Real Time",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.01),
                  child: Text(
                    "Stay informed from filing to resolution",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w300,
                      height: 1,
                      color: const Color(0xff2D2319),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        child: Consumer<RemarksProvider>(
          builder: (context, remarksProv, _) {
            /// LOADING
            if (remarksProv.loading && remarksProv.remarks.isEmpty) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ),
                ),
              );
            }

            /// ERROR
            if (remarksProv.errorMessage != null &&
                remarksProv.remarks.isEmpty) {
              return Center(
                child: Text(
                  remarksProv.errorMessage!,
                  style: GoogleFonts.outfit(color: Colors.black, fontSize: 15),
                ),
              );
            }

            /// EMPTY
            if (remarksProv.remarks.isEmpty) {
              return Center(
                child: Text(
                  "Pending",
                  style: GoogleFonts.outfit(color: Colors.black, fontSize: 16),
                ),
              );
            }

            /// DATA
            return RefreshIndicator(
              color: const Color(0xFFD29F2A),
              backgroundColor: const Color(0xFF171717),
              onRefresh: () async {
                final phone = await LocalStorageHelper.getString("userPhone");
                if (phone != null) {
                  await remarksProv.fetchRemarks("", phone);
                }
              },
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  10,
                  10,
                  10,
                  MediaQuery.of(context).padding.bottom +
                      screenHeight * 0.06, // ✅ important
                ),
                itemCount: remarksProv.remarks.length,
                itemBuilder: (context, index) {
                  final item = remarksProv.remarks[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: buildTimelineStep(
                      remarks: item.remarks,
                      timestamp: item.createdAt,
                      isLast: index == remarksProv.remarks.length - 1,
                      isLight: true,
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
