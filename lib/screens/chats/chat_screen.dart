import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chats_lists_screen.dart';

class ChatScreen extends StatefulWidget {

  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.day == now.day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Existing StreamBuilder (wrap in Expanded)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Go to Contacts to start chatting', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                var chats = snapshot.data!.docs;

                chats.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['lastMessageTime'] as Timestamp?;
                  final bTime = bData['lastMessageTime'] as Timestamp?;

                  if (aTime == null && bTime == null) return 0;

                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data() as Map<String, dynamic>;
                    final chatId = chats[index].id;

                    final otherUserId = (chat['participants'] as List)
                        .firstWhere((id) => id != currentUser.uid);

                    return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUserId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return SizedBox();
                          }

                          final otherUser = userSnapshot.data!.data() as Map<String, dynamic>?;

                          if (otherUser == null) {
                            return SizedBox();
                          }

                          // Filter by search query
                          if (_searchQuery.isNotEmpty) {
                            final userName = (otherUser['displayName'] ?? '').toLowerCase();
                            final lastMsg = (chat['lastMessage'] ?? '').toLowerCase();

                            if (!userName.contains(_searchQuery) && !lastMsg.contains(_searchQuery)) {
                              return SizedBox(); // Hide non-matching chats
                            }
                          }

                          print('Chat ID: $chatId');
                          print('Current User: ${currentUser.uid}');
                          print('Unread Count Data: ${chat['unreadCount']}');
                          print('My Unread: ${chat['unreadCount']?[currentUser.uid]}');

                          return ListTile(
                            leading:Stack(
                              children: [
                                CircleAvatar(
                                  child: Text(otherUser['displayName']?[0].toUpperCase() ?? 'U'),
                                ),
                                // Unread badge
                                if ((chat['unreadCount']?[currentUser.uid] ?? 0) > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${chat['unreadCount'][currentUser.uid]}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(otherUser['displayName'] ?? 'Unknown User'),
                            subtitle: Text(
                              chat['lastMessage'] ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: chat['lastMessageTime'] != null
                                ? Text(
                              _formatTime(chat['lastMessageTime']),
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            )
                                : null,
                            onLongPress: () async {
                              bool? confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Chat'),
                                  content: Text('Are you sure you want to delete this chat?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(chatId)
                                    .delete();
                              }
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatsScreen(
                                    chatId: chatId,
                                    otherUserName: otherUser['displayName'] ?? 'User',
                                    otherUserId: otherUserId,
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      )
    );
  }
}