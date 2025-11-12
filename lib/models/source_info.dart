enum SourceFormat { file, url, clipboard }

enum DataType { sourceCode, binary }

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
