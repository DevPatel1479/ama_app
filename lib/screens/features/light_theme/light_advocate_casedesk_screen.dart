import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/custom_widgets/golden_light_theme_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LightAdvocateCasedeskScreen extends StatefulWidget {
  const LightAdvocateCasedeskScreen({super.key});

  @override
  State<LightAdvocateCasedeskScreen> createState() =>
      _LightAdvocateCasedeskScreenState();
}

class _LightAdvocateCasedeskScreenState
    extends State<LightAdvocateCasedeskScreen> {
  bool isMyCaseActive = true;
  bool isPendingActive = true; // secondary toggle

  // Example list of bank details
  final List<Map<String, dynamic>> bankDetails = [
    {
      "bankName": "HDFC Bank",
      "accountNumber": "1111 2222 3333 4444",
      "type": "Credit Card",
      "typeColor": Color(0xFF337EFF),
      "amount": "\$211111",
      "amountColor": Color(0xFFFF5858),
    },
    {
      "bankName": "HDFC Bank",
      "accountNumber": "5555 6666 7777 8888",
      "type": "Personal Loan",
      "typeColor": Color(0xFF008C38),
      "amount": "\$500000",
      "amountColor": Color(0xFFFF5858),
    },
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GradientTopLayout(
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

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          AppAssets.backArrowIcon,
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          fit: BoxFit.contain,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.12),
                      Text(
                        "My Casedesk",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.065,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          fixedPositionWidget:
              // SizedBox(height: screenHeight * 0.03),
              Column(
                children: [
                  // Primary Toggle bar (My Case / Bank Details)
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => isMyCaseActive = true),
                              child: Container(
                                margin: EdgeInsets.all(screenWidth * 0.01),
                                decoration: BoxDecoration(
                                  color: isMyCaseActive
                                      ? const Color(0xFFD29F2A)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "My Case",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => isMyCaseActive = false),
                              child: Container(
                                margin: EdgeInsets.all(screenWidth * 0.01),
                                decoration: BoxDecoration(
                                  color: !isMyCaseActive
                                      ? const Color(0xFFD29F2A)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Bank Details",
                                  style: GoogleFonts.outfit(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Secondary toggle row (Pending / Resolved) only for My Case
                  if (isMyCaseActive)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pending
                          GestureDetector(
                            onTap: () => setState(() => isPendingActive = true),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.02,
                                  ),
                                  child: Text(
                                    "Pending",
                                    style: GoogleFonts.outfit(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.03,
                                  ), // adjust as needed
                                  child: Container(
                                    width: screenWidth * 0.15,
                                    height: 2,
                                    color: isPendingActive
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Resolved
                          GestureDetector(
                            onTap: () =>
                                setState(() => isPendingActive = false),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: screenWidth * 0.02,
                                  ),
                                  child: Text(
                                    "Resolved",
                                    style: GoogleFonts.outfit(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: screenWidth * 0.01,
                                  ),
                                  child: Container(
                                    width: screenWidth * 0.15,
                                    height: 2,
                                    color: !isPendingActive
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
          child:
              // Content Section - scrollable
              isMyCaseActive
              ? isPendingActive
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Pending queries",
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              "All queries in the system have been resolved!",
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth * 0.035,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // let parent scroll
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        itemCount: 5, // Example multiple resolved cases
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color.fromRGBO(210, 159, 42, 0.65),
                                  Color.fromRGBO(255, 255, 255, 0.65),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(
                                1.5,
                              ), // Thin gradient border effect
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2319),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: Client icon and Resolved tag
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            AppAssets.portfolioIcon,
                                            width: screenWidth * 0.05,
                                            height: screenWidth * 0.05,
                                          ),
                                          SizedBox(width: screenWidth * 0.03),
                                          Text(
                                            "Client: TestDp Demo",
                                            style: GoogleFonts.outfit(
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.004,
                                          horizontal: screenWidth * 0.04,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0x33FFFFFF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF04C527),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          "Resolved",
                                          style: GoogleFonts.outfit(
                                            fontSize: screenWidth * 0.03,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF04C527),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  // Client Phone
                                  Text(
                                    "Client Phone: 1122334455",
                                    style: GoogleFonts.outfit(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  // Advocate Info
                                  Row(
                                    children: [
                                      Image.asset(
                                        AppAssets.advocateIcon,
                                        width: screenWidth * 0.05,
                                        height: screenWidth * 0.05,
                                      ),
                                      SizedBox(width: screenWidth * 0.03),
                                      Text(
                                        "Advocate: Patel",
                                        style: GoogleFonts.outfit(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.015),

                                  // First Remarks Box - Admin’s Remarks with nested text
                                  Container(
                                    width: screenWidth * 0.85,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0x0404C527,
                                      ), // #04C5270D
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF04C527,
                                        ), // #04C527
                                        width: 1,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.04,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              AppAssets.remarksIcon,
                                              width: screenWidth * 0.06,
                                              height: screenWidth * 0.06,
                                            ),
                                            SizedBox(width: screenWidth * 0.03),
                                            Text(
                                              "Admin’s Remarks",
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.008),
                                        Text(
                                          "new remark from the Admin Side!",
                                          style: GoogleFonts.outfit(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.015),

                                  // Second Remarks Box - Same style but blue border with nested text
                                  Container(
                                    width: screenWidth * 0.85,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0x083883F6,
                                      ), // #8383F60D
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF8383F6,
                                        ), // #8383F6
                                        width: 1,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.04,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              AppAssets.remarksIcon,
                                              width: screenWidth * 0.06,
                                              height: screenWidth * 0.06,
                                            ),
                                            SizedBox(width: screenWidth * 0.03),
                                            Text(
                                              "Client Queries",
                                              style: GoogleFonts.outfit(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.008),
                                        Text(
                                          "new Queries from the Client Side!",
                                          style: GoogleFonts.outfit(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
              : ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // let parent scroll
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  itemCount: bankDetails.length,
                  itemBuilder: (context, index) {
                    final bank = bankDetails[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: BankCard(
                        bankName: bank["bankName"],
                        accountNumber: bank["accountNumber"],
                        type: bank["type"],
                        typeColor: bank["typeColor"],
                        amount: bank["amount"],
                        amountColor: bank["amountColor"],
                      ),
                    );
                  },
                ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

// Reusable Bank Card widget
class BankCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String type;
  final Color typeColor;
  final String amount;
  final Color amountColor;

  const BankCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.type,
    required this.typeColor,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2319),
        shape: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(210, 159, 42, 0.65),
              const Color.fromRGBO(255, 255, 255, 0.65),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          width: 2,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.025,
        horizontal: screenWidth * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Column
          // Left Column (Labels)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bankText("Bank Name"),
              _bankText("Account Number"),
              _bankText("Type"),
              _bankText("Amount"),
            ],
          ),
          // Right Column (Actual Values)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bankText(bankName),
              _bankText(accountNumber),
              _bankText(type, color: typeColor),
              _bankText(amount, color: amountColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bankText(String text, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}

// Gradient Border Shape
class GradientBoxBorder extends ShapeBorder {
  final Gradient gradient;
  final double width;
  final BorderRadius borderRadius;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(
      gradient: gradient,
      width: width * t,
      borderRadius: borderRadius * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect).deflate(width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final rrect = (borderRadius ?? this.borderRadius)
        .toRRect(rect)
        .deflate(width / 2);
    canvas.drawRRect(rrect, paint);
  }
}
