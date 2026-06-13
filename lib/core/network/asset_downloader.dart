import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../constants.dart';
import '../errors/app_exceptions.dart';
import 'package:logger/logger.dart';

class AssetDownloader {
  final Dio _dio;
  final Logger _logger;

  AssetDownloader({Dio? dio, Logger? logger}) 
      : _dio = dio ?? Dio(),
        _logger = logger ?? Logger();

  Future<String> getModelPath(Function(int, int)? onProgress) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${AppConstants.modelFileName}';
      final file = File(filePath);

      if (await file.exists()) {
        _logger.i('Model found in cache: $filePath');
        return filePath;
      }

      _logger.i('Downloading model to: $filePath');
      final url = '${AppConstants.backendBaseUrl}/assets/${AppConstants.modelFileName}';
      
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
      );
      
      _logger.i('Model downloaded successfully');
      return filePath;
    } catch (e) {
      _logger.e('Failed to download model', error: e);
      throw AssetDownloadException('Failed to download model', e);
    }
  }
}
