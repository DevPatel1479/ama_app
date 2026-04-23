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
  final bool? isFilingDispute;
  const LightRaiseQueryScreen({
    super.key,
    this.isQuestionPosting,
    this.isFilingDispute,
  });

  @override
  State<LightRaiseQueryScreen> createState() => _LightRaiseQueryScreenState();
}

class _LightRaiseQueryScreenState extends State<LightRaiseQueryScreen> {
  final TextEditingController _queryController = TextEditingController();
  String? selectedService;
  bool isQuestedPosted = false;

  final List<String> services = [
    "Banking & Finance",
    "Loan Settlement",
    "Intellectual Property Rights",
    "Entertainment Law",
    "Real Estate",
    "Criminal Law",
    "Corporate Law",
    "Arbitration Law",
    "IT & Cyber Law",
    "Civil Law",
    "Drafting",
    "Litigation",
  ];

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

    final headerVisualHeight = screenHeight * 0.03; // tweak if you need taller
    final appBarHeight =
        MediaQuery.of(context).padding.top + headerVisualHeight;
    return Scaffold(
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

        title: Row(
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
              onPressed: () =>
                  (widget.isQuestionPosting != null &&
                      widget.isQuestionPosting == true &&
                      isQuestedPosted == true)
                  ? context.go(AppPathsForScreen.userHomePath)
                  : Navigator.pop(context),
              splashRadius: 24, // optional, makes tap area bigger
            ),

            // SizedBox(width: screenWidth * 0.02 * scaleFactor),
            Text(
              (widget.isQuestionPosting != null &&
                      widget.isQuestionPosting == true)
                  ? "Ask a Question"
                  : "Raise your Queries",
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: GradientTopLayout(
          screenName: "home",
          // headerContent: Container(
          //   width: double.infinity,

          //   padding: EdgeInsets.symmetric(
          //     horizontal: screenWidth * 0.04 * scaleFactor,
          //     vertical: screenHeight * 0.015 * scaleFactor,
          //   ),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFD29F2A),
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(screenWidth * 0.07), // ~responsive
          //       bottomRight: Radius.circular(screenWidth * 0.07), // ~responsive
          //     ),
          //   ),

          //   child: Column(
          //     children: [
          //       /// Fixed Custom AppBar
          //       Row(
          //         children: [
          //           GestureDetector(
          //             onTap: () =>
          //                 (widget.isQuestionPosting != null &&
          //                     widget.isQuestionPosting == true)
          //                 ? context.go(AppPathsForScreen.userHomePath)
          //                 : Navigator.pop(context),
          //             child: Image.asset(
          //               AppAssets.backArrowIcon,
          //               width: screenWidth * 0.05,
          //               height: screenWidth * 0.05,
          //               fit: BoxFit.contain,
          //               color: Colors.black,
          //             ),
          //           ),
          //           SizedBox(width: screenWidth * 0.12 * scaleFactor),
          //           Text(
          //             "Raise your Queries",
          //             style: GoogleFonts.outfit(
          //               fontSize: screenWidth * 0.065 * scaleFactor,
          //               fontWeight: FontWeight.w600,
          //               color: Colors.black,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
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
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04 * scaleFactor),
                  if (widget.isFilingDispute == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04 * scaleFactor,
                            vertical: screenHeight * 0.010 * scaleFactor,
                          ),
                          child: Text(
                            "Select Service",
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.055 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04 * scaleFactor,
                            vertical: screenHeight * 0.010 * scaleFactor,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: const Color.fromARGB(255, 217, 188, 121),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05 * scaleFactor,
                              vertical: screenHeight * 0.010 * scaleFactor,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedService,
                                dropdownColor: const Color.fromARGB(
                                  255,
                                  217,
                                  188,
                                  121,
                                ),
                                icon: const Icon(Icons.arrow_drop_down),
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(15),
                                hint: Text(
                                  "Select a Service",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    selectedService = value;
                                  });
                                },
                                items: services
                                    .map(
                                      (service) => DropdownMenuItem(
                                        value: service,
                                        child: Text(service),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03 * scaleFactor),
                      ],
                    ),

                  /// Query Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04 * scaleFactor,
                        vertical: screenHeight * 0.010 * scaleFactor,
                      ),

                      child: Text(
                        (widget.isQuestionPosting != null &&
                                widget.isQuestionPosting == true)
                            ? "Question"
                            : "Query",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.055 * scaleFactor, // ~22px
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015 * scaleFactor),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04 * scaleFactor,
                      vertical: screenHeight * 0.010 * scaleFactor,
                    ),
                    child:
                        /// Query Card
                        Container(
                          width: double.infinity,
                          height: screenHeight * 0.28,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromARGB(255, 217, 188, 121),
                          ),
                          child: TextField(
                            controller: _queryController,
                            expands: true,
                            maxLines: null,
                            textInputAction: TextInputAction.done,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  (widget.isQuestionPosting != null &&
                                      widget.isQuestionPosting == true)
                                  ? "Ask a Question"
                                  : "Raise your Query...",
                              hintStyle: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
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
                          width: screenWidth * 0.9 * scaleFactor,
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
                                    if (selectedService == null &&
                                        widget.isFilingDispute == true) {
                                      showCustomMessage(
                                        context,
                                        "Please select service",
                                        true,
                                      );
                                      return;
                                    }
                                    if (queryText.isEmpty) {
                                      showCustomMessage(
                                        context,
                                        "Please enter a query",
                                        true,
                                      );
                                      return;
                                    }

                                    if (widget.isFilingDispute != null &&
                                        widget.isFilingDispute == true) {
                                      if (!context.mounted) return;
                                      await provider.raiseQuery(
                                        context: context,
                                        role: role,
                                        phone: phone,
                                        name: name,
                                        queryText: queryText,
                                        selectedService: selectedService,
                                        fileDispute: true,
                                      );
                                      if (provider.successMessage != null) {
                                        print(provider.successMessage);
                                        if (!context.mounted) return;
                                        context.pop();
                                        showCustomMessage(
                                          context,
                                          provider.successMessage ?? "",
                                          false,
                                        );
                                      }
                                    } else {
                                      final success = await provider.raiseQuery(
                                        context: context,
                                        role: role,
                                        phone: phone,
                                        name: name,
                                        queryText: queryText,
                                        fileDispute: false,
                                      );

                                      if (success) {
                                        context.pop(true);
                                      }
                                    }

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
                          width: screenWidth * 0.9 * scaleFactor,
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

                                    setState(() {
                                      isQuestedPosted = true;
                                      selectedService = null;
                                    });
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
