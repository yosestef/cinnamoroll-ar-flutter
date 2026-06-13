import 'package:ar_flutter_plugin_engine/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_engine/models/ar_hittest_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ar/anchor_manager.dart';
import '../../../core/ar/ar_session_service.dart';
import '../../../core/ar/plane_overlay_controller.dart';
import '../data/character_repository.dart';
import '../domain/place_character_usecase.dart';
import 'ar_viewer_state.dart';
import 'widgets/plane_grid_overlay.dart';
import 'widgets/status_hud_widget.dart';

class ARViewerScreen extends ConsumerStatefulWidget {
  const ARViewerScreen({super.key});

  @override
  ConsumerState<ARViewerScreen> createState() => _ARViewerScreenState();
}

class _ARViewerScreenState extends ConsumerState<ARViewerScreen> with WidgetsBindingObserver {
  late ArSessionService _arSessionService;
  late PlaneOverlayController _planeOverlayController;
  late AnchorManager _anchorManager;
  String? _localModelPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _arSessionService = ArSessionService();
    _planeOverlayController = PlaneOverlayController();
    _anchorManager = AnchorManager();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  Future<void> _initApp() async {
    final hasPermission = await _arSessionService.requestCameraPermission();
    if (!hasPermission) {
      ref.read(arViewerProvider.notifier).setError("Permiso de cámara denegado. Es necesario para AR.");
      return;
    }

    final repo = ref.read(characterRepositoryProvider);
    ref.read(arViewerProvider.notifier).setStatus(ArViewerStatus.downloadingModel);
    
    try {
      _localModelPath = await repo.getModelPath(
        onProgress: (received, total) {
          if (total != -1) {
            ref.read(arViewerProvider.notifier).updateDownloadProgress(received / total);
          }
        }
      );
      ref.read(arViewerProvider.notifier).setStatus(ArViewerStatus.scanning);
    } catch (e) {
      ref.read(arViewerProvider.notifier).setError("Error al descargar modelo: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause AR
    } else if (state == AppLifecycleState.resumed) {
      // Resume AR
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _arSessionService.dispose();
    _planeOverlayController.dispose();
    super.dispose();
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    _arSessionService.onARViewCreated(arSessionManager, arObjectManager, arAnchorManager, arLocationManager);
    _planeOverlayController.initialize(arSessionManager, arObjectManager);
    _anchorManager.initialize(arAnchorManager, arObjectManager);
    
    _planeOverlayController.isPlaneDetected.addListener(() {
      final isDetected = _planeOverlayController.isPlaneDetected.value;
      if (isDetected && ref.read(arViewerProvider).status == ArViewerStatus.scanning) {
        ref.read(arViewerProvider.notifier).setStatus(ArViewerStatus.planeDetected);
      } else if (!isDetected && ref.read(arViewerProvider).status == ArViewerStatus.planeDetected) {
        ref.read(arViewerProvider.notifier).setStatus(ArViewerStatus.scanning);
      }
    });

    arSessionManager.onPlaneOrPointTap = _onPlaneOrPointTapped;
    
    final size = MediaQuery.of(context).size;
    _planeOverlayController.startScanning(size.width, size.height);
  }

  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (hitTestResults.isEmpty || _localModelPath == null) return;
    if (ref.read(arViewerProvider).status == ArViewerStatus.characterPlaced) return;

    final placeUsecase = ref.read(placeCharacterUseCaseProvider);
    final success = await placeUsecase.execute(
      hitResult: hitTestResults.first,
      anchorManager: _anchorManager,
      localModelPath: _localModelPath!,
      planeType: 'horizontal_up', // Simplified
    );

    if (success) {
      ref.read(arViewerProvider.notifier).setStatus(ArViewerStatus.characterPlaced);
      _planeOverlayController.hideGrid();
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && ref.read(arViewerProvider).status == ArViewerStatus.characterPlaced) {
          // Status HUD disappears after 2 seconds inherently if we clear message, but here we just leave the state
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(arViewerProvider);

    if (state.status == ArViewerStatus.error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(state.errorMessage ?? 'Error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          const PlaneGridOverlay(),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(child: StatusHudWidget()),
          ),
          if (state.status == ArViewerStatus.initializing || state.status == ArViewerStatus.downloadingModel)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
