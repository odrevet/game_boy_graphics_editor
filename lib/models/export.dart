import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_boy_graphics_editor/models/graphics/meta_tile.dart';
import 'package:image/image.dart' as img;

import 'graphics/background.dart';

tilesSaveAsPNG(MetaTile metaTile, List<Color> colorSet, String tileName,
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
      pixel.setRgb(color.red, color.green, color.blue);
    }
  }

  final png = img.encodePng(image);
  File("$directory/$tileName.png").writeAsBytesSync(png);
}

backgroundSaveAsPNG(Background background, MetaTile metaTile,
    List<Color> colorSet, String backgroundName, String directory) {
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

      pixel.setRgb(color.red, color.green, color.blue);
    }
  }

  final png = img.encodePng(image);
  File("$directory/$backgroundName.png").writeAsBytesSync(png);
}
