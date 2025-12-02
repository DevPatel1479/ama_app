import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountRequestScreen extends StatefulWidget {
  final bool isDark;

  const DeleteAccountRequestScreen({super.key, required this.isDark});

  @override
  State<DeleteAccountRequestScreen> createState() =>
      _DeleteAccountRequestScreenState();
}

class _DeleteAccountRequestScreenState
    extends State<DeleteAccountRequestScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDeleteRequestMade = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDeleteRequestStatus();
  }

  Future<void> _loadDeleteRequestStatus() async {
    bool? status = await LocalStorageHelper.getBool('isDeleteRequestMade');
    setState(() {
      _isDeleteRequestMade = status ?? false;
    });
  }

  Future<void> _submitDeleteRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate API delay

    await LocalStorageHelper.saveBool('isDeleteRequestMade', true);

    setState(() {
      _isSubmitting = false;
      _isDeleteRequestMade = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final Color bgColor = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF7F7F7);
    final Color buttonColor = const Color(0xFFD29F2A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,

        backgroundColor: (!isDark) ? Color(0xFFD29F2A) : bgColor,
        elevation: 0,
        title: Text(
          "Delete Account Request",
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: isDark
            ? Brightness.dark == Brightness.dark
                  ? const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                    )
                  : SystemUiOverlayStyle.light
            : const SystemUiOverlayStyle(
                statusBarColor: Color(0xFFD29F2A),
                statusBarIconBrightness: Brightness.dark, // dark icons
                statusBarBrightness: Brightness.light, // for iOS
              ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.07,
          vertical: screenHeight * 0.03,
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _isDeleteRequestMade
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: buttonColor,
                        size: screenWidth * 0.12,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Your account deletion request has been received.\nOur team is processing your request. You’ll be notified once it’s completed.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: textColor.withOpacity(0.9),
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Please provide a reason for deleting your account:",
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 4,
                          style: GoogleFonts.outfit(color: textColor),
                          decoration: InputDecoration(
                            hintText: "Write your reason here...",
                            hintStyle: GoogleFonts.outfit(
                              color: textColor.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF2F2F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please provide a reason.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : _submitDeleteRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: buttonColor.withOpacity(
                                0.6,
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Submit Request",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
