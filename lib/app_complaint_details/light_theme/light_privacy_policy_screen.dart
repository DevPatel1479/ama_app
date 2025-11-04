import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LightPrivacyPolicyScreen extends StatelessWidget {
  const LightPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Ama Legal Solutions",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Privacy Policy\nEffective Date: November 1, 2025\nLast Updated: November 1, 2025",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Ama Legal Solutions (“we,” “our,” or “us”) respects your privacy and is committed to protecting your personal information. "
                "This Privacy Policy explains how we collect, use, store, and protect your data when you use our mobile application “Ama Legal Solutions”.\n\n"
                "By using the Ama Legal Solutions app, you acknowledge that you have read, understood, and agree to the terms of this Privacy Policy.",
                style: TextStyle(height: 1.5, color: Colors.black87),
              ),

              const SizedBox(height: 20),
              _sectionTitle("1. About Ama Legal Solutions"),
              const Text(
                "Ama Legal Solutions is a trusted Indian law firm and legal advisory platform designed to connect clients with verified advocates. "
                "Our mission is to provide strategic, result-driven, and personalized legal services that safeguard clients’ rights and promote their success.\n\n"
                "Through the Ama Legal Solutions mobile app, users can:\n"
                "• Explore legal services offered by our firm\n"
                "• Ask questions or share legal issues for guidance\n"
                "• Receive answers and assistance from registered and verified advocates or authorized admins\n\n"
                "The app includes one introductory video, which safely explains what Ama Legal Solutions is and the services it provides. "
                "This video is offline, non-educational, and does not collect any user data or tracking information.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("2. Information We Collect"),
              const Text(
                "We may collect and process the following personal information from users:\n"
                "• Full Name\n• Email Address\n• Phone Number\n• State / Location\n• Profile Picture\n\n"
                "This data helps us verify your identity, connect you with the right advocate, and provide personalized legal support.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("3. Purpose of Collecting Data"),
              const Text(
                "We collect and use your personal information for the following purposes:\n"
                "• Account creation and identity verification\n"
                "• Sending one-time passwords (OTP) via WhatsApp for secure login verification\n"
                "• Facilitating communication between users and verified advocates/admins\n"
                "• Providing customer support and resolving user queries\n"
                "• Sending updates and notifications through Firebase Cloud Messaging (FCM)\n"
                "• Fulfilling legal and regulatory obligations",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("4. OTP and Third-Party WhatsApp Integration"),
              const Text(
                "For authentication, our app sends a One-Time Password (OTP) to your registered phone number using a third-party WhatsApp API service. "
                "Your phone number is only used for login verification and is not shared or sold to any external parties.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("5. Video Content"),
              const Text(
                "The Ama Legal Solutions app contains a single introductory video that provides an overview of our firm, its values, and available services. "
                "The video is stored offline within the app and does not stream from external servers. "
                "It does not collect or track any user data or behavior. "
                "The video is safe, informational, and included only to help users understand the purpose of Ama Legal Solutions. "
                "There are no educational, promotional, or third-party advertisements in this video.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("6. Data Protection and Security"),
              const Text(
                "We take strong measures to ensure your data security. All communication between your device and our servers is encrypted using HTTPS protocols.\n\n"
                "Your personal data is stored on secure servers with restricted access to authorized personnel only. "
                "We apply technical, administrative, and physical safeguards to prevent unauthorized access, misuse, or disclosure.\n\n"
                "We comply with the Digital Personal Data Protection Act (DPDP Act), 2023 (India) and other relevant international data protection standards.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("7. Push Notifications"),
              const Text(
                "We may use Firebase Cloud Messaging (FCM) to send important notifications about:\n"
                "• Account activity\n• Advocate responses or updates\n• App improvements or support messages\n\n"
                "You can disable notifications at any time from your device settings.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("8. No Advertising Policy"),
              const Text(
                "The Ama Legal Solutions app does not display third-party advertisements. "
                "We do not track, analyze, or monetize your activity through ads or marketing tools.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("9. Children’s Privacy"),
              const Text(
                "Ama Legal Solutions does not knowingly collect or solicit personal information from children under the age of 13. "
                "Our app and services are intended for use by adults and individuals above the age of 13 only.\n\n"
                "If we discover that a child under 13 has provided us with personal information, we will promptly delete such data from our systems. "
                "If you are a parent or guardian and believe that your child has provided personal information to us, please contact us at notify@amalegalsolutions.com, "
                "and we will take appropriate action to remove that information.\n\n"
                "We strongly advise parents and guardians to monitor their children’s app usage to ensure a safe and appropriate online experience. "
                "Ama Legal Solutions fully complies with all applicable data protection and children’s privacy laws.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("10. User Consent"),
              const Text(
                "By using the Ama Legal Solutions app, you voluntarily consent to the collection, processing, and use of your information in accordance with this Privacy Policy and our Terms & Conditions.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("11. Data Retention"),
              const Text(
                "We retain personal data only as long as necessary for service delivery, compliance, or support. "
                "If you request deletion, your data will be permanently removed within 48 hours of verification.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("12. User Rights"),
              const Text(
                "As a user of Ama Legal Solutions, you are entitled to certain rights regarding your personal information, in accordance with applicable laws such as the GDPR, CCPA, and India’s DPDP Act, 2023.\n\n"
                "You have the right to:\n"
                "• Access Your Data :  Request access to the personal data we hold about you.\n• Request Deletion : Ask for your account and personal data to be deleted permanently.\n• Request Data Portability : Request a copy of your personal data in a commonly used, machine-readable format.\n\n"
                "To exercise any of these rights or to make inquiries about your data, please contact us at notify@amalegalsolutions.com.We will review and respond to your request in accordance with applicable data protection laws.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("13. Data Sharing and Disclosure"),
              const Text(
                "We do not sell, rent, or trade your personal data. "
                "Your information may only be shared with:\n"
                "• Verified advocates or admins to address your legal queries\n"
                "• Authorized internal staff for service support\n"
                "• Legal authorities when required by applicable law\n"
                "• Third-party WhatsApp OTP provider for login authentication only\n\n"
                "All such parties are obligated to maintain strict confidentiality and data protection standards.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("14. Account and Data Deletion Policy"),
              const Text(
                "If you wish to delete your account and all personal data, please contact us at:\n\n"
                "📞 Phone: +91 8700343611\n"
                "📧 Email: notify@amalegalsolutions.com\n"
                "🏢 Address: 2493AP, Block G, Sushant Lok 2, Sector 57, Gurugram, Haryana 122001\n\n"
                "Once your request is verified, your data will be permanently deleted within 48 hours.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("15. Changes to This Policy"),
              const Text(
                "We may update this Privacy Policy periodically to reflect operational or legal changes. "
                "The latest version will always be available within the app. Please review this policy regularly for updates.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),

              const SizedBox(height: 20),
              _sectionTitle("16. Contact Us"),
              const Text(
                "If you have questions, concerns, or complaints about this Privacy Policy or data handling, please reach us at:\n\n"
                "📞 Phone: +91 8700343611\n"
                "📧 Email: notify@amalegalsolutions.com\n"
                "🏢 Address: 2493AP, Block G, Sushant Lok 2, Sector 57, Gurugram, Haryana 122001\n\n"
                "By using the Ama Legal Solutions app, you acknowledge that you have read, understood, and agree to the terms of this Privacy Policy.",
                style: TextStyle(height: 1.5, color: Colors.black),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Colors.black,
      ),
    ),
  );
}
