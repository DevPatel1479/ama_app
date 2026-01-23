import 'dart:ui';

import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/client/remarks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// ------------------------------------------------------------
/// DATE FORMATTER
/// ------------------------------------------------------------
DateTime _parseTimestamp(int ts) {
  return DateTime.fromMillisecondsSinceEpoch(
    ts > 1000000000000 ? ts : ts * 1000,
  );
}

/// ------------------------------------------------------------
/// TIMELINE STEP
/// ------------------------------------------------------------
Widget buildTimelineStep({
  required String remarks,
  required int timestamp,
  required bool isLast,
  bool isLight = false,
}) {
  final date = _parseTimestamp(timestamp);

  final day = DateFormat('EEE').format(date); // Mon
  final formattedDate = DateFormat('d MMM yyyy').format(date);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// ICON + LINE
      Column(
        children: [
          Image.asset(
            isLight ? AppAssets.lightDoneIcon : AppAssets.doneIcon,
            width: 22,
            height: 22,
          ),

          if (!isLast)
            Container(
              width: 2,
              height: 90,
              margin: const EdgeInsets.only(top: 2),
              color: const Color(0xFFD29F2A),
            ),
        ],
      ),

      const SizedBox(width: 14),

      /// CONTENT CARD
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isLight
                ? const Color.fromARGB(255, 217, 188, 121)
                : const Color.fromRGBO(45, 35, 25, 0.8),

            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 5.5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// REMARK TEXT
              Text(
                remarks,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              /// DATE BOTTOM RIGHT
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "$day, $formattedDate",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: isLight ? Colors.black : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// ------------------------------------------------------------
/// MAIN SCREEN
/// ------------------------------------------------------------
class DarkLiveCaseStatusScreen extends StatelessWidget {
  const DarkLiveCaseStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android icons
        statusBarBrightness: Brightness.dark, // iOS icons
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(45, 35, 25, 0.8), Color(0xFF0F0F0F)],
            ),
          ),

          child: Column(
            children: [
              /// ===================================================
              /// FLOATING iOS BLUR APPBAR
              /// ===================================================
              SizedBox(
                height: MediaQuery.of(context).padding.top + 64,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Case Status History",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // const SizedBox(height: 24),

              /// ===================================================
              /// HEADING TEXT
              /// ===================================================
              Expanded(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: size.width * 0.11,
                              fontWeight: FontWeight.w300,
                              height: 1,
                            ),
                            children: const [
                              TextSpan(
                                text: "Track Your Legal Journey in ",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: "Real Time",
                                style: TextStyle(color: Color(0xFFD29F2A)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.06),
                        child: Text(
                          "Stay informed from filing to resolution",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w300,
                            height: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// ===================================================
                      /// TIMELINE LIST
                      /// ===================================================
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<RemarksProvider>(
                            builder: (context, remarksProv, _) {
                              /// LOADING
                              if (remarksProv.loading &&
                                  remarksProv.remarks.isEmpty) {
                                return ListView.builder(
                                  itemCount: 5,
                                  itemBuilder: (_, __) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white.withOpacity(0.06),
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
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }

                              /// EMPTY
                              if (remarksProv.remarks.isEmpty) {
                                return Center(
                                  child: Text(
                                    "Pending",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }

                              /// DATA
                              return RefreshIndicator(
                                color: const Color(0xFFD29F2A),
                                backgroundColor: const Color(0xFF171717),
                                onRefresh: () async {
                                  final phone =
                                      await LocalStorageHelper.getString(
                                        "userPhone",
                                      );
                                  if (phone != null) {
                                    await remarksProv.fetchRemarks("", phone);
                                  }
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  itemCount: remarksProv.remarks.length,
                                  itemBuilder: (context, index) {
                                    final item = remarksProv.remarks[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 26,
                                      ),
                                      child: buildTimelineStep(
                                        remarks: item.remarks,
                                        timestamp: item.createdAt,
                                        isLast:
                                            index ==
                                            remarksProv.remarks.length - 1,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
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
    );
  }
}
