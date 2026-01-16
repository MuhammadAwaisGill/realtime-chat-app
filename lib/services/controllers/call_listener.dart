// Create this widget in lib/widgets/call_listener.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/incoming_call/incoming_call_screen.dart';
import 'call_controller.dart';

class CallListener extends ConsumerWidget {
  final Widget child;
  final String userId;

  const CallListener({required this.child, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      incomingCallStreamProvider(userId),
          (previous, next) {
        next.whenData((call) {
          if (call != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncomingCallScreen(
                  call: call,
                  currentUserId: userId,
                  currentUserName: 'Your Name',
                ),
              ),
            );
          }
        });
      },
    );

    return child;
  }
}