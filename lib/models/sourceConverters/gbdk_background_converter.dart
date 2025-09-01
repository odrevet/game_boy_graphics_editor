import 'dart:io';

import 'package:game_boy_graphics_editor/models/graphics/background.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/source_converter.dart';

import '../converter_utils.dart';
import '../graphics/graphics.dart';

class GBDKBackgroundConverter extends SourceConverter {
  static final GBDKBackgroundConverter _singleton =
      GBDKBackgroundConverter._internal();

  factory GBDKBackgroundConverter() {
    return _singleton;
  }

  GBDKBackgroundConverter._internal();

  Background fromGraphics(Graphics graphics) => Background(
    data: graphics.data,
    width: graphics.width ~/ 8,
    height: graphics.height ~/ 8,
  );

  @override
  String toHeader(Graphics graphics, String name) {
    Background background = graphics as Background;

    // Read template file
    String template = File('${Directory.current.path}/lib/models/sourceConverters/templates/background.h.tpl').readAsStringSync();

    // Replace placeholders
    return template
        .replaceAll('{{name}}', name)
        .replaceAll('{{tile_origin}}', background.tileOrigin.toString())
        .replaceAll('{{width}}', graphics.width.toString())
        .replaceAll('{{height}}', graphics.height.toString())
        .replaceAll('{{length}}', graphics.data.length.toString());
  }

  @override
  String toSource(Graphics graphics, String name) {
    // Read template file
    String template = File('${Directory.current.path}/lib/models/sourceConverters/templates/background.c.tpl').readAsStringSync();

    // Format the data array
    String formattedData = formatOutput(
      graphics.data.map((e) => decimalToHex(e, prefix: true)).toList(),
    );

    // Replace placeholders
    return template
        .replaceAll('{{bank}}', '255')
        .replaceAll('{{name}}', name)
        .replaceAll('{{length}}', graphics.data.length.toString())
        .replaceAll('{{data}}', formattedData);
  }
}
