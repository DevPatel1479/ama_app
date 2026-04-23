import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';

import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/provider/ama/question_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DarkRaiseQueryScreen extends StatefulWidget {
  final bool? isQuestionPosting;
  final bool? isFilingDispute;
  const DarkRaiseQueryScreen({
    super.key,
    this.isQuestionPosting,
    this.isFilingDispute,
  });

  @override
  State<DarkRaiseQueryScreen> createState() => _DarkRaiseQueryScreenState();
}

class _DarkRaiseQueryScreenState extends State<DarkRaiseQueryScreen> {
  final TextEditingController _queryController = TextEditingController();

  // Added for dropdown selection
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
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const scaleFactor = 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Column(
          children: [
            /// Fixed Custom AppBar
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015 * scaleFactor,
              ),
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
                    onPressed: () =>
                        (widget.isQuestionPosting != null &&
                            widget.isQuestionPosting == true &&
                            isQuestedPosted == true)
                        ? context.go(AppPathsForScreen.userHomePath)
                        : Navigator.pop(context),
                    splashRadius: 24, // optional, makes tap area bigger
                  ),

                  SizedBox(width: screenWidth * 0.02 * scaleFactor),
                  Text(
                    (widget.isQuestionPosting != null &&
                            widget.isQuestionPosting == true)
                        ? "Ask a Question"
                        : "Raise your Queries",
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.065 * scaleFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            /// Scrollable content below
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04 * scaleFactor,
                  vertical: screenHeight * 0.015 * scaleFactor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Subtext
                    SizedBox(
                      width: screenWidth * 0.9 * scaleFactor,
                      child: Text(
                        "If you have any inquiries, get in touch with Us.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.050 * scaleFactor,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
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
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.01 * scaleFactor,
                              bottom: screenHeight * 0.015 * scaleFactor,
                            ),
                            child: Text(
                              "Select Service",
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.055 * scaleFactor,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: const Color.fromRGBO(210, 159, 42, 0.04),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.004,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedService,
                                dropdownColor: const Color(0xFF2D2319),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(15),
                                hint: Text(
                                  "Select a Service",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
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

                          SizedBox(height: screenHeight * 0.03 * scaleFactor),
                        ],
                      ),

                    /// Query Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.01 * scaleFactor,
                        ),
                        child: Text(
                          (widget.isQuestionPosting != null &&
                                  widget.isQuestionPosting == true)
                              ? "Question"
                              : "Query",
                          style: GoogleFonts.outfit(
                            fontSize:
                                screenWidth * 0.055 * scaleFactor, // ~22px
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015 * scaleFactor),

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
                        color: const Color.fromRGBO(210, 159, 42, 0.04),
                      ),
                      child: TextField(
                        controller: _queryController,
                        expands: true,
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        textAlignVertical: TextAlignVertical.top,
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
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
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03 * scaleFactor),
                    if (widget.isQuestionPosting == null ||
                        widget.isQuestionPosting == false)
                      /// Submit Button
                      /// Submit Button with Provider integration
                      Consumer<QueryProvider>(
                        builder: (context, provider, _) {
                          return SizedBox(
                            // width: double.infinity,
                            width: screenWidth * 0.95 * scaleFactor,

                            height: screenHeight * 0.07 * scaleFactor,
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
                                        final success = await provider
                                            .raiseQuery(
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
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.018,
                                ),
                                backgroundColor: const Color(0xFFD29F2A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 6,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          "Submit",
                                          style: GoogleFonts.outfit(
                                            fontSize:
                                                screenWidth *
                                                0.05 *
                                                scaleFactor,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
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
                            width: screenWidth * 0.95 * scaleFactor,

                            height: screenHeight * 0.07 * scaleFactor,
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
                                      await Future.delayed(
                                        Duration(seconds: 2),
                                      );
                                      Navigator.pop(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.018,
                                ),
                                backgroundColor: const Color(0xFFD29F2A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 6,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          "Submit",
                                          style: GoogleFonts.outfit(
                                            fontSize:
                                                screenWidth *
                                                0.05 *
                                                scaleFactor,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
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
          ],
        ),
      ), // bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
