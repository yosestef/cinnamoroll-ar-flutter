import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinnamorol_ar/features/ar_viewer/presentation/widgets/status_hud_widget.dart';
import 'package:cinnamorol_ar/features/ar_viewer/presentation/ar_viewer_state.dart';

class MockNotifier extends ArViewerNotifier {
  @override
  ArViewerState build() {
    return ArViewerState(status: ArViewerStatus.scanning);
  }
}

void main() {
  testWidgets('StatusHudWidget shows scanning message', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          arViewerProvider.overrideWith(() => MockNotifier()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: StatusHudWidget(),
          ),
        ),
      ),
    );

    expect(find.text('Moviendo el teléfono para detectar superficies...'), findsOneWidget);
  });
}
