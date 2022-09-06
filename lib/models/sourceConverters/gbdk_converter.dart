import 'dart:convert';

import '../convert.dart';
import '../graphics.dart';
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
    return "unsigned char $name[] =\n{${formatOutput(getRawTile(graphics.data))}\n};";
  }

  List<GraphicElement> fromSource(source) {
    var arrayElements = <GraphicElement>[];

    RegExp regExp =
        RegExp(r"(?:unsigned\s+char|uint8_t|UINT8)\s+(\w+)\[(?:\d+)?\]\s*=\s*\{(.*?)};");
    for (Match match in regExp.allMatches(source)) {
      arrayElements.add(GraphicElement(name: match.group(1)!, values: match.group(2)!));
    }

    return arrayElements;
  }

  String formatSource(String source) {
    LineSplitter ls = const LineSplitter();
    List<String> lines = ls.convert(source);
    return lines.join();
  }
}

