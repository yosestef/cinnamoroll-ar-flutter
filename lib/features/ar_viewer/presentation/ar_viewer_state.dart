import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ArViewerStatus {
  initializing,
  downloadingModel,
  scanning,
  planeDetected,
  characterPlaced,
  error
}

class ArViewerState {
  final ArViewerStatus status;
  final String? errorMessage;
  final double downloadProgress;
  final bool isOfflineMode;

  ArViewerState({
    this.status = ArViewerStatus.initializing,
    this.errorMessage,
    this.downloadProgress = 0.0,
    this.isOfflineMode = false,
  });

  ArViewerState copyWith({
    ArViewerStatus? status,
    String? errorMessage,
    double? downloadProgress,
    bool? isOfflineMode,
  }) {
    return ArViewerState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}

class ArViewerNotifier extends Notifier<ArViewerState> {
  @override
  ArViewerState build() {
    return ArViewerState();
  }

  void setStatus(ArViewerStatus status) {
    state = state.copyWith(status: status);
  }

  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOfflineMode: isOffline);
  }

  void setError(String message) {
    state = state.copyWith(
      status: ArViewerStatus.error,
      errorMessage: message,
    );
  }

  void updateDownloadProgress(double progress) {
    state = state.copyWith(
      status: ArViewerStatus.downloadingModel,
      downloadProgress: progress,
    );
  }
}

final arViewerProvider = NotifierProvider<ArViewerNotifier, ArViewerState>(() {
  return ArViewerNotifier();
});
