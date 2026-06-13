import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ar_viewer_state.dart';
import '../../../../core/constants.dart';

class PlaneGridOverlay extends ConsumerWidget {
  const PlaneGridOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(arViewerProvider);
    
    if (state.status == ArViewerStatus.characterPlaced || 
        state.status == ArViewerStatus.initializing ||
        state.status == ArViewerStatus.downloadingModel ||
        state.status == ArViewerStatus.error) {
      return const SizedBox.shrink();
    }

    final bool isDetected = state.status == ArViewerStatus.planeDetected;

    return AnimatedOpacity(
      opacity: isDetected ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppConstants.horizontalBorderColor,
              width: 2,
            ),
            color: AppConstants.horizontalGridColor.withAlpha(51), // 0.2 opacity approx
          ),
          child: Stack(
            children: [
              for (int i = 1; i < 4; i++)
                Positioned(
                  left: 50.0 * i,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 1, color: AppConstants.horizontalGridColor),
                ),
              for (int i = 1; i < 4; i++)
                Positioned(
                  top: 50.0 * i,
                  left: 0,
                  right: 0,
                  child: Container(height: 1, color: AppConstants.horizontalGridColor),
                ),
              _buildCorner(0, 0),
              _buildCorner(0, 192),
              _buildCorner(192, 0),
              _buildCorner(192, 192),
              const Center(
                child: Text(
                  'Superficie detectada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppConstants.horizontalBorderColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
