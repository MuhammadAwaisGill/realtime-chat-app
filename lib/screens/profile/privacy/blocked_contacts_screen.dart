import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockedContactsScreen extends StatefulWidget {
  const BlockedContactsScreen({Key? key}) : super(key: key);

  @override
  State<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  List<String> blockedUserIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedContacts();
  }

  Future<void> _loadBlockedContacts() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data();
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
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'blockedUsers': FieldValue.arrayRemove([userId]),
        });

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
          ? _buildEmptyState()
          : ListView.builder(
        itemCount: blockedUserIds.length,
        itemBuilder: (context, index) {
          return _buildBlockedUserItem(blockedUserIds[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildBlockedUserItem(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
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
  }
}