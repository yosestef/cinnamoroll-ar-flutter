class CharacterInfo {
  final String name;
  final String description;
  final double scale;
  final double rotationOffset;
  final String modelUrl;

  CharacterInfo({
    required this.name,
    required this.description,
    required this.scale,
    required this.rotationOffset,
    required this.modelUrl,
  });

  factory CharacterInfo.fromJson(Map<String, dynamic> json) {
    return CharacterInfo(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      scale: (json['scale'] as num?)?.toDouble() ?? 0.1,
      rotationOffset: (json['rotation_offset'] as num?)?.toDouble() ?? 0.0,
      modelUrl: json['model_url'] ?? '',
    );
  }
}
