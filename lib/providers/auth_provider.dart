import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/controllers/auth_controller.dart';

// Auth Controller Provider
final authControllerProvider = Provider((ref) => AuthController());

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.authStateChanges;
});

// Loading States
final loginLoadingProvider = StateProvider<bool>((ref) => false);
final signupLoadingProvider = StateProvider<bool>((ref) => false);