class TileInfo {
  final String? sourceName;
  final int? sourceIndex;
  final int origin;

  TileInfo({this.sourceName, this.sourceIndex, required this.origin});

  TileInfo copyWith({String? sourceName, int? sourceIndex, int? origin}) {
    return TileInfo(
      sourceName: sourceName ?? this.sourceName,
      sourceIndex: sourceIndex ?? this.sourceIndex,
      origin: origin ?? this.origin,
    );
  }
}