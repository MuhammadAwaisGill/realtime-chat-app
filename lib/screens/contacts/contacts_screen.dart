import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_service_provider.dart';
import '../chats/chats_lists_screen.dart';
import '../../providers/chat_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  Future<void> _startChat(BuildContext context, Map<String, dynamic> contact) async {
    final chatService = ref.read(chatServiceProvider);
    final chatId = await chatService.createOrGetChat(contact['uid']);

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
    final userService = ref.watch(userServiceProvider);

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
        stream: userService.getContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No contacts found"));
          }

          final contacts = snapshot.data!;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact['displayName'][0].toUpperCase()),
                ),
                title: Text(contact['displayName']),
                subtitle: Text(contact['email']),
                trailing: Icon(Icons.chat_bubble_outline),
                onTap: () => _startChat(context, contact),
              );
            },
          );
        },
      ),
    );
  }
}