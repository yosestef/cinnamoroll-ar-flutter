import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mcp/mcp_client.dart';
import '../../../core/mcp/mcp_models.dart';
import '../../../core/network/asset_downloader.dart';

final mcpClientProvider = Provider<McpClient>((ref) => McpClient());
final assetDownloaderProvider = Provider<AssetDownloader>((ref) => AssetDownloader());

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(
    mcpClient: ref.read(mcpClientProvider),
    assetDownloader: ref.read(assetDownloaderProvider),
  );
});

class CharacterRepository {
  final McpClient _mcpClient;
  final AssetDownloader _assetDownloader;

  CharacterRepository({
    required McpClient mcpClient,
    required AssetDownloader assetDownloader,
  })  : _mcpClient = mcpClient,
        _assetDownloader = assetDownloader;

  Future<CharacterInfo> getCharacterInfo(String planeType) async {
    return _mcpClient.getCharacterInfo(planeType);
  }

  Future<String> getModelPath({Function(int, int)? onProgress}) async {
    return _assetDownloader.getModelPath(onProgress);
  }

  Future<bool> logSession(String planeType, bool placedSuccessfully) async {
    return _mcpClient.logArSession(planeType, placedSuccessfully);
  }
}
