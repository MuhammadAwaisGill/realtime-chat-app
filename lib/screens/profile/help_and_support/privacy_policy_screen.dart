import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: January 11, 2026',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            _buildSection(
              title: '1. Information We Collect',
              content:
              'We collect information you provide directly to us, such as when you create an account, send messages, or contact our support team. This includes your name, email address, profile information, and messages you send through the app.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
              'We use the information we collect to:\n• Provide, maintain, and improve our services\n• Send you technical notices and support messages\n• Respond to your comments and questions\n• Protect against fraudulent or illegal activity\n• Analyze usage patterns to improve user experience',
            ),
            _buildSection(
              title: '3. Information Sharing',
              content:
              'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n• With your consent\n• To comply with legal obligations\n• To protect our rights and safety',
            ),
            _buildSection(
              title: '4. Data Security',
              content:
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized or unlawful processing, accidental loss, destruction, or damage. All messages are encrypted in transit using industry-standard protocols.',
            ),
            _buildSection(
              title: '5. Data Retention',
              content:
              'We retain your information for as long as your account is active or as needed to provide you services. You may delete your account at any time, and we will delete your information within 30 days, except where we are required to retain it for legal purposes.',
            ),
            _buildSection(
              title: '6. Your Rights',
              content:
              'You have the right to:\n• Access your personal information\n• Correct inaccurate information\n• Delete your account and data\n• Export your data\n• Opt-out of promotional communications\n• Object to certain processing of your data',
            ),
            _buildSection(
              title: '7. Cookies and Tracking',
              content:
              'We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
            ),
            _buildSection(
              title: '8. Children\'s Privacy',
              content:
              'Our service is not intended for users under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
            ),
            _buildSection(
              title: '9. Changes to This Policy',
              content:
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),
            _buildSection(
              title: '10. Contact Us',
              content:
              'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@realtimechat.com\nAddress: 123 Chat Street, Tech City, TC 12345',
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy and security are our top priorities. We are committed to protecting your personal information.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                      ),
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

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}