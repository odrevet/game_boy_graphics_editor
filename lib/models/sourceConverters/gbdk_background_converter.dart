import 'package:game_boy_graphics_editor/models/sourceConverters/source_converter.dart';
import '../graphics/graphics.dart';

class GBDKBackgroundConverter extends SourceConverter {
  static final GBDKBackgroundConverter _singleton = GBDKBackgroundConverter._internal();

  factory GBDKBackgroundConverter() {
    return _singleton;
  }

  GBDKBackgroundConverter._internal();

  @override
  String toHeader(Graphics graphics, String name) => """/*
Info: 
  Tile set  : $name    
*/
#define ${name}Width ${graphics.width}
#define ${name}Height ${graphics.height}
#define ${name}Bank 0
extern unsigned char $name[];""";

  @override
  String toSource(Graphics graphics, String name) => """#define ${name}Width ${graphics.width}
#define ${name}Height ${graphics.height}
#define ${name}Bank 0
unsigned char $name[] = {${formatOutput(graphics.data.map((e) => decimalToHex(e)).toList())}};""";
}
