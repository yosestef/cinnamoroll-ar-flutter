import 'package:flutter_test/flutter_test.dart';
import 'package:cinnamorol_ar/core/ar/ar_session_service.dart';

void main() {
  group('ArSessionService', () {
    late ArSessionService service;

    setUp(() {
      service = ArSessionService();
    });

    test('initial state has null managers', () {
      expect(service.sessionManager, isNull);
      expect(service.objectManager, isNull);
      expect(service.anchorManager, isNull);
    });

    // Cannot fully test onARViewCreated without mocking ar_flutter_plugin_engine
    // which requires method channels setup.
  });
}
