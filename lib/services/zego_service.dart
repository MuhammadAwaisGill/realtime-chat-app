import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/zego_config.dart';

// Provider for ZegoService
final zegoServiceProvider = Provider<ZegoService>((ref) {
  return ZegoService();
});

class ZegoService {
  bool _isEngineCreated = false;

  // Initialize ZegoCloud Engine
  Future<void> initializeEngine() async {
    if (_isEngineCreated) return;

    try {
      // Request permissions first
      await requestPermissions();

      // Create engine
      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          ZegoConfig.appID,
          ZegoScenario.General,
          appSign: ZegoConfig.appSign,
        ),
      );

      _isEngineCreated = true;
      print('ZegoCloud Engine initialized successfully');
    } catch (e) {
      print('Error initializing ZegoCloud: $e');
      rethrow;
    }
  }

  // Request necessary permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      print('Some permissions were not granted');
    }

    return allGranted;
  }

  // Start an audio call
  Future<void> startCall({
    required String roomID,
    required String userID,
    required String userName,
  }) async {
    try {
      if (!_isEngineCreated) {
        await initializeEngine();
      }

      // Create user
      ZegoUser user = ZegoUser(userID, userName);

      // Login to room
      await ZegoExpressEngine.instance.loginRoom(
        roomID,
        user,
        config: ZegoRoomConfig(0, true, ''),
      );

      // Start publishing audio stream
      await ZegoExpressEngine.instance.startPublishingStream(roomID);

      // Enable microphone
      await ZegoExpressEngine.instance.muteMicrophone(false);

      print('Started call in room: $roomID');
    } catch (e) {
      print('Error starting call: $e');
      rethrow;
    }
  }

  // Join an existing call
  Future<void> joinCall({
    required String roomID,
    required String userID,
    required String userName,
    required String remoteUserStreamID,
  }) async {
    try {
      if (!_isEngineCreated) {
        await initializeEngine();
      }

      // Create user
      ZegoUser user = ZegoUser(userID, userName);

      // Login to room
      await ZegoExpressEngine.instance.loginRoom(
        roomID,
        user,
        config: ZegoRoomConfig(0, true, ''),
      );

      // Start publishing own audio stream
      await ZegoExpressEngine.instance.startPublishingStream(roomID);

      // Start playing remote stream
      await ZegoExpressEngine.instance.startPlayingStream(remoteUserStreamID);

      // Enable microphone
      await ZegoExpressEngine.instance.muteMicrophone(false);

      print('Joined call in room: $roomID');
    } catch (e) {
      print('Error joining call: $e');
      rethrow;
    }
  }

  // End call
  Future<void> endCall(String roomID) async {
    try {
      // Stop publishing stream
      await ZegoExpressEngine.instance.stopPublishingStream();

      // Logout from room
      await ZegoExpressEngine.instance.logoutRoom(roomID);

      print('Ended call in room: $roomID');
    } catch (e) {
      print('Error ending call: $e');
      rethrow;
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone(bool mute) async {
    await ZegoExpressEngine.instance.muteMicrophone(mute);
  }

  // Toggle speaker
  Future<void> toggleSpeaker(bool useSpeaker) async {
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);
  }

  // Dispose engine
  Future<void> dispose() async {
    if (_isEngineCreated) {
      await ZegoExpressEngine.destroyEngine();
      _isEngineCreated = false;
    }
  }
}