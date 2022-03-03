import 'package:gbdk_graphic_editor/graphics.dart';

import 'convert.dart';

class Tiles extends Graphics {
  var size = 8;
  var count = 1;

  Tiles({required String name, required List<int> data})
      : super(name: name, data: data);

  String formatOutput(input) {
    return input.asMap().entries.map((entry) {
      int idx = entry.key;
      String val = entry.value;
      return idx % 8 == 0 ? "\n  $val" : val;
    }).join(", ");
  }

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

      for (var indexSub = 0; indexSub < size * 2; indexSub += 2) {
        lo += combinedSub[indexSub];
        hi += combinedSub[indexSub + 1];
      }

      raw.add(binaryToHex(hi));
      raw.add(binaryToHex(lo));
    }

    return raw;
  }

  List<int> getData(int index) {
    return data.sublist((size * size) * index, (size * size) * (index + 1));
  }

  setData(List<String> values) {
    data = <int>[];

    for (var index = 0; index < values.length; index += 2) {
      var lo = toBinary(values[index], size);
      var hi = toBinary(values[index + 1], size);

      var combined = "";
      for (var index = 0; index < size; index++) {
        combined += hi[index] + lo[index];
      }

      for (var index = 0; index < size * 2; index += 2) {
        data.add(int.parse(combined[index] + combined[index + 1], radix: 2));
      }
    }
  }

  @override
  String toSource() {
    return "unsigned char $name[] =\n{${formatOutput(getRaw())}\n};";
  }

  @override
  void fromSource(String source) {
    var values = parseArray(source)!;
    setData(values.split(','));
    count = data.length ~/ (size * size);
  }
}
