import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/audio_call/audio_call_screen.dart';
import '../models/call_model.dart';
import 'call_controller.dart';

class IncomingCallListener extends ConsumerWidget {
  final Widget child;

  const IncomingCallListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final callController = ref.read(callControllerProvider);

    if (currentUserId == null) return child;

    return StreamBuilder<CallModel?>(
      stream: callController.listenForIncomingCalls(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final call = snapshot.data!;

          // Show incoming call dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text('Incoming Call'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: call.callerPhoto.isNotEmpty
                          ? NetworkImage(call.callerPhoto)
                          : null,
                      child: call.callerPhoto.isEmpty
                          ? Text(call.callerName[0].toUpperCase())
                          : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      call.callerName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('is calling...'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await callController.rejectCall(call.callId);  // Use rejectCall
                      Navigator.pop(context);
                    },
                    child: Text('Decline', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await callController.answerCall(call.callId);  // Pass callId only
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AudioCallScreen(
                            call: call,
                            isCaller: false,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Accept'),
                  ),
                ],
              ),
            );
          });
        }

        return child;
      },
    );
  }
}