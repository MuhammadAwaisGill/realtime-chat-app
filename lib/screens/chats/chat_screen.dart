import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chats_lists_screen.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

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
          _buildSearchBar(),
          _buildChatsList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildChatsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var chats = _sortChatsByTime(snapshot.data!.docs);

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return _buildChatItem(chats[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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

  List<QueryDocumentSnapshot> _sortChatsByTime(List<QueryDocumentSnapshot> chats) {
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

    return chats;
  }

  Widget _buildChatItem(QueryDocumentSnapshot chatDoc) {
    final chat = chatDoc.data() as Map<String, dynamic>;
    final chatId = chatDoc.id;

    final otherUserId = (chat['participants'] as List)
        .firstWhere((id) => id != _chatService.currentUserId);

    return FutureBuilder<DocumentSnapshot>(
      future: _userService.getUserData(otherUserId),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return SizedBox();
        }

        final otherUser = userSnapshot.data!.data() as Map<String, dynamic>?;

        if (otherUser == null) {
          return SizedBox();
        }

        if (!_matchesSearchQuery(otherUser, chat)) {
          return SizedBox();
        }

        return _buildChatListTile(chat, chatId, otherUser, otherUserId);
      },
    );
  }

  bool _matchesSearchQuery(Map<String, dynamic> otherUser, Map<String, dynamic> chat) {
    if (_searchQuery.isEmpty) return true;

    final userName = (otherUser['displayName'] ?? '').toLowerCase();
    final lastMsg = (chat['lastMessage'] ?? '').toLowerCase();

    return userName.contains(_searchQuery) || lastMsg.contains(_searchQuery);
  }

  Widget _buildChatListTile(
      Map<String, dynamic> chat,
      String chatId,
      Map<String, dynamic> otherUser,
      String otherUserId,
      ) {
    final unreadCount = chat['unreadCount']?[_chatService.currentUserId] ?? 0;

    return ListTile(
      leading: _buildAvatar(otherUser, unreadCount),
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
      onLongPress: () => _confirmDeleteChat(chatId),
      onTap: () => _openChat(chatId, otherUser, otherUserId),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> otherUser, int unreadCount) {
    return Stack(
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
    );
  }

  Future<void> _confirmDeleteChat(String chatId) async {
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
      await _chatService.deleteChat(chatId);
    }
  }

  void _openChat(String chatId, Map<String, dynamic> otherUser, String otherUserId) {
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
  }
}