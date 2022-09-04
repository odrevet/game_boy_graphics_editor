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

  int get tileSize => width * height;

  List<int> getTile(int index) {
    return tileData.getRange(tileSize * index, tileSize * index + tileSize).toList();
  }

  int getPixel(int rowIndex, int colIndex, int tileIndex) =>
      tileData[(colIndex * width + rowIndex) + tileSize * tileIndex];

  void setPixel(int rowIndex, int colIndex, int tileIndex, int intensity) =>
      tileData[(colIndex * width + rowIndex) + tileSize * tileIndex] = intensity;

  List<int> getRow(int index) => tileData.sublist(index * width, index * height + width);

  void setRow(int rowIndex, int tileIndex, List<int> row) {
    for (int dotIndex = 0; dotIndex < width; dotIndex++) {
      setPixel(dotIndex, rowIndex, 0, row[dotIndex]);
    }
  }
}
