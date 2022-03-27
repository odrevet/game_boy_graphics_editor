import 'package:gbdk_graphic_editor/graphics.dart';
import 'package:gbdk_graphic_editor/tile.dart';

import 'convert.dart';

// The size of a tile is always 8x8 pixel
// width and height refer how many 8x8 tiles are displayed (in pixel)
class MetaTile extends Graphics {
  static const int size = 8;

  List<Tile> tileList = [];

  MetaTile(
      {required String name,
      required List<int> data,
      width = MetaTile.size,
      height = MetaTile.size})
      : super(name: name, data: data, height: height, width: width);

  List<String> getRaw() {
    var raw = <String>[];

    for (Tile tile in tileList) {
      raw += tile.getRaw();
    }

    return raw;
  }

  int pixelPerTile() => size * size;

  List<int> getMetaTileAtIndex(int index) {
    int from = width * height * index;
    int to = from + width * height;
    return data.sublist(from, to);
  }

  List<int> getRow(int indexTile, int indexRow) {
    int from = pixelPerTile() * indexTile;
    return data.sublist(from + size * indexRow, from + size * (indexRow + 1));
  }

  setData(List<String> values) {
    int pixelAt = 0;
    tileList.clear();

    for (var index = 0; index < values.length; index += 2) {
      var lo = toBinary(values[index]);
      var hi = toBinary(values[index + 1]);

      var combined = "";
      for (var index = 0; index < size; index++) {
        combined += hi[index] + lo[index];
      }

      for (var indexBis = 0; indexBis < size * 2; indexBis += 2) {
        String source = combined[indexBis] + combined[indexBis + 1];
        int intensity = int.parse(source, radix: 2);
        int tileIndex = pixelAt ~/ Tile.pixelPerTile;
        int pixelIndex = pixelAt - tileIndex * Tile.pixelPerTile;
        if(pixelIndex == 0){
          tileList.add(Tile());
        }
        tileList[tileIndex].data[pixelIndex] = intensity;
        pixelAt++;
      }
    }
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
    String? values = parseArray(source);
    if (values != null) {
      try {
        setData(values.split(','));
      } catch (e) {
        print(e);
        data = List.filled(64, 0,
            growable:
                true); // TODO do not reset data (change setData to write in a buffer)
        return false;
      }

      return true;
    }

    return false;
  }
}
