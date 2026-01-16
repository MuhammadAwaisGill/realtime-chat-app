import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/controllers/call_controller.dart';
import '../../services/models/call_model.dart';
import '../../services/zego_service.dart';
import 'dart:async';

class AudioCallScreen extends ConsumerStatefulWidget {
  final CallModel call;
  final bool isCaller;

  const AudioCallScreen({
    Key? key,
    required this.call,
    required this.isCaller,
  }) : super(key: key);

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  StreamSubscription? _callStatusSubscription;
  int _callDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenToCallStatus();
  }

  void _listenToCallStatus() {
    final callController = ref.read(callControllerProvider);

    _callStatusSubscription = callController
        .listenToCallStatus(widget.call.callId)
        .listen((call) {
      if (call == null) return;

      if (call.status == CallStatus.ongoing && _timer == null) {
        // Start timer when call is ongoing
        _startTimer();
      }

      if (call.status == CallStatus.ended ||
          call.status == CallStatus.rejected) {
        // Navigate back when call ends
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMute() async {
    final zegoService = ref.read(zegoServiceProvider);
    setState(() {
      _isMuted = !_isMuted;
    });
    await zegoService.toggleMicrophone(_isMuted);
  }

  Future<void> _toggleSpeaker() async {
    final zegoService = ref.read(zegoServiceProvider);
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    await zegoService.toggleSpeaker(_isSpeakerOn);
  }

  Future<void> _endCall() async {
    final callController = ref.read(callControllerProvider);
    await callController.endCall(widget.call.callId);  }

  @override
  void dispose() {
    _callStatusSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUserName = widget.isCaller
        ? widget.call.receiverName
        : widget.call.callerName;
    final otherUserPhoto = widget.isCaller
        ? widget.call.receiverPhoto
        : widget.call.callerPhoto;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // User Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: otherUserPhoto.isNotEmpty
                  ? NetworkImage(otherUserPhoto)
                  : null,
              child: otherUserPhoto.isEmpty
                  ? Text(
                otherUserName[0].toUpperCase(),
                style: const TextStyle(fontSize: 48),
              )
                  : null,
            ),

            const SizedBox(height: 24),

            // User Name
            Text(
              otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Call Status
            Text(
              widget.call.status == CallStatus.ongoing
                  ? _formatDuration(_callDuration)
                  : widget.isCaller
                  ? 'Calling...'
                  : 'Incoming call...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),

            const Spacer(),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onTap: _toggleMute,
                    backgroundColor: _isMuted ? Colors.red : Colors.white24,
                  ),

                  // End Call Button
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'End',
                    onTap: _endCall,
                    backgroundColor: Colors.red,
                    size: 70,
                  ),

                  // Speaker Button
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                    onTap: _toggleSpeaker,
                    backgroundColor: _isSpeakerOn ? Colors.blue : Colors.white24,
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

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    double size = 60,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}