import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/call_model.dart';
import '../zego_service.dart';

final callControllerProvider = Provider<CallController>((ref) {
  final zegoService = ref.watch(zegoServiceProvider);
  return CallController(
    firestore: FirebaseFirestore.instance,
    zegoService: zegoService,
  );
});

// Stream provider to listen for incoming calls
final incomingCallStreamProvider = StreamProvider.family<CallModel?, String>(
      (ref, userId) {
    return FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CallModel.fromMap(snapshot.docs.first.data());
    });
  },
);

class CallController {
  final FirebaseFirestore firestore;
  final ZegoService zegoService;

  CallController({
    required this.firestore,
    required this.zegoService,
  });

  // Listen for incoming calls - MOVED INSIDE CLASS
  Stream<CallModel?> listenForIncomingCalls(String userId) {
    return firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return CallModel.fromMap(doc.data());
    });
  }

  // Initiate a call
  Future<CallModel> initiateCall({
    required String callerId,
    required String callerName,
    String? callerPhoto,  // Made nullable
    required String receiverId,
    required String receiverName,
    String? receiverPhoto,  // Made nullable
    bool isAudioOnly = true,
  }) async {
    try {
      final callId = const Uuid().v4();
      final roomId = 'room_$callId';

      final call = CallModel(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        callerPhoto: callerPhoto ?? '',
        receiverId: receiverId,
        receiverName: receiverName,
        receiverPhoto: receiverPhoto ?? '',
        roomId: roomId,
        status: CallStatus.ringing,
        timestamp: DateTime.now(),
        isAudioOnly: isAudioOnly,
      );

      // Save call to Firestore
      await firestore.collection('calls').doc(callId).set(call.toMap());

      // Initialize ZegoCloud and start publishing
      await zegoService.startCall(
        roomID: roomId,
        userID: callerId,
        userName: callerName,
      );

      return call;
    } catch (e) {
      print('Error initiating call: $e');
      rethrow;
    }
  }

  // Answer a call - FIXED PARAMETERS
  Future<void> answerCall(String callId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get call data
      final callDoc = await firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) return;

      final call = CallModel.fromMap(callDoc.data()!);

      // Update call status to ongoing
      await firestore.collection('calls').doc(callId).update({
        'status': CallStatus.ongoing.name,
      });

      // Join the ZegoCloud room
      await zegoService.joinCall(
        roomID: call.roomId,
        userID: currentUser.uid,
        userName: currentUser.displayName ?? 'User',
        remoteUserStreamID: call.roomId,
      );
    } catch (e) {
      print('Error answering call: $e');
      rethrow;
    }
  }

  // Reject a call
  Future<void> rejectCall(String callId) async {
    try {
      await firestore.collection('calls').doc(callId).update({
        'status': CallStatus.rejected.name,
      });
    } catch (e) {
      print('Error rejecting call: $e');
      rethrow;
    }
  }

  // End a call - FIXED PARAMETERS
  Future<void> endCall(String callId) async {
    try {
      // Get call data to get roomId
      final callDoc = await firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) return;

      final call = CallModel.fromMap(callDoc.data()!);

      // Update Firestore
      await firestore.collection('calls').doc(callId).update({
        'status': CallStatus.ended.name,
      });

      // End ZegoCloud session
      await zegoService.endCall(call.roomId);
    } catch (e) {
      print('Error ending call: $e');
      rethrow;
    }
  }

  // Listen to call status changes
  Stream<CallModel?> listenToCallStatus(String callId) {
    return firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return CallModel.fromMap(snapshot.data()!);
    });
  }
}