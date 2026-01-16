import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      ref.read(loginLoadingProvider.notifier).state = true;

      try {
        final authController = ref.read(authControllerProvider);
        await authController.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Navigation handled by AuthWrapper
      } catch (e) {
        if (mounted) {
          final authController = ref.read(authControllerProvider);
          final message = authController.getErrorMessage(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } finally {
        ref.read(loginLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    ref.read(loginLoadingProvider.notifier).state = true;

    try {
      final authController = ref.read(authControllerProvider);
      await authController.signInWithGoogle();
      // Navigation handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        final authController = ref.read(authControllerProvider);
        final message = authController.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Enter your Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your Email!";
                    }
                    if (!value.contains('@')) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 8) {
                      return "Password must be 8 characters at least";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _continueWithGoogle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Continue with Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
