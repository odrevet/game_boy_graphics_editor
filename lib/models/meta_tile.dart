import 'dart:core';

class MetaTile {
  List<int> tileData;
  int height;
  int width;

  MetaTile({required this.tileData, this.height = 8, this.width = 8});

  copyWith({List<int>? tileData, int? width, int? height}) => MetaTile(
        tileData: tileData ?? this.tileData,
    width: width ?? this.width,
    height: height ?? this.height,
      );

  int get tileSize => width * width;

  List<int> getTile(int index) {
    return tileData.getRange(tileSize * index, tileSize * index + tileSize).toList();
  }
}
