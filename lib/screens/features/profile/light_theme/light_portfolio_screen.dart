import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LightPortfolioScreen extends StatefulWidget {
  const LightPortfolioScreen({super.key});
  @override
  _LightPortfolioScreenState createState() => _LightPortfolioScreenState();
}

class _LightPortfolioScreenState extends State<LightPortfolioScreen> {
  // final List<Map<String, String>> fields = [
  //   {"label": "Name", "value": "Dp"},
  //   {"label": "Phone", "value": "+91 8776655464"},
  //   {"label": "E-mail", "value": "dp@gmail.com"},
  //   {"label": "City", "value": "Ahmedabad"},
  //   {"label": "Date of Birth", "value": "31/01/2002"},
  //   {"label": "Occupation", "value": "Developer"},
  //   {"label": "Aadhar Number", "value": "1111 1111 1111"},
  //   {"label": "PAN Card Number", "value": "AAAAA0000B"},
  //   {"label": "Assigned To", "value": "ABC"},
  //   {"label": "Assigned Advocate", "value": "Adv. Abc"},
  //   {"label": "Advocate Assigned At", "value": "August 21st, 2025, 11:11 AM"},
  //   {"label": "Secondary Advocate", "value": "Adv. Cba"},
  //   {"label": "Monthly Income", "value": "\$200000-300000"},
  //   {"label": "Monthly Fees", "value": "\$7674"},
  //   {"label": "Credit Card Dues", "value": "\$57463524"},
  //   {"label": "Personal Loan Dues", "value": "\$57463524"},
  //   {"label": "Tenure", "value": "24 months"},
  //   {"label": "Start Date", "value": "31/01/2005"},
  //   {"label": "Source", "value": "Cred Settle"},
  // ];

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
          // if (showEdit)
          //   Row(
          //     children: [
          //       Image.asset(
          //         AppAssets.editIcon,
          //         width: 18,
          //         height: 18,
          //         color: const Color.fromARGB(225, 255, 255, 255),
          //       ),
          //       const SizedBox(width: 8),
          //       Text(
          //         "Edit",
          //         style: GoogleFonts.outfit(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w500,
          //           color: const Color.fromARGB(225, 255, 255, 255),
          //         ),
          //       ),
          //     ],
          //   ),
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              // color: const Color.fromARGB(240, 57, 60, 32),
              color: const Color(0x33D29F2A).withOpacity(0.3),
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
                          : Colors.black,
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
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD29F2A),
        statusBarIconBrightness: Brightness.dark, // white icons
        statusBarBrightness: Brightness.light, // iOS: white icons
      ),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: GradientTopLayout(
        screenName: "home",
        headerContent: Container(
          width: double.infinity,

          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.015,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD29F2A),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(screenWidth * 0.07), // ~responsive
              bottomRight: Radius.circular(screenWidth * 0.07), // ~responsive
            ),
          ),
          child: ClipRRect(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    AppAssets.backArrowIcon,
                    width:
                        MediaQuery.of(context).size.width *
                        0.05, // responsive icon size
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.12),
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

        child: Consumer<UserInfoProvider>(
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
              {
                "label": "Credit Card Dues",
                "value": user?.creditCardDues ?? "",
              },
              {
                "label": "Personal Loan Dues",
                "value": user?.personalLoanDues ?? "",
              },
              {"label": "Tenure", "value": user?.tenure ?? ""},
              {"label": "Start Date", "value": user?.startDate ?? ""},
              {"label": "Source", "value": user?.sourceDatabase ?? ""},
            ];

            return Column(
              children: [
                // Modern transparent + blur AppBar with proper top padding
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
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
                        widgets.add(
                          buildSectionHeader("Financial Information"),
                        );
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
              ],
            );
          },
        ),
      ),
    );
  }
}
