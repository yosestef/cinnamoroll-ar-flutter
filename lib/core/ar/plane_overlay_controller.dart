import 'dart:async';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:flutter/material.dart';

class PlaneOverlayController {
  ARSessionManager? _sessionManager;
  ARObjectManager? _objectManager;
  
  ARNode? _gridNode;
  Timer? _hitTestTimer;

  final ValueNotifier<bool> isPlaneDetected = ValueNotifier(false);

  PlaneOverlayController();

  void initialize(ARSessionManager sessionManager, ARObjectManager objectManager) {
    _sessionManager = sessionManager;
    _objectManager = objectManager;
  }

  void startScanning(double screenWidth, double screenHeight) {
    _hitTestTimer?.cancel();
    // Simulate detecting a plane after a brief moment for the sake of the HUD
    _hitTestTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_sessionManager == null) return;
      if (!isPlaneDetected.value) {
        isPlaneDetected.value = true;
      }
    });
  }

  Future<void> hideGrid() async {
    isPlaneDetected.value = false;
    if (_gridNode != null) {
      await _objectManager?.removeNode(_gridNode!);
      _gridNode = null;
    }
  }

  void dispose() {
    _hitTestTimer?.cancel();
    isPlaneDetected.dispose();
  }
}
