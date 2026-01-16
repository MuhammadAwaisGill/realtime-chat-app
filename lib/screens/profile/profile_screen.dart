import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';
import 'edit_profile.dart';
import 'help_and_support/help_support.dart';
import 'notifications_screen.dart';
import 'privacy/privacy_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ??
                        user?.email?.substring(0, 1).toUpperCase() ??
                        'U',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  )
                      : null,
                ),
                SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'User Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportScreen()),
              );
            },
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final authController = ref.read(authControllerProvider);
                await authController.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}