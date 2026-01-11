import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
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
              'Terms of Service',
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
              title: '1. Acceptance of Terms',
              content:
              'By accessing and using Realtime Chat App, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use this service.',
            ),
            _buildSection(
              title: '2. Use of Service',
              content:
              'You agree to use this service only for lawful purposes and in a way that does not infringe the rights of, restrict or inhibit anyone else\'s use and enjoyment of the service. Prohibited behavior includes harassing or causing distress or inconvenience to any other user.',
            ),
            _buildSection(
              title: '3. User Accounts',
              content:
              'When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account.',
            ),
            _buildSection(
              title: '4. Content',
              content:
              'You are responsible for the content you post on our service. You grant us the right to use, modify, publicly perform, publicly display, reproduce, and distribute such content on and through the service.',
            ),
            _buildSection(
              title: '5. Privacy',
              content:
              'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your personal information.',
            ),
            _buildSection(
              title: '6. Termination',
              content:
              'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
            ),
            _buildSection(
              title: '7. Limitation of Liability',
              content:
              'In no event shall Realtime Chat App, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
            ),
            _buildSection(
              title: '8. Changes to Terms',
              content:
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on this page.',
            ),
            _buildSection(
              title: '9. Contact Us',
              content:
              'If you have any questions about these Terms, please contact us at support@realtimechat.com',
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By continuing to use our service, you acknowledge that you have read and understood these terms.',
                      style: TextStyle(fontSize: 13),
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