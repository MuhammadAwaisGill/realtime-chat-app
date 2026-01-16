import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(FirebaseAuth.instance.currentUser) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = null;
  }
}