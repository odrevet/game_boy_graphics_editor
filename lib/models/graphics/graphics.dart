enum SourceFormat {
  file,
  url,
  clipboard,
}

enum DataType {
  sourceCode,
  binary,
}

class SourceInfo {
  final SourceFormat format;
  final DataType dataType;
  final String? path; // URL or file path (null for clipboard)
  final dynamic content; // String for source code, List<int> for binary
  final DateTime importedAt;

  SourceInfo({
    required this.format,
    required this.dataType,
    this.path,
    required this.content,
    DateTime? importedAt,
  }) : importedAt = importedAt ?? DateTime.now();

  SourceInfo copyWith({
    SourceFormat? format,
    DataType? dataType,
    String? path,
    dynamic content,
    DateTime? importedAt,
  }) {
    return SourceInfo(
      format: format ?? this.format,
      dataType: dataType ?? this.dataType,
      path: path ?? this.path,
      content: content ?? this.content,
      importedAt: importedAt ?? this.importedAt,
    );
  }
}

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
}