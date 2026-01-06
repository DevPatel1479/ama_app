import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/query_model.dart';
import 'package:ama_legal_solutions/provider/raise_query/resolve_query_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_casedesk_screen.dart'
    show GradientBorderContainer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void openResolveQueryBottomSheet(BuildContext context, QueryModel query) {
  final screenWidth = MediaQuery.of(context).size.width * 0.81;
  final screenHeight = MediaQuery.of(context).size.height * 0.81;

  bool isRemarkOn = false;
  final TextEditingController _controller = TextEditingController(
    text: 'Add remark on Query...',
  );

  showModalBottomSheet(
    backgroundColor: const Color(0xFF252525),
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final provider = Provider.of<ResolveQueryProvider>(context);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.03,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        AppAssets.backArrowIcon,
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Resolve Queries",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.06),
                  ],
                ),
                SizedBox(height: screenHeight * 0.025),

                // Toggle switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Give Remark",
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: isRemarkOn,
                      onChanged: (val) {
                        setState(() {
                          isRemarkOn = val;
                        });
                      },
                      activeColor: const Color(0xFFD29F2A),
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Remark Input + Submit Button
                if (isRemarkOn)
                  Column(
                    children: [
                      GradientBorderContainer(
                        borderRadius: 25,
                        borderWidth: 2,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD29F2A).withOpacity(0.65),
                            Colors.white.withOpacity(0.65),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        child: Container(
                          color: const Color(0xFF2D2319),
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.done,
                            maxLines: 5,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      // Submit Button with loader
                      Consumer<ResolveQueryProvider>(
                        builder: (context, provider, _) {
                          return GestureDetector(
                            onTap: provider.isLoading
                                ? null
                                : () async {
                                    if (_controller.text.trim().isEmpty ||
                                        _controller.text.trim().contains(
                                          'Add remark on Query...',
                                        )) {
                                      showCustomMessage(
                                        context,
                                        "Please provide remarks or turn off the switch to mark as resolved",
                                        true,
                                      );
                                      return;
                                    }

                                    final operatorRole =
                                        await LocalStorageHelper.getString(
                                          "userRole",
                                        );
                                    final operatorName =
                                        await LocalStorageHelper.getString(
                                          "userName",
                                        );
                                    final operatorPhone =
                                        await LocalStorageHelper.getString(
                                          "userPhone",
                                        );

                                    await provider.resolveQuery(
                                      context: context,
                                      operatorRole: operatorRole ?? "N/a",
                                      operatorName: operatorName ?? "N/a",
                                      operatorPhone: operatorPhone,
                                      queryId: query.id,
                                      parentDocId: query.parentDocId,
                                      remarks: _controller.text.trim(),
                                    );
                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );

                                    Navigator.of(
                                      context,
                                    ).pop(); // Close bottom sheet safely
                                  },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(-1, 0),
                                  end: Alignment(1, 0),
                                  colors: [
                                    Color(0xFFD29F2A),
                                    Color(0xFFFFFFFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: provider.isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Submit",
                                      style: GoogleFonts.outfit(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                else
                  // Mark Resolved Button when toggle OFF
                  Consumer<ResolveQueryProvider>(
                    builder: (context, provider, _) {
                      return GestureDetector(
                        onTap: provider.isLoading
                            ? null
                            : () async {
                                final operatorRole =
                                    await LocalStorageHelper.getString(
                                      "userRole",
                                    );
                                final operatorName =
                                    await LocalStorageHelper.getString(
                                      "userName",
                                    );
                                final operatorPhone =
                                    await LocalStorageHelper.getString(
                                      "userPhone",
                                    );

                                await provider.resolveQuery(
                                  context: context,
                                  operatorRole: operatorRole ?? "N/a",
                                  operatorName: operatorName ?? "N/a",
                                  operatorPhone: operatorPhone,
                                  queryId: query.id,
                                  parentDocId: query.parentDocId,
                                );

                                await Future.delayed(Duration(seconds: 2));
                                Navigator.pop(context);
                              },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(-1, 0),
                              end: Alignment(1, 0),
                              colors: [Color(0xFFD29F2A), Color(0xFFFFFFFF)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: provider.isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Mark Resolved",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          );
        },
      );
    },
  );
}
