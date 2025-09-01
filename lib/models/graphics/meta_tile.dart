import 'dart:core';

import 'package:game_boy_graphics_editor/models/graphics/graphics.dart';

class MetaTile extends Graphics {
  MetaTile({
    String? name,
    List<int>? data,
    required super.height,
    required super.width,
    metaTileWidth = 8,
    metaTileHeight = 8,
  }) : super(
    name: name ?? "",
    data: data ?? List.filled(width * height, 0, growable: true),
  ) {
    calcMaxTileIndex();
  }

  copyWith({List<int>? data, int? width, int? height}) => MetaTile(
    data: data ?? [...this.data],
    width: width ?? this.width,
    height: height ?? this.height,
  );

  static int tileSize = 8;
  static int nbPixelPerTile = tileSize * tileSize;
  int maxTileIndex = 0;

  void calcMaxTileIndex() => maxTileIndex = data.length ~/ (height * width);

  int get nbTilePerRow => (width ~/ tileSize);

  int get nbPixel => width * height;

  List<int> getTileAtIndex(int index) {
    return data.getRange(nbPixel * index, nbPixel * index + nbPixel).toList();
  }

  int getPixel(int rowIndex, int colIndex, int tileIndex) =>
      data[(colIndex * width + rowIndex) + nbPixel * tileIndex];

  void setPixel(int rowIndex, int colIndex, int tileIndex, int intensity) =>
      data[(colIndex * width + rowIndex) + nbPixel * tileIndex] = intensity;

  List<int> getRow(int tileIndex, int rowIndex) => data.sublist(
    tileIndex * nbPixel + rowIndex * width,
    tileIndex * nbPixel + rowIndex * height + width,
  );

  void setRow(int tileIndex, int rowIndex, List<int> row) {
    for (int dotIndex = 0; dotIndex < width; dotIndex++) {
      setPixel(dotIndex, rowIndex, tileIndex, row[dotIndex]);
    }
  }

  fill(
    int metaTileIndex,
    int intensity,
    int rowIndex,
    int colIndex,
    int targetColor,
  ) {
    if (getPixel(rowIndex, colIndex, metaTileIndex) == targetColor) {
      setPixel(rowIndex, colIndex, metaTileIndex, intensity);
      if (inbound(rowIndex, colIndex - 1)) {
        fill(metaTileIndex, intensity, rowIndex, colIndex - 1, targetColor);
      }
      if (inbound(rowIndex, colIndex + 1)) {
        fill(metaTileIndex, intensity, rowIndex, colIndex + 1, targetColor);
      }
      if (inbound(rowIndex - 1, colIndex)) {
        fill(metaTileIndex, intensity, rowIndex - 1, colIndex, targetColor);
      }
      if (inbound(rowIndex + 1, colIndex)) {
        fill(metaTileIndex, intensity, rowIndex + 1, colIndex, targetColor);
      }
    }
  }

  inbound(int rowIndex, int colIndex) =>
      rowIndex >= 0 && rowIndex < height && colIndex >= 0 && colIndex < width;

  void line(int metaTileIndex, int intensity, int xFrom, int yFrom, xTo, yTo) {
    int dx = (xTo - xFrom).abs(), sx = xFrom < xTo ? 1 : -1;
    int dy = (yTo - yFrom).abs(), sy = yFrom < yTo ? 1 : -1;
    double err = ((dx > dy ? dx : -dy) / 2);
    double e2;

    for (;;) {
      setPixel(yFrom, xFrom, metaTileIndex, intensity);
      if (xFrom == xTo && yFrom == yTo) break;
      e2 = err;
      if (e2 > -dx) {
        err -= dy;
        xFrom += sx;
      }
      if (e2 < dy) {
        err += dx;
        yFrom += sy;
      }
    }
  }

  void rectangle(
    int metaTileIndex,
    int intensity,
    int xFrom,
    int yFrom,
    int xTo,
    int yTo,
  ) {
    int startX = xFrom < xTo ? xFrom : xTo;
    int endX = xFrom < xTo ? xTo : xFrom;
    int startY = yFrom < yTo ? yFrom : yTo;
    int endY = yFrom < yTo ? yTo : yFrom;

    for (int y = startY; y <= endY; y++) {
      for (int x = startX; x <= endX; x++) {
        setPixel(y, x, metaTileIndex, intensity);
      }
    }
  }
}
