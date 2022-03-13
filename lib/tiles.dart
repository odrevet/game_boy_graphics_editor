import 'package:gbdk_graphic_editor/graphics.dart';

import 'convert.dart';

// The size of a tile is always 8x8 pixel
// width and height refer how many 8x8 tiles are displayed (in pixel)
class Tiles extends Graphics {
  static const int size = 8;

  Tiles({required String name, required List<int> data, width = Tiles.size, height = Tiles.size})
      : super(name: name, data: data, height: height, width: width);

  List<String> getRaw() {
    var raw = <String>[];

    var combined = "";
    for (var element in data) {
      combined += element.toRadixString(2).padLeft(2, "0");
    }

    for (var index = 0;
        index < combined.length ~/ size * size;
        index += size * 2) {
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

  List<int> getData(int indexFrom, [int? indexTo]) {
    indexTo ??= 1;
    int from = (size * size) * indexFrom;
    int to = from + (size * size);
    return data.sublist(from, to);
  }

  setData(List<String> values) {
    data = <int>[];

    for (var index = 0; index < values.length; index += 2) {
      var lo = toBinary(values[index]);
      var hi = toBinary(values[index + 1]);

      var combined = "";
      for (var index = 0; index < size; index++) {
        combined += hi[index] + lo[index];
      }

      for (var index = 0; index < size * 2; index += 2) {
        data.add(int.parse(combined[index] + combined[index + 1], radix: 2));
      }
    }
  }

  int count() => data.length ~/ (width * height);

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
  void fromSource(String source) {
    var values = parseArray(source)!;
    setData(values.split(','));
  }
}
