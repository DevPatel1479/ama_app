import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';

class OurLegacySection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final double scaleFactor;
  final bool isDark;

  const OurLegacySection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    this.scaleFactor = 1.0,
    required this.isDark,
  });

  @override
  _OurLegacySection createState() => _OurLegacySection();
}

class _OurLegacySection extends State<OurLegacySection> {
  bool isFounderView = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Detect scroll movement
    _scrollController.addListener(() {
      double scrollX = _scrollController.offset;

      double cardWidth = widget.screenWidth * 0.9;
      double switchPoint = cardWidth * 0.5;

      if (scrollX > switchPoint && isFounderView) {
        setState(() => isFounderView = false);
      } else if (scrollX < switchPoint && !isFounderView) {
        setState(() => isFounderView = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPrevious() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToNext() {
    _scrollController.animateTo(
      widget.screenWidth * 0.9 +
          widget.screenWidth * 0.04, // card width + spacing
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Title
        Padding(
          padding: EdgeInsets.only(
            top: widget.screenHeight * 0.03,
            left: widget.screenWidth * 0.01,
            right: widget.screenWidth * 0.04,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isFounderView ? "Our Founder" : "Our Legacy",
              style: GoogleFonts.outfit(
                fontSize: widget.screenWidth * 0.04 * widget.scaleFactor,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? Colors.white : Colors.black,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        SizedBox(height: widget.screenHeight * 0.02 * widget.scaleFactor),

        // 🔹 Horizontally scrollable cards with arrows
        Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildLegacyCard(
                    context,
                    imagePath: AppAssets.ourFoundImg,
                    title: "Anuj Anand Malik",
                    subtitle: "Founder & Legal Consultant",
                    description:
                        "Anuj Anand Malik, advocate and founder of AMA Legal Solutions, leads with a mission to simplify and modernize legal services. His focus on client-centric solutions and financial law continues the legacy of innovation and integrity.",
                  ),
                  SizedBox(
                    width: widget.screenWidth * 0.04 * widget.scaleFactor,
                  ),
                  _buildLegacyCard(
                    context,
                    imagePath: AppAssets.ourLegacyImg,
                    title: "Late Adv. R.C. Malik",
                    subtitle:
                        "Ex-Comptroller and Auditor General of India\nDirector General of Audit (Central-Receipt)",
                    description:
                        "R.C. Malik started his professional journey as a gazetted officer at DGACR, progressing through different roles within the Income Tax Department before taking on administrative duties at the Office of the Comptroller and Auditor General (CAG) of India.",
                  ),
                ],
              ),
            ),
            // 🔹 Left arrow
            Positioned(
              left: 0,
              child: Visibility(
                visible: !isFounderView,
                child: GestureDetector(
                  onTap: _scrollToPrevious,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // 🔹 Right arrow
            Positioned(
              right: 0,
              child: Visibility(
                visible: isFounderView,
                child: GestureDetector(
                  onTap: _scrollToNext,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegacyCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.01 * widget.scaleFactor,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.screenWidth * 0.9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟡 Left Image with gradient border
            Container(
              width: (title == "Anuj Anand Malik")
                  ? widget.screenWidth * 0.45 * widget.scaleFactor
                  : widget.screenWidth * 0.35 * widget.scaleFactor,
              height: widget.screenHeight * 0.25 * widget.scaleFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(210, 159, 42, 0.65),
                    Color.fromRGBO(255, 255, 255, 0.65),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),

            SizedBox(width: widget.screenWidth * 0.04 * widget.scaleFactor),

            // 🟣 Right Text Column
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD29F2A),
                      height: 20 / 15,
                    ),
                  ),
                  SizedBox(
                    height: widget.screenHeight * 0.005 * widget.scaleFactor,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: widget.isDark ? Colors.white : Colors.black,
                      height: 16 / 12,
                    ),
                  ),
                  SizedBox(
                    height: widget.screenHeight * 0.01 * widget.scaleFactor,
                  ),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: widget.isDark ? Colors.white : Colors.black,
                      height: 14 / 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
