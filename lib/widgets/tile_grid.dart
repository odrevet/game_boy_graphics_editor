import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TileGrid extends SingleChildRenderObjectWidget {
  final List<Color> pixels;

  const TileGrid({Key? key, required this.pixels}) : super(key: key);

  @override
  PixelRenderBox createRenderObject(BuildContext context) {
    return PixelRenderBox(pixels: pixels);
  }
}

class PixelRenderBox extends RenderBox {
  final Paint painter = Paint();
  final int crossAxisCount = 8;
  late double pixelSize;
  final List<Color> pixels;

  PixelRenderBox({required this.pixels});

  @override
  void paint(PaintingContext context, Offset offset) {
    pixels.asMap().forEach((index, pixel) {
      painter.color = pixel;
      context.canvas.drawRect(
          Rect.fromLTWH(
            offset.dx +
                (index % crossAxisCount).floor().toDouble() * pixelSize,
            offset.dy +
                (index / crossAxisCount).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          painter);
    });
  }

  @override
  void performLayout() {
    size = Size(
      constraints.constrainWidth(100),
      constraints.constrainHeight(100),
    );
    pixelSize = size.width / crossAxisCount;
  }
}
