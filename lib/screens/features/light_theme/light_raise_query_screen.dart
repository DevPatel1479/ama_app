import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';

import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/ama/question_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LightRaiseQueryScreen extends StatefulWidget {
  final bool? isQuestionPosting;
  const LightRaiseQueryScreen({super.key, this.isQuestionPosting});

  @override
  State<LightRaiseQueryScreen> createState() => _LightRaiseQueryScreenState();
}

class _LightRaiseQueryScreenState extends State<LightRaiseQueryScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GradientTopLayout(
          screenName: "home",
          headerContent: Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04 * scaleFactor,
              vertical: screenHeight * 0.015 * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD29F2A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(screenWidth * 0.07), // ~responsive
                bottomRight: Radius.circular(screenWidth * 0.07), // ~responsive
              ),
            ),

            child: Column(
              children: [
                /// Fixed Custom AppBar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppPathsForScreen.userHomePath),
                      child: Image.asset(
                        AppAssets.backArrowIcon,
                        width: screenWidth * 0.05,
                        height: screenWidth * 0.05,
                        fit: BoxFit.contain,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.12 * scaleFactor),
                    Text(
                      "Raise your Queries",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.065 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          child:
              /// Scrollable content below
              ///
              ///
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),

                  /// Subtext
                  SizedBox(
                    width: screenWidth * 0.9 * scaleFactor,
                    child: Text(
                      "If you have any inquiries, get in touch with Us.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.050 * scaleFactor,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04 * scaleFactor),

                  /// Query Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.10 * scaleFactor,
                      ),

                      child: Text(
                        "Query",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.045 * scaleFactor, // ~22px
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015 * scaleFactor),

                  /// Query Card
                  Container(
                    width: screenWidth * 0.92 * scaleFactor,
                    height: screenHeight * 0.28 * scaleFactor,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(210, 159, 42, 0.65),
                          Color.fromRGBO(255, 255, 255, 0.65),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2319),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _queryController,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.04 * scaleFactor,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xBFFFFFFF),
                        ),
                        decoration: InputDecoration(
                          hintText: "Raise your Query...",
                          hintStyle: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.04 * scaleFactor,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xBFFFFFFF),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04 * scaleFactor,
                            vertical: screenHeight * 0.015 * scaleFactor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03 * scaleFactor),
                  if (widget.isQuestionPosting == null ||
                      widget.isQuestionPosting == false)
                    /// Submit Button
                    ///
                    Consumer<QueryProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: screenWidth * 0.8 * scaleFactor,
                          height: screenHeight * 0.06 * scaleFactor,
                          child: ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    final role =
                                        await LocalStorageHelper.getString(
                                          "userRole",
                                        ) ??
                                        '';
                                    final phone =
                                        await LocalStorageHelper.getString(
                                          "userPhone",
                                        ) ??
                                        '';
                                    final name =
                                        await LocalStorageHelper.getString(
                                          "userName",
                                        ) ??
                                        "";
                                    final queryText = _queryController.text
                                        .trim();

                                    if (queryText.isEmpty) {
                                      showCustomMessage(
                                        context,
                                        "Please enter a query",
                                        true,
                                      );
                                      return;
                                    }

                                    await provider.raiseQuery(
                                      context: context,
                                      role: role,
                                      phone: phone,
                                      name: name,
                                      queryText: queryText,
                                    );

                                    _queryController.clear();
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.black.withOpacity(0.3),
                              elevation: 6,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: provider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Submit",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.05 * scaleFactor,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Consumer<QuestionProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: screenWidth * 0.8 * scaleFactor,
                          height: screenHeight * 0.06 * scaleFactor,
                          child: ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    if (_queryController.text.isEmpty) {
                                      showCustomMessage(
                                        context,
                                        "Please enter your question",
                                        true,
                                      );
                                      return;
                                    }

                                    final phone =
                                        await LocalStorageHelper.getString(
                                          "userPhone",
                                        );
                                    final role =
                                        await LocalStorageHelper.getString(
                                          "userRole",
                                        );
                                    final name =
                                        await LocalStorageHelper.getString(
                                          "userName",
                                        );
                                    final profilePhotoUrl =
                                        await LocalStorageHelper.getString(
                                          "profile_photo_url",
                                        );
                                    final userId = "${role}_${phone}";
                                    // print("profile img url $profilePhotoUrl");
                                    await provider.createQuestion(
                                      context,
                                      userId: userId,
                                      userName: name!,
                                      userRole: role!,
                                      phone: phone!,
                                      content: _queryController.text.trim(),
                                      profileImgUrl: profilePhotoUrl,
                                    );

                                    _queryController.clear();
                                    await Future.delayed(Duration(seconds: 2));
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.black.withOpacity(0.3),
                              elevation: 6,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: provider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Submit",
                                        style: GoogleFonts.outfit(
                                          fontSize:
                                              screenWidth * 0.05 * scaleFactor,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
        ),
      ),

      // bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
