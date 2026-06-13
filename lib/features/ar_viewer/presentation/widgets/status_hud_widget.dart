import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ar_viewer_state.dart';

class StatusHudWidget extends ConsumerWidget {
  const StatusHudWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(arViewerProvider);
    String message = '';

    switch (state.status) {
      case ArViewerStatus.initializing:
        message = 'Iniciando AR...';
        break;
      case ArViewerStatus.downloadingModel:
        message = 'Descargando modelo: ${(state.downloadProgress * 100).toInt()}%';
        break;
      case ArViewerStatus.scanning:
        message = 'Moviendo el teléfono para detectar superficies...';
        break;
      case ArViewerStatus.planeDetected:
        message = 'Superficie detectada — toca para colocar a Cinnamoroll';
        break;
      case ArViewerStatus.characterPlaced:
        message = 'Cinnamoroll colocado ✓';
        break;
      case ArViewerStatus.error:
        message = 'Error: ${state.errorMessage}';
        break;
    }

    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
