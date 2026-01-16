import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/user_service_provider.dart';

class BlockedContactsScreen extends ConsumerStatefulWidget {
  const BlockedContactsScreen({super.key});

  @override
  ConsumerState<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends ConsumerState<BlockedContactsScreen> {
  List<String> blockedUserIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedContacts();
  }

  Future<void> _loadBlockedContacts() async {
    try {
      final currentUser = ref.read(authStateProvider).value;
      final userService = ref.read(userServiceProvider);

      final userDoc = await userService.getUserData(currentUser!.uid);
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData['blockedUsers'] != null) {
        setState(() {
          blockedUserIds = List<String>.from(userData['blockedUsers']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unblockUser(String userId, String userName) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unblock User'),
        content: Text('Are you sure you want to unblock $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Unblock', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final currentUser = ref.read(authStateProvider).value;
        final userService = ref.read(userServiceProvider);

        await userService.unblockUser(currentUser!.uid, userId);

        setState(() {
          blockedUserIds.remove(userId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName has been unblocked')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error unblocking user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Contacts'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : blockedUserIds.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No blocked contacts',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Users you block will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: blockedUserIds.length,
        itemBuilder: (context, index) {
          final userId = blockedUserIds[index];
          final userService = ref.watch(userServiceProvider);

          return FutureBuilder(
            future: userService.getUserData(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>?;

              if (userData == null) {
                return SizedBox();
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    userData['displayName']?[0].toUpperCase() ?? 'U',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(userData['displayName'] ?? 'Unknown User'),
                subtitle: Text(userData['email'] ?? ''),
                trailing: TextButton(
                  onPressed: () => _unblockUser(userId, userData['displayName'] ?? 'User'),
                  child: Text('Unblock', style: TextStyle(color: Colors.blue)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}