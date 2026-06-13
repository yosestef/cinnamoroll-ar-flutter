import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_location_manager.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class ArSessionService {
  final Logger _logger;
  
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  ArSessionService({Logger? logger}) : _logger = logger ?? Logger();

  ARSessionManager? get sessionManager => _arSessionManager;
  ARObjectManager? get objectManager => _arObjectManager;
  ARAnchorManager? get anchorManager => _arAnchorManager;

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    _logger.i('Camera permission status: $status');
    return status.isGranted;
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );
    
    _arObjectManager!.onInitialize();
  }

  void dispose() {
    _logger.i('Disposing AR Session');
    _arSessionManager?.dispose();
  }
}
