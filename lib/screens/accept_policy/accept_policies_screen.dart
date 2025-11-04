import 'package:ama_legal_solutions/config/constants/app_assets_constants.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AcceptPoliciesScreen extends StatefulWidget {
  final bool isDark;
  const AcceptPoliciesScreen({super.key, required this.isDark});

  @override
  State<AcceptPoliciesScreen> createState() => _AcceptPoliciesScreenState();
}

class _AcceptPoliciesScreenState extends State<AcceptPoliciesScreen> {
  bool _acceptedPrivacy = false;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _acceptedPrivacy && _acceptedTerms;
    final size = MediaQuery.of(context).size;

    // Theme colors
    final Color bgColor = widget.isDark ? Colors.black : Colors.white;
    final Color cardColor = widget.isDark
        ? Colors.grey[900]!
        : Colors.grey[100]!;
    final Color textColor = widget.isDark ? Colors.grey[200]! : Colors.black87;
    final Color accentColor = Colors.blueAccent;
    final Color disabledColor = widget.isDark
        ? Colors.grey[700]!
        : Colors.grey[400]!;

    // ✅ System bar visibility fix
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bgColor,
        statusBarIconBrightness: widget.isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: widget.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🟢 Center logo
            Center(
              child: Image.asset(
                AppAssets.appLogoWithText,
                width: size.width * 0.55,
                fit: BoxFit.contain,
                color: !(widget.isDark) ? Colors.black : null,
              ),
            ),

            // 🟣 Bottom sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Before continuing, please accept our policies',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 🟠 Privacy Policy (whole text clickable)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _acceptedPrivacy,
                          onChanged: (value) =>
                              setState(() => _acceptedPrivacy = value ?? false),
                          activeColor: accentColor,
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => context.push(
                              AppPathsForScreen.policyScreenPath,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: accentColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 🟣 Terms & Conditions (whole text clickable)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) =>
                              setState(() => _acceptedTerms = value ?? false),
                          activeColor: accentColor,
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => context.push(
                              AppPathsForScreen.termsAndConditionsPath,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: accentColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔵 Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () async {
                                await LocalStorageHelper.saveBool(
                                  "isAcceptedPolicy",
                                  true,
                                );
                                context.pushReplacement(
                                  AppPathsForScreen.getStartedPath,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canContinue
                              ? accentColor
                              : disabledColor,
                          disabledBackgroundColor: disabledColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
