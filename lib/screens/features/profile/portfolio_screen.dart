import 'dart:ui';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final List<Map<String, String>> fields = [
    {"label": "Name", "value": "Dp"},
    {"label": "Phone", "value": "+91 8776655464"},
    {"label": "E-mail", "value": "dp@gmail.com"},
    {"label": "City", "value": "Ahmedabad"},
    {"label": "Date of Birth", "value": "31/01/2002"},
    {"label": "Occupation", "value": "Developer"},
    {"label": "Aadhar Number", "value": "1111 1111 1111"},
    {"label": "PAN Card Number", "value": "AAAAA0000B"},
    {"label": "Assigned To", "value": "ABC"},
    {"label": "Assigned Advocate", "value": "Adv. Abc"},
    {"label": "Advocate Assigned At", "value": "August 21st, 2025, 11:11 AM"},
    {"label": "Secondary Advocate", "value": "Adv. Cba"},
    {"label": "Monthly Income", "value": "\$200000-300000"},
    {"label": "Monthly Fees", "value": "\$7674"},
    {"label": "Credit Card Dues", "value": "\$57463524"},
    {"label": "Personal Loan Dues", "value": "\$57463524"},
    {"label": "Tenure", "value": "24 months"},
    {"label": "Start Date", "value": "31/01/2005"},
    {"label": "Source", "value": "Cred Settle"},
  ];

  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
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

  Widget buildField(String label, String value) {
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
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isFinancial ? const Color(0xFF008C38) : Colors.white,
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
      body: Stack(
        children: [
          // Scrollable content behind AppBar
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(fields.length, (index) {
                List<Widget> widgets = [];

                if (index == 0) {
                  widgets.add(
                    buildSectionHeader("Personal Information", showEdit: true),
                  );
                }

                if (fields[index]["label"] == "Monthly Income") {
                  widgets.add(buildSectionHeader("Financial Information"));
                }

                widgets.add(
                  buildField(fields[index]["label"]!, fields[index]["value"]!),
                );

                return Column(children: widgets);
              }),
            ),
          ),

          // Modern transparent + blur AppBar with proper top padding
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).padding.top +
                      12, // Add status bar height + some spacing
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                color: Colors.black.withOpacity(_appBarOpacity * 0.3 + 0.05),
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
          ),
        ],
      ),
    );
  }
}
