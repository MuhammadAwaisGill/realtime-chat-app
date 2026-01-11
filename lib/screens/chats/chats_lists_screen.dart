import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  final String chatId, otherUserName;
  const ChatsScreen({super.key, required this.chatId, required this.otherUserName});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> sendMessage() async {
    if(_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();

    _messageController.clear();

    await FirebaseFirestore.instance
    .collection('chats')
    .doc(widget.chatId)
    .collection('messages')
    .add({
      'text': messageText,
      'senderId': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp()
    });

    await FirebaseFirestore.instance
    .collection('chats')
    .doc(widget.chatId)
    .update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
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
          SizedBox(height: 5,),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(),);
                }

                if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                  return Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black
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
                  color: Colors.black12
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (value) => sendMessage(),
                    decoration: InputDecoration(
                        hintText: 'Type some message here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                      ),
                  ),
                ),
                SizedBox(width: 8,),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white,),
                    onPressed: sendMessage,
                  ),
                ),
                SizedBox(width: 3,),
              ],
            ),
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }
}
