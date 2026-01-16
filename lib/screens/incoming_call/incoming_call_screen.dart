import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/controllers/call_controller.dart';
import '../../services/models/call_model.dart';
import '../audio_call/audio_call_screen.dart';

class IncomingCallScreen extends ConsumerWidget {
  final CallModel call;
  final String currentUserId;
  final String currentUserName;

  const IncomingCallScreen({
    Key? key,
    required this.call,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callController = ref.read(callControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Caller Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: call.callerPhoto.isNotEmpty
                  ? NetworkImage(call.callerPhoto)
                  : null,
              child: call.callerPhoto.isEmpty
                  ? Text(
                call.callerName[0].toUpperCase(),
                style: const TextStyle(fontSize: 48),
              )
                  : null,
            ),

            const SizedBox(height: 24),

            // Caller Name
            Text(
              call.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Call Type
            Text(
              'Incoming audio call...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),

            const Spacer(),

            // Answer/Reject Buttons
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject Button
                  _buildActionButton(
                    icon: Icons.call_end,
                    label: 'Decline',
                    color: Colors.red,
                    onTap: () async {
                      await callController.rejectCall(call.callId);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),

                  // Accept Button
                  _buildActionButton(
                    icon: Icons.call,
                    label: 'Accept',
                    color: Colors.green,
                    onTap: () async {
                      await callController.answerCall(call.callId);

                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => AudioCallScreen(
                              call: call,
                              isCaller: false,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}