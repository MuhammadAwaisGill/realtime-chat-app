import 'package:flutter/material.dart';
import 'package:realtime_chat_app/screens/login/login_screen.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat App",
      home: LoginScreen(),
    );
  }
}
