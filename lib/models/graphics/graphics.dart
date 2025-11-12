import '../source_info.dart';

class Graphics {
  String name;
  List<int> data;
  int height;
  int width;
  int tileOrigin;
  String? filepath;
  int startOffset;
  int endOffset;
  SourceInfo? sourceInfo;

  Graphics({
    required this.name,
    this.data = const [],
    this.width = 0,
    this.height = 0,
    this.filepath,
    this.tileOrigin = 0,
    this.startOffset = 0,
    this.endOffset = 0,
    this.sourceInfo,
  });

  int get nbPixel => width * height;

  List<int> getTileAtIndex(int index) {
    return data.getRange(nbPixel * index, nbPixel * index + nbPixel).toList();
  }

  Graphics copyWith({
    String? name,
    List<int>? data,
    int? width,
    int? height,
    int? tileOrigin,
    String? filepath,
    int? startOffset,
    int? endOffset,
    SourceInfo? sourceInfo,
  }) {
    return Graphics(
      name: name ?? this.name,
      data: data ?? this.data,
      width: width ?? this.width,
      height: height ?? this.height,
      tileOrigin: tileOrigin ?? this.tileOrigin,
      filepath: filepath ?? this.filepath,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      sourceInfo: sourceInfo ?? this.sourceInfo,
    );
  }
}
