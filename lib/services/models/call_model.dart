import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus {
  ringing,
  ongoing,
  ended,
  missed,
  rejected,
}

class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String callerPhoto;
  final String receiverId;
  final String receiverName;
  final String receiverPhoto;
  final String roomId;
  final CallStatus status;
  final DateTime timestamp;
  final bool isAudioOnly;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.callerPhoto,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhoto,
    required this.roomId,
    required this.status,
    required this.timestamp,
    this.isAudioOnly = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'roomId': roomId,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAudioOnly': isAudioOnly,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerPhoto: map['callerPhoto'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverPhoto: map['receiverPhoto'] ?? '',
      roomId: map['roomId'] ?? '',
      status: CallStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => CallStatus.ringing,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isAudioOnly: map['isAudioOnly'] ?? true,
    );
  }

  CallModel copyWith({
    String? callId,
    String? callerId,
    String? callerName,
    String? callerPhoto,
    String? receiverId,
    String? receiverName,
    String? receiverPhoto,
    String? roomId,
    CallStatus? status,
    DateTime? timestamp,
    bool? isAudioOnly,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerPhoto: callerPhoto ?? this.callerPhoto,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhoto: receiverPhoto ?? this.receiverPhoto,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
    );
  }
}