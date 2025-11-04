import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LightDeleteAccountScreen extends StatelessWidget {
  const LightDeleteAccountScreen({super.key});

  // Delete Account Policy text kept verbatim
  final String policyText = r'''
Ama Legal Solutions
Delete Account Policy
Effective Date: November 1, 2025
Last Updated: November 1, 2025

At Ama Legal Solutions, we respect your right to privacy and control over your personal data.
If you wish to delete your account and associated information, you can request account deletion at any time by following the instructions below.

1. How to Request Account Deletion
To delete your account, please contact us using one of the following methods:

📧 Email: notify@amalegalsolutions.com
📞 Phone: +91 8700343611
🏢 Address: 2493AP, Block G, Sushant Lok 2, Sector 57, Gurugram, Haryana 122001

Please include the following details in your request:

Your registered full name

Your registered email address or phone number

A short message stating that you wish to delete your Ama Legal Solutions account

Once we receive your request, our team will verify your identity for security purposes before proceeding.

2. Data Deletion Process
After verification:

Your account and all associated personal data (name, email, phone number, profile picture, and state information) will be permanently deleted from our servers.

Any linked communication or chat data with advocates/admins will also be removed from our database.

Data deletion will be completed within 48 hours of confirmation.

You will receive an email or message notification once your account and data have been successfully deleted.

3. Data Retention Exceptions
In certain cases, we may be required to retain minimal information for a limited period to:

Comply with legal, regulatory, or tax obligations.

Resolve disputes or prevent misuse of the platform.

After the retention period expires, this information will also be permanently deleted.

4. Re-registration After Deletion
Once your account is deleted, it cannot be restored.
If you wish to use Ama Legal Solutions again, you will need to create a new account and complete the OTP verification process.

5. Contact for Assistance
If you have any questions or need help during the deletion process, please reach out to our support team at:

📧 notify@amalegalsolutions.com
📞 +91 8700343611

By submitting a deletion request, you acknowledge that your account and associated data will be permanently erased in accordance with this Delete Account Policy.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delete Account Policy',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: SingleChildScrollView(
            child: SelectableText(
              policyText,
              style: const TextStyle(
                color: Colors.black87,
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
