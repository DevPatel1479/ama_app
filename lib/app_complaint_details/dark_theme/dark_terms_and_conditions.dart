import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DarkTermsAndConditions extends StatelessWidget {
  const DarkTermsAndConditions({super.key});

  // Terms text kept verbatim (exactly as provided)
  final String termsText = r'''
Ama Legal Solutions
Terms and Conditions 
Effective Date: November 1, 2025
Last Updated: November 1, 2025

Welcome to Ama Legal Solutions (“we,” “our,” or “us”).
By downloading, accessing, or using the Ama Legal Solutions mobile application (“App”), you agree to be bound by these Terms and Conditions (“Terms”).
Please read them carefully before using the app or our services.

If you do not agree with these Terms, please refrain from using the Ama Legal Solutions app.

1. About Ama Legal Solutions
Ama Legal Solutions is a trusted Indian law firm and digital legal advisory platform.
Through the app, users can:

Explore our legal services

Ask legal questions or submit issues for review

Receive guidance or responses from verified advocates or authorized admins

The app aims to provide secure, efficient, and transparent legal assistance.

2. Acceptance of Terms
By creating an account, logging in, or using our services, you agree that you:

Are at least 18 years of age (or have legal parental consent if above 13 but below 18).

Have read, understood, and accepted these Terms and our Privacy Policy.

Provide accurate and complete information during registration and communication.

Your continued use of the app signifies your consent to these Terms and any future updates.

3. Legal Disclaimer
Ama Legal Solutions provides legal consultation and guidance through verified advocates and legal professionals.
However:

The responses, opinions, or guidance provided via the app do not constitute a formal attorney-client relationship.

The information shared is for general legal assistance and guidance.

Users are encouraged to consult directly with qualified legal professionals for specific cases or litigation matters.

Ama Legal Solutions shall not be liable for any direct or indirect consequences arising from reliance on advice shared through the app.

4. User Responsibilities
You agree to use the Ama Legal Solutions app lawfully and responsibly. You must not:

Provide false, misleading, or inaccurate information.

Impersonate another person or entity.

Use the platform to post, share, or transmit illegal, defamatory, or offensive content.

Attempt to hack, disrupt, or misuse the app or its security systems.

Violation of these rules may result in account suspension or permanent termination without prior notice.

5. Advocate and Admin Interaction
All advocates listed on Ama Legal Solutions are verified and approved professionals.

User data shared with advocates or admins is handled in accordance with our Privacy Policy.

Any communication between users and advocates is intended for informational and advisory purposes only.

Advocates are independent professionals, and Ama Legal Solutions is not responsible for their opinions or advice.

6. OTP and Account Verification
To enhance security, users are required to verify their identity using an OTP (One-Time Password) sent via WhatsApp using a secure third-party API.
Your phone number is used solely for authentication purposes and is not shared or sold to any other party.

7. Intellectual Property Rights
All content within the Ama Legal Solutions app — including but not limited to text, images, graphics, the app logo, and videos — is owned or licensed by Ama Legal Solutions.
You may not reproduce, distribute, or modify any content from the app without prior written permission.

The introductory video explaining Ama Legal Solutions is offline, safe, and informational only, and may not be copied or republished elsewhere.

8. No Advertising Policy
Ama Legal Solutions does not host third-party advertisements or marketing promotions within the app.
All in-app content is professional, ad-free, and designed solely for user convenience.

9. Data Protection and Privacy
Your privacy and data security are our top priorities.
We collect and process personal information such as your name, email, phone number, state, and profile picture only to provide our services.
All data is encrypted and transmitted securely over HTTPS and stored on secured servers.

For detailed information, please review our https://sites.google.com/view/ama-legal-solutions/home(included separately in the app and store listing).

10. Push Notifications
We may send you notifications through Firebase Cloud Messaging (FCM) regarding:

Updates from advocates or admins

Important account-related alerts

App improvements or service changes

You may disable notifications anytime via your device settings.

11. Account Termination and Data Deletion
You may request deletion of your account and all related data at any time by contacting us:
📞 +91 8700343611
📧 notify@amalegalsolutions.com
🏢 2493AP, Block G, Sushant Lok 2, Sector 57, Gurugram, Haryana 122001

Once verified, your account and data will be permanently deleted within 48 hours.

We reserve the right to suspend or terminate your account in case of policy violation or misuse of the app.

12. Limitation of Liability
While we strive to provide reliable and secure services, Ama Legal Solutions is not responsible for:

Any inaccuracies in legal responses provided by advocates.

Any damages resulting from reliance on the information provided through the app.

Any interruption, loss of data, or system errors beyond our reasonable control.

13. Governing Law and Jurisdiction
These Terms shall be governed and interpreted in accordance with the laws of India, specifically the Information Technology Act, 2000, and the Digital Personal Data Protection Act (DPDP), 2023.
Any disputes shall fall under the exclusive jurisdiction of the courts of Gurugram, Haryana, India.

14. Updates to These Terms
We may modify or update these Terms periodically to reflect changes in our operations, legal requirements, or service offerings.
The updated version will be available within the app, and continued use of the app indicates your acceptance of such changes.

15. Contact Information
For questions, feedback, or concerns about these Terms, please contact us at:

📞 +91 8700343611
📧 notify@amalegalsolutions.com
🏢 2493AP, Block G, Sushant Lok 2, Sector 57, Gurugram, Haryana 122001

By using the Ama Legal Solutions app, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions and our Privacy Policy.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: SingleChildScrollView(
            child: SelectableText(
              termsText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
