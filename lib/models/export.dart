import 'dart:io';

import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:game_boy_graphics_editor/models/sourceConverters/source_converter.dart';
import 'package:image/image.dart' as img;

import 'graphics/background.dart';
import 'graphics/graphics.dart';

void tilesSaveToPNG(MetaTile metaTile, List<int> colorSet, String tileName,
    int count, String directory) {
  final image =
      img.Image(width: metaTile.width * count, height: metaTile.height);
  for (int tileIndex = 0; tileIndex < count; tileIndex++) {
    var tile = metaTile.getTileAtIndex(tileIndex);
    for (int pixelIndex = 0;
        pixelIndex < metaTile.width * metaTile.height;
        pixelIndex++) {
      //get color in source tile
      var color = colorSet[tile[pixelIndex]];

      // get coordinate in destination image and set pixel
      int x = pixelIndex % metaTile.width + tileIndex * metaTile.width;
      int y = pixelIndex ~/ metaTile.width;
      var pixel = image.getPixel(x, y);

      int red = (color >> 16) & 0xFF;
      int green = (color >> 8) & 0xFF;
      int blue = color & 0xFF;

      pixel.setRgb(red, green, blue);
    }
  }

  final png = img.encodePng(image);
  File("$directory/$tileName.png").writeAsBytesSync(png);
}

void saveBin(List<int> bytes, String directory, String name) {
  File("$directory/$name.bin").writeAsBytesSync(bytes);
}

void backgroundSaveToPNG(Background background, MetaTile metaTile,
    List<int> colorSet, String backgroundName, String directory) {
  final image = img.Image(
      width: background.width * metaTile.width,
      height: background.height * metaTile.height);
  for (int backgroundIndex = 0;
      backgroundIndex < background.width * background.height;
      backgroundIndex++) {
    var tile = metaTile.getTileAtIndex(background.data[backgroundIndex]);

    for (int pixelIndex = 0;
        pixelIndex < metaTile.width * metaTile.height;
        pixelIndex++) {
      //get color in source tile
      var color = colorSet[tile[pixelIndex]];

      // get coordinate in destination image and set pixel
      int x = pixelIndex % metaTile.width + backgroundIndex * metaTile.width;
      int y = pixelIndex ~/ metaTile.width +
          (backgroundIndex ~/ background.width) * (metaTile.height - 1);
      var pixel = image.getPixel(x, y);

      int red = (color >> 16) & 0xFF;
      int green = (color >> 8) & 0xFF;
      int blue = color & 0xFF;

      pixel.setRgb(red, green, blue);
    }
  }

  final png = img.encodePng(image);
  File("$directory/$backgroundName.png").writeAsBytesSync(png);
}

void saveToSource(String directory, String name,
    SourceConverter sourceConverter, Graphics graphics) {
  File("$directory/$name.h")
      .writeAsString(sourceConverter.toHeader(graphics, name));
  File("$directory/$name.c")
      .writeAsString(sourceConverter.toSource(graphics, name));
}
