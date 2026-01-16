import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Stream<QuerySnapshot> getUserChats() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

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

  Future<void> resetUnreadCount(String chatId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'unreadCount.$currentUserId': 0,
    });
  }

  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }

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