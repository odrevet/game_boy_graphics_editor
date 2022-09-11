import 'package:flutter/material.dart';

class DotMatrix extends StatelessWidget {
  final List<Color> pixels;
  final bool showGrid;
  final int width;
  final int height;

  const DotMatrix(
      {Key? key,
      required this.pixels,
      required this.width,
      required this.height,
      this.showGrid = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => CustomPaint(
              painter: DotMatrixPainter(
                  pixels: pixels,
                  pixelSize: (constraints.maxWidth / width),
                  showGrid: showGrid,
                  width: width,
                  height: height),
            ));
  }
}

class DotMatrixPainter extends CustomPainter {
  final double pixelSize;
  final List<Color> pixels;
  final bool showGrid;
  final int width;
  final int height;

  DotMatrixPainter(
      {required this.pixels,
      required this.pixelSize,
      required this.width,
      required this.height,
      this.showGrid = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    pixels.asMap().forEach((index, pixel) {
      paint.color = pixel;
      canvas.drawRect(
          Rect.fromLTWH(
            (index % width).floor().toDouble() * pixelSize,
            (index / height).floor().toDouble() * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint);
    });

    if (showGrid) {
      for (int index = 1; index <= width; index++) {
        paint.color = index % 8 == 0 ? Colors.blueAccent : Colors.blueGrey;
        paint.strokeWidth = index % 8 == 0 ? 2.0 : 1.0;
        canvas.drawLine(Offset((index % width).floor().toDouble() * pixelSize, 0),
            Offset((index % width).floor().toDouble() * pixelSize, size.height), paint);
      }

      for (int index = 1; index <= height; index++) {
        paint.color = index % 8 == 0 ? Colors.blueAccent : Colors.blueGrey;
        paint.strokeWidth = index % 8 == 0 ? 2.0 : 1.0;
        canvas.drawLine(Offset(0, (index % height).floor().toDouble() * pixelSize),
            Offset(size.width, (index % height).floor().toDouble() * pixelSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
