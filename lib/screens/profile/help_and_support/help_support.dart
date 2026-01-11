import 'package:flutter/material.dart';
import 'contact_us_screen.dart';
import 'report_problem_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Get Help'),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('FAQ'),
            subtitle: Text('Frequently asked questions'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text('Contact Us'),
            subtitle: Text('Get in touch with our support team'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Report a Problem'),
            subtitle: Text('Let us know if something isn\'t working'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportProblemScreen()),
              );
            },
          ),
          Divider(),
          _buildSectionHeader('About'),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms of Service'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I start a chat?',
        'answer': 'Go to the Contacts tab and tap on any contact to start chatting.'
      },
      {
        'question': 'How do I delete a chat?',
        'answer': 'Long press on any chat in the Chats tab and select delete.'
      },
      {
        'question': 'Can I send images?',
        'answer': 'Image sharing feature is coming soon in the next update.'
      },
      {
        'question': 'How do I change my profile picture?',
        'answer': 'Go to Profile > Edit Profile and tap on your profile picture.'
      },
      {
        'question': 'Is my data secure?',
        'answer': 'Yes, all messages are securely stored and protected.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                faqs[index]['question']!,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    faqs[index]['answer']!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}