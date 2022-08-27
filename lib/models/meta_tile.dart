import 'dart:core';

import 'package:game_boy_graphics_editor/models/graphics.dart';
import 'package:game_boy_graphics_editor/models/tile.dart';

import 'convert.dart';

// width and height refer how many 8x8 tiles are displayed (in pixel)
class MetaTile extends Graphics {
  final List<Tile> tileList;

  MetaTile({String name = 'tiles', width = Tile.size, height = Tile.size, required this.tileList})
      : super(name: name, height: height, width: width);

  MetaTile copyWith({List<Tile>? tileList, String? name, int? width, int? height}) {
    var newTileList = <Tile>[];
    if (tileList == null) {
      newTileList = <Tile>[];
      for (var tile in this.tileList) {
        var newTile = Tile();
        newTile.data = [...tile.data];
        newTileList.add(newTile);
      }
    }

    return MetaTile(
        tileList: tileList ?? newTileList,
        name: name ?? this.name,
        width: width ?? this.width,
        height: height ?? this.height);
  }

  List<String> getRaw() {
    var raw = <String>[];

    for (Tile tile in tileList) {
      raw += tile.getRaw();
    }

    return raw;
  }

  List<int> getPattern() {
    var pattern = <int>[];

    if (width == 8 && height == 8) {
      pattern = <int>[0];
    } else if (width == 8 && height == 16) {
      pattern = <int>[0, 1];
    } else if (width == 16 && height == 16) {
      pattern = <int>[0, 2, 1, 3];
    } else if (width == 32 && height == 32) {
      pattern = <int>[0, 2, 8, 10, 1, 3, 9, 11, 4, 6, 12, 14, 5, 7, 13, 15];
    } else {
      throw ('Unknown meta tile size');
    }

    return pattern;
  }

  int nbTilePerMetaTile() => (width * height) ~/ Tile.pixelPerTile;

  int nbTilePerRow() => width ~/ Tile.size;

  int nbTilePerCol() => height ~/ Tile.size;

  List<int> getRow(int metaTileIndex, int rowIndex) {
    var row = <int>[];
    for (int i = 0; i < width ~/ Tile.size; i++) {
      int tileIndex = metaTileIndex * nbTilePerMetaTile() +
          getPattern()[i + (rowIndex ~/ Tile.size) * nbTilePerRow()];
      row += tileList[tileIndex].getRow(rowIndex % Tile.size);
    }
    return row;
  }

  void setRow(int metaTileIndex, int rowIndex, List<int> row) {
    int dotOffset = 0;
    for (int i = 0; i < width ~/ Tile.size; i++) {
      int tileIndex = metaTileIndex * nbTilePerMetaTile() +
          getPattern()[i + (rowIndex ~/ Tile.size) * nbTilePerRow()];
      tileList[tileIndex]
          .setRow(rowIndex % Tile.size, row.sublist(dotOffset, dotOffset + Tile.size));
      dotOffset += Tile.size;
    }
  }

  setData(List<String> values) {
    int pixelAt = 0;
    tileList.clear();

    for (var index = 0; index < values.length; index += 2) {
      var lo = toBinary(values[index]);
      var hi = toBinary(values[index + 1]);

      var combined = "";
      for (var index = 0; index < Tile.size; index++) {
        combined += hi[index] + lo[index];
      }

      for (var indexBis = 0; indexBis < Tile.size * 2; indexBis += 2) {
        String source = combined[indexBis] + combined[indexBis + 1];
        int intensity = int.parse(source, radix: 2);
        int tileIndex = pixelAt ~/ Tile.pixelPerTile;
        int pixelIndex = pixelAt - tileIndex * Tile.pixelPerTile;
        if (pixelIndex == 0) {
          tileList.add(Tile());
        }
        tileList[tileIndex].data[pixelIndex] = intensity;
        pixelAt++;
      }
    }
  }

  List getTileIndex(int rowIndex, int colIndex, int selectedMetaTileIndex) {
    int tileIndex = (rowIndex ~/ Tile.size) + (colIndex ~/ Tile.size) * nbTilePerRow();
    int metaTileIndex = getPattern()[tileIndex] + selectedMetaTileIndex * nbTilePerMetaTile();
    int pixelIndex = ((colIndex % Tile.size) * Tile.size) + (rowIndex % Tile.size);

    return [metaTileIndex, pixelIndex];
  }

  int getPixel(int rowIndex, int colIndex, int selectedMetaTileIndex) {
    var index = getTileIndex(rowIndex, colIndex, selectedMetaTileIndex);
    int indexTile = index[0];
    int indexPixel = index[1];
    return tileList[indexTile].data[indexPixel];
  }

  setPixel(int rowIndex, int colIndex, int selectedMetaTileIndex, int intensity) {
    var index = getTileIndex(rowIndex, colIndex, selectedMetaTileIndex);
    int indexTile = index[0];
    int indexPixel = index[1];
    tileList[indexTile].data[indexPixel] = intensity;
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

  setTiles(int selectedMetaTileIndex, int intensity) {
    tileList[0].data.fillRange(0, 64, intensity);
  }

  @override
  String toHeader() {
    return """#define ${name}Bank 0
extern unsigned char $name[];""";
  }

  @override
  String toSource() {
    return "unsigned char $name[] =\n{${formatOutput(getRaw())}\n};";
  }

  @override
  bool fromSource(String source) {
    return true;
  }
}
