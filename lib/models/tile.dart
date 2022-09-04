import 'convert.dart';

class Tile {
  static const int size = 8;
  static const int pixelPerTile = 8 * 8;

  List<int> data = List<int>.filled(pixelPerTile, 0, growable: false);

  List<String> getRaw() {
    var raw = <String>[];

    var combined = "";
    for (var element in data) {
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





  void setPixel(int colIndex, int rowIndex, int intensity) =>
      data[colIndex + (rowIndex * size)] = intensity;
}
