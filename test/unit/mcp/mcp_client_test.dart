import 'package:flutter_test/flutter_test.dart';
import 'package:cinnamorol_ar/core/mcp/mcp_client.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

void main() {
  group('McpClient', () {
    late McpClient client;

    setUp(() {
      client = McpClient(dio: Dio(), logger: Logger(level: Level.off));
    });

    test('getCharacterInfo offline fallback', () async {
      final info = await client.getCharacterInfo('horizontal_down');
      expect(info.scale, 0.08);
      expect(info.name, 'Cinnamoroll');
    });
  });
}
