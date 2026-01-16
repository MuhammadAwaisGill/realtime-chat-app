import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email/Password
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user?.updateDisplayName(name.trim());

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email.trim(),
        displayName: name.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Email/Password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user document exists, if not create one
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? '',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());
      }

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get error message
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Password is too weak';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        default:
          return 'An error occurred. Please try again';
      }
    }
    return 'An unexpected error occurred';
  }
}