import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // Get all chats for current user
  Stream<QuerySnapshot> getUserChats() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }

  // Get messages for a specific chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(String chatId, String messageText, String otherUserId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$otherUserId': FieldValue.increment(1),
    });
  }

  // Initialize unread count for a chat
  Future<void> initializeUnreadCount(String chatId, String otherUserId) async {
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data() as Map<String, dynamic>?;

    if (chatData?['unreadCount'] == null) {
      await _firestore.collection('chats').doc(chatId).set({
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0,
        },
      }, SetOptions(merge: true));
    }

    await resetUnreadCount(chatId);
  }

  // Reset unread count for current user
  Future<void> resetUnreadCount(String chatId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'unreadCount.$currentUserId': 0,
    });
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }

  // Create or get existing chat
  Future<String> createOrGetChat(String otherUserId) async {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatId = ids.join('_');

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0,
        },
      });
    } else {
      final chatData = chatDoc.data() as Map<String, dynamic>;
      if (chatData['unreadCount'] == null) {
        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount': {
            currentUserId: 0,
            otherUserId: 0,
          },
        });
      }
    }

    return chatId;
  }
}