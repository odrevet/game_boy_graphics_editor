import 'dart:core';

class MetaTile {
  List<int> tileData;
  int height;
  int width;

  MetaTile({required this.tileData, this.height = 8, this.width = 8});

  copyWith({List<int>? tileData, int? width, int? height}) => MetaTile(
        tileData: tileData ?? [...this.tileData],
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

  List<int> getRow(int tileIndex, int rowIndex) => tileData.sublist(
      tileIndex * tileSize + rowIndex * width, tileIndex * tileSize + rowIndex * height + width);

  void setRow(int tileIndex, int rowIndex, List<int> row) {
    for (int dotIndex = 0; dotIndex < width; dotIndex++) {
      setPixel(dotIndex, rowIndex, tileIndex, row[dotIndex]);
    }
  }

  flood(int metaTileIndex, int intensity, int rowIndex, int colIndex, int targetColor) {
    if (getPixel(rowIndex, colIndex, metaTileIndex) == targetColor) {
      setPixel(rowIndex, colIndex, metaTileIndex, intensity);
      if (inbound(rowIndex, colIndex - 1)) {
        flood(metaTileIndex, intensity, rowIndex, colIndex - 1, targetColor);
      }
      if (inbound(rowIndex, colIndex + 1)) {
        flood(metaTileIndex, intensity, rowIndex, colIndex + 1, targetColor);
      }
      if (inbound(rowIndex - 1, colIndex)) {
        flood(metaTileIndex, intensity, rowIndex - 1, colIndex, targetColor);
      }
      if (inbound(rowIndex + 1, colIndex)) {
        flood(metaTileIndex, intensity, rowIndex + 1, colIndex, targetColor);
      }
    }
  }

  inbound(int rowIndex, int colIndex) =>
      rowIndex >= 0 && rowIndex < height && colIndex >= 0 && colIndex < width;
}
