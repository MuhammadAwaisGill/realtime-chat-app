import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  Future<void> updateUserProfile(String userId, String displayName) {
    return _firestore.collection('users').doc(userId).update({
      'displayName': displayName,
    });
  }

  Future<void> unblockUser(String currentUserId, String userIdToUnblock) {
    return _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([userIdToUnblock]),
    });
  }

  String get currentUserId => _auth.currentUser!.uid;

  Stream<List<Map<String, dynamic>>> getContacts() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc['uid'] != currentUserId)
          .map((doc) => doc.data())
          .toList();
    });
  }
}
