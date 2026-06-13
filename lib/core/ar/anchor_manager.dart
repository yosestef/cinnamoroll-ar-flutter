import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:logger/logger.dart';

class AnchorManager {
  final Logger _logger;
  ARAnchorManager? _anchorManager;
  ARObjectManager? _objectManager;

  ARAnchor? _currentAnchor;
  ARNode? _currentNode;

  AnchorManager({Logger? logger}) : _logger = logger ?? Logger();

  void initialize(ARAnchorManager anchorManager, ARObjectManager objectManager) {
    _anchorManager = anchorManager;
    _objectManager = objectManager;
  }

  Future<bool> placeNodeOnAnchor(ARNode node, ARPlaneAnchor anchor) async {
    try {
      await clearCurrentCharacter();

      final anchorAdded = await _anchorManager!.addAnchor(anchor);
      if (anchorAdded == true) {
        _currentAnchor = anchor;
        final nodeAdded = await _objectManager!.addNode(node, planeAnchor: anchor);
        if (nodeAdded == true) {
          _currentNode = node;
          _logger.i('Successfully placed node on anchor');
          return true;
        } else {
          _logger.w('Failed to add node to anchor');
          await _anchorManager!.removeAnchor(anchor);
          _currentAnchor = null;
          return false;
        }
      }
      return false;
    } catch (e) {
      _logger.e('Error placing node on anchor', error: e);
      return false;
    }
  }

  Future<void> clearCurrentCharacter() async {
    if (_currentNode != null) {
      await _objectManager?.removeNode(_currentNode!);
      _currentNode = null;
    }
    if (_currentAnchor != null) {
      await _anchorManager?.removeAnchor(_currentAnchor!);
      _currentAnchor = null;
    }
  }
}
