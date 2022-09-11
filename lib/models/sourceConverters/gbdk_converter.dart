import 'dart:convert';

import '../graphics/graphics.dart';
import '../graphics/meta_tile.dart';
import 'source_converter.dart';

class GBDKConverter extends SourceConverter {
  static final GBDKConverter _singleton = GBDKConverter._internal();

  factory GBDKConverter() {
    return _singleton;
  }

  GBDKConverter._internal();

  List<String> getRawTile(List<int> tileData) {
    var raw = <String>[];
    const int size = 8;

    var combined = "";
    for (var element in tileData) {
      combined += element.toRadixString(2).padLeft(2, "0");
    }

    for (var index = 0; index < (combined.length ~/ size) * size; index += size * 2) {
      var lo = "";
      var hi = "";
      var combinedSub = combined.substring(index, index + size * 2);

      for (var indexSub = 0; indexSub < 8 * 2; indexSub += 2) {
        lo += combinedSub[indexSub];
        hi += combinedSub[indexSub + 1];
      }

      raw.add(binaryToHex(hi));
      raw.add(binaryToHex(lo));
    }

    return raw;
  }

  List<int> getPattern(int width, int height) {
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

  @override
  String toHeader(Graphics graphics, String name) {
    return """#define ${name}Bank 0
extern unsigned char $name[];""";
  }

  @override
  String toSource(Graphics graphics, String name) {
    List<int> reorderedData = [];
    for (int pixelIndex = 0;
        pixelIndex < graphics.data.length;
        pixelIndex += graphics.height * graphics.width) {
      getPattern(graphics.width, graphics.height).forEach((patternIndex) {
        int nbTilePerRow = (graphics.width ~/ MetaTile.tileSize);
        int pixel = ((patternIndex % nbTilePerRow) * MetaTile.tileSize) + (patternIndex ~/ nbTilePerRow).floor() * MetaTile.nbPixelPerTile * nbTilePerRow;
        for (int col = 0; col < MetaTile.tileSize; col++) {
          int start = pixelIndex + pixel + col * graphics.width;
          int end = start + MetaTile.tileSize;
          var row = graphics.data.sublist(start, end);
          reorderedData = [...reorderedData, ...row];
        }
      });
    }

    return "unsigned char $name[] =\n{${formatOutput(getRawTile(reorderedData))}\n};";
  }

  List<GraphicElement> readGraphicElementsFromSource(source) {
    var arrayElements = <GraphicElement>[];

    RegExp regExp =
        RegExp(r"(?:unsigned\s+char|uint8_t|UINT8)\s+(\w+)\[(?:\d+)?\]\s*=\s*\{(.*?)};");
    for (Match match in regExp.allMatches(source)) {
      arrayElements.add(GraphicElement(name: match.group(1)!, values: match.group(2)!));
    }

    return arrayElements;
  }
  
  List<int>fromSource(values){
    var data = <int>[];

    for (var index = 0; index < values.length; index += 2) {
      var lo = toBinary(values[index]);
      var hi = toBinary(values[index + 1]);

      var combined = "";
      for (var index = 0; index < MetaTile.tileSize; index++) {
        combined += hi[index] + lo[index];
      }

      for (var indexBis = 0; indexBis < MetaTile.tileSize * 2; indexBis += 2) {
        data.add(int.parse(combined[indexBis] + combined[indexBis + 1], radix: 2));
      }
    }
    
    return data;
  }

  String formatSource(String source) {
    LineSplitter ls = const LineSplitter();
    List<String> lines = ls.convert(source);
    return lines.join();
  }
  
  
  List<int> reorderData(List<int> data, int width, int height){
    // if data is too small, resize it to fit the metaTile dimensions
    if(data.length < width * height){
      data.addAll(List.filled(width * height - data.length, 0));
    }

    List<int> reorderedData = List.filled(data.length, 0);
    var pattern = getPattern(width, height);
    int nbTilePerRow = (width ~/ MetaTile.tileSize);
    int nbTilePerMetaTile =(width * height) ~/ MetaTile.nbPixelPerTile;

    for (int tileIndex = 0; tileIndex < data.length ~/ MetaTile.nbPixelPerTile; tileIndex++) {
      int patternIndex = pattern[tileIndex % pattern.length];

      int metaTileIndex = tileIndex ~/ nbTilePerMetaTile;
      int pixel = patternIndex * MetaTile.nbPixelPerTile;
      for (int col = 0; col < MetaTile.tileSize; col++) {
        int start = pixel + col * MetaTile.tileSize + (metaTileIndex * width * height);
        int end = start + MetaTile.tileSize;
        var row = data.sublist(start, end);
        int reorderedPixel = ((tileIndex % nbTilePerRow) * MetaTile.tileSize) +
            (tileIndex ~/ nbTilePerRow).floor() * MetaTile.nbPixelPerTile * nbTilePerRow +
            col * width;
        reorderedData.setRange(reorderedPixel, reorderedPixel + MetaTile.tileSize, row);
      }
    }

    return reorderedData;
  }
}
