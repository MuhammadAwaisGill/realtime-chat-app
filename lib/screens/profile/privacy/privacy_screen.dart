import 'package:flutter/material.dart';
import 'blocked_contacts_screen.dart';
import 'two_step_verification_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _lastSeenVisibility = 'Everyone';
  String _profilePhotoVisibility = 'Everyone';
  String _aboutVisibility = 'Everyone';
  bool _readReceipts = true;
  bool _typingIndicator = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy'),
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
          _buildSectionHeader('Who can see my personal info'),
          _buildPrivacyOption(
            icon: Icons.access_time,
            title: 'Last Seen',
            currentValue: _lastSeenVisibility,
            onTap: () => _showPrivacyDialog('Last Seen', _lastSeenVisibility,
                    (value) => setState(() => _lastSeenVisibility = value)),
          ),
          _buildPrivacyOption(
            icon: Icons.photo,
            title: 'Profile Photo',
            currentValue: _profilePhotoVisibility,
            onTap: () => _showPrivacyDialog(
                'Profile Photo',
                _profilePhotoVisibility,
                    (value) => setState(() => _profilePhotoVisibility = value)),
          ),
          _buildPrivacyOption(
            icon: Icons.info,
            title: 'About',
            currentValue: _aboutVisibility,
            onTap: () => _showPrivacyDialog('About', _aboutVisibility,
                    (value) => setState(() => _aboutVisibility = value)),
          ),
          SizedBox(height: 8),
          _buildSectionHeader('Messages'),
          _buildSwitchTile(
            icon: Icons.done_all,
            title: 'Read Receipts',
            subtitle: 'Let others know when you\'ve read their messages',
            value: _readReceipts,
            onChanged: (value) => setState(() => _readReceipts = value),
          ),
          _buildSwitchTile(
            icon: Icons.edit,
            title: 'Typing Indicator',
            subtitle: 'Let others know when you\'re typing',
            value: _typingIndicator,
            onChanged: (value) => setState(() => _typingIndicator = value),
          ),
          SizedBox(height: 8),
          _buildSectionHeader('Security'),
          _buildPrivacyOption(
            icon: Icons.block,
            title: 'Blocked Contacts',
            currentValue: 'Manage blocked users',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlockedContactsScreen()),
              );
            },
          ),
          _buildPrivacyOption(
            icon: Icons.lock,
            title: 'Two-Step Verification',
            currentValue: 'Add extra security to your account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TwoStepVerificationScreen()),
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

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        currentValue,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  void _showPrivacyDialog(
      String title, String currentValue, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Who can see your $title?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Everyone'),
              value: 'Everyone',
              groupValue: currentValue,
              onChanged: (value) {
                onSelect(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('My Contacts'),
              value: 'My Contacts',
              groupValue: currentValue,
              onChanged: (value) {
                onSelect(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('Nobody'),
              value: 'Nobody',
              groupValue: currentValue,
              onChanged: (value) {
                onSelect(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}