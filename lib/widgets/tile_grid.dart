import 'package:flutter/material.dart';

class TileGrid extends StatefulWidget {
  final List<Color> pixels;

  const TileGrid({Key? key, required this.pixels}) : super(key: key);

  @override
  _TileGridState createState() => _TileGridState();
}

class _TileGridState extends State<TileGrid> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return CustomPaint(
            size: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
            painter:
                PixelPainter(pixels: widget.pixels, constraints: constraints),
          );
        },
      ),
    );
  }
}

class PixelPainter extends CustomPainter {
  final Paint painter = Paint();
  final int crossAxisCount = 8;
  late double pixelSize = 10;
  final List<Color> pixels;
  final BoxConstraints constraints;

  PixelPainter({required this.pixels, required this.constraints});

  @override
  void paint(Canvas canvas, Size size) {
    pixelSize = constraints.maxWidth / 8;
    pixels.asMap().forEach((index, pixel) {
      painter.color = pixel;
      canvas.drawRect(
          Rect.fromLTWH(
            (index % crossAxisCount).floor().toDouble() * pixelSize,
            (index / crossAxisCount).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          painter);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
