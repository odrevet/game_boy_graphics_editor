import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'graphics/graphics.dart';
import 'graphics/meta_tile.dart';

Uint8List tilesToPNG(Graphics metaTile, List<int> colorSet, int count) {
  final image = img.Image(
    width: metaTile.width * count,
    height: metaTile.height,
  );
  for (int tileIndex = 0; tileIndex < count; tileIndex++) {
    var tile = metaTile.getTileAtIndex(tileIndex);
    for (
      int pixelIndex = 0;
      pixelIndex < metaTile.width * metaTile.height;
      pixelIndex++
    ) {
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

  return img.encodePng(image);
}

Uint8List backgroundToPNG(
  Graphics background,
  MetaTile metaTile,
  List<int> colorSet,
) {
  final image = img.Image(
    width: background.width * metaTile.width,
    height: background.height * metaTile.height,
  );
  for (
    int backgroundIndex = 0;
    backgroundIndex < background.width * background.height;
    backgroundIndex++
  ) {
    var tile = metaTile.getTileAtIndex(background.data[backgroundIndex]);

    for (
      int pixelIndex = 0;
      pixelIndex < metaTile.width * metaTile.height;
      pixelIndex++
    ) {
      //get color in source tile
      var color = colorSet[tile[pixelIndex]];

      // get coordinate in destination image and set pixel
      int x = pixelIndex % metaTile.width + backgroundIndex * metaTile.width;
      int y =
          pixelIndex ~/ metaTile.width +
          (backgroundIndex ~/ background.width) * (metaTile.height - 1);
      var pixel = image.getPixel(x, y);

      int red = (color >> 16) & 0xFF;
      int green = (color >> 8) & 0xFF;
      int blue = color & 0xFF;

      pixel.setRgb(red, green, blue);
    }
  }

  return img.encodePng(image);
}
