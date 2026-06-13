import 'package:ar_flutter_plugin_engine/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_engine/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../../core/ar/anchor_manager.dart';
import '../data/character_repository.dart';

final placeCharacterUseCaseProvider = Provider<PlaceCharacterUsecase>((ref) {
  return PlaceCharacterUsecase(
    repository: ref.read(characterRepositoryProvider),
  );
});

class PlaceCharacterUsecase {
  final CharacterRepository _repository;
  
  PlaceCharacterUsecase({required CharacterRepository repository}) 
      : _repository = repository;

  Future<bool> execute({
    required ARHitTestResult hitResult,
    required AnchorManager anchorManager,
    required String localModelPath,
    required String planeType,
  }) async {
    final charInfo = await _repository.getCharacterInfo(planeType);
    
    final anchor = ARPlaneAnchor(transformation: hitResult.worldTransform);
    
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: localModelPath,
      scale: Vector3.all(charInfo.scale),
      position: Vector3(0.0, 0.0, 0.0),
      rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      data: {"smoothed": true}, // For C) setSmoothed(true) requirement if engine supports it via data
    );

    final success = await anchorManager.placeNodeOnAnchor(node, anchor);
    
    // Log the session asynchronously
    _repository.logSession(planeType, success);
    
    return success;
  }
}
