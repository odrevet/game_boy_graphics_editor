import 'package:gbdk_graphic_editor/graphics.dart';
import 'package:gbdk_graphic_editor/tiles.dart';

import 'convert.dart';

class Background extends Graphics {
  Tiles? tiles;

  Background({height = 0, width = 0, name = "", int fill = 0, this.tiles})
      : super(
            name: name,
            width: width,
            height: height,
            data: List<int>.filled(height * width, fill, growable: true));

  @override
  String toHeader() {
    return """/*
Info: 
  Tile set  : ${tiles?.name ?? ""}    
*/
#define ${name}Width $width
#define ${name}Height $height
#define ${name}Bank 0
extern unsigned char $name[];""";
  }

  @override
  String toSource() {
    return """#define ${name}Width $width
#define ${name}Height $height
#define ${name}Bank 0
unsigned char $name[] = {${data.map((e) => decimalToHex(e)).join(",")}};""";
  }

  @override
  void fromSource(String source) {
    var values = parseArray(source)!;
    data = List<int>.from(
        values.split(',').map((value) => int.parse(value)).toList());

    RegExp regExpWidth = RegExp(r"#define \w+Width (\d+)");
    var matchesWidth = regExpWidth.allMatches(source);
    for (Match match in matchesWidth) {
      width = int.parse(match.group(1)!);
    }

    RegExp regExpHeight = RegExp(r"#define \w+Height (\d+)");
    var matchesHeight = regExpHeight.allMatches(source);
    for (Match match in matchesHeight) {
      height = int.parse(match.group(1)!);
    }
  }
}
