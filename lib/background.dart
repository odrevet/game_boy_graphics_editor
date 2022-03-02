import 'convert.dart';

class Background {
  String name;
  int height;
  int width;
  List<int> data = [];

  Background({this.height = 0, this.width = 0, this.name = "", int fill = 0}) {
    data = List.filled(height * width, fill, growable: true);
  }

  String toSource() {
    return """
    #define ${name}Width $width
    #define ${name}Height $height
    #define ${name}Bank 0
    unsigned char $name[] =\n{${data.map((e) => decimalToHex(e)).join(",")}\n};""";
  }
}
