import 'package:game_boy_graphics_editor/models/source_info.dart';

class TileInfo {
  final String? sourceName;
  final int? sourceIndex;
  final int origin;
  final SourceInfo? sourceInfo;

  TileInfo({this.sourceName, this.sourceIndex, required this.origin, this.sourceInfo});

  TileInfo copyWith({String? sourceName, int? sourceIndex, int? origin, SourceInfo? sourceInfo}) {
    return TileInfo(
      sourceName: sourceName ?? this.sourceName,
      sourceIndex: sourceIndex ?? this.sourceIndex,
      origin: origin ?? this.origin,
      sourceInfo: sourceInfo ?? this.sourceInfo,
    );
  }
}