import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart';
import '../../services/controllers/call_controller.dart';
import '../audio_call/audio_call_screen.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;

  const ChatsScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ref.read(chatServiceProvider);
    _chatService.initializeUnreadCount(widget.chatId, widget.otherUserId);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    await _chatService.sendMessage(widget.chatId, messageText, widget.otherUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.otherUserName),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: () async {
              final callController = ref.read(callControllerProvider);
              final currentUser = FirebaseAuth.instance.currentUser;  // <-- Get current user

              if (currentUser == null) return;

              // Initiate call
              final call = await callController.initiateCall(
                callerId: currentUser.uid,  // <-- Current user ID
                callerName: currentUser.displayName ?? 'User',  // <-- Current user name
                callerPhoto: currentUser.photoURL,  // <-- Current user photo
                receiverId: widget.otherUserId,  // <-- Already have this
                receiverName: widget.otherUserName,  // <-- Already have this
                receiverPhoto: null,  // Can be null
              );

              // Go to call screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AudioCallScreen(call: call, isCaller: true),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 5),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == _chatService.currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -2),
                  blurRadius: 5,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (value) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type some message here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
                SizedBox(width: 3),
              ],
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}