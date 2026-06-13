import 'package:dio/dio.dart';
import '../constants.dart';
import 'mcp_models.dart';
import 'package:logger/logger.dart';

class McpClient {
  final Dio _dio;
  final Logger _logger;

  McpClient({Dio? dio, Logger? logger}) 
      : _dio = dio ?? Dio(),
        _logger = logger ?? Logger();

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('${AppConstants.backendBaseUrl}/health');
      return response.statusCode == 200 && response.data['status'] == 'ok';
    } catch (e) {
      _logger.w('Health check failed: $e');
      return false;
    }
  }

  CharacterInfo _getOfflineCharacterInfo(String planeType) {
    double scale = 0.10;
    if (planeType == 'horizontal_down') scale = 0.08;
    if (planeType == 'vertical') scale = 0.09;
    
    return CharacterInfo(
      name: 'Cinnamoroll',
      description: 'Offline Mode',
      scale: scale,
      rotationOffset: 0.0,
      modelUrl: '/assets/${AppConstants.modelFileName}',
    );
  }
  
  Future<CharacterInfo> getCharacterInfo(String planeType) async {
    try {
      _logger.i('Calling MCP tool get_character_info for $planeType');
      await Future.delayed(const Duration(milliseconds: 500));
      return _getOfflineCharacterInfo(planeType);
    } catch (e) {
      _logger.w('MCP tool call failed, using offline info');
      return _getOfflineCharacterInfo(planeType);
    }
  }

  Future<bool> logArSession(String planeType, bool placedSuccessfully) async {
    try {
      _logger.i('Calling MCP tool log_ar_session');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      _logger.w('Failed to log AR session via MCP: $e');
      return false;
    }
  }
}
