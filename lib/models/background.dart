import 'package:game_boy_graphics_editor/models/graphics.dart';

import 'convert.dart';
import 'meta_tile.dart';

class Background extends Graphics {
  MetaTile? metaTile;
  List<int> data = [];

  Background({height = 0, width = 0, name = "", int fill = 0, this.metaTile})
      : super(name: name, width: width, height: height) {
    data = List<int>.filled(height * width, fill, growable: true);
  }

  @override
  String toHeader() {
    return """/*
Info: 
  Tile set  : ${metaTile?.name ?? ""}    
*/
#define ${name}Width $width
#define ${name}Height $height
#define ${name}Bank 0
extern unsigned char $name[];""";
  }

  @override
  String toSource() {
    var arrayData = data.map((e) => decimalToHex(e)).toList();
    return """#define ${name}Width $width
#define ${name}Height $height
#define ${name}Bank 0
unsigned char $name[] = {${formatOutput(arrayData)}};""";
  }

  @override
  bool fromSource(String source) {
    var graphicsElement = fromGBDKSource(source)[0];

    name = graphicsElement.name;

    data =
        List<int>.from(graphicsElement.values.split(',').map((value) => int.parse(value)).toList());

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

    return true; //TODO
  }

  void insertCol(int at, int fill) {
    width += 1;
    for (int index = at; index < data.length; index += width) {
      data.insert(index, fill);
    }
  }

  void deleteCol(int at) {
    width -= 1;
    for (int index = at; index < data.length; index += width) {
      data.removeAt(index);
    }
  }

  void insertRow(int at, int fill) {
    height += 1;
    for (int index = 0; index < width; index += 1) {
      data.insert(at * width, fill);
    }
  }

  void deleteRow(int at) {
    height -= 1;
    for (int index = 0; index < width; index += 1) {
      data.removeAt(at * width);
    }
  }
}
