import 'package:flutter/material.dart';

import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
              ),
            ),
            SizedBox(height: 40,),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter you Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email)
              ),
            ),
            SizedBox(height: 22,),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock)
              ),
            ),
            SizedBox(height: 28,),
            ElevatedButton(
              onPressed: () {
                print("Login Pressed");
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50)
              ),
            ),
            SizedBox(height: 16,),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupScreen())
                );
              },
              child: Text("Don\'t have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
