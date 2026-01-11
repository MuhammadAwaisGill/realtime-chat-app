import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _messageNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showPreview = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
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
          _buildSectionHeader('Message Notifications'),
          SwitchListTile(
            title: Text('Enable Notifications'),
            subtitle: Text('Receive notifications for new messages'),
            value: _messageNotifications,
            onChanged: (value) {
              setState(() => _messageNotifications = value);
            },
            secondary: Icon(Icons.notifications_active),
          ),
          Divider(),
          _buildSectionHeader('Notification Settings'),
          SwitchListTile(
            title: Text('Sound'),
            subtitle: Text('Play sound for notifications'),
            value: _soundEnabled,
            onChanged: _messageNotifications
                ? (value) {
              setState(() => _soundEnabled = value);
            }
                : null,
            secondary: Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: Text('Vibration'),
            subtitle: Text('Vibrate for notifications'),
            value: _vibrationEnabled,
            onChanged: _messageNotifications
                ? (value) {
              setState(() => _vibrationEnabled = value);
            }
                : null,
            secondary: Icon(Icons.vibration),
          ),
          SwitchListTile(
            title: Text('Message Preview'),
            subtitle: Text('Show message content in notifications'),
            value: _showPreview,
            onChanged: _messageNotifications
                ? (value) {
              setState(() => _showPreview = value);
            }
                : null,
            secondary: Icon(Icons.preview),
          ),
          Divider(),
          _buildSectionHeader('Other'),
          ListTile(
            leading: Icon(Icons.do_not_disturb),
            title: Text('Do Not Disturb'),
            subtitle: Text('Set quiet hours'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Do Not Disturb settings
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