import 'utils.dart';

class Tiles {
  var data = List.filled(64, 0, growable: true);
  var size = 8;
  var count = 1;
  var index = 0;
  String name = "data";

  String formatOutput(input) {
    return input.asMap().entries.map((entry) {
      int idx = entry.key;
      String val = entry.value;
      return idx % 8 == 0 ? "\n  $val" : val;
    }).join(", ");
  }

  String toSource() {
    return "unsigned char $name[] =\n{${formatOutput(getRawFromIntensity(data, size))}\n};";
  }
}
