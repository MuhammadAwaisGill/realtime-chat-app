import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_app/screens/chats/chat_screen.dart';
import 'package:realtime_chat_app/screens/contacts/contacts_screen.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabProvider);
    final authController = ref.read(authControllerProvider);

    final List<Widget> screens = [
      ChatScreen(),
      ContactsScreen(),
      ProfileScreen()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Realtime Chat App"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          // ThemeSwitcher(), // Add your theme switcher
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
              // Navigation handled by AuthWrapper
            },
          ),
        ],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlue[300],
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}