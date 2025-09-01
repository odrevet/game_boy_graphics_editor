import 'dart:io';

import '../converter_utils.dart';
import '../graphics/graphics.dart';
import '../graphics/meta_tile.dart';
import 'source_converter.dart';

class GBDKTileConverter extends SourceConverter {
  static final GBDKTileConverter _singleton = GBDKTileConverter._internal();

  factory GBDKTileConverter() {
    return _singleton;
  }

  GBDKTileConverter._internal();

  List<int> getRawTileInt(List<int> tileData) {
    var raw = <int>[];
    const int size = 8;

    var combined = "";
    for (var element in tileData) {
      combined += element.toRadixString(2).padLeft(2, "0");
    }

    for (
      int index = 0;
      index < (combined.length ~/ size) * size;
      index += size * 2
    ) {
      String lo = "";
      String hi = "";
      String combinedSub = combined.substring(index, index + size * 2);

      for (var indexSub = 0; indexSub < 8 * 2; indexSub += 2) {
        lo += combinedSub[indexSub];
        hi += combinedSub[indexSub + 1];
      }

      raw.add(binaryToDec(hi));
      raw.add(binaryToDec(lo));
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

  String toHeader(Graphics graphics, String name) {
    // Read template file
    String template = File('${Directory.current.path}/lib/models/sourceConverters/templates/tile.h.tpl').readAsStringSync();

    // Replace placeholders
    return template
        .replaceAll('{{NAME}}', name.toUpperCase())
        .replaceAll('{{name}}', name)
        .replaceAll('{{tile_origin}}', graphics.tileOrigin.toString())
        .replaceAll('{{length}}', graphics.data.length.toString())
        .replaceAll('{{width}}', graphics.width.toString())
        .replaceAll('{{height}}', graphics.height.toString());
  }

  @override
  String toSource(Graphics graphics, String name) {
    // Read template file
    String template = File('${Directory.current.path}/lib/models/sourceConverters/templates/tile.c.tpl').readAsStringSync();

    // Format the data array
    String formattedData = formatOutput(
        graphics.data.map((e) => decimalToHex(e, prefix: true)).toList()
    );

    // Determine bank
    int bank = 255;

    return template
        .replaceAll('{{bank}}', bank.toString())
        .replaceAll('{{name}}', name)
        .replaceAll('{{length}}', graphics.data.length.toString())
        .replaceAll('{{data}}', formattedData);
  }

  List<int> reorderFromSourceToCanvas(List<int> data, int width, int height) {
    // if data is too small, resize it to fit the metaTile dimensions
    if (data.length < width * height) {
      data.addAll(List.filled(width * height - data.length, 0));
    }

    List<int> reorderedData = List.filled(data.length, 0);
    var pattern = getPattern(width, height);
    int nbTilePerRow = (width ~/ MetaTile.tileSize);
    int nbTilePerMetaTile = (width * height) ~/ MetaTile.nbPixelPerTile;

    for (
      int tileIndex = 0;
      tileIndex < data.length ~/ MetaTile.nbPixelPerTile;
      tileIndex++
    ) {
      int patternIndex = pattern[tileIndex % pattern.length];
      int metaTileIndex = tileIndex ~/ nbTilePerMetaTile;
      int pixel = patternIndex * MetaTile.nbPixelPerTile;
      for (int col = 0; col < MetaTile.tileSize; col++) {
        int start =
            pixel + col * MetaTile.tileSize + (metaTileIndex * width * height);
        int end = start + MetaTile.tileSize;
        var row = data.sublist(start, end);
        int reorderedPixel =
            ((tileIndex % nbTilePerRow) * MetaTile.tileSize) +
            (tileIndex ~/ nbTilePerRow).floor() *
                MetaTile.nbPixelPerTile *
                nbTilePerRow +
            col * width;
        reorderedData.setRange(
          reorderedPixel,
          reorderedPixel + MetaTile.tileSize,
          row,
        );
      }
    }

    return reorderedData;
  }

  List<int> reorderFromCanvasToSource(Graphics graphics) {
    List<int> reorderedData = List.filled(
      graphics.data.length,
      0,
      growable: true,
    );
    var pattern = getPattern(graphics.width, graphics.height);
    final int nbTilePerRow = (graphics.width ~/ MetaTile.tileSize);
    for (
      int pixelIndex = 0;
      pixelIndex < graphics.data.length;
      pixelIndex += MetaTile.tileSize
    ) {
      final int rowIndex =
          pixelIndex ~/ (nbTilePerRow * MetaTile.nbPixelPerTile);
      final int colIndex = (pixelIndex ~/ MetaTile.tileSize) % nbTilePerRow;
      final int tileIndex = colIndex + rowIndex * nbTilePerRow;
      final int patternIndex = pattern[tileIndex % pattern.length];
      final tileRowIndex = (pixelIndex ~/ graphics.width) % MetaTile.tileSize;
      final Iterable<int> rowData = graphics.data.sublist(
        pixelIndex,
        pixelIndex + MetaTile.tileSize,
      );
      final metaTileIndex = pixelIndex ~/ (graphics.width * graphics.height);
      final int start =
          (patternIndex * MetaTile.nbPixelPerTile) +
          (tileRowIndex * MetaTile.tileSize) +
          (metaTileIndex * graphics.width * graphics.height);
      final int end = start + MetaTile.tileSize;
      reorderedData.setRange(start, end, rowData);
    }
    return reorderedData;
  }

  List<int> toSourceData(Graphics graphics) =>
      getRawTileInt(reorderFromCanvasToSource(graphics));

  String toBin(Graphics graphics) =>
      toSourceData(graphics).map((e) => decimalToHex(e, prefix: false)).join();

  List<int> combine(List<int> values) {
    var data = <int>[];

    for (var index = 0; index < values.length; index += 2) {
      var lo = decToBinary(values[index]);
      var hi = decToBinary(values[index + 1]);

      var combined = "";
      for (var index = 0; index < MetaTile.tileSize; index++) {
        combined += hi[index] + lo[index];
      }

      for (var indexBis = 0; indexBis < MetaTile.tileSize * 2; indexBis += 2) {
        data.add(
          int.parse(combined[indexBis] + combined[indexBis + 1], radix: 2),
        );
      }
    }

    return data;
  }
}
