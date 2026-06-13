class AppException implements Exception {
  final String message;
  final dynamic cause;

  AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message ${cause != null ? '(Cause: $cause)' : ''}';
}

class NetworkException extends AppException {
  NetworkException(super.message, [super.cause]);
}

class ARCoreException extends AppException {
  ARCoreException(super.message, [super.cause]);
}

class AssetDownloadException extends AppException {
  AssetDownloadException(super.message, [super.cause]);
}
