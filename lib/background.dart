import 'package:gbdk_graphic_editor/graphics.dart';

import 'convert.dart';

class Background extends Graphics {
  int height;
  int width;

  Background({this.height = 0, this.width = 0, name = "", int fill = 0})
      : super(
            name: name,
            data: List<int>.filled(height * width, fill, growable: true));

  @override
  String toSource() {
    return """
    #define ${name}Width $width
    #define ${name}Height $height
    #define ${name}Bank 0
    unsigned char $name[] =\n{${data.map((e) => decimalToHex(e)).join(",")}\n};""";
  }

  @override
  void fromSource(String source) {
    var nameValues = parseArray(source)!;
    name = nameValues[0];
    data = List<int>.from(
        nameValues[1].split(',').map((value) => int.parse(value)).toList());
  }
}
