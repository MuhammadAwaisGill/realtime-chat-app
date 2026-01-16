import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_service_provider.dart';
import 'chats_lists_screen.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.day == now.day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);
    final userService = ref.watch(userServiceProvider);
    final searchQuery = ref.watch(searchQueryProvider);

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
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value.toLowerCase();
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getUserChats(),
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
                        .firstWhere((id) => id != chatService.currentUserId);

                    return FutureBuilder<DocumentSnapshot>(
                      future: userService.getUserData(otherUserId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return SizedBox();
                        }

                        final otherUser = userSnapshot.data!.data() as Map<String, dynamic>?;

                        if (otherUser == null) {
                          return SizedBox();
                        }

                        final userName = (otherUser['displayName'] ?? '').toLowerCase();
                        final lastMsg = (chat['lastMessage'] ?? '').toLowerCase();

                        if (searchQuery.isNotEmpty && !userName.contains(searchQuery) && !lastMsg.contains(searchQuery)) {
                          return SizedBox();
                        }

                        final unreadCount = chat['unreadCount']?[chatService.currentUserId] ?? 0;

                        return ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                child: Text(otherUser['displayName']?[0].toUpperCase() ?? 'U'),
                              ),
                              if (unreadCount > 0)
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
                                        '$unreadCount',
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
                              await chatService.deleteChat(chatId);
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
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}