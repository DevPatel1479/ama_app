import 'dart:ui';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DarkPortfolioScreen extends StatefulWidget {
  const DarkPortfolioScreen({super.key});
  @override
  _DarkPortfolioScreenState createState() => _DarkPortfolioScreenState();
}

class _DarkPortfolioScreenState extends State<DarkPortfolioScreen> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserInfoProvider>(
        context,
        listen: false,
      ).fetchUserInfo(context, false);
    });

    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      double newOpacity = (offset / 150).clamp(0, 1);
      if (newOpacity != _appBarOpacity) {
        setState(() {
          _appBarOpacity = newOpacity;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildSectionHeader(String title, {bool showEdit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: title == "Personal Information"
                  ? const Color(0xFF337EFF)
                  : const Color(0xFF008C38),
            ),
          ),
          if (showEdit)
            Row(
              children: [
                Image.asset(AppAssets.editIcon, width: 18, height: 18),
                const SizedBox(width: 8),
                Text(
                  "Edit",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xB2FFFFFF),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildField(String label, String value, bool isLoading) {
    final financialLabels = [
      "Monthly Income",
      "Monthly Fees",
      "Credit Card Dues",
      "Personal Loan Dues",
    ];
    final isFinancial = financialLabels.contains(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(240, 57, 60, 32),
              borderRadius: BorderRadius.circular(15),
            ),
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade800,
                    highlightColor: Colors.grey.shade600,
                    child: Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isFinancial
                          ? const Color(0xFF008C38)
                          : Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Consumer<UserInfoProvider>(
        builder: (context, provider, _) {
          final isLoading = provider.isLoading;
          final user = provider.userInfo;

          // Map labels -> values from API model
          final fields = [
            {"label": "Name", "value": user?.name ?? ""},
            {"label": "Phone", "value": user?.phone ?? ""},
            {"label": "E-mail", "value": user?.email ?? ""},
            {"label": "City", "value": user?.city ?? ""},
            {"label": "Date of Birth", "value": user?.dob ?? ""},
            {"label": "Occupation", "value": user?.occupation ?? ""},
            {"label": "Aadhar Number", "value": user?.aadharNumber ?? ""},
            {"label": "PAN Card Number", "value": user?.panNumber ?? ""},
            {"label": "Assigned To", "value": user?.status ?? ""},
            {"label": "Assigned Advocate", "value": user?.allocAdv ?? ""},
            {
              "label": "Advocate Assigned At",
              "value": user?.allocAdvAt?["_seconds"].toString() ?? "",
            },
            {
              "label": "Secondary Advocate",
              "value": user?.allocAdvSecondary ?? "",
            },
            {"label": "Monthly Income", "value": user?.monthlyIncome ?? ""},
            {"label": "Monthly Fees", "value": user?.monthlyFees ?? ""},
            {"label": "Credit Card Dues", "value": user?.creditCardDues ?? ""},
            {
              "label": "Personal Loan Dues",
              "value": user?.personalLoanDues ?? "",
            },
            {"label": "Tenure", "value": user?.tenure ?? ""},
            {"label": "Start Date", "value": user?.startDate ?? ""},
            {"label": "Source", "value": user?.sourceDatabase ?? ""},
          ];

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(fields.length, (index) {
                    List<Widget> widgets = [];

                    if (index == 0) {
                      widgets.add(
                        buildSectionHeader(
                          "Personal Information",
                          showEdit: true,
                        ),
                      );
                    }

                    if (fields[index]["label"] == "Monthly Income") {
                      widgets.add(buildSectionHeader("Financial Information"));
                    }

                    widgets.add(
                      buildField(
                        fields[index]["label"]!,
                        fields[index]["value"]!,
                        isLoading,
                      ),
                    );

                    return Column(children: widgets);
                  }),
                ),
              ),

              // Modern transparent AppBar
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    color: Colors.black.withOpacity(
                      _appBarOpacity * 0.3 + 0.05,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            AppAssets.backArrowIcon,
                            width: MediaQuery.of(context).size.width * 0.05,
                            height: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.12,
                        ),
                        Text(
                          "Portfolio",
                          style: GoogleFonts.outfit(
                            fontSize: MediaQuery.of(context).size.width * 0.065,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
