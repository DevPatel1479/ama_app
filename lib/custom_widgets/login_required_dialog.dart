import 'dart:ui';
import 'package:flutter/material.dart';

class LoginRequiredDialog extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final bool isDarkTheme;

  const LoginRequiredDialog({
    super.key,
    required this.onLoginPressed,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.85;

    final titleColor = isDarkTheme ? Colors.white : Colors.black87;
    final textColor = isDarkTheme ? Colors.white70 : Colors.black54;

    final buttonColor = isDarkTheme
        ? const Color(0xFF3B82F6)
        : Colors.blueAccent;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: width,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.06) // DARK: soft glass
                      : Colors.white.withOpacity(0.25), // LIGHT: iOS frosted
                  border: Border.all(
                    color: isDarkTheme
                        ? Colors.white.withOpacity(0.18)
                        : Colors.grey.withOpacity(0.3), // LIGHT border fix
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),

                    Icon(Icons.lock_outline, size: 42, color: titleColor),
                    const SizedBox(height: 12),

                    Text(
                      "Login Required",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "You are currently using guest mode.\nPlease login to access this feature.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: textColor),
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 6,
            top: 6,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(
                          0.45,
                        ), // LIGHT: better close bg
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
