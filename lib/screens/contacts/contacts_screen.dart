import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chat_app/screens/chats/chat_screen.dart';

import '../chats/chats_lists_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  Stream<List<Map<String, dynamic>>> getContacts() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot){
      return snapshot.docs
          .where((doc) => doc['uid'] != currentUser!.uid)
          .map((doc) => doc.data())
          .toList();
    });
  }

  Future<void> startChat(BuildContext context, Map<String, dynamic> contact) async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    List<String> ids = [currentUser.uid, contact['uid']];
    ids.sort();
    String chatId = ids.join('_');

    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get();

    if (!chatDoc.exists) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({
        'participants': [currentUser.uid, contact['uid']],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'unreadCount': {
          currentUser.uid: 0,
          contact['uid']: 0,
        },
      });
    } else {
      // ADD THIS - Update existing chat to add unreadCount if missing
      final chatData = chatDoc.data() as Map<String, dynamic>;
      if (chatData['unreadCount'] == null) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .update({
          'unreadCount': {
            currentUser.uid: 0,
            contact['uid']: 0,
          },
        });
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsScreen(
          chatId: chatId,
          otherUserName: contact['displayName'],
          otherUserId: contact['uid'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getContacts(),
        builder: (context, snapshot) {
          print('Has data: ${snapshot.hasData}');
          print('Data length: ${snapshot.data?.length}');
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }

          if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(child: Text("No contacts found"));
          }

          final contacts = snapshot.data!;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context,index){
              final contact = contacts[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact['displayName'][0].toUpperCase()),
                ),
                title: Text(contact['displayName']),
                subtitle: Text(contact['email']),
                trailing: Icon(Icons.chat_bubble_outline),
                onTap: () {
                  startChat(context, contact);
                },
              );
            },
          );
        },
      ),
    );
  }
}